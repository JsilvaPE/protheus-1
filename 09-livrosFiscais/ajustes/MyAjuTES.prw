#include 'rwmake.ch'
#include 'xmlxfun.ch'
#define CRLF chr(13)+chr(10)
#define TAGBR '<br/>'
#define ENTRADA 1
#define SAIDA   2
#define CONDICAO 1
#define TES      2
///////////////////////////////////////////////////////////////////////////////
User Function MyAjuTES()
///////////////////////////////////////////////////////////////////////////////
// Data : 22/01/2014
// User : Thieres Tembra
// Desc : Função para definir TES, Situação Tributária e Classificação Fiscal
//        para as NF de Entrada, Saída e Cupons Fiscais (SD1/SD2)
///////////////////////////////////////////////////////////////////////////////
Local oDlg
Local lOk := .F.  

Private _nRadio := 1
Private _aTipo := {'Entrada', 'Saída', 'Entrada e Saída'}
Private _dInicio := Date()
Private _dFim    := Date()

If !(cEmpAnt $ '03;04;05;10;99')
	Alert('Atenção esta rotina deve ser executada somente nos postos!')
	Return Nil
EndIf

@ 200,1 To 380,380 Dialog oDlg Title OemToAnsi('Ajusta TES')
@ 010,010 Say 'Período:' Size 50,10
@ 010,040 Get _dInicio Size 50,10
@ 010,100 Get _dFim Size 50,10
@ 030,040 Radio _aTipo Var _nRadio       
@ 070,128 BMPButton Type 01 Action (lOk:=.T.,Close(oDlg))
@ 070,158 BMPButton Type 02 Action (lOk:=.F.,Close(oDlg))

Activate Dialog oDlg Centered

If !lOk
	Return Nil
EndIf

If _nRadio == 3
	Processa({||AjuTES(ENTRADA)},'Ajusta TES (' + _aTipo[_nRadio] + ') - Aguarde','Localizando registros..')
	Processa({||AjuTES(SAIDA)},'Ajusta TES (' + _aTipo[_nRadio] + ') - Aguarde','Localizando registros..')
Else
	Processa({||AjuTES(_nRadio)},'Ajusta TES (' + _aTipo[_nRadio] + ') - Aguarde','Localizando registros..')
EndIf

Return Nil

/* ----------------------- */

Static Function AjuTES(nOpc)

Local cQry
Local nCount   := 0
Local nTotal   := 0
Local cTES     := '001'
Local cSAX     := ''
Local cTab     := ''
Local cCpo     := ''
Local cCliFor  := ''
Local cTexto   := ''
Local cClasFis := ''
Local cSitTrib := ''
Local nTipoDef := 0
Local aConfig  := {}
Local nI, nTam, nAliq
Local cError   := ''
Local cWarning := ''
Local cNode    := ''
Local cEntSai  := ''
Local cCpoItem := ''
Local cCpoCond := ''
Local cCpoTES  := ''
Local cAux     := ''
Local aAux := {}

Local bError
Local nError := 0

Private _cError := ''
Private _oMyXML

/*
 * Exemplo do arquivo XML:
 * Na tag <condicao> pode ser utilizado qualquer expresão ADVPL, bem como
 * pode ser feito referência as seguintes tabelas (sempre com o alias):
 *   Se dentro da tag <entrada>: SB1, SA2, SD1
 *   Se dentro da tag <saida>  : SB1, SA1, SD2
 *
 * <MyAjuTES>
 *     <entrada>
 *         <item>
 *             <condicao><![CDATA[ SD1->D1_CF == '1102' .and. SB1->B1_TIPO == AllTrim('ME') ]]></condicao>
 *             <tes>012</tes>
 *         </item>
 *         <item>
 *             <condicao><![CDATA[ SD1->D1_CF == '2102' .or. SA2->A2_EST <> 'PA' ]]></condicao>
 *             <tes>005</tes>
 *         </item>
 *         <item>
 *             <condicao><![CDATA[ SD1->D1_CF == '1102' ]]></condicao>
 *             <tes>003</tes>
 *         </item>
 *     </entrada>
 *     <saida>
 *         <item>
 *             <condicao><![CDATA[ SD2->D2_CF == '6405' .and. SA1->A1_EST <> 'PA' ]]></condicao>
 *             <tes>505</tes>
 *         </item>
 *         <item>
 *             <condicao><![CDATA[ SD2->D2_CF == '5656' ]]></condicao>
 *             <tes>501</tes>
 *         </item>
 *     </saida>
 * </MyAjuTES>
 */
//carregando e validando layout do arquivo XML
_oMyXML := XmlParserFile('\MyAjuTES.xml', '_', @cError, @cWarning)

If cError <> ''
	Alert('<b>Erro MyAjuTES.xml</b>' + TAGBR + cError)
	Return Nil
EndIf

If cWarning <> ''
	MsgAlert('<b>Aviso MyAjuTES.xml</b>' + TAGBR + cWarning)
	If !MsgYesNo('Deseja continuar?')
		Return Nil
	EndIf
EndIf

If Type('_oMyXML:_MyAjuTES:_entrada:_item') == 'U' .or. Type('_oMyXML:_MyAjuTES:_saida:_item') == 'U'
	Alert('<b>Erro MyAjuTES.xml</b>' + TAGBR + 'O arquivo XML está em um formato inválido.')
	Return Nil
EndIf

If nOpc == ENTRADA
	cQry := " SELECT R_E_C_N_O_ NRECNO"
	cQry += " FROM " + RetSqlName('SD1')
	cQry += " WHERE D_E_L_E_T_ <> '*'"
	cQry += "   AND D1_FILIAL   = '" + xFilial('SD1') + "'"
	cQry += "   AND D1_DTDIGIT >= '" + DTOS(_dInicio) + "'"
	cQry += "   AND D1_DTDIGIT <= '" + DTOS(_dFim) + "'"
	cTab    := 'SD1'
	cCpo    := 'D1'
	cSAX    := 'SA2'
	cCliFor := 'SD1->(D1_FORNECE+D1_LOJA)'
	cNode   := '_entrada'
	cEntSai := 'entrada'
ElseIf nOpc == SAIDA
	cQry := " SELECT R_E_C_N_O_ NRECNO"
	cQry += " FROM " + RetSqlName('SD2')
	cQry += " WHERE D_E_L_E_T_ <> '*'"
	cQry += "   AND D2_FILIAL   = '" + xFilial('SD2') + "'"
	cQry += "   AND D2_EMISSAO >= '" + DTOS(_dInicio) + "'"
	cQry += "   AND D2_EMISSAO <= '" + DTOS(_dFim) + "'"
	cTab    := 'SD2'
	cCpo    := 'D2'
	cSAX    := 'SA1'
	cCliFor := 'SD2->(D2_CLIENTE+D2_LOJA)'
	cNode   := '_saida'
	cEntSai := 'saída'
Else
	Alert('Opção inválida!')
	Return Nil
EndIf

//validando e salvando informações do XML para o vetor aConfig
cCpoItem := '_oMyXML:_MyAjuTES:' + cNode + ':_item'
If Type(cCpoItem) $ 'A/O'
	If Type(cCpoItem) == 'O'
		nTam := 1
	Else
		nTam := Len(&(cCpoItem))
	EndIf
	For nI := 1 to nTam
		If nTam > 1
			cAux := '[' + cValToChar(nI) + ']'
		Else
			cAux := ''
		EndIf
		
		aAux := {}
		
		cCpoCond := '_oMyXML:_MyAjuTES:' + cNode + ':_item' + cAux + ':_condicao:TEXT'
		If Type(cCpoCond) == 'C'
			bError := ErrorBlock( { |oError| MyError( oError ) } )
			Begin Sequence
				cCpoCond := AllTrim(&(cCpoCond))
				If ValType(&(cCpoCond)) == 'L'
					aAdd(aAux, cCpoCond)
				Else
					Alert('<b>Erro MyAjuTES.xml</b>' + TAGBR + 'A condição do item ' + cValToChar(nI) + ' (' + cEntSai + ') está com erro e ' + TAGBR + ' não está retornando um valor lógico.')
					Return Nil
				EndIf
			Recover
				Alert('<b>Erro MyAjuTES.xml</b>' + TAGBR + 'A condição do item ' + cValToChar(nI) + ' (' + cEntSai + ') está retornando o seguinte erro:' + TAGBR + TAGBR + _cError)
				nError := 1
			End Sequence
			ErrorBlock(bError)
			If nError == 1
				Return Nil
			EndIf
		Else
			Alert('<b>Erro MyAjuTES.xml</b>' + TAGBR + 'A condição do item ' + cValToChar(nI) + ' (' + cEntSai + ') não foi definida ou ' + TAGBR + ' não é do tipo caractere.')
			Return Nil
		EndIf
		
		cCpoTES := '_oMyXML:_MyAjuTES:' + cNode + ':_item' + cAux + ':_tes:TEXT'
		If Type(cCpoTES) == 'C'
			cCpoTES := AllTrim(&(cCpoTES))
			aAdd(aAux, cCpoTES)
		Else
			Alert('<b>Erro MyAjuTES.xml</b>' + TAGBR + 'A TES do item ' + cValToChar(nI) + ' (' + cEntSai + ') não foi definida ou ' + TAGBR + ' não é do tipo caractere.')
			Return Nil
		EndIf
		
		aAdd(aConfig, aClone(aAux))
	Next nI
Else
	Alert('<b>Erro MyAjuTES.xml</b>' + TAGBR + 'Não foi encontrado nenhum item de configuração de ' + StrTran(cNode, '_', '') + '.')
	Return Nil
EndIf
	
nTam := Len(aConfig)

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'NOTAS',.T.)

NOTAS->(dbEval({||nCount++}))

nTotal := nCount
nCount := 0

ProcRegua(nTotal)

&(cSAX)->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SF4->(dbSetOrder(1))
	
NOTAS->(dbGoTop())
While !NOTAS->(Eof())
	nCount++
	IncProc('Ajustando '+_aTipo[nOpc]+' ('+cValToChar(nCount)+'/'+cValToChar(nTotal)+')..')
	
	&(cTab)->(dbGoTo(NOTAS->NRECNO))
	
	//procurando cliente/fornecedor
	If &(cSAX)->(dbSeek( xFilial(cSAX) + &(cCliFor) ))
		//procurando produto
		If SB1->(dbSeek(xFilial('SB1') + &(cTab + '->' + cCpo + '_COD') ))
			//definindo qual TES utilizar
			
			//pegando TES padrão de entrada ou saída
			nTipoDef := 0
			cTES := AllTrim(Iif(nOpc==ENTRADA,SB1->B1_TE,SB1->B1_TS))
			
			If cTES == ''
				//não existe TES padrão, pegando os 3 últimos caracteres
				//do grupo do produto e definindo como possível TES
				nTipoDef := 1
				cTES := Iif(nOpc==ENTRADA,Right(SB1->B1_GRUPO, 3),'5' + Right(SB1->B1_GRUPO, 2))
			EndIf
			
			//percorrendo vetor com definições de TES para verificar
			//se uma das condições pré-definidas é atendida
			For nI := 1 to nTam
				If &(aConfig[nI][CONDICAO])
					nTipoDef := 2
					cTES := aConfig[nI][TES]
					Exit
				EndIf
			Next nI
			
			If SF4->(dbSeek( xFilial('SF4') + cTES ))
				//atualiza
				RecLock(cTab, .F.)
				&(cTab + '->' + cCpo + '_TES') := SF4->F4_CODIGO
				&(cTab + '->' + cCpo + '_GRUPO') := SB1->B1_GRUPO
				&(cTab + '->' + cCpo + '_TP') := SB1->B1_TIPO
				
				cClasFis := SB1->B1_ORIGEM + SF4->F4_SITTRIB
				&(cTab + '->' + cCpo + '_CLASFIS') := cClasFis
				
				If nOpc == SAIDA
					If AllTrim(&(cTab + '->' + cCpo + '_PDV')) <> ''
						//executa somente se for ECF
						nAliq := &(cTab + '->' + cCpo + '_PICM')
						If cClasFis == '000' .and. nAliq <> 0
							//tributado
							cSitTrib := 'T' + cValToChar(NoRound(nAliq*100,0))
						ElseIf cClasFis == '040'
							//isento
							cSitTrib := 'I1'
						ElseIf cClasFis == '041'
							//não tributado
							cSitTrib := 'N1'
						ElseIf cClasFis $ '010/030/060/070' .and. nAliq == 0
							//outros
							cSitTrib := 'F1'
						EndIf
						&(cTab + '->' + cCpo + '_SITTRIB') := cSitTrib
					Else
						&(cTab + '->' + cCpo + '_SITTRIB') := ''
					EndIf
				EndIf
				
				&(cTab)->(MsUnlock())
			Else
				If nTipoDef == 0
					cTexto := 'TES definida diretamente no cadastro do produto.'
				ElseIf nTipoDef == 1
					cTexto := 'TES definida através dos 3 últimos caracteres do grupo do produto.'
				ElseIf nTipoDef == 2
					cTexto := 'TES definida através de condição pré-definida em arquivo de configuração (MyAjuTES.xml) presente no diretório Protheus_Data.'
				EndIf
				If Aviso('Criar TES ' + cTES + ' para',;
				cTexto + CRLF + CRLF +;
				'Filial: '    + &(cTab + '->' + cCpo + '_FILIAL') + CRLF +;
				'Grupo: '     + SB1->B1_GRUPO + '-' + SB1->B1_FABRIC + CRLF +;
				'Produto: '   + &(cTab + '->' + cCpo + '_COD') + '-' + SB1->B1_DESC + CRLF +;
				'CFOP: '      + &(cTab + '->' + cCpo + '_CF')  + CRLF +;
				'Documento: ' + &(cTab + '->' + cCpo + '_DOC') + CRLF +;
				Iif(nOpc==ENTRADA,'Fornecedor: ','Cliente: ') + &(cCliFor),;
				{'Continuar','Sair'}, 3) == 2
					NOTAS->(dbCloseArea())
					Return Nil
				EndIf
			EndIf
		Else
			Alert('O produto ' + &(cTab + '->' + cCpo + '_COD') +;
			' do documento ' + &(cTab + '->' + cCpo + '_DOC') +;
			' não existe no Microsiga. '+;
			'Considere remigrar a tabela de produtos.')
			NOTAS->(dbCloseArea())
			Return Nil
		EndIf
	Else
		Alert('O ' + Iif(nOpc==ENTRADA,'fornecedor','cliente') + ' ' + &(cCliFor) +;
		' do documento ' + &(cTab + '->' + cCpo + '_DOC') +;
		' não existe no Microsiga. '+;
		'Considere remigrar a tabela de ' + Iif(nOpc==ENTRADA,'fornecedores','clientes') + '.')
		NOTAS->(dbCloseArea())
		Return Nil
	EndIf
	
	NOTAS->(dbSkip())
EndDo
NOTAS->(dbCloseArea())

Return Nil

/* ----------------------- */

Static Function MyError( oError )

_cError := oError:Description
Break

Return Nil
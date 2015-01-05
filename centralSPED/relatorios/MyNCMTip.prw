#include 'rwmake.ch'
#include 'protheus.ch'

#define NF_SERIE   01
#define NF_NFISCAL 02
#define NF_CFOPS   03
#define NF_VALCONT 04
#define NF_TOTAL   05
#define NF_ENTRADA 06
#define NF_CLIEFOR 07
#define NF_LOJA    08
#define NF_NOME    09
#define NF_CHVNFE  10
#define NF_FINAL   11
///////////////////////////////////////////////////////////////////////////////
User Function MyNCMTip()
///////////////////////////////////////////////////////////////////////////////
// Data : 09/05/2014
// User : Thieres Tembra
// Desc : Relação de Produtos que possuem NCM divergentes da tabela TIPI
///////////////////////////////////////////////////////////////////////////////

Local cTitulo := 'Relação de Produtos que possuem NCM divergentes da tabela TIPI'
Local cPerg := '#MyNCMTip'

CriaSX1(cPerg)

If !Pergunte(cPerg, .T., cTitulo)
	Return Nil
End If

If MV_PAR01 == 2
	If MV_PAR02 == Nil .or. MV_PAR02 == CTOD('') .or. MV_PAR03 == Nil .or. MV_PAR03 == CTOD('')
		Alert('Informe as datas para geração do relatório.')
		Return Nil
	ElseIf MV_PAR02 > MV_PAR03
		Alert('A data final deve ser maior que a data inicial.')
		Return Nil
	EndIf
EndIf

If AllTrim(MV_PAR04) == ''
	MV_PAR04 := Left(DTOS(Date()),4)
EndIf

MsAguarde({|| Aguarde(cTitulo) },'Aguarde','Realizando consulta...')

Return Nil

/* -------------- */

Static Function Aguarde(cTitulo)

Processa({|| Executa(cTitulo) },cTitulo,'Realizando consulta...')

Return Nil

/* -------------- */

Static Function Executa(cTitulo)

Local cQry
Local cAux, cRet
Local cArq := 'MyNCMTip'
Local aExcel := {}
Local nCnt, nQtd
Local cTIPI, cValid
Local aNFEnt, aNFSai

ProcRegua(0)
IncProc()

If MV_PAR01 == 1
	cQry := CRLF + " SELECT"
	cQry += CRLF + "    B1_COD"
	cQry += CRLF + "   ,B1_DESC"
	cQry += CRLF + "   ,B1_POSIPI"
	cQry += CRLF + "   ,ZYD_COD"
	cQry += CRLF + "   ,ZYD_VALID"
	cQry += CRLF + "   ,ZYD_DESC"
	cQry += CRLF + " FROM " + RetSqlName('SB1') + " SB1"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('ZYD') + " ZYD"
	cQry += CRLF + " ON  ZYD.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND ZYD_FILIAL = '" + xFilial('SYD') + "'"
	cQry += CRLF + " AND ZYD_COD = B1_POSIPI"
	cQry += CRLF + " AND LEN(ZYD_COD) = 8"
	cQry += CRLF + " WHERE SB1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND B1_FILIAL = '" + xFilial('SB1') + "'"
	cQry += CRLF + "   AND ("
	cQry += CRLF + "        ZYD_COD IS NULL"
	cQry += CRLF + "     OR ("
	cQry += CRLF + "           ZYD_VALID <= '" + DTOS(Date()) + "'"
	cQry += CRLF + "       AND ZYD_VALID <> ''"
	cQry += CRLF + "     )"
	cQry += CRLF + "   )"
	cQry += CRLF + "   AND B1_COD BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'"
	cQry += CRLF + " ORDER BY"
	cQry += CRLF + "    ZYD_VALID DESC"
	cQry += CRLF + "   ,B1_POSIPI"
	cQry += CRLF + "   ,B1_COD"
Else
	cQry := CRLF + " SELECT"
	cQry += CRLF + "    B1_COD"
	cQry += CRLF + "   ,B1_DESC"
	cQry += CRLF + "   ,B1_POSIPI"
	cQry += CRLF + "   ,ZYD_COD"
	cQry += CRLF + "   ,ZYD_VALID"
	cQry += CRLF + "   ,ZYD_DESC"
	cQry += CRLF + " FROM " + RetSqlName('SB1') + " SB1"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('ZYD') + " ZYD"
	cQry += CRLF + " ON  ZYD.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND ZYD_FILIAL = '" + xFilial('SYD') + "'"
	cQry += CRLF + " AND ZYD_COD = B1_POSIPI"
	cQry += CRLF + " AND LEN(ZYD_COD) = 8"
	cQry += CRLF + " WHERE SB1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND B1_FILIAL = '" + xFilial('SB1') + "'"
	cQry += CRLF + "   AND ("
	cQry += CRLF + "        ZYD_COD IS NULL"
	cQry += CRLF + "     OR ("
	cQry += CRLF + "           ZYD_VALID <= '" + DTOS(Date()) + "'"
	cQry += CRLF + "       AND ZYD_VALID <> ''"
	cQry += CRLF + "     )"
	cQry += CRLF + "   )"
	cQry += CRLF + "   AND B1_COD IN ("
	cQry += CRLF + "     SELECT"
	cQry += CRLF + "        FT_PRODUTO"
	cQry += CRLF + "     FROM " + RetSqlName('SFT') + " SFT"
	cQry += CRLF + "     WHERE SFT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "       AND FT_FILIAL = '" + xFilial('SFT') + "'"
	cQry += CRLF + "       AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "'"
	cQry += CRLF + "       AND FT_PRODUTO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'"
	cQry += CRLF + "     GROUP BY FT_PRODUTO"
	cQry += CRLF + "   )"
	cQry += CRLF + " ORDER BY"
	cQry += CRLF + "    ZYD_VALID DESC"
	cQry += CRLF + "   ,B1_POSIPI"
	cQry += CRLF + "   ,B1_COD"
EndIf

cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY',.T.)

nQtd := 0
MQRY->(dbEval({||nQtd++}))
MQRY->(dbGoTop())

ProcRegua(nQtd)

aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' às '+Time()+' por '+AllTrim(cUsername)})
If MV_PAR01 == 1
	aAdd(aExcel, {'Origem: Produto (SB1)'})
Else
	aAdd(aExcel, {'Origem: L. Fiscal (SFT)'})
	aAdd(aExcel, {'Período: '+DTOC(MV_PAR02)+' até '+DTOC(MV_PAR03)})
EndIf
aAdd(aExcel, {'Ano NF: '+MV_PAR04})
aAdd(aExcel, {''})
aAdd(aExcel, {'Empresa: '+cEmpAnt+'/'+cFilAnt+'-'+AllTrim(SM0->M0_NOME)+' / '+AllTrim(SM0->M0_FILIAL) + ' - CNPJ: '+Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')})
aAdd(aExcel, {'','','','','Dados da Última NF de Entrada do Ano ' + MV_PAR04 + ' ou Inferior','','','','','','','','','','Dados da Última NF de Saída do Ano ' + MV_PAR04 + ' ou Inferior','','','','','','',''})
aAdd(aExcel, {'Produto','NCM','Status TIPI','Validade','Série','Nota Fiscal','CFOPs','Valor Contábil','Valor Total','Entrada','Fornecedor','Loja','Nome Fornecedor','Chave','Série','Nota Fiscal','CFOPs','Valor Contábil','Valor Total','Entrada','Cliente','Loja','Nome Cliente','Chave','Descrição do Produto','Descrição do NCM'})

nCnt := 0
While !MQRY->(Eof())
	nCnt++
	IncProc('Analisando produto ' + cValToChar(nCnt) + '/' + cValToChar(nQtd) + '..')
	
	cTIPI := AllTrim(MQRY->ZYD_COD)
	If cTIPI == ''
		cTIPI := 'NÃO EXISTE NA TIPI!'
	Else
		cTIPI := 'VALIDADE VENCIDA!'
	EndIf
	
	cValid := AllTrim(MQRY->ZYD_VALID)
	
	aNFEnt := Nota(0, MQRY->B1_COD)
	aNFSai := Nota(1, MQRY->B1_COD)
	
	aAdd(aExcel, {;
		AllTrim(MQRY->B1_COD),;
		AllTrim(MQRY->B1_POSIPI),;
		cTIPI,;
		Iif(cValid=='','',STOD(cValid)),;
		aNFEnt[NF_SERIE],;
		aNFEnt[NF_NFISCAL],;
		aNFEnt[NF_CFOPS],;
		aNFEnt[NF_VALCONT],;
		aNFEnt[NF_TOTAL],;
		aNFEnt[NF_ENTRADA],;
		aNFEnt[NF_CLIEFOR],;
		aNFEnt[NF_LOJA],;
		aNFEnt[NF_NOME],;
		aNFEnt[NF_CHVNFE],;
		aNFSai[NF_SERIE],;
		aNFSai[NF_NFISCAL],;
		aNFSai[NF_CFOPS],;
		aNFSai[NF_VALCONT],;
		aNFSai[NF_TOTAL],;
		aNFSai[NF_ENTRADA],;
		aNFSai[NF_CLIEFOR],;
		aNFSai[NF_LOJA],;
		aNFSai[NF_NOME],;
		aNFSai[NF_CHVNFE],;
		AllTrim(MQRY->B1_DESC),;
		AllTrim(MQRY->ZYD_DESC);
	})
	MQRY->(dbSkip())
EndDo

MQRY->(dbCloseArea())

IncProc()

cAux := AllTrim(cGetFile('CSV (*.csv)|*.csv', 'Selecione o diretório onde será salvo o relatório', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NETWORKDRIVE, GETF_RETDIRECTORY ), .F., .T.))
If cAux <> ''
	cAux := SubStr(cAux, 1, RAt('\', cAux)) + cArq
	cAux := cAux + '-' + DTOS(Date()) + '-' + StrTran(Time(), ':', '') + '.csv'
	
	cRet := U_MyArrCsv(aExcel, cAux, Nil, cTitulo)
	If cRet <> ''
		Alert(cRet)
	EndIf
Else
	Alert('A geração do relatório foi cancelada!')
EndIf

Return Nil

/* -------------- */

Static Function Nota(nTipo, cProd)

Local cQry
Local aRet := {}
Local lOk := .F.
Local cCFOP := ''
Local cChave1, cChave2

cQry := CRLF + " SELECT"
cQry += CRLF + "    FT_SERIE        AS SERIE"
cQry += CRLF + "   ,FT_NFISCAL      AS NFISCAL"
cQry += CRLF + "   ,FT_ENTRADA      AS ENTRADA"
cQry += CRLF + "   ,FT_CLIEFOR      AS CLIEFOR"
cQry += CRLF + "   ,FT_LOJA         AS LOJA"
cQry += CRLF + "   ,FT_CFOP         AS CFOP"
cQry += CRLF + "   ,FT_CHVNFE       AS CHVNFE"
cQry += CRLF + "   ,SUM(FT_VALCONT) AS VALCONT"
cQry += CRLF + "   ,SUM(FT_TOTAL)   AS TOTAL"
If nTipo == 0
	cQry += CRLF + "   ,A2_NOME    AS NOME"
ElseIf nTipo == 1
	cQry += CRLF + "   ,A1_NOME    AS NOME"
EndIf
cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
If nTipo == 0
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SA2') + " SA2"
	cQry += CRLF + " ON  SA2.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND A2_FILIAL = '" + xFilial('SA2') + "'"
	cQry += CRLF + " AND A2_COD = FT_CLIEFOR"
	cQry += CRLF + " AND A2_LOJA = FT_LOJA
ElseIf nTipo == 1
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SA1') + " SA1"
	cQry += CRLF + " ON  SA1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND A1_FILIAL = '" + xFilial('SA1') + "'"
	cQry += CRLF + " AND A1_COD = FT_CLIEFOR"
	cQry += CRLF + " AND A1_LOJA = FT_LOJA"
EndIf
cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND FT_PRODUTO = '" + cProd + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,4) <= '" + MV_PAR04 + "'"
cQry += CRLF + "   AND FT_TIPO NOT IN ('D','B')"
If nTipo == 0
	cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
ElseIf nTipo == 1
	cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
EndIf
cQry += CRLF + " GROUP BY"
cQry += CRLF + "    FT_SERIE"
cQry += CRLF + "   ,FT_NFISCAL"
cQry += CRLF + "   ,FT_ENTRADA"
cQry += CRLF + "   ,FT_CLIEFOR"
cQry += CRLF + "   ,FT_LOJA"
cQry += CRLF + "   ,FT_CFOP"
cQry += CRLF + "   ,FT_CHVNFE"
If nTipo == 0
	cQry += CRLF + "   ,A2_NOME"
ElseIf nTipo == 1
	cQry += CRLF + "   ,A1_NOME"
EndIf
cQry += CRLF + " ORDER BY"
cQry += CRLF + "    FT_ENTRADA DESC"

cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'NOTA',.T.)

While !NOTA->(Eof())
	If !lOk
		aRet := {;
			AllTrim(NOTA->SERIE),;
			AllTrim(NOTA->NFISCAL),;
			'',;
			NOTA->VALCONT,;
			NOTA->TOTAL,;
			STOD(NOTA->ENTRADA),;
			AllTrim(NOTA->CLIEFOR),;
			AllTrim(NOTA->LOJA),;
			AllTrim(NOTA->NOME),;
			AllTrim(NOTA->CHVNFE);
		}
		lOk := .T.
	EndIf
	
	cChave1 := AllTrim(NOTA->SERIE) + AllTrim(NOTA->NFISCAL) + NOTA->ENTRADA          + AllTrim(NOTA->CLIEFOR) + AllTrim(NOTA->LOJA)
	cChave2 := aRet[NF_SERIE]       + aRet[NF_NFISCAL]       + DTOS(aRet[NF_ENTRADA]) + aRet[NF_CLIEFOR]       + aRet[NF_LOJA]
	If cChave1 <> cChave2
		Exit
	EndIf
	
	cCFOP += AllTrim(NOTA->CFOP) + ', '
	
	NOTA->(dbSkip())
EndDo

If !lOk
	aRet := Array(NF_FINAL-1)
	aFill(aRet, '')
Else
	cCFOP := SubStr(cCFOP, 1, Len(cCFOP)-2)
	aRet[NF_CFOPS] := cCFOP
EndIf

NOTA->(dbCloseArea())

Return aClone(aRet)

/* -------------- */

Static Function CriaSX1(cPerg)

Local nTamGrp := Len(SX1->X1_GRUPO)
Local aHelpPor := {}, aHelpEng := {}, aHelpSpa := {}
Local cNome

aHelpPor := {}
aAdd(aHelpPor, 'Selecione a origem do relatório.     ')
cNome := 'Origem'
PutSx1(PadR(cPerg,nTamGrp), '01', cNome, cNome, cNome,;
'MV_CH1', 'N', 1, 0, 1, 'C', '', '', '', '', 'MV_PAR01',;
'Produto (SB1)', 'Produto (SB1)', 'Produto (SB1)', '',;
'L. Fiscal (SFT)', 'L. Fiscal (SFT)', 'L. Fiscal (SFT)',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Somente para origem SFT:             ')
aAdd(aHelpPor, '    Informe a data inicial/final para')
aAdd(aHelpPor, '    geração do relatório.            ')
cNome := 'Data inicial'
PutSx1(PadR(cPerg,nTamGrp), '02', cNome, cNome, cNome,;
'MV_CH2', 'D', 8, 0, 0, 'G', '', '', '', '', 'MV_PAR02',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

cNome := 'Data final'
PutSx1(PadR(cPerg,nTamGrp), '03', cNome, cNome, cNome,;
'MV_CH3', 'D', 8, 0, 0, 'G', '', '', '', '', 'MV_PAR03',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe o ano a ser considerado na   ')
aAdd(aHelpPor, 'busca da última nota de entrada deste')
aAdd(aHelpPor, 'produto. Deixe em branco para        ')
aAdd(aHelpPor, 'considerar o ano atual.              ')
cNome := 'Ano NF'
PutSx1(PadR(cPerg,nTamGrp), '04', cNome, cNome, cNome,;
'MV_CH4', 'C', 4, 0, 0, 'G', '', '', '', '', 'MV_PAR04',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe o produto inicial a ser      ')
aAdd(aHelpPor, 'considerado.                         ')
cNome := 'Produto de'
PutSx1(PadR(cPerg,nTamGrp), '05', cNome, cNome, cNome,;
'MV_CH5', 'C', 15, 0, 0, 'G', '', 'SB1', '', '', 'MV_PAR05',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe o produto final a ser        ')
aAdd(aHelpPor, 'considerado.                         ')
cNome := 'Produto até'
PutSx1(PadR(cPerg,nTamGrp), '06', cNome, cNome, cNome,;
'MV_CH6', 'C', 15, 0, 0, 'G', '', 'SB1', '', '', 'MV_PAR06',;
'', '', '', 'zzzzzzzzzzzzzzz',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
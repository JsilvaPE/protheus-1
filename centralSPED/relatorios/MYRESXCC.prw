#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyRESXCC()
///////////////////////////////////////////////////////////////////////////////
// Data : 23/04/2013
// User : Thieres Tembra
// Desc : Gera relatório de Entrada (SD1) e Saída (SD2) por Centro de Custo
//        conforme definição do colaborador Mauro Vulcão:
//        Administrativo = 101;206;207;303
//        Operacional    = 102;103;104;201;202;204;205;301;302
///////////////////////////////////////////////////////////////////////////////

Local cTitulo := 'Relatório Entrada/Saída por Centro de Custo'
Local cPerg   := '#TDESXCC'
Local cCCAdm  := '101;206;207;303'
Local cCCOpe  := '102;103;104;201;202;204;205;301;302'
Local aAux1, aAux2, _cDescConta
Local nI, nJ, nMaxI, nMaxJ
Local aArea := GetArea()
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSF2 := SF2->(GetArea())

CriaSX1(cPerg)

If !Pergunte(cPerg, .T., cTitulo)
	Return Nil
End If

If MV_PAR01 == Nil .or. MV_PAR01 == CTOD('') .or. MV_PAR02 == Nil .or. MV_PAR02 == CTOD('')
	Alert('Informe as datas para geração do relatório.')
	Return Nil
ElseIf MV_PAR01 > MV_PAR02
	Alert('A data final deve ser maior que a data inicial.')
	Return Nil
Else
	If AllTrim(MV_PAR05) == ''
		MV_PAR05 := cCCAdm
	EndIf
	aAux1 := Separa(MV_PAR05, ';')
	nMaxI := Len(aAux1)
	For nI := 1 to nMaxI
		If Len(AllTrim(aAux1[nI])) <> 3
			Alert('Erro no CC Administrativo' + CRLF +;
			'Cada centro de custo informado deve conter os 3 dígitos iniciais.' + CRLF +;
			'Corrija o centro de custo da posição ' + cValToChar(nI) + '.')
			Return Nil
		EndIf
	Next nI
	
	If AllTrim(MV_PAR06) == ''
		MV_PAR06 := cCCOpe
	EndIf
	aAux2 := Separa(MV_PAR06, ';')
	nMaxI := Len(aAux2)
	For nI := 1 to nMaxI
		If Len(AllTrim(aAux2[nI])) <> 3
			Alert('Erro no CC Operacional' + CRLF +;
			'Cada centro de custo informado deve conter os 3 dígitos iniciais.' + CRLF +;
			'Corrija o centro de custo da posição ' + cValToChar(nI) + '.')
			Return Nil
		EndIf
	Next nI
	
	nMaxI := Len(aAux1)
	nMaxJ := Len(aAux2)
	For nI := 1 to nMaxI
		For nJ := 1 to nMaxJ
			If AllTrim(aAux1[nI]) == AllTrim(aAux2[nJ])
				Alert('O mesmo CC não pode estar contido nos parâmetros ' +;
				'operacional e administrativo. Verifique a inconsistência ' +;
				'com o CC ' + AllTrim(aAux1[nI]) + '.')
				Return Nil
			EndIf
		Next nJ
	Next nI
EndIf

Processa({|| Executa(cTitulo) },cTitulo,'Selecionando registros...')

SF2->(RestArea(aAreaSF2))
SF1->(RestArea(aAreaSF1))
RestArea(aArea)

Return Nil

/* -------------- */

Static Function Executa(cTitulo)

Local nI, nMax, nPos, nTipo, nCount, nTotal
Local cQry, cQry2, cRet, cAux
Local cArq      := 'ESxCC'
Local aExcel    := {}
Local aAux      := {}
Local aTipo     := {'Administrativo', 'Operacional', 'Não classificado'}
Local nValNota  := 0                    
Local _cDescCta := ""
Local _nVlrCta  := 0.00
Local _cDoc		 := ""
Local _cFornece := ""
Local _cLoja    := ""

Private aSoma     := {0,0,0}
Private aSomaCC   := {}
Private aSomaCFC  := {}
Private aSomaCF   := {} 

Private _nCntCv3  := 0
Private _nRecSF1  := 0
Private _cContas  := ""
Private _cCta     := ""
Private _cICMCOM  := ''
Private _cISS     := ''

ProcRegua(0)

aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Período: '+DTOC(MV_PAR01)+' até '+DTOC(MV_PAR02)})
aAdd(aExcel, {'Notas de: '+Iif(MV_PAR03==1,'Entrada','Saída')})
aAdd(aExcel, {'Considera: Data de '+Iif(MV_PAR04==1,'Entrada','Emissão')})
aAdd(aExcel, {'CC Administrativo: '+StrTran(MV_PAR05,';',',')})
aAdd(aExcel, {'CC Operacional: '+StrTran(MV_PAR06,';',',')})
aAdd(aExcel, {'CC Operacional: '+StrTran(MV_PAR06,';',',')})
aAdd(aExcel, {'Grupo : '+ Alltrim(SM0->M0_NOMECOM) + " Filial: " + Alltrim(SM0->M0_FILIAL) })

If AllTrim(MV_PAR07) <> ''
	aAdd(aExcel, {'CFOPs: '+StrTran(MV_PAR07,';',',')})
EndIf

aAdd(aExcel, {''})

cQry := ''
If MV_PAR03 == 1
	cQry += CRLF + " SELECT"
	cQry += CRLF + "        D1_DOC        AS DOCUMENTO"
	cQry += CRLF + "       ,D1_SERIE      AS SERIE"
	cQry += CRLF + "       ,D1_EMISSAO    AS EMISSAO"
	cQry += CRLF + "       ,D1_DTDIGIT    AS ENTRADA"
	cQry += CRLF + "       ,D1_FORNECE    AS CLIEFOR"
	cQry += CRLF + "       ,D1_LOJA       AS LOJA"
	cQry += CRLF + "       ,A2_CGC        AS FORCNPJ"
	cQry += CRLF + "       ,A2_NOME       AS FORNOME"
	cQry += CRLF + "       ,A1_CGC        AS CLICNPJ"
	cQry += CRLF + "       ,A1_NOME       AS CLINOME"
	cQry += CRLF + "       ,D1_TIPO       AS TIPO"
	cQry += CRLF + "       ,D1_CF         AS CFOP"
	cQry += CRLF + "       ,D1_CC         AS CC"
	//cQry += CRLF + "       ,B1_GRPCTB     AS GRPCTB"
	cQry += CRLF + "       ,CTT_DESC01    AS CCDESC"
	cQry += CRLF + "       ,SUM(D1_TOTAL) AS VALOR"
	cQry += CRLF + " FROM " + RetSqlName('SD1') + " SD1"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('CTT') + " CTT"
	cQry += CRLF + " ON  CTT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND CTT_FILIAL = '" + xFilial('CTT') + "'"
	cQry += CRLF + " AND CTT_CUSTO  = D1_CC"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SA2') + " SA2"
	cQry += CRLF + " ON  SA2.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND A2_FILIAL = '" + xFilial('SA2') + "'"
	cQry += CRLF + " AND A2_COD    = D1_FORNECE"
	cQry += CRLF + " AND A2_LOJA   = D1_LOJA"
	cQry += CRLF + " AND D1_TIPO   NOT IN ('D','B')"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SA1') + " SA1"
	cQry += CRLF + " ON  SA1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND A1_FILIAL = '" + xFilial('SA1') + "'"
	cQry += CRLF + " AND A1_COD    = D1_FORNECE"
	cQry += CRLF + " AND A1_LOJA   = D1_LOJA"
	cQry += CRLF + " AND D1_TIPO   IN ('D','B')"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SB1') + " SB1"
	cQry += CRLF + " ON  SB1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND B1_FILIAL = '" + xFilial('SB1') + "'"
	cQry += CRLF + " AND B1_COD    = D1_COD"
	cQry += CRLF + " WHERE D1_FILIAL = '" + xFilial('SD1') + "'"
	cQry += CRLF + "   AND SD1.D_E_L_E_T_ <> '*'"
	If MV_PAR04 == 1
		cQry += CRLF + "   AND D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	Else
		cQry += CRLF + "   AND D1_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	EndIf
	If AllTrim(MV_PAR07) <> ''
		cQry += CRLF + "   AND D1_CF IN " + U_MyGeraIn(AllTrim(MV_PAR07))
	EndIf
	cQry += CRLF + " GROUP BY D1_DOC"
	cQry += CRLF + "         ,D1_SERIE"
	cQry += CRLF + "         ,D1_EMISSAO"
	cQry += CRLF + "         ,D1_DTDIGIT"
	cQry += CRLF + "         ,D1_FORNECE"
	cQry += CRLF + "         ,D1_LOJA"
	cQry += CRLF + "         ,A2_CGC"
	cQry += CRLF + "         ,A2_NOME"
	cQry += CRLF + "         ,A1_CGC"
	cQry += CRLF + "         ,A1_NOME"
	cQry += CRLF + "         ,D1_TIPO"
	cQry += CRLF + "         ,D1_CF"
	cQry += CRLF + "         ,D1_CC"
	cQry += CRLF + "         ,CTT_DESC01"
	cQry += CRLF + " ORDER BY D1_DOC"
	cQry += CRLF + "         ,D1_SERIE"
	cQry += CRLF + "         ,D1_EMISSAO"
	cQry += CRLF + "         ,D1_DTDIGIT"
	cQry += CRLF + "         ,D1_FORNECE"
	cQry += CRLF + "         ,D1_LOJA"
	cQry += CRLF + "         ,A2_CGC"
	cQry += CRLF + "         ,A2_NOME"
	cQry += CRLF + "         ,A1_CGC"
	cQry += CRLF + "         ,A1_NOME"
	cQry += CRLF + "         ,D1_TIPO"
	cQry += CRLF + "         ,D1_CF"
	cQry += CRLF + "         ,D1_CC"
	cQry += CRLF + "         ,CTT_DESC01"
Else
	cQry += CRLF + " SELECT"
	cQry += CRLF + "        D2_DOC        AS DOCUMENTO"
	cQry += CRLF + "       ,D2_SERIE      AS SERIE"
	cQry += CRLF + "       ,D2_EMISSAO    AS EMISSAO"
	cQry += CRLF + "       ,D2_DTDIGIT    AS ENTRADA"
	cQry += CRLF + "       ,D2_CLIENTE    AS CLIEFOR"
	cQry += CRLF + "       ,D2_LOJA       AS LOJA"
	cQry += CRLF + "       ,A1_CGC        AS CLICNPJ"
	cQry += CRLF + "       ,A1_NOME       AS CLINOME"
	cQry += CRLF + "       ,A2_CGC        AS FORCNPJ"
	cQry += CRLF + "       ,A2_NOME       AS FORNOME"
	cQry += CRLF + "       ,D2_TIPO       AS TIPO"
	cQry += CRLF + "       ,D2_CF         AS CFOP"
	cQry += CRLF + "       ,D2_CCUSTO     AS CC"
	cQry += CRLF + "       ,CTT_DESC01    AS CCDESC"
	cQry += CRLF + "       ,SUM(D2_TOTAL) AS VALOR"
	cQry += CRLF + " FROM " + RetSqlName('SD2') + " SD2"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('CTT') + " CTT"
	cQry += CRLF + " ON  CTT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND CTT_FILIAL = '" + xFilial('CTT') + "'"
	cQry += CRLF + " AND CTT_CUSTO  = D2_CCUSTO"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SA1') + " SA1"
	cQry += CRLF + " ON  SA1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND A1_FILIAL = '" + xFilial('SA1') + "'"
	cQry += CRLF + " AND A1_COD    = D2_CLIENTE"
	cQry += CRLF + " AND A1_LOJA   = D2_LOJA"
	cQry += CRLF + " AND D2_TIPO   NOT IN ('D','B')"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SA2') + " SA2"
	cQry += CRLF + " ON  SA2.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND A2_FILIAL = '" + xFilial('SA2') + "'"
	cQry += CRLF + " AND A2_COD    = D2_CLIENTE"
	cQry += CRLF + " AND A2_LOJA   = D2_LOJA"
	cQry += CRLF + " AND D2_TIPO   IN ('D','B')"
	cQry += CRLF + " WHERE D2_FILIAL = '" + xFilial('SD2') + "'"
	cQry += CRLF + "   AND SD2.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND D2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	If AllTrim(MV_PAR07) <> ''
		cQry += CRLF + "   AND D2_CF IN " + U_MyGeraIn(AllTrim(MV_PAR07))
	EndIf
	cQry += CRLF + " GROUP BY D2_DOC"
	cQry += CRLF + "         ,D2_SERIE"
	cQry += CRLF + "         ,D2_EMISSAO"
	cQry += CRLF + "         ,D2_DTDIGIT"
	cQry += CRLF + "         ,D2_CLIENTE"
	cQry += CRLF + "         ,D2_LOJA"
	cQry += CRLF + "         ,A1_CGC"
	cQry += CRLF + "         ,A1_NOME"
	cQry += CRLF + "         ,A2_CGC"
	cQry += CRLF + "         ,A2_NOME
	cQry += CRLF + "         ,D2_TIPO"
	cQry += CRLF + "         ,D2_CF"
	cQry += CRLF + "         ,D2_CCUSTO"
	cQry += CRLF + "         ,CTT_DESC01"
	cQry += CRLF + "         ,D2_CONTA"
	cQry += CRLF + " ORDER BY D2_DOC"
	cQry += CRLF + "         ,D2_SERIE"
	cQry += CRLF + "         ,D2_EMISSAO"
	cQry += CRLF + "         ,D2_DTDIGIT"
	cQry += CRLF + "         ,D2_CLIENTE"
	cQry += CRLF + "         ,D2_LOJA"
	cQry += CRLF + "         ,A1_CGC"
	cQry += CRLF + "         ,A1_NOME"
	cQry += CRLF + "         ,A2_CGC"
	cQry += CRLF + "         ,A2_NOME
	cQry += CRLF + "         ,D2_TIPO"
	cQry += CRLF + "         ,D2_CF"
	cQry += CRLF + "         ,D2_CCUSTO"
	cQry += CRLF + "         ,CTT_DESC01"
EndIf

cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY',.T.)
nTotal := 0
nCount := 0
MQRY->(dbEval({||nTotal++}))
ProcRegua(nTotal+3)
MQRY->(dbGoTop())

SF1->(dbSetOrder(1))
SF2->(dbSetOrder(1))

aAdd(aExcel, {'Nota Fiscal','Série','Tipo','Emissão','Entrada','Cliente/Fornecedor','CNPJ','Razão Social','CFOP','Centro de Custo','Descrição CC','Tipo de CC','Conta Contabil','Descricao','Valor','Valor Nota','Valor Contabil','Diferenca','Pendencias'})

While !MQRY->(Eof())
	nCount++
	IncProc('Analisando nota ' + cValToChar(nCount) + '/' + cValToChar(nTotal) + '..')
	
	nTipo := TipoCC(MQRY->CC)
	
	cCNPJ := AllTrim(MQRY->FORCNPJ)
	cNome := AllTrim(MQRY->FORNOME)
	If cCNPJ == '' .and. cNome == ''
		cCNPJ := AllTrim(MQRY->CLICNPJ)
		cNome := AllTrim(MQRY->CLINOME)
	EndIf
	
	nValNota := 0
	If MV_PAR03 == 1
		SF1->(dbGoTop())
		If SF1->(dbSeek( xFilial('SF1') + PadR(MQRY->DOCUMENTO,9) + PadR(MQRY->SERIE,3) + PadR(MQRY->CLIEFOR,6) + PadR(MQRY->LOJA,2) , .T.))
			nValNota := SF1->F1_VALBRUT
		EndIf
	Else
		SF2->(dbGoTop())
		If SF2->(dbSeek( xFilial('SF2') + PadR(MQRY->DOCUMENTO,9) + PadR(MQRY->SERIE,3) + PadR(MQRY->CLIEFOR,6) + PadR(MQRY->LOJA,2) , .T.))
			nValNota := SF2->F2_VALBRUT
		EndIf
	EndIf

   _nRecSF1 := SF1->(Recno())
            
	IF MV_PAR03 == 1
		_cContas := Alltrim(MV_PAR08) + Alltrim(MV_PAR09) + Alltrim(MV_PAR10)
		
		cQry2 :=""
		cQry2 += CRLF + "SELECT "
		cQry2 += CRLF + "   CT2_DEBITO "
		cQry2 += CRLF + "   ,D1_CF  "
		cQry2 += CRLF + "   ,D1_CC  "
		cQry2 += CRLF + "   ,D1_DOC  "
		cQry2 += CRLF + "   ,D1_FORNECE  "
		cQry2 += CRLF + "   ,D1_LOJA  "
		cQry2 += CRLF + "   ,ROUND(SUM(CT2_VALOR),2) AS CT2_VALOR "
		cQry2 += CRLF + "FROM "
		cQry2 += CRLF + "    " + RetSQLName("CV3") + " CV3 "
		cQry2 += CRLF + "   ," + RetSQLName("CT2") + " CT2 "
		cQry2 += CRLF + "   ," + RetSQLName("SD1") + " SD1 "
		cQry2 += CRLF + "WHERE "
		cQry2 += CRLF + "   CV3.D_E_L_E_T_ <> '*' "
		cQry2 += CRLF + "   AND CT2.D_E_L_E_T_ <> '*' "
		cQry2 += CRLF + "   AND SD1.D_E_L_E_T_ <> '*' "
		cQry2 += CRLF + "   AND CV3.CV3_FILIAL = '" + xFilial("CV3") + "' "
		cQry2 += CRLF + "   AND CT2.CT2_FILIAL = '" + xFilial("CT2") + "' "
		cQry2 += CRLF + "   AND CV3.CV3_FILIAL = CT2.CT2_FILIAL "
		cQry2 += CRLF + "   AND CV3.CV3_TABORI = 'SF1' "
		cQry2 += CRLF + "   AND CONVERT(INT,CV3.CV3_RECORI) =  " + cValtoChar(_nRecSF1) + " "
		cQry2 += CRLF + "   AND CT2.R_E_C_N_O_ = CV3.CV3_RECDES "
//		cQry2 += CRLF + "   AND CV3.CV3_DEBITO = CT2.CT2_DEBITO "
		cQry2 += CRLF + "   AND CV3.CV3_DC IN ('1','3') "
		cQry2 += CRLF + "   AND CT2.CT2_DEBITO IN " + U_MyGeraIn(AllTrim(_cContas)) + " "
		cQry2 += CRLF + "   AND SD1.D1_FILIAL  = '" + xFilial("SD1")  + "' "
		cQry2 += CRLF + "   AND SD1.D1_DOC     = '" + MQRY->DOCUMENTO + "' "
		cQry2 += CRLF + "   AND SD1.D1_SERIE   = '" + MQRY->SERIE     + "' "
		cQry2 += CRLF + "   AND SD1.D1_FORNECE = '" + MQRY->CLIEFOR   + "' "
		cQry2 += CRLF + "   AND SD1.D1_LOJA    = '" + MQRY->LOJA      + "' "
		cQry2 += CRLF + "   AND SD1.D1_CC      = '" + MQRY->CC        + "' "
		cQry2 += CRLF + "   AND SD1.D1_CF      = '" + MQRY->CFOP      + "' "
		cQry2 += CRLF + "   AND SD1.D1_FILIAL  = SUBSTRING(CV3.CV3_KEY,1,2) "
		cQry2 += CRLF + "   AND SD1.D1_DOC     = SUBSTRING(CV3.CV3_KEY,3,9) "
		cQry2 += CRLF + "   AND SD1.D1_SERIE   = SUBSTRING(CV3.CV3_KEY,12,3) "
		cQry2 += CRLF + "   AND SD1.D1_FORNECE = SUBSTRING(CV3.CV3_KEY,15,6) "
		cQry2 += CRLF + "   AND SD1.D1_LOJA    = SUBSTRING(CV3.CV3_KEY,21,2) "
		cQry2 += CRLF + "   AND SD1.D1_COD+SD1.D1_ITEM = SUBSTRING(CV3.CV3_KEY,23,19) "
		cQry2 += CRLF + "GROUP BY "
		cQry2 += CRLF + "   CT2_DEBITO "
		cQry2 += CRLF + "   ,D1_CF "
		cQry2 += CRLF + "   ,D1_CC "
		cQry2 += CRLF + "   ,D1_DOC "
		cQry2 += CRLF + "   ,D1_FORNECE "
		cQry2 += CRLF + "   ,D1_LOJA "
	    
		cQry2 := ChangeQuery(cQry2)
		dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry2),'TMPCT2',.T.)
	             
		_cCta     := ""	   
		_cDescCta := ""	   
		_nVlrCta  := 0.00	   
		_cDoc		 := ""
		_cFornece := ""
		_cLoja    := ""
		_nCntCv3 := 0
		
   	Do While !TMPCT2->(EOF())       
			If !(Alltrim(TMPCT2->CT2_DEBITO) $ _cCta)
				_cCta     += Alltrim(TMPCT2->CT2_DEBITO) + " "
				_cDescCta += Alltrim(Posicione("CT1",1,xFilial("CT1")+TMPCT2->CT2_DEBITO,"CT1_DESC01"))
			Endif
			
			_nVlrCta  += TMPCT2->CT2_VALOR
			
			_nCntCv3++
			TMPCT2->(dbSkip())
   	Enddo
   	
   	If _nCntCv3 == 0
   		TMPCT2->(dbCloseArea())
			_cICMCOM := ""
			_cISS := ""
			If AllTrim(MQRY->CFOP) $ '1556/2556'
				_cICMCOM := "+SD1.D1_ICMSCOM"
			EndIf
			If SF1->F1_ISS > 0
				_cISS := "+SD1.D1_VALIMP5+SD1.D1_VALIMP6"
			EndIf
			cQry2 :=""
			cQry2 += CRLF + "SELECT "
			cQry2 += CRLF + "   CT2_DEBITO "
			cQry2 += CRLF + "   ,D1_CF  "
			cQry2 += CRLF + "   ,D1_CC  "
			cQry2 += CRLF + "   ,D1_DOC  "
			cQry2 += CRLF + "   ,D1_FORNECE  "
			cQry2 += CRLF + "   ,D1_LOJA  "
			cQry2 += CRLF + "   ,ROUND(SUM(CT2_VALOR),2) AS CT2_VALOR "
			cQry2 += CRLF + "FROM "
			cQry2 += CRLF + "    " + RetSQLName("CV3") + " CV3 "
			cQry2 += CRLF + "   ," + RetSQLName("CT2") + " CT2 "
			cQry2 += CRLF + "   ," + RetSQLName("SD1") + " SD1 "
			cQry2 += CRLF + "WHERE "
			cQry2 += CRLF + "   CV3.D_E_L_E_T_ <> '*' "
			cQry2 += CRLF + "   AND CT2.D_E_L_E_T_ <> '*' "
			cQry2 += CRLF + "   AND SD1.D_E_L_E_T_ <> '*' "
			cQry2 += CRLF + "   AND CV3.CV3_FILIAL = '" + xFilial("CV3") + "' "
			cQry2 += CRLF + "   AND CT2.CT2_FILIAL = '" + xFilial("CT2") + "' "
			cQry2 += CRLF + "   AND CV3.CV3_FILIAL = CT2.CT2_FILIAL "
			cQry2 += CRLF + "   AND CV3.CV3_TABORI = 'SF1' "
			cQry2 += CRLF + "   AND CONVERT(INT,CV3.CV3_RECORI) =  " + cValtoChar(_nRecSF1) + " "
			cQry2 += CRLF + "   AND CT2.R_E_C_N_O_ = CV3.CV3_RECDES "
//			cQry2 += CRLF + "   AND CV3.CV3_DEBITO = CT2.CT2_DEBITO "
			cQry2 += CRLF + "   AND CV3.CV3_DC IN ('1','3') "
			cQry2 += CRLF + "   AND CT2.CT2_DEBITO IN " + U_MyGeraIn(AllTrim(_cContas)) + " "
			cQry2 += CRLF + "   AND SD1.D1_FILIAL  = '" + xFilial("SD1")  + "' "
			cQry2 += CRLF + "   AND SD1.D1_DOC     = '" + MQRY->DOCUMENTO + "' "
			cQry2 += CRLF + "   AND SD1.D1_SERIE   = '" + MQRY->SERIE     + "' "
			cQry2 += CRLF + "   AND SD1.D1_FORNECE = '" + MQRY->CLIEFOR   + "' "
			cQry2 += CRLF + "   AND SD1.D1_LOJA    = '" + MQRY->LOJA      + "' "
			cQry2 += CRLF + "   AND SD1.D1_CC      = '" + MQRY->CC        + "' "
			cQry2 += CRLF + "   AND SD1.D1_CF      = '" + MQRY->CFOP      + "' "
			cQry2 += CRLF + "   AND SD1.D1_CC      = CV3.CV3_CCD"
			cQry2 += CRLF + "   AND ROUND(SD1.D1_CUSTO+SD1.D1_VALDESC" + _cICMCOM + _cISS + ",2) = CV3.CV3_VLR01"
			cQry2 += CRLF + "GROUP BY "
			cQry2 += CRLF + "   CT2_DEBITO "
			cQry2 += CRLF + "   ,D1_CF "
			cQry2 += CRLF + "   ,D1_CC "
			cQry2 += CRLF + "   ,D1_DOC "
			cQry2 += CRLF + "   ,D1_FORNECE "
			cQry2 += CRLF + "   ,D1_LOJA "
		    
			cQry2 := ChangeQuery(cQry2)
			dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry2),'TMPCT2',.T.)
		             
			_cCta     := ""	   
			_cDescCta := ""	   
			_nVlrCta  := 0.00	   
			_cDoc		 := ""
			_cFornece := ""
			_cLoja    := ""
			
	   	Do While !TMPCT2->(EOF())       
				If !(Alltrim(TMPCT2->CT2_DEBITO) $ _cCta)
					_cCta     += Alltrim(TMPCT2->CT2_DEBITO) + " "
					_cDescCta += Alltrim(Posicione("CT1",1,xFilial("CT1")+TMPCT2->CT2_DEBITO,"CT1_DESC01"))
				Endif
				
				_nVlrCta  += TMPCT2->CT2_VALOR
				
				TMPCT2->(dbSkip())
	   	Enddo
   	EndIf

		If Alltrim(_cCta) <> "" .AND. Alltrim(_cDescCta) <> "" // .AND. MQRY->CFOP == _cCF .AND. MQRY->CC == _cCC .AND. MQRY->DOCUMENTO == _cDoc .AND. MQRY->CLIEFOR == _cFornece .AND. MQRY->LOJA == _cLoja
			If MV_PAR11 == 1
				aAux := DetItem()
				nMax := Len(aAux)
				If nMax > 0
					aAdd(aExcel, {MQRY->DOCUMENTO,MQRY->SERIE,TipoNF(MQRY->TIPO),STOD(MQRY->EMISSAO),STOD(MQRY->ENTRADA),MQRY->CLIEFOR,cCNPJ,cNome,MQRY->CFOP,MQRY->CC,MQRY->CCDESC,aTipo[nTipo],_cCta,_cDescCta,MQRY->VALOR,nValNota,_nVlrCta,MQRY->VALOR-_nVlrCta})
					CalcResumo(nTipo)
				EndIf
				For nI := 1 to nMax
					aAdd(aExcel, aClone(aAux[nI]))
				Next nI
			Else
				aAdd(aExcel, {MQRY->DOCUMENTO,MQRY->SERIE,TipoNF(MQRY->TIPO),STOD(MQRY->EMISSAO),STOD(MQRY->ENTRADA),MQRY->CLIEFOR,cCNPJ,cNome,MQRY->CFOP,MQRY->CC,MQRY->CCDESC,aTipo[nTipo],_cCta,_cDescCta,MQRY->VALOR,nValNota,_nVlrCta,MQRY->VALOR-_nVlrCta})
				CalcResumo(nTipo)
			EndIf
		Endif
   	
		TMPCT2->(dbCloseArea())
	Else
		aAdd(aExcel, {MQRY->DOCUMENTO, MQRY->SERIE, TipoNF(MQRY->TIPO), STOD(MQRY->EMISSAO), STOD(MQRY->ENTRADA), MQRY->CLIEFOR, MQRY->LOJA, cCNPJ, cNome, MQRY->CFOP, MQRY->CC, MQRY->CCDESC, aTipo[nTipo],_cCta,_cDescCta,MQRY->VALOR, nValNota})
		CalcResumo(nTipo)
	Endif	
	
	MQRY->(dbSkip())
EndDo 

MQRY->(dbCloseArea())

//imprimindo totais por CFOP e CC
IncProc('Totalizando por CFOP e CC..')
aAdd(aExcel, {''})
aAdd(aExcel, {'Totais por CFOP e Centro de Custo'})
aAdd(aExcel, {'CFOP', 'Centro de Custo', 'Descrição CC', 'Tipo de CC', 'Valor'})
aSort(aSomaCFC,,, {|x,y| x[1]+x[2] < y[1]+y[2] })
nMax := Len(aSomaCFC)
For nI := 1 to nMax
	nTipo := TipoCC(aSomaCFC[nI][2])
	aAdd(aExcel, {aSomaCFC[nI][1], aSomaCFC[nI][2], aSomaCFC[nI][3], aTipo[nTipo], aSomaCFC[nI][4]})
Next nI

//imprimindo totais por CC
IncProc('Totalizando por CC..')
aAdd(aExcel, {''})
aAdd(aExcel, {'Totais por Centro de Custo'})
aAdd(aExcel, {'Centro de Custo', 'Descrição CC', 'Tipo de CC', 'Valor'})
aSort(aSomaCC,,, {|x,y| x[1] < y[1] })
nMax := Len(aSomaCC)
For nI := 1 to nMax
	nTipo := TipoCC(aSomaCC[nI][1])
	aAdd(aExcel, {aSomaCC[nI][1], aSomaCC[nI][2], aTipo[nTipo], aSomaCC[nI][3]})
Next nI

//imprimindo totais por CFOP
IncProc('Totalizando por CFOP..')
aAdd(aExcel, {''})
aAdd(aExcel, {'Totais por CFOP'})
aAdd(aExcel, {'CFOP', 'Valor'})
nMax := Len(aSomaCF)
For nI := 1 to nMax
	aAdd(aExcel, {aSomaCF[nI][1], aSomaCF[nI][2]})
Next nI

//imprimindo totais por Tipo de CC
IncProc('Totalizando por Tipo de CC..')
aAdd(aExcel, {''})
aAdd(aExcel, {'Totais por Tipo de Centro de Custo'})
aAdd(aExcel, {'Tipo de CC', 'Valor'})
For nI := 1 to 3
	aAdd(aExcel, {aTipo[nI], aSoma[nI]})
Next nI

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

Static Function DetItem()

Local cQry := ""
Local cDesc
Local lCabec := .F.
Local aRet := {}
Local nTipoCC
Local lExibe
Local aAreas, aSvArea
Local cNat, cNatCOpe, cNatCAdm

cQry += CRLF + " SELECT DISTINCT"
cQry += CRLF + "        SD1.D1_COD     AS CODIGO"
cQry += CRLF + "       ,SD1.D1_DESCRIC AS DESC_D1"
cQry += CRLF + "       ,SB1.B1_DESC    AS DESC_B1"
cQry += CRLF + "       ,SB1.B1_DESC    AS DESC_B1"
cQry += CRLF + "       ,SB1.B1_GRUPO   AS GRUPO"
cQry += CRLF + "       ,SBM.BM_DESC    AS GRUPO_DESC"
cQry += CRLF + "       ,SB1.B1_GRPCTB  AS GRPCTB"
cQry += CRLF + "       ,SZ3.Z3_DESCGRP AS GRPCTB_DESC"
cQry += CRLF + "       ,SZ3.Z3_CTCUSTO AS CONTA_CUSTO"
cQry += CRLF + "       ,SZ3.Z3_CTDESP  AS CONTA_DESPESA"
cQry += CRLF + "       ,CT2.CT2_DEBITO AS CONTA_CONTABILIZADA"
cQry += CRLF + " FROM " + RetSqlName('SD1') + " SD1"
cQry += CRLF + " INNER JOIN " + RetSqlName('CV3') + " CV3"
cQry += CRLF + " ON  CV3.D_E_L_E_T_ <> '*' "
cQry += CRLF + " AND CV3.CV3_FILIAL = '" + xFilial("CV3") + "' "
cQry += CRLF + " AND CV3.CV3_TABORI = 'SF1' "
cQry += CRLF + " AND CONVERT(INT,CV3.CV3_RECORI) =  " + cValtoChar(_nRecSF1) + " "
cQry += CRLF + " AND CV3.CV3_DC IN ('1','3') "
If _nCntCv3 > 0
	cQry += CRLF + " AND SD1.D1_FILIAL  = SUBSTRING(CV3.CV3_KEY,1,2) "
	cQry += CRLF + " AND SD1.D1_DOC     = SUBSTRING(CV3.CV3_KEY,3,9) "
	cQry += CRLF + " AND SD1.D1_SERIE   = SUBSTRING(CV3.CV3_KEY,12,3) "
	cQry += CRLF + " AND SD1.D1_FORNECE = SUBSTRING(CV3.CV3_KEY,15,6) "
	cQry += CRLF + " AND SD1.D1_LOJA    = SUBSTRING(CV3.CV3_KEY,21,2) "
	cQry += CRLF + " AND SD1.D1_COD+SD1.D1_ITEM = SUBSTRING(CV3.CV3_KEY,23,19) "
Else
	cQry += CRLF + " AND SD1.D1_CC      = CV3.CV3_CCD"
	cQry += CRLF + " AND ROUND(SD1.D1_CUSTO+SD1.D1_VALDESC" + _cICMCOM + _cISS + ",2) = CV3.CV3_VLR01"
EndIf
cQry += CRLF + " INNER JOIN " + RetSqlName('CT2') + " CT2"
cQry += CRLF + " ON  CT2.D_E_L_E_T_ <> '*' "
cQry += CRLF + " AND CT2.CT2_FILIAL = '" + xFilial("CT2") + "' "
cQry += CRLF + " AND CV3.CV3_FILIAL = CT2.CT2_FILIAL "
cQry += CRLF + " AND CT2.R_E_C_N_O_ = CV3.CV3_RECDES "
cQry += CRLF + " AND CT2.CT2_DEBITO IN " + U_MyGeraIn(AllTrim(_cContas)) + " "
cQry += CRLF + " LEFT JOIN " + RetSqlName('SB1') + " SB1"
cQry += CRLF + " ON  SB1.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND SB1.B1_FILIAL = '" + xFilial("SB1")  + "'"
cQry += CRLF + " AND SB1.B1_COD = SD1.D1_COD"
cQry += CRLF + " LEFT JOIN " + RetSqlName('SBM') + " SBM"
cQry += CRLF + " ON  SBM.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND SBM.BM_FILIAL = '" + xFilial("SBM")  + "'"
cQry += CRLF + " AND SBM.BM_GRUPO = SB1.B1_GRUPO"
cQry += CRLF + " LEFT JOIN " + RetSqlName('SZ3') + " SZ3"
cQry += CRLF + " ON  SZ3.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND SZ3.Z3_FILIAL = '" + xFilial("SZ3")  + "'"
cQry += CRLF + " AND SZ3.Z3_COD = SB1.B1_GRPCTB"
cQry += CRLF + " WHERE SD1.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SD1.D1_FILIAL  = '" + xFilial("SD1")  + "' "
cQry += CRLF + "   AND SD1.D1_DOC     = '" + MQRY->DOCUMENTO + "' "
cQry += CRLF + "   AND SD1.D1_SERIE   = '" + MQRY->SERIE     + "' "
cQry += CRLF + "   AND SD1.D1_FORNECE = '" + MQRY->CLIEFOR   + "' "
cQry += CRLF + "   AND SD1.D1_LOJA    = '" + MQRY->LOJA      + "' "
cQry += CRLF + "   AND SD1.D1_CC      = '" + MQRY->CC        + "' "
cQry += CRLF + "   AND SD1.D1_CF      = '" + MQRY->CFOP      + "' "

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'DET',.T.)

nTipoCC := TipoCC(MQRY->CC)

aAreas := {'SE2','SED' }
aSvArea := U_MyArea(aAreas, .T.)

cNat := ''
cNatCOpe := ''
cNatCAdm := ''
SE2->(dbSetOrder(6))
If SE2->(dbSeek( xFilial('SE2') + MQRY->CLIEFOR + MQRY->LOJA + MQRY->SERIE + MQRY->DOCUMENTO ))
	cNat := SE2->E2_NATUREZ
	SED->(dbSetOrder(1))
	If SED->(dbSeek( xFilial('SED') + cNat ))
		cNatDesc := AllTrim(SED->ED_DESCRIC)
		cNatCOpe := AllTrim(SED->ED_CONTAC)
		cNatCAdm := AllTrim(SED->ED_CONTA)
	EndIf
	cNat := AllTrim(cNat)
EndIf

U_MyArea(aSvArea, .F.)
	
While !DET->(Eof())
	lExibe := .F.
	If nTipoCC == 1
		If AllTrim(DET->CONTA_CONTABILIZADA) <> AllTrim(DET->CONTA_DESPESA)
			lExibe := .T.
		EndIf
		If cNatCAdm <> '' .and. AllTrim(DET->CONTA_CONTABILIZADA) <> cNatCAdm
			lExibe := .T.
		EndIf
	ElseIf nTipoCC == 2
		If AllTrim(DET->CONTA_CONTABILIZADA) <> AllTrim(DET->CONTA_CUSTO)
			lExibe := .T.
		EndIf
		If cNatCOpe <> '' .and. AllTrim(DET->CONTA_CONTABILIZADA) <> cNatCOpe
			lExibe := .T.
		EndIf
	EndIf
	
	If lExibe	
		If !lCabec
			aAdd(aRet, {'','Produto','Descrição','Grupo Materiais','Descrição','Grupo Contábil PRODUTO','Descrição','Conta Custo','Conta Despesa','Natureza TÍTULO','Descrição','Conta Custo','Conta Despesa','','Conta Contabilizada','NOVO GRUPO CONTÁBIL'})
			lCabec := .T.
		EndIf
		cDesc := AllTrim(DET->DESC_B1)
		If cDesc == ''
			cDesc := AllTrim(DET->DESC_D1)
		EndIf
		aAdd(aRet, {'',DET->CODIGO,cDesc,DET->GRUPO,AllTrim(DET->GRUPO_DESC),DET->GRPCTB,AllTrim(DET->GRPCTB_DESC),AllTrim(DET->CONTA_CUSTO),AllTrim(DET->CONTA_DESPESA),cNat,cNatDesc,cNatCOpe,cNatCAdm,'',AllTrim(DET->CONTA_CONTABILIZADA)})
	EndIf
	DET->(dbSkip())
EndDo

DET->(dbCloseArea())

Return aClone(aRet)

/* -------------- */

Static Function CalcResumo(nTipo)
//somando por Tipo de CC
aSoma[nTipo] += MQRY->VALOR
		
//somando por CC
nPos := aScan(aSomaCC, {|x| x[1] == MQRY->CC})
If nPos > 0
	aSomaCC[nPos][3] += MQRY->VALOR
Else
	aAdd(aSomaCC, {MQRY->CC, MQRY->CCDESC, MQRY->VALOR})
EndIf
		
//somando por CFOP e CC
nPos := aScan(aSomaCFC, {|x| x[1] == MQRY->CFOP .and. x[2] == MQRY->CC})
If nPos > 0
	aSomaCFC[nPos][4] += MQRY->VALOR
Else
	aAdd(aSomaCFC, {MQRY->CFOP, MQRY->CC, MQRY->CCDESC, MQRY->VALOR})
EndIf
		
//somando por CFOP
nPos := aScan(aSomaCF, {|x| x[1] == MQRY->CFOP})
If nPos > 0
	aSomaCF[nPos][2] += MQRY->VALOR
Else
	aAdd(aSomaCF, {MQRY->CFOP, MQRY->VALOR})
EndIf
Return()

/* -------------- */

Static Function TipoCC(cCC)

Local nRet   := 0
Local cCCAdm := MV_PAR05
Local cCCOpe := MV_PAR06

cCC := AllTrim(cCC)
If cCC <> ''
	If Left(cCC, 3) $ cCCAdm
		nRet := 1
	ElseIf Left(cCC, 3) $ cCCOpe
		nRet := 2
	Else
		nRet := 3
	EndIf
Else
	nRet := 3
EndIf

Return nRet

/* -------------- */

Static Function TipoNF(cTipo)

Local cRet  := ''
Local aTipo := {;
	{'N','Normal'},;
	{'D','Devolução'},;
	{'I','Compl. ICMS'},;
	{'P','Compl. IPI'},;
	{'C','Compl. Preço/Frete'},;
	{'B','Beneficiamento'};
}
Local nPos

nPos := aScan(aTipo, {|x| x[1] == cTipo})
If nPos > 0
	cRet := aTipo[nPos][2]
EndIf

Return cRet

/* -------------- */

Static Function CriaSX1(cPerg)

Local nTamGrp := Len(SX1->X1_GRUPO)
Local aHelpPor := {}, aHelpEng := {}, aHelpSpa := {}
Local cNome

aHelpPor := {}
aAdd(aHelpPor, 'Informe a data inicial/final para    ')
aAdd(aHelpPor, 'geração do relatório.                ')
cNome := 'Data inicial'
PutSx1(PadR(cPerg,nTamGrp), '01', cNome, cNome, cNome,;
'MV_CH1', 'D', 8, 0, 0, 'G', '', '', '', '', 'MV_PAR01',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

cNome := 'Data final'
PutSx1(PadR(cPerg,nTamGrp), '02', cNome, cNome, cNome,;
'MV_CH2', 'D', 8, 0, 0, 'G', '', '', '', '', 'MV_PAR02',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Selecione se deseja imprimir o livro ')
aAdd(aHelpPor, 'de entrada ou saída.                 ')
cNome := 'Livro'
PutSx1(PadR(cPerg,nTamGrp), '03', cNome, cNome, cNome,;
'MV_CH3', 'C', 1, 0, 0, 'C', '', '', '', '', 'MV_PAR03',;
'Entrada', 'Entrada', 'Entrada', '1',;
'Saida', 'Saida', 'Saida',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Selecione se deseja considerar a data')
aAdd(aHelpPor, 'de entrada ou emissão da nota fiscal.')
cNome := 'Considera'
PutSx1(PadR(cPerg,nTamGrp), '04', cNome, cNome, cNome,;
'MV_CH4', 'C', 1, 0, 0, 'C', '', '', '', '', 'MV_PAR04',;
'Data de Entrada', 'Data de Entrada', 'Data de Entrada', '1',;
'Data de Emissão', 'Data de Emissão', 'Data de Emissão',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe os 3 primeiros caracteres    ')
aAdd(aHelpPor, 'dos Centros de Custo administrativos ')
aAdd(aHelpPor, 'separados por ponto e vírgula (;).   ')
aAdd(aHelpPor, 'Ex: 101;102;204;305                  ')
cNome := 'CC Administrativo'
PutSx1(PadR(cPerg,nTamGrp), '05', cNome, cNome, cNome,;
'MV_CH5', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR05',;
'', '', '', '101;206;207;303',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe os 3 primeiros caracteres    ')
aAdd(aHelpPor, 'dos Centros de Custo operacionais    ')
aAdd(aHelpPor, 'separados por ponto e vírgula (;).   ')
aAdd(aHelpPor, 'Ex: 101;102;204;305                  ')
cNome := 'CC Operacional'
PutSx1(PadR(cPerg,nTamGrp), '06', cNome, cNome, cNome,;
'MV_CH6', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR06',;
'', '', '', '102;103;104;201;202;204;205;301;302',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe os CFOPs separados por ponto ')
aAdd(aHelpPor, 'e vígula (;) a serem listados no     ')
aAdd(aHelpPor, 'relatório. Deixe em branco para      ')
aAdd(aHelpPor, 'considerar todos.                    ')
cNome := 'CFOPs'
PutSx1(PadR(cPerg,nTamGrp), '07', cNome, cNome, cNome,;
'MV_CH7', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR07',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe as contas contabeis          ')
aAdd(aHelpPor, 'separadas por ponto e vírgula (;).   ')
aAdd(aHelpPor, 'Ex: 101;102;204;305                  ')
cNome := 'Contas Contabeis'
PutSx1(PadR(cPerg,nTamGrp), '08', cNome, cNome, cNome,;
'MV_CH8', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR08',;
'', '', '', '313020005;313020008;313020009;313020010;313030004;313030006;',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe as contas contabeis          ')
aAdd(aHelpPor, 'separadas por ponto e vírgula (;).   ')
aAdd(aHelpPor, 'Ex: 101;102;204;305                  ')
cNome := 'Contas Contabeis 2' 
PutSx1(PadR(cPerg,nTamGrp), '09', cNome, cNome, cNome,;
'MV_CH9', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR09',;
'', '', '', '313030010;313030012;313030019;313020007;',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe as contas contabeis          ')
aAdd(aHelpPor, 'separadas por ponto e vírgula (;).   ')
aAdd(aHelpPor, 'Ex: 101;102;204;305                  ')
cNome := 'Contas Contabeis 3' 
PutSx1(PadR(cPerg,nTamGrp), '10', cNome, cNome, cNome,;
'MV_CHA', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR10',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe se deseja exibir somente as  ')
aAdd(aHelpPor, 'notas que possuem produtos           ')
aAdd(aHelpPor, 'contabilizados em contas contábeis   ')
aAdd(aHelpPor, 'diferentes das especificadas no grupo')
aAdd(aHelpPor, 'contábil do produto, conforme o CC.  ')
cNome := 'Detalhar por produto' 
PutSx1(PadR(cPerg,nTamGrp), '11', cNome, cNome, cNome,;
'MV_CHB', 'N', 1, 0, 1, 'C', '', '', '', '', 'MV_PAR11',;
'Sim', 'Sim', 'Sim', '',;
'Não', 'Não', 'Não',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
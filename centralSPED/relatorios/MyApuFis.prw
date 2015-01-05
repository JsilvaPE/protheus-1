#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyApuFis()

Local cTitulo := 'Relatório Entrada/Saída X CST X CFOP'
Local cPerg   := '#MyApuFis'
Local aArea := GetArea()

CriaSX1(cPerg)

If !Pergunte(cPerg, .T., cTitulo)
	Return Nil
End If
Processa({|| Executa(cTitulo) },cTitulo,'Selecionando registros...')

RestArea(aArea)

Return Nil

/* -------------- */

Static Function Executa(cTitulo)

Local nI
Local nMax
Local nPos
Local nTipo
Local nCount
Local nTotal
Local cQry
Local cQry2
Local cRet
Local cAux
Local cArq      := 'ESxCFO'
Local aExcel    := {}
Local aAux      := {}
Local aTipo     := {'Administrativo', 'Operacional', 'Não classificado'}
Local nValNota  := 0                    
Local _nRecSF1  := 0
Local _cCta     := ""	   
Local _cDescCta := ""	   
Local _cContas  := ""
Local _nVlrCta  := 0.00
Local _cDoc		 := ""
Local _cFornece := ""
Local _cLoja    := ""
Local _nCntCv3  := 0
Local _cICMCOM  := ''
Local _cISS     := ''
Local _cCodPro	 := ""
Local _cDesPro	 := ""
Local _cNCM 	 := ""

Private aSoma     := {0,0,0}
Private aSomaCC   := {}
Private aSomaCFC  := {}
Private aSomaCF   := {} 


Private _nVALCONT := 0.00
Private _nBASEICM := 0.00
Private _nVALICM  := 0.00
Private _nBASERET := 0.00
Private _nICMSRET := 0.00
Private _nBASEPIS := 0.00
Private _nVALPIS  := 0.00
Private _nBASECOF := 0.00
Private _nVALCOF  := 0.00

ProcRegua(0)

aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em ' + DTOC(Date()) + ' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Empresa: ' + Alltrim(SM0->M0_NOME) + '-' + Alltrim(SM0->M0_FILIAL)})
aAdd(aExcel, {'Periodo de: ' + DTOC(MV_PAR01) + ' ate:' + DTOC(MV_PAR02)})

aAdd(aExcel, {''})

cQry := ''
cQry += CRLF + "SELECT "
cQry += CRLF + "	FT_CLASFIS "
cQry += CRLF + "	,FT_CFOP "
cQry += CRLF + "	,FT_ALIQICM "
cQry += CRLF + "	,SUM(FT_VALCONT) AS FT_VALCONT "
cQry += CRLF + "	,SUM(FT_BASEICM) AS FT_BASEICM "
cQry += CRLF + "	,SUM(FT_VALICM)  AS FT_VALICM "
cQry += CRLF + "	,SUM(FT_BASERET) AS FT_BASERET "
cQry += CRLF + "	,SUM(FT_ICMSRET) AS FT_ICMSRET "
cQry += CRLF + "	,SUM(FT_BASEPIS) AS FT_BASEPIS "
cQry += CRLF + "	,SUM(FT_VALPIS)  AS FT_VALPIS "
cQry += CRLF + "	,SUM(FT_BASECOF) AS FT_BASECOF "
cQry += CRLF + "	,SUM(FT_VALCOF)  AS FT_VALCOF "
cQry += CRLF + "FROM "
cQry += CRLF + "	" + RETSQLNAME("SFT") + " "
cQry += CRLF + "WHERE "
cQry += CRLF + "	D_E_L_E_T_ <> '*' " 
cQry += CRLF + "	AND FT_FILIAL = '" + XFILIAL("SFT") + "' "
cQry += CRLF + "	AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
cQry += CRLF + "  AND FT_TIPO <> 'S' "
cQry += CRLF + "  AND LEN(FT_DTCANC) = 0"
cQry += CRLF + "  AND FT_OBSERV NOT LIKE '%INUTIL%'"
cQry += CRLF + "  AND FT_OBSERV NOT LIKE '%CANCEL%'"

If MV_PAR03 == 1 // ENTRADAS
	cQry += CRLF + "	AND FT_CFOP < '5000' "
Elseif MV_PAR03 == 2 // SAIDAS
	cQry += CRLF + "	AND FT_CFOP >= '5000' "
Endif

cQry += CRLF + "GROUP BY "
cQry += CRLF + "	FT_CLASFIS "
cQry += CRLF + "	,FT_CFOP "
cQry += CRLF + "	,FT_ALIQICM "
cQry += CRLF + "ORDER BY "
cQry += CRLF + "	FT_CLASFIS "
cQry += CRLF + "	,FT_CFOP "
cQry += CRLF + "	,FT_ALIQICM "
                  
cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY',.T.)

nTotal := 0
nCount := 0

MQRY->(dbEval({||nTotal++}))

ProcRegua(nTotal+3)

MQRY->(dbGoTop())

If MV_PAR04 == 2
	aAdd(aExcel, {'CST/ICMS','CFOP','Aliquota ICMS','Total Operacao','Base ICMS','Total ICMS','Base ICMS ST','Total ICMS ST','Base PIS','Total PIS','Base COFINS','Total COFINS'})
Else
	aAdd(aExcel, {'CST/ICMS','CFOP','Aliquota ICMS','Total Operacao','Base ICMS','Total ICMS','Base ICMS ST','Total ICMS ST','Base PIS','TOtal PIS','Base COFINS','Total COFINS','Produto','Descrição','NCM'})
Endif

// Primeiro Laco -- Entradas
_nVALCONT := 0.00
_nBASEICM := 0.00
_nVALICM  := 0.00
_nBASERET := 0.00
_nICMSRET := 0.00
_nBASEPIS := 0.00
_nVALPIS  := 0.00
_nBASECOF := 0.00
_nVALCOF  := 0.00

MQRY->(dbGotop())
While !MQRY->(Eof())
	If MQRY->FT_CFOP < '5000'
		nCount++
		IncProc('Analisando registro ' + cValToChar(nCount) + '/' + cValToChar(nTotal) + '..')
	
		aAdd(aExcel, {MQRY->FT_CLASFIS, MQRY->FT_CFOP, MQRY->FT_ALIQICM, MQRY->FT_VALCONT, MQRY->FT_BASEICM, MQRY->FT_VALICM, MQRY->FT_BASERET, MQRY->FT_ICMSRET, MQRY->FT_BASEPIS, MQRY->FT_VALPIS, MQRY->FT_BASECOF, MQRY->FT_VALCOF})

		_nVALCONT += MQRY->FT_VALCONT
		_nBASEICM += MQRY->FT_BASEICM
		_nVALICM  += MQRY->FT_VALICM
		_nBASERET += MQRY->FT_BASERET
		_nICMSRET += MQRY->FT_ICMSRET
		_nBASEPIS += MQRY->FT_BASEPIS
		_nVALPIS  += MQRY->FT_VALPIS
		_nBASECOF += MQRY->FT_BASECOF
		_nVALCOF  += MQRY->FT_VALCOF
	
		If MV_PAR04 == 2
			cQry2 := ""
			cQry2 += CRLF + "SELECT "
			cQry2 += CRLF + "   * "
			cQry2 += CRLF + "FROM "
			cQry2 += CRLF + "   " + RetSQLName("SFT") + " "
			cQry2 += CRLF + "WHERE "
			cQry2 += CRLF + "   D_E_L_E_T_<>'*' "
			cQry2 += CRLF + "   AND FT_FILIAL  = '" + xFilial("SFT") + "' "
			cQry2 += CRLF + "   AND FT_CLASFIS = '" + MQRY->FT_CLASFIS + "' "
		   cQry2 += CRLF + "   AND FT_CFOP    = '" + MQRY->FT_CFOP    + "' "
		   cQry2 += CRLF + "   AND FT_ALIQICM =  " + STR(MQRY->FT_ALIQICM) + " "
		   cQry2 += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
			cQry2 += CRLF + "   AND FT_TIPO <> 'S' "
			cQry2 += CRLF + "   AND LEN(FT_DTCANC) = 0"
			cQry2 += CRLF + "   AND FT_OBSERV NOT LIKE '%INUTIL%'"
			cQry2 += CRLF + "   AND FT_OBSERV NOT LIKE '%CANCEL%'"
			cQry2 += CRLF + "ORDER BY "
			cQry2 += CRLF + "   FT_NFISCAL "
			cQry2 += CRLF + "   ,FT_SERIE "
		
			cQry2 := ChangeQuery(cQry2)
			dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry2),'MQRY2',.T.)
		
			Do While !MQRY2->(EOF())                                                       
				_cCodPro	 := Posicione("SB1",1,xFilial("SB1") + MQRY2->FT_PRODUTO,"B1_COD")
				_cDesPro	 := Posicione("SB1",1,xFilial("SB1") + MQRY2->FT_PRODUTO,"B1_DESC") 
				_cNCM 	 := Posicione("SB1",1,xFilial("SB1") + MQRY2->FT_PRODUTO,"B1_POSIPI")
				
				aAdd(aExcel, {'', MQRY2->FT_NFISCAL, MQRY2->FT_SERIE, MQRY2->FT_VALCONT, MQRY2->FT_BASEICM, MQRY2->FT_VALICM, MQRY2->FT_BASERET, MQRY2->FT_ICMSRET, MQRY2->FT_BASEPIS, MQRY2->FT_VALPIS, MQRY2->FT_BASECOF, MQRY2->FT_VALCOF, Alltrim(_cCodPro),Alltrim(_cDesPro),Alltrim(_cNCM)})
				
				MQRY2->(dbSkip())	
			Enddo
	
			aAdd(aExcel, {'','','','','','','','','','','',''})
	
			MQRY2->(dbCloseArea())
		Endif
	Endif

	MQRY->(dbSkip())
EndDo 

If MV_PAR03 <> 2 // SAÍDAS
	aAdd(aExcel, {"TOTAL ENTRADAS:",'','',_nVALCONT,_nBASEICM,_nVALICM,_nBASERET,_nICMSRET,_nBASEPIS,_nVALPIS,_nBASECOF,_nVALCOF})
	aAdd(aExcel, {'','','','','','','','','','','',''})
EndIf

// Primeiro Laco -- Saidas
_nVALCONT := 0.00
_nBASEICM := 0.00
_nVALICM  := 0.00
_nBASERET := 0.00
_nICMSRET := 0.00
_nBASEPIS := 0.00
_nVALPIS  := 0.00
_nBASECOF := 0.00
_nVALCOF  := 0.00

MQRY->(dbGotop())
While !MQRY->(Eof())
	If MQRY->FT_CFOP >= '5000'
		nCount++
		IncProc('Analisando registro ' + cValToChar(nCount) + '/' + cValToChar(nTotal) + '..')
	
		aAdd(aExcel, {MQRY->FT_CLASFIS, MQRY->FT_CFOP, MQRY->FT_ALIQICM, MQRY->FT_VALCONT, MQRY->FT_BASEICM, MQRY->FT_VALICM, MQRY->FT_BASERET, MQRY->FT_ICMSRET, MQRY->FT_BASEPIS, MQRY->FT_VALPIS, MQRY->FT_BASECOF, MQRY->FT_VALCOF})

		_nVALCONT += MQRY->FT_VALCONT
		_nBASEICM += MQRY->FT_BASEICM
		_nVALICM  += MQRY->FT_VALICM
		_nBASERET += MQRY->FT_BASERET
		_nICMSRET += MQRY->FT_ICMSRET
		_nBASEPIS += MQRY->FT_BASEPIS
		_nVALPIS  += MQRY->FT_VALPIS
		_nBASECOF += MQRY->FT_BASECOF
		_nVALCOF  += MQRY->FT_VALCOF
	
		If MV_PAR04 == 2
			cQry2 := ""
			cQry2 += CRLF + "SELECT "
			cQry2 += CRLF + "   * "
			cQry2 += CRLF + "FROM "
			cQry2 += CRLF + "   " + RetSQLName("SFT") + " "
			cQry2 += CRLF + "WHERE "
			cQry2 += CRLF + "   D_E_L_E_T_<>'*' "
			cQry2 += CRLF + "   AND FT_FILIAL  = '" + xFilial("SFT") + "' "
			cQry2 += CRLF + "   AND FT_CLASFIS = '" + MQRY->FT_CLASFIS + "' "
		   cQry2 += CRLF + "   AND FT_CFOP    = '" + MQRY->FT_CFOP    + "' "
		   cQry2 += CRLF + "   AND FT_ALIQICM =  " + STR(MQRY->FT_ALIQICM) + " "
		   cQry2 += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
			cQry2 += CRLF + "   AND FT_TIPO <> 'S' "
			cQry2 += CRLF + "   AND LEN(FT_DTCANC) = 0"
			cQry2 += CRLF + "   AND FT_OBSERV NOT LIKE '%INUTIL%'"
			cQry2 += CRLF + "   AND FT_OBSERV NOT LIKE '%CANCEL%'"
			cQry2 += CRLF + "ORDER BY "
			cQry2 += CRLF + "   FT_NFISCAL "
			cQry2 += CRLF + "   ,FT_SERIE "
		
			cQry2 := ChangeQuery(cQry2)
			dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry2),'MQRY2',.T.)
		
			Do While !MQRY2->(EOF())                                                       
				_cCodPro	 := Posicione("SB1",1,xFilial("SB1") + MQRY2->FT_PRODUTO,"B1_COD")
				_cDesPro	 := Posicione("SB1",1,xFilial("SB1") + MQRY2->FT_PRODUTO,"B1_DESC") 
				_cNCM 	 := Posicione("SB1",1,xFilial("SB1") + MQRY2->FT_PRODUTO,"B1_POSIPI")
				
				aAdd(aExcel, {'', MQRY2->FT_NFISCAL, MQRY2->FT_SERIE, MQRY2->FT_VALCONT, MQRY2->FT_BASEICM, MQRY2->FT_VALICM, MQRY2->FT_BASERET, MQRY2->FT_ICMSRET, MQRY2->FT_BASEPIS, MQRY2->FT_VALPIS, MQRY2->FT_BASECOF, MQRY2->FT_VALCOF, Alltrim(_cCodPro),Alltrim(_cDesPro),Alltrim(_cNCM)})
				
				MQRY2->(dbSkip())	
			Enddo
	
			aAdd(aExcel, {'','','','','','','','','','','',''})
	
			MQRY2->(dbCloseArea())
		Endif
	Endif

	MQRY->(dbSkip())
EndDo 

If MV_PAR03 <> 1 // ENTRADAS
	aAdd(aExcel, {"TOTAL SAIDAS:",'','',_nVALCONT,_nBASEICM,_nVALICM,_nBASERET,_nICMSRET,_nBASEPIS,_nVALPIS,_nBASECOF,_nVALCOF})
	aAdd(aExcel, {'','','','','','','','','','','',''})
EndIf

MQRY->(dbCloseArea())

/*
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
*/

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
'Ambos', 'Ambos', 'Ambos',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Selecione se deseja considerar a data')
aAdd(aHelpPor, 'de entrada ou emissão da nota fiscal.')
cNome := 'Tipo de relatorio'
PutSx1(PadR(cPerg,nTamGrp), '04', cNome, cNome, cNome,;
'MV_CH4', 'C', 1, 0, 0, 'C', '', '', '', '', 'MV_PAR04',;
'Sintetico', 'Sintetico', 'Sintetico', '1',;
'Analitico', 'Analitico', 'Analitico',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))
                                    
/*
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
*/
Return Nil
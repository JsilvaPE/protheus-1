#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyFIXFT()
///////////////////////////////////////////////////////////////////////////////
// Data : 30/04/2014
// User : Walber Freire
// Desc : Compara SFI com SFT
// Ação : A rotina compara os registros das tabelas SFI e SFT
//        e exporta o resultado para o excel.
///////////////////////////////////////////////////////////////////////////////

Local cTitulo := 'Comparação Red. Z x Cupom (SFI x SFT x SD2)'
Local cPerg := '#MyFIFTD2'

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
ElseIf MV_PAR03 == Nil .or. MV_PAR03 == '' .or. MV_PAR04 == Nil .or. MV_PAR04 == ''
	Alert('Informe a(s) filal(is) para a geração do relatório.')
	Return Nil
ElseIf MV_PAR03 > MV_PAR04
	Alert('A filial final deve ser maior que a filial inicial.')
	Return Nil
EndIf

MsAguarde({|| Executa(cTitulo) },cTitulo,'Aguarde...')

Return Nil

/* -------------- */

Static Function Executa(cTitulo)

Local nI, nMax, nX, nCtrl
Local nSomaFi, nSomaFt, nSomaD2, nSomaDFt, nSomaDD2
Local nSomaDFi, nSomaDFt, nSomaDD2, nSomaDDFt, nSomaDDD2
Local cQry
Local cRet, cAux
Local cArq := 'FIxFTxD2'
Local aDados := {}
Local aFI := {}
Local aFT := {}
Local aD2 := {}
Local aExcel := {}
Local aAux   := {}
//Local aDifs  := {aDifFI, aDifFT}

Local cPriNFis := ''
Local cUltNFis := ''
Local cPriDoc := ''
Local cUltDoc := ''

Local nValFt := 0
Local nValD2 := 0
Local nValDFt := 0
Local nValDD2 := 0

Local cDatAt := ''
Local cDatAn := ''

Local dMyData
Local dMydataAte
//SET DATE FORMAT("DD/MM/YYYY")

dMyData    := MV_PAR01
dMyDataAte := MV_PAR02

nSomaFi  := 0
nSomaFt  := 0
nSomaD2  := 0
nSomaDFt := 0
nSomaDD2 := 0

nSomaDFi  := 0
nSomaDFt  := 0
nSomaDD2  := 0
nSomaDDFt := 0
nSomaDDD2 := 0

aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Período: '+DTOC(MV_PAR01)+' até '+DTOC(MV_PAR02)+' - Filial: '+MV_PAR03+' até '+MV_PAR04})
aAdd(aExcel, {''})
           //{ FILIAL , DATA  ,  PDV ,  NUMREDZ   ,  SERPDV) , Val FI ,  Val FT ,  Val D2 , 'FI-FT', 'FI-D2', 'MINNFIS' , 'MAXNFIS' , 'MINDOC', 'MAXDOC'})
aAdd(aExcel, {'FILIAL', 'DATA', 'PDV', 'Num RED Z', 'NUM ECF','Val FI', 'Val FT', 'Val D2', 'FI-FT', 'FI-D2', 'NFIS DE' , 'NFIS ATE', 'DOC DE', 'DOC ATE'})


While dMyData <= dMyDataAte
	cQry := " SELECT FI_FILIAL, FI_DTMOVTO, FI_PDV, FI_NUMERO, FI_NUMREDZ, FI_SERPDV, FI_NUMINI, FI_NUMFIM, ROUND(SUM(FI_VALCON),2) VALCONT "
	cQry += " FROM "+RetSqlName('SFI')
	cQry += " WHERE FI_DTMOVTO = '"+DTOS(dMyData)+"'"
	cQry += "   AND D_E_L_E_T_ <> '*'"
	cQry += "   AND FI_FILIAL >= '"+MV_PAR03+"'"
	cQry += "   AND FI_FILIAL <= '"+MV_PAR04+"'"
	cQry += " GROUP BY FI_FILIAL, FI_DTMOVTO, FI_PDV, FI_NUMERO, FI_NUMREDZ, FI_SERPDV, FI_NUMINI, FI_NUMFIM"
	cQry += " ORDER BY FI_FILIAL, FI_DTMOVTO, FI_PDV, FI_NUMERO, FI_NUMREDZ"
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSFI',.T.)	
	While !SSFI->(Eof())
		aAdd(aDados, {AllTrim(SSFI->FI_FILIAL), AllTrim(SSFI->FI_DTMOVTO), AllTrim(SSFI->FI_PDV), AllTrim(SSFI->FI_NUMREDZ), AllTrim(SSFI->FI_SERPDV), SSFI->VALCONT, 0, 0, '', '', '', ''})
		SSFI->(DBSKIP())
	EndDo
	SSFI->(dbCloseArea())
	
	cQry := " SELECT FT_FILIAL, FT_ENTRADA, FT_PDV, ROUND(SUM(VALCONT),2) AS VALCONT, MIN(SSFT.FT_NFISCAL) AS MINNFIS, MAX(SSFT.FT_NFISCAL) AS MAXNFIS FROM"
	cQry += " (SELECT FT_FILIAL, FT_ENTRADA, FT_PDV, FT_NFISCAL, ROUND(SUM(FT_VALCONT),2) VALCONT "
	cQry += " FROM "+RetSqlName('SFT')
	cQry += " WHERE FT_ENTRADA = '"+DTOS(dMyData)+"'"
	cQry += "   AND LEFT(FT_CFOP,1) >= '5'"
	cQry += "   AND D_E_L_E_T_ <> '*'"
	cQry += "   AND FT_FILIAL >= '"+MV_PAR03+"'"
	cQry += "   AND FT_FILIAL <= '"+MV_PAR04+"'"
	cQry += "   AND FT_TIPO <> 'S'"
	cQry += "   AND FT_ESPECIE = 'CF   '"
	cQry += " GROUP BY FT_FILIAL, FT_ENTRADA, FT_PDV, FT_NFISCAL) AS SSFT"
	cQry += " GROUP BY SSFT.FT_FILIAL, SSFT.FT_ENTRADA, SSFT.FT_PDV"
	cQry += " ORDER BY SSFT.FT_FILIAL, SSFT.FT_ENTRADA, SSFT.FT_PDV"
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSFT',.T.)	
	While !SSFT->(Eof())
		_nPos := aScan(aDados, {|x| x[1]+x[2]+X[3] == AllTrim(SSFT->FT_FILIAL)+AllTrim(SSFT->FT_ENTRADA)+AllTrim(SSFT->FT_PDV)})
		If _nPos > 0
			aDados[_nPos][7]  := SSFT->VALCONT
			aDados[_nPos][9]  := AllTrim(SSFT->MINNFIS)
			aDados[_nPos][10] := AllTrim(SSFT->MAXNFIS)
   	Else
			aAdd(aDados, {AllTrim(SSFT->FT_FILIAL), AllTrim(SSFT->FT_ENTRADA), AllTrim(SSFT->FT_PDV), '', '', 0, SSFT->VALCONT, 0, AllTrim(SSFT->MINNFIS), AllTrim(SSFT->MAXNFIS), '', ''})
		EndIf		
		SSFT->(DBSKIP())
	EndDo
	SSFT->(dbCloseArea())
	
	cQry := " SELECT SSD2.D2_FILIAL, SSD2.D2_EMISSAO, SSD2.D2_PDV, ROUND(SUM(SSD2.VALCONT),2) AS VALCONT, MIN(SSD2.D2_DOC) AS MINDOC, MAX(SSD2.D2_DOC) AS MAXDOC FROM "
	cQry += " (SELECT D2_FILIAL, D2_EMISSAO, D2_PDV, D2_DOC, ROUND(SUM(D2_TOTAL),2) VALCONT "
	cQry += " FROM "+RetSqlName('SD2')
	cQry += " WHERE D2_EMISSAO = '"+DTOS(dMyData)+"'"
	cQry += "   AND LEFT(D2_CF,1) >= '5'"
	cQry += "   AND D_E_L_E_T_ <> '*'"
	cQry += "   AND D2_FILIAL >= '"+MV_PAR03+"'"
	cQry += "   AND D2_FILIAL <= '"+MV_PAR04+"'"
	cQry += "   AND D2_TIPO <> 'S'"
	//cQry += "   AND D2_ESPECIE = 'CF   '
	cQry += " GROUP BY D2_FILIAL, D2_EMISSAO, D2_PDV, D2_DOC) AS SSD2"
	cQry += " GROUP BY SSD2.D2_FILIAL, SSD2.D2_EMISSAO, SSD2.D2_PDV"
	cQry += " ORDER BY SSD2.D2_FILIAL, SSD2.D2_EMISSAO, SSD2.D2_PDV"
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSD2',.T.)	
	While !SSD2->(Eof())
		_nPos := aScan(aDados, {|x| x[1]+x[2]+X[3] == AllTrim(SSD2->D2_FILIAL)+AllTrim(SSD2->D2_EMISSAO)+AllTrim(SSD2->D2_PDV)})
		If _nPos > 0
			aDados[_nPos][8]  := SSD2->VALCONT
			aDados[_nPos][11]  := AllTrim(SSD2->MINDOC)
			aDados[_nPos][12] := AllTrim(SSD2->MAXDOC)
   	Else
			aAdd(aDados, {AllTrim(SSD2->D2_FILIAL), AllTrim(SSD2->D2_EMISSAO), AllTrim(SSD2->D2_PDV), '', '', 0, 0, SSD2->VALCONT, '', '', AllTrim(SSD2->MINDOC), AllTrim(SSD2->MAXDOC)})
		EndIf		
		SSD2->(DBSKIP())
	EndDo
	SSD2->(dbCloseArea())
	dMyData := dMyData + 1	
EndDo

//aSort(aDados,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]})

If MV_PAR05 == 1 
	PorData(aDados, aExcel)
Else
	PorPDV(aDados, aExcel)
EndIf

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

/*----------------*/

Static Function PorData(aDados, aExcel)
Local nSomaFI := 0
Local nSomaFT := 0
Local nSomaD2 := 0
Local nDifFT  := 0
Local nDifD2  := 0

Local nSomaTFI := 0
Local nSomaTFT := 0
Local nSomaTD2 := 0
Local nDifTFT  := 0
Local nDifTD2  := 0

for i:=1 to Len(aDados)
	If i == 1
		_cNoFil := aDados[i][1]
		_cAtFil := _cNoFil
	EndIf
   _cNoFil := aDados[i][1]
   If _cNoFil <> _cAtFil
		//aAdd(aExcel, {'', '', '', '', 'TOTAL:',nSomaFI, nSomaFT, nSomaD2, nDifFT, nDifD2, '' , '', '', ''})
		aAdd(aExcel, {'','','','','','','','','','','','','',''})
		aAdd(aExcel, {'','','','','','','','','','','','','',''})
		aAdd(aExcel, {'','','','','','','','','','','','','',''})
		aAdd(aExcel, {'','','','','','','','','','','','','',''})
		aAdd(aExcel, {'FILIAL', 'DATA', 'PDV', 'Num RED Z', 'NUM ECF','Val FI', 'Val FT', 'Val D2', 'FI-FT', 'FI-D2', 'NFIS DE' , 'NFIS ATE', 'DOC DE', 'DOC ATE'})   	
		
		nSomaTFI += nSomaFI
		nSomaTFT += nSomaFT
		nSomaTD2 += nSomaD2
		nDifTFT  += nDifFT
		nDifTD2  += nDifD2
		
		nSomaFI := 0
		nSomaFT := 0
		nSomaD2 := 0
		nDifFT  := 0
		nDifD2  := 0
		   	
   	_cAtFil := _cNoFil
   EndIf
            //{ FILIAL      , DATA        ,  PDV        ,  NUMREDZ    ,  SERPDV)    , Val FI      , Val FT      , Val D2      , FI-FT                    , FI-D2                    , MINNFIS     , MAXNFIS      , MINDOC       , MAXDOC      })
	aAdd(aExcel, {aDados[i][1], aDados[i][2], aDados[i][3], aDados[i][4], aDados[i][5], aDados[i][6], aDados[i][7], aDados[i][8], aDados[i][6]-aDados[i][7], aDados[i][6]-aDados[i][8], aDados[i][9], aDados[i][10], aDados[i][11], aDados[i][12]})
	nSomaFI += aDados[i][6]
	nSomaFT += aDados[i][7]
	nSomaD2 += aDados[i][8]
	nDifFT  += aDados[i][6]-aDados[i][7]
	nDifD2  += aDados[i][6]-aDados[i][8]	
Next i
//aAdd(aExcel, {'', '', '', '', 'TOTAL:',nSomaFI, nSomaFT, nSomaD2, nDifFT, nDifD2, '' , '', '', ''})
nSomaTFI += nSomaFI
nSomaTFT += nSomaFT
nSomaTD2 += nSomaD2
nDifTFT  += nDifFT
nDifTD2  += nDifD2
//aAdd(aExcel, {'','','','','','','','','','','','','',''})
//aAdd(aExcel, {'', '', '', '', 'TOTAL GERAL:',nSomaTFI, nSomaTFT, nSomaTD2, nDifTFT, nDifTD2, '' , '', '', ''})

return nil

/*----------------*/

Static Function PorPDV(aDados, aExcel)
local cPDVAt := ''
local cPDVAn := ''

Local nSomaFI := 0
Local nSomaFT := 0
Local nSomaD2 := 0
Local nDifFT  := 0
Local nDifD2  := 0

Local nSomaTFI := 0
Local nSomaTFT := 0
Local nSomaTD2 := 0
Local nDifTFT  := 0
Local nDifTD2  := 0

for i:=1 to Len(aDados)
	If aDados[i][3] == ''
		Loop
	Else
		cPDVAt := aDados[i][3]		
	EndIf
	
	If i == 1
		_cNoFil := aDados[i][1]
		_cAtFil := _cNoFil
		cPDVAn  := cPDVAt
	EndIf
	
   _cNoFil := aDados[i][1]
   If _cNoFil <> _cAtFil
		aAdd(aExcel, {'','','','','','','','','','','','','',''})
		aAdd(aExcel, {'','','','','','','','','','','','','',''})
		aAdd(aExcel, {'','','','','','','','','','','','','',''})
		aAdd(aExcel, {'','','','','','','','','','','','','',''})
		aAdd(aExcel, {'FILIAL', 'DATA', 'PDV', 'Num RED Z', 'NUM ECF','Val FI', 'Val FT', 'Val D2', 'FI-FT', 'FI-D2', 'NFIS DE' , 'NFIS ATE', 'DOC DE', 'DOC ATE'})   	
   	_cAtFil := _cNoFil
   EndIf
   _nPos := aScan(aDados,{|x| x[1]+x[3] == _cNoFil+cPDVAt})
   while _nPos > 0
   	//Mudança de PDV
		If cPDVAn <> cPDVAt
			aAdd(aExcel, {''})
			//aAdd(aExcel, {'', '', '', '', 'TOTAL:',nSomaFI, nSomaFT, nSomaD2, nDifFT, nDifD2, '' , '', '', ''})
			
			nSomaTFI += nSomaFI
			nSomaTFT += nSomaFT
			nSomaTD2 += nSomaD2
			nDifTFT  += nDifFT
			nDifTD2  += nDifD2
			
			nSomaFI := 0
			nSomaFT := 0
			nSomaD2 := 0
			nDifFT  := 0
			nDifD2  := 0
			
			aAdd(aExcel, {'','','','','','','','','','','','','',''})
			aAdd(aExcel, {'FILIAL', 'DATA', 'PDV', 'Num RED Z', 'NUM ECF','Val FI', 'Val FT', 'Val D2', 'FI-FT', 'FI-D2', 'NFIS DE' , 'NFIS ATE', 'DOC DE', 'DOC ATE'})	
			cPDVAn := cPDVAt
		EndIf
	            //{ FILIAL      , DATA        ,  PDV        ,  NUMREDZ    ,  SERPDV)    , Val FI      , Val FT      , Val D2      , FI-FT                    , FI-D2                    , MINNFIS     , MAXNFIS      , MINDOC       , MAXDOC      })
		aAdd(aExcel, {aDados[_nPos][1], aDados[_nPos][2], aDados[_nPos][3], aDados[_nPos][4], aDados[_nPos][5], aDados[_nPos][6], aDados[_nPos][7], aDados[_nPos][8], aDados[_nPos][6]-aDados[_nPos][7], aDados[_nPos][6]-aDados[_nPos][8], aDados[_nPos][9], aDados[_nPos][10], aDados[_nPos][11], aDados[_nPos][12]})
		nSomaFI += aDados[i][6]
		nSomaFT += aDados[i][7]
		nSomaD2 += aDados[i][8]
		nDifFT  += aDados[i][6]-aDados[i][7]
		nDifD2  += aDados[i][6]-aDados[i][8]
		aDados[_nPos][3] := ''
		_nPos := aScan(aDados,{|x| x[1]+x[3] == _cNoFil+cPDVAt})
   EndDo
Next i
//aAdd(aExcel, {'', '', '', '', 'TOTAL:',nSomaFI, nSomaFT, nSomaD2, nDifFT, nDifD2, '' , '', '', ''})
nSomaTFI += nSomaFI
nSomaTFT += nSomaFT
nSomaTD2 += nSomaD2
nDifTFT  += nDifFT
nDifTD2  += nDifD2
//aAdd(aExcel, {'','','','','','','','','','','','','',''})
//aAdd(aExcel, {'', '', '', '', 'TOTAL GERAL:',nSomaTFI, nSomaTFT, nSomaTD2, nDifTFT, nDifTD2, '' , '', '', ''})
return nil

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
aAdd(aHelpPor, 'Informe as filiais que devem ser     ')
aAdd(aHelpPor, 'consideradas.                        ')
cNome := 'Da Filial'
PutSx1(PadR(cPerg,nTamGrp), '03', cNome, cNome, cNome,;
'MV_CH3', 'C', 2, 0, 0, 'G', '', 'SM0', '', '', 'MV_PAR03',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

cNome := 'Ate Filial'
PutSx1(PadR(cPerg,nTamGrp), '04', cNome, cNome, cNome,;
'MV_CH4', 'C', 2, 0, 0, 'G', '', 'SM0', '', '', 'MV_PAR04',;
'', '', '', 'ZZ',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe se deseja totalizar por dia  ')
aAdd(aHelpPor, 'ou por PDV.                          ')
cNome := 'Totalizar Por'
PutSx1(PadR(cPerg,nTamGrp), '05', cNome, cNome, cNome,;
'MV_CH5', 'N', 1, 0, 0, 'C', '', 'SM0', '', '', 'MV_PAR05',;
'Data', 'Data', 'Date', '0',;
'PDV', 'PDV', 'PDV',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyRD2XFT()
///////////////////////////////////////////////////////////////////////////////
// Data : 20/06/2013
// User : Thieres Tembra
// Desc : Compara SD2 com SFT
// Ação : A rotina compara o valor por CFOP das tabelas SD2 e SFT
//        e exporta o resultado para o excel.
///////////////////////////////////////////////////////////////////////////////

Local cTitulo := 'Comparação Itens Saída x Itens Livro Fiscal (SD2 x SFT)'
Local cPerg := '#TDD2XFT'

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
EndIf

MsAguarde({|| TDD2XFT(cTitulo) },cTitulo,'Aguarde...')

Return Nil

/* -------------- */

Static Function TDD2XFT(cTitulo)

Local nI, nMax, nSomaD2, nSomaFT, nX
Local cQry
Local cRet, cAux
Local cArq := 'D2xFT'
Local aDados := {}
Local aDifD2 := {}
Local aDifFT := {}
Local aExcel := {}
Local aAux   := {}
Local aDifs  := {aDifD2, aDifFT}

cQry := " SELECT D2_CF CFOP, SUM(D2_VALBRUT) VALCONT"
cQry += " FROM "+RetSqlName('SD2')
cQry += " WHERE D2_EMISSAO >= '"+DTOS(MV_PAR01)+"'"
cQry += "   AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"'"
cQry += "   AND D_E_L_E_T_ <> '*'"
cQry += "   AND D2_FILIAL >= '"+MV_PAR03+"'"
cQry += "   AND D2_FILIAL <= '"+MV_PAR04+"'"
If AllTrim(MV_PAR05) <> ''
	cQry += "   AND D2_CF IN "+U_MyGeraIn(AllTrim(MV_PAR05))
EndIf
cQry += " GROUP BY D2_CF"
cQry += " ORDER BY D2_CF"

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSD2',.T.)
Analisa('SSD2', aDados)
SSD2->(dbCloseArea())

cQry := " SELECT FT_CFOP CFOP, SUM(FT_VALCONT) VALCONT"
cQry += " FROM "+RetSqlName('SFT')
cQry += " WHERE FT_ENTRADA >= '"+DTOS(MV_PAR01)+"'"
cQry += "   AND FT_ENTRADA <= '"+DTOS(MV_PAR02)+"'"
cQry += "   AND LEN(FT_DTCANC) = 0"
cQry += "   AND D_E_L_E_T_ <> '*'"
cQry += "   AND FT_FILIAL >= '"+MV_PAR03+"'"
cQry += "   AND FT_FILIAL <= '"+MV_PAR04+"'"
cQry += "   AND LEFT(FT_CFOP,1) >= '5'"
If AllTrim(MV_PAR05) <> ''
	cQry += "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR05))
EndIf
cQry += " GROUP BY FT_CFOP"
cQry += " ORDER BY FT_CFOP"

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSFT',.T.)
Analisa('SSFT', aDados)
SSFT->(dbCloseArea())

If MV_PAR06 == 1
	AnaDif(aDados, aDifD2, 1)
	AnaDif(aDados, aDifFT, 2)
EndIf

aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Período: '+DTOC(MV_PAR01)+' até '+DTOC(MV_PAR02)+' - Filial: '+MV_PAR03+' até '+MV_PAR04})
aAdd(aExcel, {''})
aAdd(aExcel, {'CFOP', 'Valor SD2', 'Valor SFT', 'Diferença (SD2-SFT)'})
nSomaD2 := 0
nSomaFT := 0
nMax := Len(aDados)
For nI := 1 to nMax
	aAdd(aExcel, {aDados[nI][1], aDados[nI][2], aDados[nI][3], aDados[nI][2]-aDados[nI][3]})
	nSomaD2 += aDados[nI][2]
	nSomaFT += aDados[nI][3]
Next nI
aAdd(aExcel, {'Total',nSomaD2,nSomaFT})

If MV_PAR06 == 1
	For nX := 1 to Len(aDifs)
		aAux := aClone(aDifs[nX])
		aAdd(aExcel, {''})
		aAdd(aExcel, {'Notas com divergências ('+Iif(nX==1,'D2','FT')+' a maior)'})
		aAdd(aExcel, {'CFOP', 'Nota', 'Série', 'Fornecedor/Cliente', 'Entrada', 'Valor SD2', 'Valor SFT', 'Diferença ('+Iif(nX==1,'SD2-SFT','SFT-SD2')+') por Nota'})
		nMax := Len(aAux)
		nSomaD2 := 0
		nSomaFT := 0
		For nI := 1 to nMax
			aAdd(aExcel, {aAux[nI][1], aAux[nI][2], aAux[nI][3], aAux[nI][4], aAux[nI][5], aAux[nI][6], aAux[nI][7], Iif(nX==1,aAux[nI][6]-aAux[nI][7],aAux[nI][7]-aAux[nI][6])})
			nSomaD2 += aAux[nI][6]
			nSomaFT += aAux[nI][7]
		Next nI
		aAdd(aExcel, {'', '', '', '', 'Total', nSomaD2, nSomaFT})
	Next nX
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

/* -------------- */

Static Function Analisa(cAlias, aDados)

Local nValD2, nValFT, nPos

While !(cAlias)->(Eof())
	If cAlias == 'SSD2'
		nValD2 := (cAlias)->VALCONT
		nValFT := 0
	ElseIf cAlias == 'SSFT'
		nValD2 := 0
		nValFT := (cAlias)->VALCONT
	Else
		nValD2 := 0
		nValFT := 0
	EndIf
	
	nPos := aScan(aDados, {|x| x[1] == (cAlias)->CFOP })
	If nPos == 0
		aAdd(aDados, { (cAlias)->CFOP, nValD2, nValFT })
	Else
		If nValD2 <> 0
			aDados[nPos][2] := nValD2
		ElseIf nValFT <> 0
			aDados[nPos][3] := nValFT
		EndIf
	EndIf
	
	(cAlias)->(dbSkip())
EndDo

Return Nil

/* -------------- */

Static Function AnaDif(aDados, aDif, nTipo)

Local nI, nMax, nVal1, nVal2

nMax := Len(aDados)

For nI := 1 to nMax
	If aDados[nI][2]-aDados[nI][3] <> 0
		If nTipo == 1
			cQry := " SELECT *,"
			cQry += "        D2_VALBRUT VALOR"
			cQry += " FROM "+RetSqlName('SD2')
			cQry += " WHERE D2_EMISSAO >= '"+DTOS(MV_PAR01)+"'"
			cQry += "   AND D2_EMISSAO <= '"+DTOS(MV_PAR02)+"'"
			cQry += "   AND D_E_L_E_T_ <> '*'"
			cQry += "   AND D2_CF = '"+aDados[nI][1]+"'"
			cQry += "   AND D2_FILIAL >= '"+MV_PAR03+"'"
			cQry += "   AND D2_FILIAL <= '"+MV_PAR04+"'"
			cQry += " ORDER BY D2_FILIAL,"
			cQry += "          D2_DOC,"
			cQry += "          D2_SERIE,"
			cQry += "          D2_CLIENTE,"
			cQry += "          D2_LOJA"
		ElseIf nTipo == 2
			cQry := " SELECT FT_FILIAL,"
			cQry += "        FT_ENTRADA,"
			cQry += "        FT_NFISCAL,"
			cQry += "        FT_SERIE,"
			cQry += "        FT_CLIEFOR,"
			cQry += "        FT_LOJA,"
			cQry += "        SUM(FT_VALCONT) VALOR"
			cQry += " FROM "+RetSqlName('SFT')
			cQry += " WHERE FT_ENTRADA >= '"+DTOS(MV_PAR01)+"'"
			cQry += "   AND FT_ENTRADA <= '"+DTOS(MV_PAR02)+"'"
			cQry += "   AND LEN(FT_DTCANC) = 0"
			cQry += "   AND D_E_L_E_T_ <> '*'"
			cQry += "   AND FT_CFOP = '"+aDados[nI][1]+"'"
			cQry += "   AND FT_FILIAL >= '"+MV_PAR03+"'"
			cQry += "   AND FT_FILIAL <= '"+MV_PAR04+"'"
			cQry += " GROUP BY FT_FILIAL,"
			cQry += "          FT_NFISCAL,"
			cQry += "          FT_SERIE,"
			cQry += "          FT_CLIEFOR,"
			cQry += "          FT_LOJA,"
			cQry += "          FT_ENTRADA"
			cQry += " ORDER BY FT_FILIAL,"
			cQry += "          FT_NFISCAL,"
			cQry += "          FT_SERIE,"
			cQry += "          FT_CLIEFOR,"
			cQry += "          FT_LOJA,"
			cQry += "          FT_ENTRADA"
		EndIf
		
		dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY1',.T.)
		While !MQRY1->(Eof())
			nVal1 := MQRY1->VALOR
			
			If nTipo == 1
				cQry := " SELECT SUM(FT_VALCONT) VALOR"
				cQry += " FROM "+RetSqlName('SFT')
				cQry += " WHERE LEN(FT_DTCANC) = 0"
				cQry += "   AND D_E_L_E_T_ <> '*'"
				cQry += "   AND FT_CFOP    = '"+MQRY1->D2_CF+"'"
				cQry += "   AND FT_NFISCAL = '"+MQRY1->D2_DOC+"'"
				cQry += "   AND FT_SERIE   = '"+MQRY1->D2_SERIE+"'"
				cQry += "   AND FT_CLIEFOR = '"+MQRY1->D2_CLIENTE+"'"
				cQry += "   AND FT_LOJA    = '"+MQRY1->D2_LOJA+"'"
				cQry += "   AND FT_ENTRADA = '"+MQRY1->D2_EMISSAO+"'"
				cQry += "   AND FT_FILIAL  = '"+MQRY1->D2_FILIAL+"'"
			ElseIf nTipo == 2
				cQry := " SELECT SUM(D2_VALBRUT) VALOR"
				cQry += " FROM "+RetSqlName('SD2')
				cQry += " WHERE D_E_L_E_T_ <> '*'"
				cQry += "   AND D2_CF      = '"+aDados[nI][1]+"'"
				cQry += "   AND D2_DOC     = '"+MQRY1->FT_NFISCAL+"'"
				cQry += "   AND D2_SERIE   = '"+MQRY1->FT_SERIE+"'"
				cQry += "   AND D2_CLIENTE = '"+MQRY1->FT_CLIEFOR+"'"
				cQry += "   AND D2_EMISSAO = '"+MQRY1->FT_ENTRADA+"'"
				cQry += "   AND D2_FILIAL  = '"+MQRY1->FT_FILIAL+"'"
			EndIf
			
			dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY2',.T.)
			
			If !MQRY2->(Eof())
				While !MQRY2->(Eof())
					nVal2 := MQRY2->VALOR
					If nVal2 <> nVal1
						If nTipo == 1
							aAdd(aDif, {aDados[nI][1], MQRY1->D2_DOC, MQRY1->D2_SERIE, MQRY1->D2_CLIENTE+'-'+MQRY1->D2_LOJA, U_MyDataBR(MQRY1->D2_EMISSAO), nVal1, nVal2})
						ElseIf nTipo == 2
							aAdd(aDif, {aDados[nI][1], MQRY1->FT_NFISCAL, MQRY1->FT_SERIE, MQRY1->FT_CLIEFOR+'-'+MQRY1->FT_LOJA, U_MyDataBR(MQRY1->FT_ENTRADA), nVal2, nVal1})
						EndIf
					EndIf			
					MQRY2->(dbSkip())
				EndDo
			Else
				nVal2 := 0
				If nTipo == 1
					aAdd(aDif, {aDados[nI][1], MQRY1->D2_DOC+' - Nota não encontrada na SFT', MQRY1->D2_SERIE, MQRY1->D2_CLIENTE+'-'+MQRY1->D2_LOJA, U_MyDataBR(MQRY1->D2_EMISSAO), nVal1, nVal2})
				ElseIf nTipo == 2
					aAdd(aDif, {aDados[nI][1], MQRY1->FT_NFISCAL+' - Nota não encontrada na SD2', MQRY1->FT_SERIE, MQRY1->FT_CLIEFOR+'-'+MQRY1->FT_LOJA, U_MyDataBR(MQRY1->FT_ENTRADA), nVal2, nVal1})
				EndIf
			EndIf
			MQRY2->(dbCloseArea())
						
			MQRY1->(dbSkip())
		EndDo
		MQRY1->(dbCloseArea())
	EndIf
Next nI

Return Nil

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
aAdd(aHelpPor, 'Informe os CFOPs separados por ponto ')
aAdd(aHelpPor, 'e vígula (;) a serem listados no     ')
aAdd(aHelpPor, 'relatório. Deixe em branco para      ')
aAdd(aHelpPor, 'considerar todos.                    ')
cNome := 'CFOPs'
PutSx1(PadR(cPerg,nTamGrp), '05', cNome, cNome, cNome,;
'MV_CH5', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR05',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Selecione se deseja efetuar a quebra ')
aAdd(aHelpPor, 'por nota fiscal.                     ')
cNome := 'Quebra por nota'
PutSx1(PadR(cPerg,nTamGrp), '06', cNome, cNome, cNome,;
'MV_CH6', 'C', 1, 0, 0, 'C', '', '', '', '', 'MV_PAR06',;
'Sim', 'Sim', 'Sim', '2',;
'Nao', 'Nao', 'Nao',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
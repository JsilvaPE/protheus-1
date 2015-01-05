#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyRF3XFT()
///////////////////////////////////////////////////////////////////////////////
// Data : 23/04/2013
// User : Thieres Tembra
// Desc : Compara SF3 com SFT
// Ação : A rotina compara o valor contábil por CFOP das tabelas SF3 e SFT
//        e exporta o resultado para o excel.
///////////////////////////////////////////////////////////////////////////////
// Alterações:
// 1) Walber Freire - 21/06/13
//    Criado comparativo entre notas.
//
// 2) Thieres Tembra - 12/06/13
//    Ajustado comparativo entre notas e duplicado o mesmo para fazer:
//    1 - F3 a maior
//    2 - FT a menor
//    
// 3) Thieres Tembra - 26/11/13
//    Ajusta automaticamente a diferença entre os CFOPs 5656, 5102 e 5405
//    devido a se tratar de diferença de Redução Z (SF3) para Cupom Fiscal (SFT)
//    gerado pelo sistema origem (EMSys ou Seller). A diferença é colocada no
//    item (SFT) com maior valor que possua CST 04,05,06 do PIS/COFINS. Caso
//    não haja um item com esta CST, o usuário é informado.
///////////////////////////////////////////////////////////////////////////////

Local cTitulo := 'Comparação Livro Fiscal x Itens (SF3 x SFT)'
Local cPerg := '#TDF3XFT'

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
//Alt. (3)
ElseIf MV_PAR08 == 1 .and. MV_PAR04 <> MV_PAR05
	Alert('Para ajustar a diferença os campos "Da Filial" e "Ate Filial" devem ser iguais, pois o ajuste é feito por filial.')
	Return Nil
ElseIf MV_PAR08 == 1 .and. MV_PAR03 == 1
	Alert('O ajuste de diferença é realizado somente no Livro de Saída.')
	Return Nil
//Fim Alt. (3)
EndIf

MsAguarde({|| TDF3XFT(cTitulo) },cTitulo,'Aguarde...')

Return Nil

/* -------------- */

Static Function TDF3XFT(cTitulo)

Local nI, nMax, nSomaF3, nSomaFT, nX
Local cQry
Local cRet, cAux
Local cArq := 'F3xFT'
Local aDados := {}
Local aDifF3 := {} //Alt. (2)
Local aDifFT := {} //Alt. (2)
Local aExcel := {}
Local aAux   := {} //Alt. (2)
Local aDifs  := {aDifF3, aDifFT} //Alt. (2)

cQry := " SELECT F3_CFO CFOP, ROUND(SUM(F3_VALCONT),2) VALCONT"
cQry += " FROM "+RetSqlName('SF3')
cQry += " WHERE F3_ENTRADA >= '"+DTOS(MV_PAR01)+"'"
cQry += "   AND F3_ENTRADA <= '"+DTOS(MV_PAR02)+"'"
If MV_PAR03 == 1
	cQry += "   AND LEFT(F3_CFO,1) < '5'"
Else
	cQry += "   AND LEFT(F3_CFO,1) >= '5'"
EndIf
cQry += "   AND LEN(F3_DTCANC) = 0"
cQry += "   AND D_E_L_E_T_ <> '*'"
cQry += "   AND F3_FILIAL >= '"+MV_PAR04+"'"
cQry += "   AND F3_FILIAL <= '"+MV_PAR05+"'"
cQry += "   AND F3_TIPO <> 'S'"
If AllTrim(MV_PAR06) <> ''
	cQry += "   AND F3_CFO IN "+U_MyGeraIn(AllTrim(MV_PAR06))
EndIf
cQry += " GROUP BY F3_CFO"
cQry += " ORDER BY F3_CFO"

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSF3',.T.)
Analisa('SSF3', aDados)
SSF3->(dbCloseArea())

cQry := " SELECT FT_CFOP CFOP, ROUND(SUM(FT_VALCONT),2) VALCONT"
cQry += " FROM "+RetSqlName('SFT')
cQry += " WHERE FT_ENTRADA >= '"+DTOS(MV_PAR01)+"'"
cQry += "   AND FT_ENTRADA <= '"+DTOS(MV_PAR02)+"'"
If MV_PAR03 == 1
	cQry += "   AND LEFT(FT_CFOP,1) < '5'"
Else
	cQry += "   AND LEFT(FT_CFOP,1) >= '5'"
EndIf
cQry += "   AND LEN(FT_DTCANC) = 0"
cQry += "   AND D_E_L_E_T_ <> '*'"
cQry += "   AND FT_FILIAL >= '"+MV_PAR04+"'"
cQry += "   AND FT_FILIAL <= '"+MV_PAR05+"'"
If AllTrim(MV_PAR06) <> ''
	cQry += "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR06))
EndIf
cQry += " GROUP BY FT_CFOP"
cQry += " ORDER BY FT_CFOP"

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSFT',.T.)
Analisa('SSFT', aDados)
SSFT->(dbCloseArea())

If MV_PAR07 == 1
	AnaDif(aDados, aDifF3, 1) //Alt. (1) Alt. (2)
	AnaDif(aDados, aDifFT, 2) //Alt. (2)
EndIf

aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Período: '+DTOC(MV_PAR01)+' até '+DTOC(MV_PAR02)+' - Filial: '+MV_PAR04+' até '+MV_PAR05})
aAdd(aExcel, {''})
aAdd(aExcel, {'CFOP', 'Valor SF3', 'Valor SFT', 'Diferença (SF3-SFT)'})
nSomaF3 := 0
nSomaFT := 0
nMax := Len(aDados)
For nI := 1 to nMax
	aAdd(aExcel, {aDados[nI][1], aDados[nI][2], aDados[nI][3], aDados[nI][2]-aDados[nI][3]})
	nSomaF3 += aDados[nI][2]
	nSomaFT += aDados[nI][3]
Next nI
aAdd(aExcel, {'Total',nSomaF3,nSomaFT})

If MV_PAR07 == 1
	//Alt. (1) Alt. (2)
	For nX := 1 to Len(aDifs)
		aAux := aClone(aDifs[nX])
		aAdd(aExcel, {''})
		aAdd(aExcel, {'Notas com divergências ('+Iif(nX==1,'F3','FT')+' a maior)'})
		aAdd(aExcel, {'CFOP', 'Nota', 'Série', 'Fornecedor/Cliente', 'Entrada', 'Valor SF3', 'Valor SFT', 'Diferença ('+Iif(nX==1,'SF3-SFT','SFT-SF3')+') por Nota'})
		nMax := Len(aAux)
		nSomaF3 := 0
		nSomaFT := 0
		For nI := 1 to nMax
			aAdd(aExcel, {aAux[nI][1], aAux[nI][2], aAux[nI][3], aAux[nI][4], aAux[nI][5], aAux[nI][6], aAux[nI][7], Iif(nX==1,aAux[nI][6]-aAux[nI][7],aAux[nI][7]-aAux[nI][6])})
			nSomaF3 += aAux[nI][6]
			nSomaFT += aAux[nI][7]
		Next nI
		aAdd(aExcel, {'', '', '', '', 'Total', nSomaF3, nSomaFT})
	Next nX
	//Fim Alt. (1) Alt. (2)
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

//Alt. (3)
//ajusta diferença somente se for livro de saída
If MV_PAR08 == 1 .and. MV_PAR03 == 2
	If MsgYesNo('Deseja realmente ajustar a diferença encontrada?')
		MsAguarde({|| AjustaDif(@aDados) },'Ajustando Diferença','Aguarde...')
	Endif
EndIf
//Fim Alt. (3)

Return Nil

/* -------------- */

Static Function Analisa(cAlias, aDados)

Local nValF3, nValFT, nPos

While !(cAlias)->(Eof())
	If cAlias == 'SSF3'
		nValF3 := (cAlias)->VALCONT
		nValFT := 0
	ElseIf cAlias == 'SSFT'
		nValF3 := 0
		nValFT := (cAlias)->VALCONT
	Else
		nValF3 := 0
		nValFT := 0
	EndIf
	
	nPos := aScan(aDados, {|x| x[1] == (cAlias)->CFOP })
	If nPos == 0
		aAdd(aDados, { (cAlias)->CFOP, nValF3, nValFT })
	Else
		If nValF3 <> 0
			aDados[nPos][2] := nValF3
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
			cQry += "        F3_VALCONT VALOR"
			cQry += " FROM "+RetSqlName('SF3')
			cQry += " WHERE F3_ENTRADA >= '"+DTOS(MV_PAR01)+"'"
			cQry += "   AND F3_ENTRADA <= '"+DTOS(MV_PAR02)+"'"
			cQry += "   AND LEN(F3_DTCANC) = 0"
			cQry += "   AND D_E_L_E_T_ <> '*'"
			cQry += "   AND F3_CFO      = '"+aDados[nI][1]+"'"
			cQry += "   AND F3_FILIAL  >= '"+MV_PAR04+"'"
			cQry += "   AND F3_FILIAL  <= '"+MV_PAR05+"'"
			cQry += "   AND F3_TIPO    <> 'S'"
			cQry += " ORDER BY F3_FILIAL,"
			cQry += "          F3_NFISCAL,"
			cQry += "          F3_SERIE,"
			cQry += "          F3_CLIEFOR,"
			cQry += "          F3_LOJA"
		ElseIf nTipo == 2
			cQry := " SELECT FT_FILIAL,"
			cQry += "        FT_ENTRADA,"
			cQry += "        FT_NFISCAL,"
			cQry += "        FT_SERIE,"
			cQry += "        FT_CLIEFOR,"
			cQry += "        FT_LOJA,"
			cQry += "        ROUND(SUM(FT_VALCONT),2) VALOR"
			cQry += " FROM "+RetSqlName('SFT')
			cQry += " WHERE FT_ENTRADA >= '"+DTOS(MV_PAR01)+"'"
			cQry += "   AND FT_ENTRADA <= '"+DTOS(MV_PAR02)+"'"
			cQry += "   AND LEN(FT_DTCANC) = 0"
			cQry += "   AND D_E_L_E_T_ <> '*'"
			cQry += "   AND FT_CFOP = '"+aDados[nI][1]+"'"
			cQry += "   AND FT_FILIAL >= '"+MV_PAR04+"'"
			cQry += "   AND FT_FILIAL <= '"+MV_PAR05+"'"
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
				cQry := " SELECT ROUND(SUM(FT_VALCONT),2) VALOR"
				cQry += " FROM "+RetSqlName('SFT')
				cQry += " WHERE LEN(FT_DTCANC) = 0"
				cQry += "   AND D_E_L_E_T_ <> '*'"
				cQry += "   AND FT_CFOP    = '"+MQRY1->F3_CFO+"'"
				cQry += "   AND FT_NFISCAL = '"+MQRY1->F3_NFISCAL+"'"
				cQry += "   AND FT_SERIE   = '"+MQRY1->F3_SERIE+"'"
				cQry += "   AND FT_CLIEFOR = '"+MQRY1->F3_CLIEFOR+"'"
				cQry += "   AND FT_LOJA    = '"+MQRY1->F3_LOJA+"'"
				cQry += "   AND FT_ENTRADA = '"+MQRY1->F3_ENTRADA+"'"
				cQry += "   AND FT_FILIAL  = '"+MQRY1->F3_FILIAL+"'"
			ElseIf nTipo == 2
				cQry := " SELECT ROUND(SUM(F3_VALCONT),2) VALOR"
				cQry += " FROM "+RetSqlName('SF3')
				cQry += " WHERE LEN(F3_DTCANC) = 0"
				cQry += "   AND D_E_L_E_T_ <> '*'"
				cQry += "   AND F3_CFO      = '"+aDados[nI][1]+"'"
				cQry += "   AND F3_NFISCAL  = '"+MQRY1->FT_NFISCAL+"'"
				cQry += "   AND F3_SERIE    = '"+MQRY1->FT_SERIE+"'"
				cQry += "   AND F3_CLIEFOR  = '"+MQRY1->FT_CLIEFOR+"'"
				cQry += "   AND F3_ENTRADA  = '"+MQRY1->FT_ENTRADA+"'"
				cQry += "   AND F3_FILIAL   = '"+MQRY1->FT_FILIAL+"'"
				cQry += "   AND F3_TIPO    <> 'S'"
			EndIf
			
			dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY2',.T.)
			
			If !MQRY2->(Eof())
				While !MQRY2->(Eof())
					nVal2 := MQRY2->VALOR
					If nVal2 <> nVal1
						If nTipo == 1
							aAdd(aDif, {aDados[nI][1], MQRY1->F3_NFISCAL, MQRY1->F3_SERIE, MQRY1->F3_CLIEFOR+'-'+MQRY1->F3_LOJA, U_MyDataBR(MQRY1->F3_ENTRADA), nVal1, nVal2})
						ElseIf nTipo == 2
							aAdd(aDif, {aDados[nI][1], MQRY1->FT_NFISCAL, MQRY1->FT_SERIE, MQRY1->FT_CLIEFOR+'-'+MQRY1->FT_LOJA, U_MyDataBR(MQRY1->FT_ENTRADA), nVal2, nVal1})
						EndIf
					EndIf			
					MQRY2->(dbSkip())
				EndDo
			Else
				nVal2 := 0
				If nTipo == 1
					aAdd(aDif, {aDados[nI][1], MQRY1->F3_NFISCAL+' - Nota não encontrada na SFT', MQRY1->F3_SERIE, MQRY1->F3_CLIEFOR+'-'+MQRY1->F3_LOJA, U_MyDataBR(MQRY1->F3_ENTRADA), nVal1, nVal2})
				ElseIf nTipo == 2
					aAdd(aDif, {aDados[nI][1], MQRY1->FT_NFISCAL+' - Nota não encontrada na SF3', MQRY1->FT_SERIE, MQRY1->FT_CLIEFOR+'-'+MQRY1->FT_LOJA, U_MyDataBR(MQRY1->FT_ENTRADA), nVal2, nVal1})
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

Static Function AjustaDif(aDados)

Local cQry := ''
Local cCFOP
Local nI, nTamI
Local nDif, nCnt, nSaldo

nTamI := Len(aDados)
For nI := 1 to nTamI
	cCFOP := AllTrim(aDados[nI][1])
	If cCFOP $ '5656;5102;5405'
		//somente ajusta os CFOPs acima
		nDif := aDados[nI][2]-aDados[nI][3]
		If nDif <> 0
			//se existir diferença a maior, procura o produto com CST 04/05/06 de maior valor
			//no geral e em seguida os itens de cupom deste produto ordenadores pelo maior valor
			cQry := " SELECT R_E_C_N_O_ RECNUM"
			cQry += " FROM " + RetSqlName('SFT')
			cQry += " WHERE FT_FILIAL = '" + MV_PAR04 + "'"
			cQry += "   AND FT_ENTRADA >= '" + DTOS(MV_PAR01) + "'"
			cQry += "   AND FT_ENTRADA <= '" + DTOS(MV_PAR02) + "'"
			cQry += "   AND FT_CFOP = '" + cCFOP + "'"
			cQry += "   AND FT_PRODUTO IN ("
			cQry += "     SELECT FT_PRODUTO FROM ("
			cQry += "       SELECT TOP 1"
			cQry += "              FT_PRODUTO,"
			cQry += "              FT_CSTPIS,"
			cQry += "              FT_CFOP,"
			cQry += "              ROUND(SUM(FT_VALCONT),2) VALCONT"
			cQry += "       FROM " + RetSqlName('SFT')
			cQry += "       WHERE FT_FILIAL = '" + MV_PAR04 + "'"
			cQry += "         AND FT_ENTRADA >= '" + DTOS(MV_PAR01) + "'"
			cQry += "         AND FT_ENTRADA <= '" + DTOS(MV_PAR02) + "'"
			cQry += "         AND FT_CFOP = '" + cCFOP + "'"
			cQry += "         AND FT_CSTPIS IN ('04','05','06')"
			cQry += "         AND LEN(FT_DTCANC) = 0"
			cQry += "         AND FT_USERLGI LIKE '#TD_D2FT%'"
			cQry += "         AND D_E_L_E_T_ <> '*'"
			cQry += "       GROUP BY FT_PRODUTO, FT_CSTPIS, FT_CFOP"
			If nDif < 0
				cQry += "       HAVING ROUND(SUM(FT_VALCONT),2) > " + cValToChar(nDif)
			EndIf
			cQry += "       ORDER BY VALCONT DESC"
			cQry += "     ) AS TEMPPROD"
			cQry += "   )"
			cQry += "   AND FT_CSTPIS IN ('04','05','06')"
			cQry += "   AND LEN(FT_DTCANC) = 0"
			cQry += "   AND FT_USERLGI LIKE '#TD_D2FT%'"
			cQry += "   AND D_E_L_E_T_ <> '*'"
			cQry += " ORDER BY FT_VALCONT DESC"
			dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MDIF',.T.)
			nCnt := 0
			nSaldo := nDif
			While !MDIF->(Eof())
				SFT->(dbGoTo(MDIF->RECNUM))
				If RecLock('SFT', .F.)
					nCnt++
					If (SFT->FT_VALCONT+nSaldo) <= 0
						If SFT->FT_BASEICM > 0
							SFT->FT_BASEICM := 0.10
							SFT->FT_VALICM  := Round(SFT->FT_BASEICM * (SFT->FT_ALIQICM / 100), 2)
							SFT->FT_ISENICM := 0
							SFT->FT_OUTRICM := 0
						ElseIf SFT->FT_ISENICM > 0
							SFT->FT_ISENICM := 0.10
							SFT->FT_OUTRICM := 0
						Else
							SFT->FT_OUTRICM := 0.10
						EndIf
						nSaldo := nSaldo + (SFT->FT_VALCONT - 0.10)
						SFT->FT_VALCONT := 0.10
					Else
						If SFT->FT_BASEICM == SFT->FT_VALCONT
							SFT->FT_BASEICM := SFT->FT_BASEICM + nSaldo
							SFT->FT_VALICM  := Round(SFT->FT_BASEICM * (SFT->FT_ALIQICM / 100), 2)
						ElseIf SFT->FT_ISENICM == SFT->FT_VALCONT
							SFT->FT_ISENICM := SFT->FT_ISENICM + nSaldo
						Else
							SFT->FT_OUTRICM := SFT->FT_OUTRICM + nSaldo
						EndIf
						SFT->FT_VALCONT := SFT->FT_VALCONT + nSaldo
						nSaldo := 0
					EndIf
					SFT->FT_BASEPIS := SFT->FT_VALCONT
					SFT->FT_BASECOF := SFT->FT_VALCONT
					SFT->FT_USERLGI := '#TD_D2FTx' + SubStr(SFT->FT_USERLGI, 10) //substitui "-" por "x" para marcar registro alterado
					SFT->(MsUnlock())
				Else
					Alert('CFOP ' + cCFOP + ': Não foi possível atualizar o registro ' + cValToChar(MDIF->RECNUM) + ' (SFT). A diferença não será ajustada automaticamente.')
				EndIf
				If nSaldo == 0
					Exit
				EndIf
				MDIF->(dbSkip())
			EndDo
			MDIF->(dbCloseArea())
			If nCnt == 0
				Alert('CFOP ' + cCFOP + ': Não foi encontrado um produto com CST 04/05/06 onde o valor de sua venda seja maior que '+ cValToChar(nDif) + '. A diferença não será ajustada automaticamente.')
			Else
				MsgAlert('CFOP ' + cCFOP + ': Diferença ajustada com sucesso em ' + cValToChar(nCnt) + ' registro(s).')
			EndIf
		EndIf
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
aAdd(aHelpPor, 'Informe as filiais que devem ser     ')
aAdd(aHelpPor, 'consideradas.                        ')
cNome := 'Da Filial'
PutSx1(PadR(cPerg,nTamGrp), '04', cNome, cNome, cNome,;
'MV_CH4', 'C', 2, 0, 0, 'G', '', 'SM0', '', '', 'MV_PAR04',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

cNome := 'Ate Filial'
PutSx1(PadR(cPerg,nTamGrp), '05', cNome, cNome, cNome,;
'MV_CH5', 'C', 2, 0, 0, 'G', '', 'SM0', '', '', 'MV_PAR05',;
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
PutSx1(PadR(cPerg,nTamGrp), '06', cNome, cNome, cNome,;
'MV_CH6', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR06',;
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
PutSx1(PadR(cPerg,nTamGrp), '07', cNome, cNome, cNome,;
'MV_CH7', 'C', 1, 0, 0, 'C', '', '', '', '', 'MV_PAR07',;
'Sim', 'Sim', 'Sim', '2',;
'Nao', 'Nao', 'Nao',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Selecione se deseja ajustar a        ')
aAdd(aHelpPor, 'diferença nos CFOPs 5656, 5102 e 5405')
aAdd(aHelpPor, 'referente a Redução Z x Cupom Fiscal.')
cNome := 'Ajusta diferença'
PutSx1(PadR(cPerg,nTamGrp), '08', cNome, cNome, cNome,;
'MV_CH8', 'C', 1, 0, 0, 'C', '', '', '', '', 'MV_PAR08',;
'Sim', 'Sim', 'Sim', '2',;
'Nao', 'Nao', 'Nao',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
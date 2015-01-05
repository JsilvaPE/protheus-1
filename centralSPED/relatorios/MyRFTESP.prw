#include 'rwmake.ch'
#include 'protheus.ch'
#define CRLF chr(13) + chr(10)
///////////////////////////////////////////////////////////////////////////////
User Function TD_FTESP()
///////////////////////////////////////////////////////////////////////////////
// Data : 02/10/2013
// User : Thieres Tembra
// Desc : Emite o relatório de apuração agrupando os valores de acordo com
//        produto, NCM ou Tab.Nat.Rec
// Ação : A rotina emite o relatório filtrando por CFOP e por CST da tabela SFT
//        e exporta o resultado para o excel.
///////////////////////////////////////////////////////////////////////////////

Local cTitulo := 'Apuração Analítica (SFT)'
Local cPerg := '#TDFTESP'
Local aArea := GetArea()
Local aAreaSM0 := SM0->(GetArea())

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
ElseIf MV_PAR09 == 2 .and. MV_PAR08 == 5
	Alert('Para emitir somente o relatório analítico, não deve ser escolhido o tipo de analítico como "Todos".')
	Return Nil
EndIf

Processa({|| TDFTESP(cTitulo) },cTitulo,'Realizando consulta...')

SM0->(RestArea(aAreaSM0))
RestArea(aArea)

Return Nil

/* -------------- */

Static Function TDFTESP(cTitulo)

Local cQry
Local cRet, cAux, cFAnt
Local cArq := 'FTESP'
Local aExcel := {}
Local aCST, aSomaE, aSomaS, aCFOPG
Local nCnt, nPos
Local cCFAnt
Local nTot1, nTot2, nTot3, nTot4, nTot5

//Modificado por Walber Freire
Local aTCF := {}
Local aTCC := {}

ProcRegua(0)

aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' às '+Time()+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Período: '+DTOC(MV_PAR01)+' até '+DTOC(MV_PAR02)+' - Filial: '+MV_PAR03+' até '+MV_PAR04})
If AllTrim(MV_PAR06) <> ''
	aAdd(aExcel, {'Somente CFOPs: '+AllTrim(MV_PAR06)})
EndIf
If AllTrim(MV_PAR07) <> ''
	aAdd(aExcel, {'Somente CSTs: '+AllTrim(MV_PAR07)})
EndIf
If AllTrim(MV_PAR10) <> ''
	aAdd(aExcel, {'Somente Cli/For: '+AllTrim(MV_PAR10)})
EndIf

If MV_PAR09 == 1
	//somente analítico = NAO
	
	/*
	Modificado por Walber Freire
	-Capturando dados de fornecedor
	bkp:
	------------------------------------------
	cQry :=        " SELECT FT_FILIAL FILIAL,"
	cQry += CRLF + "        FT_NFISCAL DOC,"
	cQry += CRLF + "        FT_SERIE SERIE,"
	cQry += CRLF + "        FT_CLIEFOR CLIEFOR,"
	cQry += CRLF + "        FT_LOJA LOJA,"
	cQry += CRLF + "        SUM(FT_VALCONT) VALCONT,"
	cQry += CRLF + "        SUM(FT_BASEPIS) BASEPIS,"
	cQry += CRLF + "        SUM(FT_BASECOF) BASECOF,"
	cQry += CRLF + "        SUM(FT_VALPIS) VALPIS,"
	cQry += CRLF + "        SUM(FT_VALCOF) VALCOF"
	cQry += CRLF + " FROM "+RetSqlName('SFT')
	cQry += CRLF + " WHERE FT_ENTRADA >= '"+DTOS(MV_PAR01)+"'"
	cQry += CRLF + "   AND FT_ENTRADA <= '"+DTOS(MV_PAR02)+"'"
	cQry += CRLF + "   AND LEN(FT_DTCANC) = 0"
	cQry += CRLF + "   AND D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL >= '"+MV_PAR03+"'"
	cQry += CRLF + "   AND FT_FILIAL <= '"+MV_PAR04+"'"
	If MV_PAR05 == 1
		cQry += CRLF + "   AND LEFT(FT_CFOP,1) < '5'"
	Else
		cQry += CRLF + "   AND LEFT(FT_CFOP,1) >= '5'"
	EndIf
	If AllTrim(MV_PAR06) <> ''
		cQry += CRLF + "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR06))
	EndIf
	If AllTrim(MV_PAR07) <> ''
		cQry += CRLF + "   AND FT_CSTPIS IN "+U_MyGeraIn(AllTrim(MV_PAR07))
	EndIf
	cQry += CRLF + " GROUP BY FT_FILIAL,"
	cQry += CRLF + "          FT_NFISCAL,"
	cQry += CRLF + "          FT_SERIE,"
	cQry += CRLF + "          FT_CLIEFOR,"
	cQry += CRLF + "          FT_LOJA"
	cQry += CRLF + " ORDER BY FT_FILIAL,"
	cQry += CRLF + "          FT_NFISCAL,"
	cQry += CRLF + "          FT_SERIE,"
	cQry += CRLF + "          FT_CLIEFOR,"
	cQry += CRLF + "          FT_LOJA"
	------------------------------------------
	novo:
	------------------------------------------
	*/
	
	cQry :=        " SELECT FT_FILIAL FILIAL,"
	cQry += CRLF + "        FT_ENTRADA DTNF,"
	cQry += CRLF + "        FT_NFISCAL DOC,"
	cQry += CRLF + "        FT_SERIE SERIE,"
	cQry += CRLF + "        FT_CLIEFOR CLIEFOR,"
	cQry += CRLF + "        FT_LOJA LOJA,"
	cQry += CRLF + "        SUM(FT_VALCONT) VALCONT,"
	cQry += CRLF + "        SUM(FT_BASEPIS) BASEPIS,"
	cQry += CRLF + "        SUM(FT_BASECOF) BASECOF,"
	cQry += CRLF + "        SUM(FT_VALPIS) VALPIS,"
	cQry += CRLF + "        SUM(FT_VALCOF) VALCOF,"
	
	If MV_PAR05 == 1
		cQry += CRLF + "        A2_NOME NOMCLIEFOR"
	Else
		cQry += CRLF + "        A1_NOME NOMCLIEFOR"
	EndIf
	
	cQry += CRLF + " FROM "+RetSqlName('SFT')+" as SFT "
	
	If MV_PAR05 == 1
		cQry += CRLF + " LEFT JOIN "+RetSqlName('SA2')+" as SAX"
		cQry += CRLF + " ON FT_CLIEFOR = A2_COD"
		cQry += CRLF + "   AND FT_LOJA = A2_LOJA"
		cQry += CRLF + "   AND SAX.D_E_L_E_T_ <> '*'"
		cQry += CRLF + "   AND A2_FILIAL = ''"
	Else
		cQry += CRLF + " LEFT JOIN "+RetSqlName('SA1')+" as SAX"
		cQry += CRLF + " ON FT_CLIEFOR = A1_COD"
		cQry += CRLF + "   AND FT_LOJA = A1_LOJA"
		cQry += CRLF + "   AND SAX.D_E_L_E_T_ <> '*'"
		cQry += CRLF + "   AND A1_FILIAL = ''"
	EndIf
		
	cQry += CRLF + " WHERE FT_ENTRADA >= '"+DTOS(MV_PAR01)+"'"
	cQry += CRLF + "   AND FT_ENTRADA <= '"+DTOS(MV_PAR02)+"'"
	cQry += CRLF + "   AND LEN(FT_DTCANC) = 0"
	cQry += CRLF + "   AND SFT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL >= '"+MV_PAR03+"'"
	cQry += CRLF + "   AND FT_FILIAL <= '"+MV_PAR04+"'"
	
	If MV_PAR05 == 1
		cQry += CRLF + "   AND LEFT(FT_CFOP,1) < '5'"
	Else
		cQry += CRLF + "   AND LEFT(FT_CFOP,1) >= '5'"
	EndIf
	
	If AllTrim(MV_PAR06) <> ''
		cQry += CRLF + "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR06))
	EndIf
	If AllTrim(MV_PAR07) <> ''
		cQry += CRLF + "   AND FT_CSTPIS IN "+U_MyGeraIn(AllTrim(MV_PAR07))
	EndIf
	If AllTrim(MV_PAR10) <> ''
		cQry += CRLF + "   AND FT_CLIEFOR IN "+U_MyGeraIn(AllTrim(MV_PAR10))
	EndIf
	cQry += CRLF + " GROUP BY FT_FILIAL,"
	cQry += CRLF + "          FT_ENTRADA,"
	cQry += CRLF + "          FT_NFISCAL,"
	cQry += CRLF + "          FT_SERIE,"
	cQry += CRLF + "          FT_CLIEFOR,"
	cQry += CRLF + "          FT_LOJA,"
	If MV_PAR05 == 1
		cQry += CRLF + "        A2_NOME"
	Else
		cQry += CRLF + "        A1_NOME"
	EndIf
	cQry += CRLF + " ORDER BY FT_FILIAL,"
	cQry += CRLF + "          FT_ENTRADA,"
	cQry += CRLF + "          FT_NFISCAL,"
	cQry += CRLF + "          FT_SERIE,"
	cQry += CRLF + "          FT_CLIEFOR,"
	cQry += CRLF + "          FT_LOJA,"
	If MV_PAR05 == 1
		cQry += CRLF + "        A2_NOME"
	Else
		cQry += CRLF + "        A1_NOME"
	EndIf	
	/*
	------------------------------------------
	*/
	
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'NOTAS',.T.)
	nCnt := 0
	NOTAS->(dbEval({||nCnt++}))
	NOTAS->(dbGoTop())
	
	ProcRegua(nCnt)
	
	cFAnt  := ''
	While !NOTAS->(Eof())
		If cFAnt <> NOTAS->FILIAL
			//inicia nova empresa
			aAdd(aExcel, {''})
			SM0->(dbSetOrder(1))
			SM0->(dbSeek(cEmpAnt+NOTAS->FILIAL))
			cAux := 'Empresa: '+cEmpAnt+'/'+NOTAS->FILIAL+'-'+AllTrim(SM0->M0_NOME)+' '+AllTrim(SM0->M0_FILIAL)+' - CNPJ: '+Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')
			IncProc(cAux)
			aAdd(aExcel, {cAux})
		Else
			IncProc()
		EndIf
		
		
		/*
		Modificado por Walber Freire
		-Incluindo a data de entrada do FT no relatório
		bkp:
		-------------------------------------------------
		aAdd(aExcel, {'Filial', 'Nota Fiscal', 'Série', Iif(MV_PAR05==1,'Fornecedor','Cliente'), 'Loja', 'Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
		aAdd(aExcel, {NOTAS->FILIAL, NOTAS->DOC, NOTAS->SERIE, NOTAS->CLIEFOR, NOTAS->LOJA, NOTAS->VALCONT, NOTAS->BASEPIS, NOTAS->BASECOF, NOTAS->VALPIS, NOTAS->VALCOF})
		-------------------------------------------------
		novo:
		-------------------------------------------------
		aAdd(aExcel, {'Filial', 'Data', 'Nota Fiscal', 'Série', Iif(MV_PAR05==1,'Fornecedor','Cliente'), 'Loja', 'Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
		aAdd(aExcel, {NOTAS->FILIAL, DTOC(STOD(NOTAS->DTNF)), NOTAS->DOC, NOTAS->SERIE, NOTAS->CLIEFOR, NOTAS->LOJA, NOTAS->VALCONT, NOTAS->BASEPIS, NOTAS->BASECOF, NOTAS->VALPIS, NOTAS->VALCOF})		
		-------------------------------------------------
		*/
		aAdd(aExcel, {'Filial', 'Data', 'Nota Fiscal', 'Série', Iif(MV_PAR05==1,'Fornecedor','Cliente'), 'Loja', 'Nome ' + Iif(MV_PAR05==1,'Fornecedor','Cliente'), 'Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
		aAdd(aExcel, {NOTAS->FILIAL, DTOC(STOD(NOTAS->DTNF)), NOTAS->DOC, NOTAS->SERIE, NOTAS->CLIEFOR, NOTAS->LOJA, AllTrim(NOTAS->NOMCLIEFOR), NOTAS->VALCONT, NOTAS->BASEPIS, NOTAS->BASECOF, NOTAS->VALPIS, NOTAS->VALCOF})
		aAdd(aExcel, {''})
		
		//gerando analítico conforme escolha do usuário
		If MV_PAR08 <> 5
			Analitico(MV_PAR08, aExcel, aTCF, aTCC)
		Else
			Analitico(1, aExcel, aTCF, aTCC)
			Analitico(2, aExcel, aTCF, aTCC)
			Analitico(3, aExcel, aTCF, aTCC)
			Analitico(4, aExcel, aTCF, aTCC)
		EndIf
		
		aAdd(aExcel, {''})
		
		cFAnt := NOTAS->FILIAL
		NOTAS->(dbSkip())
	EndDo
	
	NOTAS->(dbCloseArea())
	
	If MV_PAR08 == 1 .and. MV_PAR09 == 1
		//Modificado por Walber Freire
		//-Exibindo totalizadores
		aAdd(aExcel, {'', 'Totalizadores Gerais:'})
		aAdd(aExcel, {'', '', 'CFOP','Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
	   nMax := len(aTCF)
	   nTot1 := 0
	   nTot2 := 0
	   nTot3 := 0
	   nTot4 := 0
	   nTot5 := 0
	   For nI := 1 to nMax
	   	nTot1 += aTCF[nI][2]
	   	nTot2 += aTCF[nI][3]
	   	nTot3 += aTCF[nI][4]
	   	nTot4 += aTCF[nI][5]
	   	nTot5 += aTCF[nI][6]
	   	aAdd(aExcel, {'', '', aTCF[nI][1],aTCF[nI][2],aTCF[nI][3],aTCF[nI][4],aTCF[nI][5],aTCF[nI][6]})
	   Next nI
   	aAdd(aExcel, {'', '', 'Totais',nTot1,nTot2,nTot3,nTot4,nTot5})
		aAdd(aExcel, {'', ''})
		aAdd(aExcel, {'', 'C.Contabil', 'Desc. Grp Contabil','Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'}) 
		nMax := len(aTCC)
	   nTot1 := 0
	   nTot2 := 0
	   nTot3 := 0
	   nTot4 := 0
	   nTot5 := 0
		For nI := 1 to nMax
	   	nTot1 += aTCC[nI][3]
	   	nTot2 += aTCC[nI][4]
	   	nTot3 += aTCC[nI][5]
	   	nTot4 += aTCC[nI][6]
	   	nTot5 += aTCC[nI][7]
	   	aAdd(aExcel, {'', aTCC[nI][1],aTCC[nI][2],aTCC[nI][3],aTCC[nI][4],aTCC[nI][5],aTCC[nI][6],aTCC[nI][7]})
	   Next nI
   	aAdd(aExcel, {'', 'Totais','',nTot1,nTot2,nTot3,nTot4,nTot5})
	   aTCF := {}
	   aTCC := {}
	 EndIf
	
Else
	//somente analítico = SIM
	Analitico(MV_PAR08, aExcel, aTCF, aTCC)
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

Static Function Analitico(nTipo, aExcel, aTCF, aTCC)

Local cQry, cAux, cFAnt
Local nCnt
/*
Modificado por Walber Freire
-Criando variáveis para totalizar por cfop e por conta contábil
*/
Local aTCFOP  := {}
Local aTCCont := {}
Local nPos    := 0
Local nI
Local nMax
Local nTot1, nTot2, nTot3, nTot4, nTot5

If nTipo == 1
/* 
Modificado por Walber Freire
-Inclusão do grupo contábil e conta contábil no relatório.
bkp:
----------------------------------------------------------
	//produto
	cQry :=        " SELECT FT_PRODUTO CODIGO,"
	cQry += CRLF + "        B1_DESC DESCRICAO,"
	cQry += CRLF + "        FT_CFOP CFOP,"
	cQry += CRLF + "        FT_POSIPI NCM,"
	cQry += CRLF + "        FT_TNATREC TNATREC,"
	cQry += CRLF + "        FT_CNATREC CNATREC,"
	cQry += CRLF + "        FT_CSTPIS CSTPIS,"
	cQry += CRLF + "        FT_CSTCOF CSTCOF,"
	If MV_PAR09 == 1
		cQry += CRLF + "        FT_VALCONT VALCONT,"
		cQry += CRLF + "        FT_BASEPIS BASEPIS,"
		cQry += CRLF + "        FT_BASECOF BASECOF,"
		cQry += CRLF + "        FT_VALPIS VALPIS,"
		cQry += CRLF + "        FT_VALCOF VALCOF"
	Else
		cQry += CRLF + "        FT_FILIAL FILIAL,"
		cQry += CRLF + "        SUM(FT_VALCONT) VALCONT,"
		cQry += CRLF + "        SUM(FT_BASEPIS) BASEPIS,"
		cQry += CRLF + "        SUM(FT_BASECOF) BASECOF,"
		cQry += CRLF + "        SUM(FT_VALPIS) VALPIS,"
		cQry += CRLF + "        SUM(FT_VALCOF) VALCOF"
	EndIf
	cQry += CRLF + " FROM "+RetSqlName('SFT')+" SFT,"
	cQry += CRLF + "      "+RetSqlName('SB1')+" SB1"
	cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND SB1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_PRODUTO = B1_COD"
	If MV_PAR09 == 1
		cQry += CRLF + "   AND FT_FILIAL = '"+NOTAS->FILIAL+"'"
		cQry += CRLF + "   AND B1_FILIAL = '"+Iif(AllTrim(xFilial('SB1'))=='',xFilial('SB1'),NOTAS->FILIAL)+"'"
		cQry += CRLF + "   AND FT_NFISCAL = '"+NOTAS->DOC+"'"
		cQry += CRLF + "   AND FT_SERIE = '"+NOTAS->SERIE+"'"
		cQry += CRLF + "   AND FT_CLIEFOR = '"+NOTAS->CLIEFOR+"'"
		cQry += CRLF + "   AND FT_LOJA = '"+NOTAS->LOJA+"'"
	Else
		cQry += CRLF + "   AND FT_ENTRADA >= '"+DTOS(MV_PAR01)+"'"
		cQry += CRLF + "   AND FT_ENTRADA <= '"+DTOS(MV_PAR02)+"'"
		cQry += CRLF + "   AND LEN(FT_DTCANC) = 0"
		cQry += CRLF + "   AND FT_FILIAL >= '"+MV_PAR03+"'"
		cQry += CRLF + "   AND FT_FILIAL <= '"+MV_PAR04+"'"
		cQry += CRLF + "   AND B1_FILIAL = "+Iif(AllTrim(xFilial('SB1'))=='',"'"+xFilial('SB1')+"'",'FT_FILIAL')
		If MV_PAR05 == 1
			cQry += CRLF + "   AND LEFT(FT_CFOP,1) < '5'"
		Else
			cQry += CRLF + "   AND LEFT(FT_CFOP,1) >= '5'"
		EndIf
		If AllTrim(MV_PAR06) <> ''
			cQry += CRLF + "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR06))
		EndIf
		If AllTrim(MV_PAR07) <> ''
			cQry += CRLF + "   AND FT_CSTPIS IN "+U_MyGeraIn(AllTrim(MV_PAR07))
		EndIf
	EndIf
	If MV_PAR09 == 2
		cQry += CRLF + " GROUP BY FT_FILIAL,"
		cQry += CRLF + "          FT_PRODUTO,"
		cQry += CRLF + "          B1_DESC,"
		cQry += CRLF + "          FT_CFOP,"
		cQry += CRLF + "          FT_POSIPI,"
		cQry += CRLF + "          FT_TNATREC,"
		cQry += CRLF + "          FT_CNATREC,"
		cQry += CRLF + "          FT_CSTPIS,"
		cQry += CRLF + "          FT_CSTCOF"
	EndIf
	If MV_PAR09 == 1
		cQry += CRLF + " ORDER BY FT_PRODUTO"
	Else
		cQry += CRLF + " ORDER BY FT_FILIAL,"
		cQry += CRLF + "          FT_PRODUTO"
	EndIf
	
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'ANA',.T.)
	If MV_PAR09 == 1
		aAdd(aExcel, {'', 'Por Produto'})
		aAdd(aExcel, {'', '', 'Código', 'Descrição', 'CFOP', 'NCM', 'Tab Nat Receita', 'Cód Nat Receita', 'CST PIS', 'CST COFINS', 'Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
	Else
		nCnt := 0
		ANA->(dbEval({||nCnt++}))
		ProcRegua(nCnt)
		ANA->(dbGoTop())
	EndIf
	cFAnt := ''
	While !ANA->(Eof())
		If MV_PAR09 == 2
			If cFAnt <> ANA->FILIAL
				//inicia nova empresa
				aAdd(aExcel, {''})
				SM0->(dbSetOrder(1))
				SM0->(dbSeek(cEmpAnt+ANA->FILIAL))
				cAux := 'Empresa: '+cEmpAnt+'/'+ANA->FILIAL+'-'+AllTrim(SM0->M0_NOME)+' '+AllTrim(SM0->M0_FILIAL)+' - CNPJ: '+Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')
				IncProc(cAux)
				aAdd(aExcel, {cAux})
				aAdd(aExcel, {'', 'Por Produto'})
				aAdd(aExcel, {'', '', 'Código', 'Descrição', 'CFOP', 'NCM', 'Tab Nat Receita', 'Cód Nat Receita', 'CST PIS', 'CST COFINS', 'Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
			Else
				IncProc()
			EndIf
		EndIf
		aAdd(aExcel, {'', '', ANA->CODIGO, ANA->DESCRICAO, ANA->CFOP, ANA->NCM, ANA->TNATREC, ANA->CNATREC, ANA->CSTPIS, ANA->CSTCOF, ANA->VALCONT, ANA->BASEPIS, ANA->BASECOF, ANA->VALPIS, ANA->VALCOF})
		
		If MV_PAR09 == 2
			cFAnt := ANA->FILIAL
		EndIf
		
		ANA->(dbSkip())
	EndDo
	ANA->(dbCloseArea())
----------------------------------------------------------
*/
	//produto
	cQry :=        " SELECT FT_PRODUTO CODIGO,"
	cQry += CRLF + "        B1_DESC DESCRICAO,"
	If MV_PAR09 == 1
		cQry += CRLF + "        B1_GRPCTB GRPCTB,"
		cQry += CRLF + "        Z3_DESCGRP DESCGRP,"
		cQry += CRLF + "        Z3_CTCUSTO CTCUSTO,"
	EndIf
	cQry += CRLF + "        FT_CFOP CFOP,"
	cQry += CRLF + "        FT_POSIPI NCM,"
	cQry += CRLF + "        FT_TNATREC TNATREC,"
	cQry += CRLF + "        FT_CNATREC CNATREC,"
	cQry += CRLF + "        FT_CSTPIS CSTPIS,"
	cQry += CRLF + "        FT_CSTCOF CSTCOF,"
	If MV_PAR09 == 1
		//somente analítico = NAO
		cQry += CRLF + "        FT_VALCONT VALCONT,"
		cQry += CRLF + "        FT_BASEPIS BASEPIS,"
		cQry += CRLF + "        FT_BASECOF BASECOF,"
		cQry += CRLF + "        FT_VALPIS VALPIS,"
		cQry += CRLF + "        FT_VALCOF VALCOF"
	Else
		cQry += CRLF + "        FT_FILIAL FILIAL,"
		cQry += CRLF + "        SUM(FT_VALCONT) VALCONT,"
		cQry += CRLF + "        SUM(FT_BASEPIS) BASEPIS,"
		cQry += CRLF + "        SUM(FT_BASECOF) BASECOF,"
		cQry += CRLF + "        SUM(FT_VALPIS) VALPIS,"
		cQry += CRLF + "        SUM(FT_VALCOF) VALCOF"
	EndIf
	cQry += CRLF + " FROM "+RetSqlName('SFT')+" SFT,"
	cQry += CRLF + "      "+RetSqlName('SB1')+" SB1"
	
	If MV_PAR09 == 1
		cQry += CRLF + " LEFT JOIN "+RetSqlName('SZ3')+" SZ3"
		cQry += CRLF + " ON Z3_COD = B1_GRPCTB"
		cQry += CRLF + " AND SZ3.D_E_L_E_T_ <> '*'"
		cQry += CRLF + " AND Z3_FILIAL = '"+Iif(AllTrim(xFilial('SZ3'))=='',xFilial('SZ3'),NOTAS->FILIAL)+"'"
	EndIf
	
	cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND SB1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_PRODUTO = B1_COD"
	If MV_PAR09 == 1
		//somente analítico = NAO
		cQry += CRLF + "   AND FT_FILIAL = '"+NOTAS->FILIAL+"'"
		cQry += CRLF + "   AND B1_FILIAL = '"+Iif(AllTrim(xFilial('SB1'))=='',xFilial('SB1'),NOTAS->FILIAL)+"'"
		cQry += CRLF + "   AND FT_NFISCAL = '"+NOTAS->DOC+"'"
		cQry += CRLF + "   AND FT_SERIE = '"+NOTAS->SERIE+"'"
		cQry += CRLF + "   AND FT_CLIEFOR = '"+NOTAS->CLIEFOR+"'"
		cQry += CRLF + "   AND FT_LOJA = '"+NOTAS->LOJA+"'"
	Else
		cQry += CRLF + "   AND FT_ENTRADA >= '"+DTOS(MV_PAR01)+"'"
		cQry += CRLF + "   AND FT_ENTRADA <= '"+DTOS(MV_PAR02)+"'"
		cQry += CRLF + "   AND LEN(FT_DTCANC) = 0"
		cQry += CRLF + "   AND FT_FILIAL >= '"+MV_PAR03+"'"
		cQry += CRLF + "   AND FT_FILIAL <= '"+MV_PAR04+"'"
		cQry += CRLF + "   AND B1_FILIAL = "+Iif(AllTrim(xFilial('SB1'))=='',"'"+xFilial('SB1')+"'",'FT_FILIAL')
		If MV_PAR05 == 1
			cQry += CRLF + "   AND LEFT(FT_CFOP,1) < '5'"
		Else
			cQry += CRLF + "   AND LEFT(FT_CFOP,1) >= '5'"
		EndIf
		/*
		If AllTrim(MV_PAR06) <> ''
			cQry += CRLF + "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR06))
		EndIf
		If AllTrim(MV_PAR07) <> ''
			cQry += CRLF + "   AND FT_CSTPIS IN "+U_MyGeraIn(AllTrim(MV_PAR07))
		EndIf
		*/
	EndIf
	
	If AllTrim(MV_PAR06) <> ''
		cQry += CRLF + "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR06))
	EndIf
	If AllTrim(MV_PAR07) <> ''
		cQry += CRLF + "   AND FT_CSTPIS IN "+U_MyGeraIn(AllTrim(MV_PAR07))
	EndIf
	If AllTrim(MV_PAR10) <> ''
		cQry += CRLF + "   AND FT_CLIEFOR IN "+U_MyGeraIn(AllTrim(MV_PAR10))
	EndIf
		
	If MV_PAR09 == 2
		cQry += CRLF + " GROUP BY FT_FILIAL,"
		cQry += CRLF + "          FT_PRODUTO,"
		cQry += CRLF + "          B1_DESC,"
		cQry += CRLF + "          FT_CFOP,"
		cQry += CRLF + "          FT_POSIPI,"
		cQry += CRLF + "          FT_TNATREC,"
		cQry += CRLF + "          FT_CNATREC,"
		cQry += CRLF + "          FT_CSTPIS,"
		cQry += CRLF + "          FT_CSTCOF"
	EndIf
	If MV_PAR09 == 1
		cQry += CRLF + " ORDER BY FT_PRODUTO"
	Else
		cQry += CRLF + " ORDER BY FT_FILIAL,"
		cQry += CRLF + "          FT_PRODUTO"
	EndIf
	
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'ANA',.T.)
	If MV_PAR09 == 1
		aAdd(aExcel, {'', 'Por Produto'})
		aAdd(aExcel, {'', '', 'Código', 'Descrição', 'Grp Contabil', 'Desc. Grp Contabil', 'C.Contabil', 'CFOP', 'NCM', 'Tab Nat Receita', 'Cód Nat Receita', 'CST PIS', 'CST COFINS', 'Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
	Else
		nCnt := 0
		ANA->(dbEval({||nCnt++}))
		ProcRegua(nCnt)
		ANA->(dbGoTop())
	EndIf
	cFAnt := ''
	While !ANA->(Eof())
		If MV_PAR09 == 2
			If cFAnt <> ANA->FILIAL
				//inicia nova empresa
				aAdd(aExcel, {''})
				SM0->(dbSetOrder(1))
				SM0->(dbSeek(cEmpAnt+ANA->FILIAL))
				cAux := 'Empresa: '+cEmpAnt+'/'+ANA->FILIAL+'-'+AllTrim(SM0->M0_NOME)+' '+AllTrim(SM0->M0_FILIAL)+' - CNPJ: '+Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')
				IncProc(cAux)
				aAdd(aExcel, {cAux})
				aAdd(aExcel, {'', 'Por Produto'})
				aAdd(aExcel, {'', '', 'Código', 'Descrição', 'CFOP', 'NCM', 'Tab Nat Receita', 'Cód Nat Receita', 'CST PIS', 'CST COFINS', 'Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
			Else
				IncProc()
			EndIf
		EndIf
		If MV_PAR09 == 1
			nPos := 0
			nPos := aScan(aTCFOP, {|x| x[1] == ANA->CFOP})
			If nPos <> 0
				aTCFOP[nPos,2] += ANA->VALCONT
				aTCFOP[nPos,3] += ANA->BASEPIS
				aTCFOP[nPos,4] += ANA->BASECOF
				aTCFOP[nPos,5] += ANA->VALPIS
				aTCFOP[nPos,6] += ANA->VALCOF
			Else
				aAdd(aTCFOP, {ANA->CFOP, ANA->VALCONT, ANA->BASEPIS, ANA->BASECOF, ANA->VALPIS, ANA->VALCOF})
			EndIf
			
			nPos := 0
			nPos := aScan(aTCCont, {|x| x[1] == ANA->CTCUSTO})
			If nPos <> 0
				aTCCont[nPos,2] += ANA->VALCONT
				aTCCont[nPos,3] += ANA->BASEPIS
				aTCCont[nPos,4] += ANA->BASECOF
				aTCCont[nPos,5] += ANA->VALPIS
				aTCCont[nPos,6] += ANA->VALCOF
			Else
				aAdd(aTCCont, {ANA->CTCUSTO, ANA->VALCONT, ANA->BASEPIS, ANA->BASECOF, ANA->VALPIS, ANA->VALCOF})
			EndIf
						
			//Totalizadores Gerais
			nPos := 0
			nPos := aScan(aTCF, {|x| x[1] == ANA->CFOP})
			If nPos <> 0
				aTCF[nPos,2] += ANA->VALCONT
				aTCF[nPos,3] += ANA->BASEPIS
				aTCF[nPos,4] += ANA->BASECOF
				aTCF[nPos,5] += ANA->VALPIS
				aTCF[nPos,6] += ANA->VALCOF
			Else
				aAdd(aTCF, {ANA->CFOP, ANA->VALCONT, ANA->BASEPIS, ANA->BASECOF, ANA->VALPIS, ANA->VALCOF})
			EndIf
			
			nPos := 0
			nPos := aScan(aTCC, {|x| x[1] == ANA->CTCUSTO})
			If nPos <> 0
				aTCC[nPos,3] += ANA->VALCONT
				aTCC[nPos,4] += ANA->BASEPIS
				aTCC[nPos,5] += ANA->BASECOF
				aTCC[nPos,6] += ANA->VALPIS
				aTCC[nPos,7] += ANA->VALCOF
			Else
				aAdd(aTCC, {ANA->CTCUSTO, AllTrim(ANA->DESCGRP), ANA->VALCONT, ANA->BASEPIS, ANA->BASECOF, ANA->VALPIS, ANA->VALCOF})
			EndIf
		EndIf
		
		If MV_PAR09 == 2
			aAdd(aExcel, {'', '', ANA->CODIGO, ANA->DESCRICAO, ANA->CFOP, ANA->NCM, ANA->TNATREC, ANA->CNATREC, ANA->CSTPIS, ANA->CSTCOF, ANA->VALCONT, ANA->BASEPIS, ANA->BASECOF, ANA->VALPIS, ANA->VALCOF})
		Else
			aAdd(aExcel, {'', '', ANA->CODIGO, ANA->DESCRICAO, ANA->GRPCTB, AllTrim(ANA->DESCGRP), ANA->CTCUSTO, ANA->CFOP, ANA->NCM, ANA->TNATREC, ANA->CNATREC, ANA->CSTPIS, ANA->CSTCOF, ANA->VALCONT, ANA->BASEPIS, ANA->BASECOF, ANA->VALPIS, ANA->VALCOF})
		EndIf
		
		If MV_PAR09 == 2
			cFAnt := ANA->FILIAL
		EndIf
		
		ANA->(dbSkip())
	EndDo
	ANA->(dbCloseArea())
   
	//Modificado por Walber Freire
	//-Exibindo totalizadores
	aAdd(aExcel, {'', '','','','','','','','','','','', 'Totalizadores:'})
	aAdd(aExcel, {'', '','','','','','','','','','','', 'CFOP','Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
   nMax := len(aTCFOP)
   nTot1 := 0
   nTot2 := 0
   nTot3 := 0
   nTot4 := 0
   nTot5 := 0
   For nI := 1 to nMax
   	nTot1 += aTCF[nI][2]
   	nTot2 += aTCF[nI][3]
   	nTot3 += aTCF[nI][4]
   	nTot4 += aTCF[nI][5]
   	nTot5 += aTCF[nI][6]
   	aAdd(aExcel, {'', '','','','','','','','','','','',aTCFOP[nI][1],aTCFOP[nI][2],aTCFOP[nI][3],aTCFOP[nI][4],aTCFOP[nI][5],aTCFOP[nI][6]})
   Next nI
  	aAdd(aExcel, {'', '','','','','','','','','','','','Totais',nTot1,nTot2,nTot3,nTot4,nTot5})
	aAdd(aExcel, {'', ''})
	aAdd(aExcel, {'', '','','','','','','','','','','', 'C.Contabil','Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'}) 
	nMax := len(aTCCont)
   nTot1 := 0
   nTot2 := 0
   nTot3 := 0
   nTot4 := 0
   nTot5 := 0
	For nI := 1 to nMax
   	nTot1 += aTCCont[nI][2]
   	nTot2 += aTCCont[nI][3]
   	nTot3 += aTCCont[nI][4]
   	nTot4 += aTCCont[nI][5]
   	nTot5 += aTCCont[nI][6]
   	aAdd(aExcel, {'', '','','','','','','','','','','',aTCCont[nI][1],aTCCont[nI][2],aTCCont[nI][3],aTCCont[nI][4],aTCCont[nI][5],aTCCont[nI][6]})
   Next nI
  	aAdd(aExcel, {'', '','','','','','','','','','','','Totais',nTot1,nTot2,nTot3,nTot4,nTot5})   
   aTCFOP := {}
   aTCCont := {}
ElseIf nTipo == 2
	//ncm
	cQry :=        " SELECT FT_POSIPI CODIGO,"
	cQry += CRLF + "        YD_DESC_P DESCRICAO,"
	If MV_PAR09 == 2
		cQry += CRLF + "        FT_FILIAL FILIAL,"
	EndIf
	cQry += CRLF + "        SUM(FT_VALCONT) VALCONT,"
	cQry += CRLF + "        SUM(FT_BASEPIS) BASEPIS,"
	cQry += CRLF + "        SUM(FT_BASECOF) BASECOF,"
	cQry += CRLF + "        SUM(FT_VALPIS) VALPIS,"
	cQry += CRLF + "        SUM(FT_VALCOF) VALCOF"
	cQry += CRLF + " FROM "+RetSqlName('SFT')+" SFT,"
	cQry += CRLF + "      "+RetSqlName('SB1')+" SB1"
	cQry += CRLF + " LEFT JOIN "+RetSqlName('SYD')+" SYD"
	cQry += CRLF + " ON  B1_POSIPI = YD_TEC"
	cQry += CRLF + " AND B1_EX_NCM = YD_EX_NCM"
	cQry += CRLF + " AND SYD.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND YD_FILIAL = '"+Iif(AllTrim(xFilial('SYD'))=='',xFilial('SYD'),NOTAS->FILIAL)+"'"
	cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND SB1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_PRODUTO = B1_COD"
	If MV_PAR09 == 1
		cQry += CRLF + "   AND FT_FILIAL = '"+NOTAS->FILIAL+"'"
		cQry += CRLF + "   AND B1_FILIAL = '"+Iif(AllTrim(xFilial('SB1'))=='',xFilial('SB1'),NOTAS->FILIAL)+"'"
		cQry += CRLF + "   AND FT_NFISCAL = '"+NOTAS->DOC+"'"
		cQry += CRLF + "   AND FT_SERIE = '"+NOTAS->SERIE+"'"
		cQry += CRLF + "   AND FT_CLIEFOR = '"+NOTAS->CLIEFOR+"'"
		cQry += CRLF + "   AND FT_LOJA = '"+NOTAS->LOJA+"'"
	Else
		cQry += CRLF + "   AND FT_ENTRADA >= '"+DTOS(MV_PAR01)+"'"
		cQry += CRLF + "   AND FT_ENTRADA <= '"+DTOS(MV_PAR02)+"'"
		cQry += CRLF + "   AND LEN(FT_DTCANC) = 0"
		cQry += CRLF + "   AND FT_FILIAL >= '"+MV_PAR03+"'"
		cQry += CRLF + "   AND FT_FILIAL <= '"+MV_PAR04+"'"
		cQry += CRLF + "   AND B1_FILIAL = "+Iif(AllTrim(xFilial('SB1'))=='',"'"+xFilial('SB1')+"'",'FT_FILIAL')
		If MV_PAR05 == 1
			cQry += CRLF + "   AND LEFT(FT_CFOP,1) < '5'"
		Else
			cQry += CRLF + "   AND LEFT(FT_CFOP,1) >= '5'"
		EndIf
		/*
		If AllTrim(MV_PAR06) <> ''
			cQry += CRLF + "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR06))
		EndIf
		If AllTrim(MV_PAR07) <> ''
			cQry += CRLF + "   AND FT_CSTPIS IN "+U_MyGeraIn(AllTrim(MV_PAR07))
		EndIf*/
	EndIf
	If AllTrim(MV_PAR06) <> ''
		cQry += CRLF + "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR06))
	EndIf
	If AllTrim(MV_PAR07) <> ''
		cQry += CRLF + "   AND FT_CSTPIS IN "+U_MyGeraIn(AllTrim(MV_PAR07))
	EndIf
	If AllTrim(MV_PAR10) <> ''
		cQry += CRLF + "   AND FT_CLIEFOR IN "+U_MyGeraIn(AllTrim(MV_PAR10))
	EndIf
	If MV_PAR09 == 1
		cQry += CRLF + " GROUP BY FT_POSIPI,"
		cQry += CRLF + "          YD_DESC_P"
	Else
		cQry += CRLF + " GROUP BY FT_FILIAL,"
		cQry += CRLF + "          FT_POSIPI,"
		cQry += CRLF + "          YD_DESC_P"
	EndIf
	If MV_PAR09 == 1
		cQry += CRLF + " ORDER BY FT_POSIPI,"
		cQry += CRLF + "          YD_DESC_P"
	Else
		cQry += CRLF + " ORDER BY FT_FILIAL,"
		cQry += CRLF + "          FT_POSIPI,"
		cQry += CRLF + "          YD_DESC_P"
	EndIf
	
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'ANA',.T.)
	If MV_PAR09 == 1
		aAdd(aExcel, {'', 'Por NCM'})
		aAdd(aExcel, {'', '', 'Código', 'Descrição', 'Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
	Else
		nCnt := 0
		ANA->(dbEval({||nCnt++}))
		ProcRegua(nCnt)
		ANA->(dbGoTop())
	EndIf
	cFAnt := ''
	While !ANA->(Eof())
		If MV_PAR09 == 2
			If cFAnt <> ANA->FILIAL
				//inicia nova empresa
				aAdd(aExcel, {''})
				SM0->(dbSetOrder(1))
				SM0->(dbSeek(cEmpAnt+ANA->FILIAL))
				cAux := 'Empresa: '+cEmpAnt+'/'+ANA->FILIAL+'-'+AllTrim(SM0->M0_NOME)+' '+AllTrim(SM0->M0_FILIAL)+' - CNPJ: '+Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')
				IncProc(cAux)
				aAdd(aExcel, {cAux})
				aAdd(aExcel, {'', 'Por NCM'})
				aAdd(aExcel, {'', '', 'Código', 'Descrição', 'Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
			Else
				IncProc()
			EndIf
		EndIf
		aAdd(aExcel, {'', '', ANA->CODIGO, ANA->DESCRICAO, ANA->VALCONT, ANA->BASEPIS, ANA->BASECOF, ANA->VALPIS, ANA->VALCOF})
		
		If MV_PAR09 == 2
			cFAnt := ANA->FILIAL
		EndIf
		
		ANA->(dbSkip())
	EndDo
	ANA->(dbCloseArea())
ElseIf nTipo == 3
	//tab+cód nat receita
	cQry :=        " SELECT FT_TNATREC TABELA,"
	cQry += CRLF + "        FT_CNATREC CODIGO,"
	cQry += CRLF + "        CCZ_DESC DESCRICAO,"
	If MV_PAR09 == 2
		cQry += CRLF + "        FT_FILIAL FILIAL,"
	EndIf
	cQry += CRLF + "        SUM(FT_VALCONT) VALCONT,"
	cQry += CRLF + "        SUM(FT_BASEPIS) BASEPIS,"
	cQry += CRLF + "        SUM(FT_BASECOF) BASECOF,"
	cQry += CRLF + "        SUM(FT_VALPIS) VALPIS,"
	cQry += CRLF + "        SUM(FT_VALCOF) VALCOF"
	cQry += CRLF + " FROM "+RetSqlName('SFT')+" SFT"
	cQry += CRLF + " LEFT JOIN "+RetSqlName('CCZ')+" CCZ"
	cQry += CRLF + " ON  FT_TNATREC = CCZ_TABELA"
	cQry += CRLF + " AND FT_CNATREC = CCZ_COD"
	cQry += CRLF + " AND CCZ.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND CCZ_FILIAL = '"+Iif(AllTrim(xFilial('CCZ'))=='',xFilial('CCZ'),NOTAS->FILIAL)+"'"
	cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
	If MV_PAR09 == 1
		cQry += CRLF + "   AND FT_FILIAL = '"+NOTAS->FILIAL+"'"
		cQry += CRLF + "   AND FT_NFISCAL = '"+NOTAS->DOC+"'"
		cQry += CRLF + "   AND FT_SERIE = '"+NOTAS->SERIE+"'"
		cQry += CRLF + "   AND FT_CLIEFOR = '"+NOTAS->CLIEFOR+"'"
		cQry += CRLF + "   AND FT_LOJA = '"+NOTAS->LOJA+"'"
	Else
		cQry += CRLF + "   AND FT_ENTRADA >= '"+DTOS(MV_PAR01)+"'"
		cQry += CRLF + "   AND FT_ENTRADA <= '"+DTOS(MV_PAR02)+"'"
		cQry += CRLF + "   AND LEN(FT_DTCANC) = 0"
		cQry += CRLF + "   AND FT_FILIAL >= '"+MV_PAR03+"'"
		cQry += CRLF + "   AND FT_FILIAL <= '"+MV_PAR04+"'"
		If MV_PAR05 == 1
			cQry += CRLF + "   AND LEFT(FT_CFOP,1) < '5'"
		Else
			cQry += CRLF + "   AND LEFT(FT_CFOP,1) >= '5'"
		EndIf
		/*
		If AllTrim(MV_PAR06) <> ''
			cQry += CRLF + "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR06))
		EndIf
		If AllTrim(MV_PAR07) <> ''
			cQry += CRLF + "   AND FT_CSTPIS IN "+U_MyGeraIn(AllTrim(MV_PAR07))
		EndIf
		*/
	EndIf
	
	If AllTrim(MV_PAR06) <> ''
		cQry += CRLF + "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR06))
	EndIf
	If AllTrim(MV_PAR07) <> ''
		cQry += CRLF + "   AND FT_CSTPIS IN "+U_MyGeraIn(AllTrim(MV_PAR07))
	EndIf
	If AllTrim(MV_PAR10) <> ''
		cQry += CRLF + "   AND FT_CLIEFOR IN "+U_MyGeraIn(AllTrim(MV_PAR10))
	EndIf
	If MV_PAR09 == 1
		cQry += CRLF + " GROUP BY FT_TNATREC,"
		cQry += CRLF + "          FT_CNATREC,"
		cQry += CRLF + "          CCZ_DESC"
	Else
		cQry += CRLF + " GROUP BY FT_FILIAL,"
		cQry += CRLF + "          FT_TNATREC,"
		cQry += CRLF + "          FT_CNATREC,"
		cQry += CRLF + "          CCZ_DESC"
	EndIf
	If MV_PAR09 == 1
		cQry += CRLF + " ORDER BY FT_TNATREC,"
		cQry += CRLF + "          FT_CNATREC,"
		cQry += CRLF + "          CCZ_DESC"
	Else
		cQry += CRLF + " ORDER BY FT_FILIAL,"
		cQry += CRLF + "          FT_TNATREC,"
		cQry += CRLF + "          FT_CNATREC,"
		cQry += CRLF + "          CCZ_DESC"
	EndIf
	
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'ANA',.T.)
	If MV_PAR09 == 1
		aAdd(aExcel, {'', 'Por Tab+Cód Nat. Receita'})
		aAdd(aExcel, {'', '', 'Tabela', 'Código', 'Descrição', 'Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
	Else
		nCnt := 0
		ANA->(dbEval({||nCnt++}))
		ProcRegua(nCnt)
		ANA->(dbGoTop())
	EndIf
	cFAnt := ''
	While !ANA->(Eof())
		If MV_PAR09 == 2
			If cFAnt <> ANA->FILIAL
				//inicia nova empresa
				aAdd(aExcel, {''})
				SM0->(dbSetOrder(1))
				SM0->(dbSeek(cEmpAnt+ANA->FILIAL))
				cAux := 'Empresa: '+cEmpAnt+'/'+ANA->FILIAL+'-'+AllTrim(SM0->M0_NOME)+' '+AllTrim(SM0->M0_FILIAL)+' - CNPJ: '+Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')
				IncProc(cAux)
				aAdd(aExcel, {cAux})
				aAdd(aExcel, {'', 'Por Tab+Cód Nat. Receita'})
				aAdd(aExcel, {'', '', 'Tabela', 'Código', 'Descrição', 'Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
			Else
				IncProc()
			EndIf
		EndIf
		aAdd(aExcel, {'', '', ANA->TABELA, ANA->CODIGO, ANA->DESCRICAO, ANA->VALCONT, ANA->BASEPIS, ANA->BASECOF, ANA->VALPIS, ANA->VALCOF})
		
		If MV_PAR09 == 2
			cFAnt := ANA->FILIAL
		EndIf
		
		ANA->(dbSkip())
	EndDo
	ANA->(dbCloseArea())
ElseIf nTipo == 4
	//cfop
	cQry :=        " SELECT FT_CFOP CODIGO,"
	If MV_PAR09 == 2
		cQry += CRLF + "        FT_FILIAL FILIAL,"
	EndIf
	cQry += CRLF + "        SUM(FT_VALCONT) VALCONT,"
	cQry += CRLF + "        SUM(FT_BASEPIS) BASEPIS,"
	cQry += CRLF + "        SUM(FT_BASECOF) BASECOF,"
	cQry += CRLF + "        SUM(FT_VALPIS) VALPIS,"
	cQry += CRLF + "        SUM(FT_VALCOF) VALCOF"
	cQry += CRLF + " FROM "+RetSqlName('SFT')
	cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
	If MV_PAR09 == 1
		cQry += CRLF + "   AND FT_FILIAL = '"+NOTAS->FILIAL+"'"
		cQry += CRLF + "   AND FT_NFISCAL = '"+NOTAS->DOC+"'"
		cQry += CRLF + "   AND FT_SERIE = '"+NOTAS->SERIE+"'"
		cQry += CRLF + "   AND FT_CLIEFOR = '"+NOTAS->CLIEFOR+"'"
		cQry += CRLF + "   AND FT_LOJA = '"+NOTAS->LOJA+"'"
	Else
		cQry += CRLF + "   AND FT_ENTRADA >= '"+DTOS(MV_PAR01)+"'"
		cQry += CRLF + "   AND FT_ENTRADA <= '"+DTOS(MV_PAR02)+"'"
		cQry += CRLF + "   AND LEN(FT_DTCANC) = 0"
		cQry += CRLF + "   AND FT_FILIAL >= '"+MV_PAR03+"'"
		cQry += CRLF + "   AND FT_FILIAL <= '"+MV_PAR04+"'"
		If MV_PAR05 == 1
			cQry += CRLF + "   AND LEFT(FT_CFOP,1) < '5'"
		Else
			cQry += CRLF + "   AND LEFT(FT_CFOP,1) >= '5'"
		EndIf
		/*
		If AllTrim(MV_PAR06) <> ''
			cQry += CRLF + "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR06))
		EndIf
		If AllTrim(MV_PAR07) <> ''
			cQry += CRLF + "   AND FT_CSTPIS IN "+U_MyGeraIn(AllTrim(MV_PAR07))
		EndIf
		*/
	EndIf
	
	If AllTrim(MV_PAR06) <> ''
		cQry += CRLF + "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR06))
	EndIf
	If AllTrim(MV_PAR07) <> ''
		cQry += CRLF + "   AND FT_CSTPIS IN "+U_MyGeraIn(AllTrim(MV_PAR07))
	EndIf
	If AllTrim(MV_PAR10) <> ''
		cQry += CRLF + "   AND FT_CLIEFOR IN "+U_MyGeraIn(AllTrim(MV_PAR10))
	EndIf
	If MV_PAR09 == 1
		cQry += CRLF + " GROUP BY FT_CFOP"
	Else
		cQry += CRLF + " GROUP BY FT_FILIAL,"
		cQry += CRLF + "          FT_CFOP"
	EndIf
	If MV_PAR09 == 1
		cQry += CRLF + " ORDER BY FT_CFOP"
	Else
		cQry += CRLF + " ORDER BY FT_FILIAL,"
		cQry += CRLF + "          FT_CFOP"
	EndIf
	
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'ANA',.T.)
	If MV_PAR09 == 1
		aAdd(aExcel, {'', 'Por CFOP'})
		aAdd(aExcel, {'', '', 'Código', 'Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
	Else
		nCnt := 0
		ANA->(dbEval({||nCnt++}))
		ProcRegua(nCnt)
		ANA->(dbGoTop())
	EndIf
	cFAnt := ''
	While !ANA->(Eof())
		If MV_PAR09 == 2
			If cFAnt <> ANA->FILIAL
				//inicia nova empresa
				aAdd(aExcel, {''})
				SM0->(dbSetOrder(1))
				SM0->(dbSeek(cEmpAnt+ANA->FILIAL))
				cAux := 'Empresa: '+cEmpAnt+'/'+ANA->FILIAL+'-'+AllTrim(SM0->M0_NOME)+' '+AllTrim(SM0->M0_FILIAL)+' - CNPJ: '+Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')
				IncProc(cAux)
				aAdd(aExcel, {cAux})
				aAdd(aExcel, {'', 'Por CFOP'})
				aAdd(aExcel, {'', '', 'Código', 'Valor Contábil', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
			Else
				IncProc()
			EndIf
		EndIf
		aAdd(aExcel, {'', '', ANA->CODIGO, ANA->VALCONT, ANA->BASEPIS, ANA->BASECOF, ANA->VALPIS, ANA->VALCOF})
		
		If MV_PAR09 == 2
			cFAnt := ANA->FILIAL
		EndIf
		
		ANA->(dbSkip())
	EndDo
	ANA->(dbCloseArea())
EndIf

aAdd(aExcel, {''})

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
aAdd(aHelpPor, 'Selecione se deseja imprimir o livro ')
aAdd(aHelpPor, 'de entrada ou saída.                 ')
cNome := 'Livro'
PutSx1(PadR(cPerg,nTamGrp), '05', cNome, cNome, cNome,;
'MV_CH5', 'C', 1, 0, 0, 'C', '', '', '', '', 'MV_PAR05',;
'Entrada', 'Entrada', 'Entrada', '1',;
'Saida', 'Saida', 'Saida',;
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
aAdd(aHelpPor, 'Informe os CSTs separados por ponto  ')
aAdd(aHelpPor, 'e vígula (;) a serem listados no     ')
aAdd(aHelpPor, 'relatório. Deixe em branco para      ')
aAdd(aHelpPor, 'considerar todos.                    ')
cNome := 'CSTs'
PutSx1(PadR(cPerg,nTamGrp), '07', cNome, cNome, cNome,;
'MV_CH7', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR07',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Selecione o tipo de analítico        ')
aAdd(aHelpPor, 'desejado.                            ')
cNome := 'Tipo de analítico'
PutSx1(PadR(cPerg,nTamGrp), '08', cNome, cNome, cNome,;
'MV_CH8', 'C', 1, 0, 0, 'C', '', '', '', '', 'MV_PAR08',;
'Produto', 'Produto', 'Produto', '1',;
'NCM', 'NCM', 'NCM',;
'Tab+Cód Nat Rec', 'Tab+Cód Nat Rec', 'Tab+Cód Nat Rec',;
'CFOP', 'CFOP', 'CFOP',;
'Todos', 'Todos', 'Todos',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Selecione se deseja imprimir somente ')
aAdd(aHelpPor, 'analítico. Caso escolha "Sim", o     ')
aAdd(aHelpPor, 'parâmetro "Tipo de Analítico" deve   ')
aAdd(aHelpPor, 'ser diferente de "Todos".            ')
cNome := 'Somente analítico'
PutSx1(PadR(cPerg,nTamGrp), '09', cNome, cNome, cNome,;
'MV_CH9', 'C', 1, 0, 0, 'C', '', '', '', '', 'MV_PAR09',;
'Não', 'Não', 'Não', '1',;
'Sim', 'Sim', 'Sim',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe os cliente e fornecedores    ')
aAdd(aHelpPor, 'separados por ponto e vígula (;) a   ')
aAdd(aHelpPor, 'serem listados no relatório. Deixe em')
aAdd(aHelpPor, 'branco para considerar todos.        ')
cNome := 'Cli/For'
PutSx1(PadR(cPerg,nTamGrp), '10', cNome, cNome, cNome,;
'MV_CHA', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR10',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyF100(cFil, dData1, dData2, cFilAte, cFilCST)
///////////////////////////////////////////////////////////////////////////////
// Data : 26/03/2014
// User : Thieres Tembra
// Desc : Esta função executa a query de consulta para verificar os títulos
//        que deverão ser gerados no EFD Contribuições (PIS/COFINS).
//
//        Esta rotina é executada em dois locais:
//        - No ponto de entrada SPDPIS09 que gera os registros F100
//        - No relatório customizado de apuração MyApuPC
//
//        Esta rotina utiliza os parâmetros customizados MY_NATEPC e MY_NATSPC
//        para configurar as naturezas de entrada e saída, respectivamente
//        que deverão ser consultadas, cada um com sua respectiva CST.
///////////////////////////////////////////////////////////////////////////////
// Alterações:
// 1) Thieres Tembra - 06/05/2014
//    Modificado query para trazer somente registros da SE1 onde a diferença
//    entre os campos E1_VALOR e E1_VALCOM5 seja maior que 0.
///////////////////////////////////////////////////////////////////////////////
Local aAreaSX6 := SX6->(GetArea())
Local aRet     := {}
Local aAux1    := {}
Local aAux2    := {}
Local aNat     := {}
Local cQry     := ''
Local cCST     := ''
Local cBCC     := ''
Local nI, nX
Local nMax, nMaxX
Local nPos
Local lGera
Local cAux1, cAux2, cAux3
Local aEntSai := {;
	{'',''},;
	{'',''} ;
}

Default cFilAte := ''
Default cFilCST := ''

If !SX6->(dbSeek('  MY_NATEPC '))
    RecLock('SX6',.T.)
    SX6->X6_VAR     := 'MY_NATEPC '
    SX6->X6_TIPO    := 'C'
    SX6->X6_DESCRIC := 'Informe as naturezas do SE1 p/ o F100 customizado '
    SX6->X6_DESC1   := 'do PIS/COFINS com as CSTs e BCC (se houver).      '
    SX6->X6_DESC2   := 'Formato: NAT-CST-BCC Ex: R02001-01;R02002-01      '
    SX6->X6_CONTEUD := ''
    SX6->X6_PROPRI  := 'U'
    SX6->(MsUnLock())
EndIf
If !SX6->(dbSeek('  MY_NATSPC '))
    RecLock('SX6',.T.)
    SX6->X6_VAR     := 'MY_NATSPC '
    SX6->X6_TIPO    := 'C'
    SX6->X6_DESCRIC := 'Informe as naturezas do SE2 p/ o F100 customizado '
    SX6->X6_DESC1   := 'do PIS/COFINS com as CSTs e BCC (se houver).      '
    SX6->X6_DESC2   := 'Formato: NAT-CST-BCC Ex: D01063-50-06;D01001-70-06'
    SX6->X6_CONTEUD := ''
    SX6->X6_PROPRI  := 'U'
    SX6->(MsUnLock())
EndIf

SX6->(RestArea(aAreaSX6))

//naturezas de entrada
aEntSai[1][1] := GetMV('MY_NATEPC')
aEntSai[1][2] := GetMV('MY_NATSPC')

nMaxX := Len(aEntSai[1])
For nX := 1 to nMaxX
	aAux1 := Separa(aEntSai[1][nX], ';')
	nMax := Len(aAux1)
	For nI := 1 to nMax
		aAux2 := Separa(aAux1[nI], '-')
		
		If Len(aAux2) >= 1
			//limpando campos auxiliares
			cAux1 := ''
			cAux2 := ''
			cAux3 := ''
			
			//associando natureza, CST e BCC em um array
			cAux1 := AllTrim(aAux2[1])
			If Len(aAux2) >= 2
				cAux2 := AllTrim(aAux2[2])
			EndIf
			If Len(aAux2) >= 3
				cAux3 := AllTrim(aAux2[3])
			EndIf
			aAdd(aNat, {cAux1, cAux2, cAux3})
			
			//separando naturezas para usar na query
			aEntSai[2][nX] += cAux1 + ';'
		EndIf
	Next nI
Next nX

cQry := ""
If AllTrim(aEntSai[2][1]) <> ''
	cQry += CRLF + " SELECT"
	cQry += CRLF + "        'SE1'                 AS TABELA"
	cQry += CRLF + "       ,SE1.R_E_C_N_O_        AS RECNUM"
	cQry += CRLF + "       ,E1_NATUREZ            AS NATUREZA"
	cQry += CRLF + "       ,''                    AS CC"
	cQry += CRLF + "       ,(E1_VALOR-E1_VALCOM5) AS VALOR"
	cQry += CRLF + " FROM " + RetSqlName('SE1') + " AS SE1"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SA1') + " AS SA1"
	cQry += CRLF + " ON  SA1.D_E_L_E_T_ <> '*'"
	If AllTrim(xFilial('SA1')) == ''
		cQry += CRLF + " AND A1_FILIAL = ''"
	Else
		cQry += CRLF + " AND A1_FILIAL = E1_FILIAL"
	EndIf
	cQry += CRLF + " AND A1_COD = E1_CLIENTE"
	cQry += CRLF + " AND A1_LOJA = E1_LOJA"
	cQry += CRLF + " WHERE SE1.D_E_L_E_T_ <> '*'"
	If cFilAte == ''
		cQry += CRLF + "   AND E1_FILIAL  = '" + cFil + "'"
	Else
		cQry += CRLF + "   AND E1_FILIAL BETWEEN '" + cFil + "' AND '" + cFilAte + "'"
	EndIf
	cQry += CRLF + "   AND E1_NATUREZ IN " + U_MyGeraIn(aEntSai[2][1])
	cQry += CRLF + "   AND E1_NATUREZ <> ''"
	//cQry += CRLF + "   AND E1_EMISSAO BETWEEN '" + DTOS(dData1) + "' AND '" + DTOS(dData2) + "'"
	cQry += CRLF + "   AND E1_EMIS1 BETWEEN '" + DTOS(dData1) + "' AND '" + DTOS(dData2) + "'"
	//Alt. (1)
	cQry += CRLF + "   AND (E1_VALOR-E1_VALCOM5) > 0"
	//Fim Alt. (1)
	cQry += CRLF + "   AND E1_ORIGEM LIKE 'FIN%'"
	cQry += CRLF + "   AND E1_FATURA <> 'NOTFAT'"
	cQry += CRLF + "   AND E1_TIPO NOT IN ('RA','PR')"
	cQry += CRLF + "   AND A1_PESSOA NOT IN ('F')"
EndIf
If AllTrim(aEntSai[2][1]) <> '' .and. AllTrim(aEntSai[2][2]) <> ''
	cQry += CRLF + " UNION ALL"
EndIf
If AllTrim(aEntSai[2][2]) <> ''
	cQry += CRLF + " SELECT"
	cQry += CRLF + "        'SE2'          AS TABELA"
	cQry += CRLF + "       ,SE2.R_E_C_N_O_ AS RECNUM"
	cQry += CRLF + "       ,E2_NATUREZ     AS NATUREZA"
	cQry += CRLF + "       ,E2_CCD         AS CC"
	cQry += CRLF + "       ,E2_VALOR       AS VALOR"
	cQry += CRLF + " FROM " + RetSqlName('SE2') + " AS SE2"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SA2') + " AS SA2"
	cQry += CRLF + " ON  SA2.D_E_L_E_T_ <> '*'"
	If AllTrim(xFilial('SA2')) == ''
		cQry += CRLF + " AND A2_FILIAL = ''"
	Else
		cQry += CRLF + " AND A2_FILIAL = E2_FILIAL"
	EndIf
	cQry += CRLF + " AND A2_COD = E2_FORNECE"
	cQry += CRLF + " AND A2_LOJA = E2_LOJA"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('CTT') + " AS CTT"
	cQry += CRLF + " ON  CTT.D_E_L_E_T_ <> '*'"
	If AllTrim(xFilial('CTT')) == ''
		cQry += CRLF + " AND CTT_FILIAL = ''"
	Else
		cQry += CRLF + " AND CTT_FILIAL = E2_FILIAL"
	EndIf
	cQry += CRLF + " AND CTT_CUSTO = LEFT(E2_CCD,3)"
	cQry += CRLF + " WHERE SE2.D_E_L_E_T_ <> '*'"
	If cFilAte == ''
		cQry += CRLF + "   AND E2_FILIAL  = '" + cFil + "'"
	Else
		cQry += CRLF + "   AND E2_FILIAL BETWEEN '" + cFil + "' AND '" + cFilAte + "'"
	EndIf
	cQry += CRLF + "   AND E2_NATUREZ IN " + U_MyGeraIn(aEntSai[2][2])
	cQry += CRLF + "   AND E2_NATUREZ <> ''"
	//cQry += CRLF + "   AND E2_EMISSAO BETWEEN '" + DTOS(dData1) + "' AND '" + DTOS(dData2) + "'"
	cQry += CRLF + "   AND E2_EMIS1 BETWEEN '" + DTOS(dData1) + "' AND '" + DTOS(dData2) + "'"
	cQry += CRLF + "   AND E2_ORIGEM LIKE 'FIN%'"
	cQry += CRLF + "   AND E2_FATURA <> 'NOTFAT'"
	cQry += CRLF + "   AND E2_TIPO NOT IN ('PA','PR')"
	cQry += CRLF + "   AND A2_TIPO NOT IN ('F')"
	cQry += CRLF + "   AND CTT_TDCRPC = 'S'"
EndIf

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY',.T.)
While !MQRY->(Eof())
	lGera := .T.
	
	nPos := aScan(aNat, {|x| x[1] == AllTrim(MQRY->NATUREZA)})
	If nPos > 0
		cCST := aNat[nPos][2]
		cBCC := aNat[nPos][3]
	Else
		cCST := ''
		cBCC := ''
	EndIf
	
	//não gera se houver filtro por CST e o título não satifizer as condições
	If cFilCST <> '' .and. cCST <> '' .and. !(cCST $ cFilCST)
		lGera := .F.
	EndIf
	
	If lGera
		//          Tabela      , Natureza               , Centro Custo     , CST , BCC , Valor      , RecNo
		aAdd(aRet, {MQRY->TABELA, AllTrim(MQRY->NATUREZA), AllTrim(MQRY->CC), cCST, cBCC, MQRY->VALOR, MQRY->RECNUM})
	EndIf
	
	MQRY->(dbSkip())
EndDo
MQRY->(dbCloseArea())

Return aClone(aRet)
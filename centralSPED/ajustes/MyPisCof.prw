#include 'rwmake.ch'
#include 'protheus.ch'
#include 'topconn.ch'

//#define NAO_EXECUTA

#define LIMPA_APURACAO		01
#define ATUALIZA_NCM			02

#define ENT_ZPI_PASSO1		03
#define ENT_ZPI_PASSO2		04
#define ENT_GENERICAS		05
#define ENT_MONOF_ALIQZERO	06
#define ENT_TRIBUTADOS		07
#define ENT_TRIBUTADOS_TTL	08
#define ENT_FRETE_GERAL		09
#define ENT_FRETE_CST50		10
#define ENT_DEVOLUCAO		11
#define ENT_ENERGIA			12
#define ENT_PF					13
#define ENT_PF_DEVOLUCAO	14
#define ENT_DEVOLUCAO_ZF	15
#define ENT_DEVOLUCAO_ALC	16
#define ENT_SITTRIB			17
#define ENT_INUTILIZADAS	18
#define ENT_SD1				19
#define ENT_SF1				20

#define SAI_ZPI_PASSO1		21
#define SAI_ZPI_PASSO2		22
#define SAI_GENERICAS		23
#define SAI_MONOF_ALIQZERO	24
#define SAI_TRIBUTADOS		25
#define SAI_SERVICO			26
#define SAI_ZF			 		27
#define SAI_ALC				28
#define SAI_SITTRIB			29
#define SAI_DEVOLUCAO		30
#define SAI_INUTILIZADAS	31
#define SAI_SD2				32
#define SAI_SF2				33

#define QRY_FINAL				34

///////////////////////////////////////////////////////////////////////////////
User Function MyPisCof()
///////////////////////////////////////////////////////////////////////////////
// Data : 27/01/2014
// User : Thieres Tembra
// Desc : Função para calcular PIS/COFINS customizado
///////////////////////////////////////////////////////////////////////////////
Local cPerg := '#MyPisCof '
Local dDtFis := GetMV('MV_DATAFIS')

CriaSX1(cPerg)

If !Pergunte(cPerg, .T.)
	Return Nil
EndIf

//validando MV_DATAFIS
If MV_PAR01 > MV_PAR02
	MsgAlert('O ano mês final deve ser igual ou maior que o ano mês inicial.')
	Return Nil
ElseIf DTOS(dDtFis) > MV_PAR02 + '31'
	MsgAlert('O período selecionado já está bloqueado.' + CRLF + 'O parâmetro MV_DATAFIS está configurado como ' + DTOC(dDtFis) + '.')
	Return Nil
EndIf

Processa({|| Executa() }, 'Calculando PIS/COFINS...')

Return Nil

/* ---------------- */

Static Function Executa()

Local nTam := QRY_FINAL - 1
Local aQry := Array(nTam)
Local aDesc := Array(nTam)
Local aAux1, aAux2, aAux3
Local cQry
Local nI, nMaxI, nJ, nMaxJ, nRet
Local lErro := .F.
Local lExecuta := .T.
Local lNCM := .T.
Local nPIS, nCOF
Local cCFBCC := '02=1126-2126-1407-2407-1556-2556-1653-2653;03=1933-2933;04=1254-2254;13=1351-2351'
Local cCFEnt := ''
Local cCFSai := ''
Local cCFDev := '5202;6202;5210;6210;5411;6411;5413;6413;5661;6661'
Local cCFFre := U_MyGeraIn('1351;2351;1352;2352;1353;2353')
Local cCFEne := U_MyGeraIn('1252;2252;1253;2253;1254;2254')
Local cCFSub := U_MyGeraIn('1401;2401;1403;2403;1406;2406;1407;2407;1651;2651;1652;2652;1653;2653')
Local cCFSer := U_MyGeraIn('5933;6933;5949;6949')

//array para definir o CFOP de entrada padrão por empresa
Local aCFEnt := {;
	{'01', '1126;2126;1254;2254;1351;2351;1407;2407;1556;2556;1653;2653;1922;2922;1933;2933'};
}
//array para definir o CFOP de saída padrão por empresa
Local aCFSai := {;
	{'01', '5353;6353;5933;6933'};
}
//array para definir o que NÃO deverá ser executado por empresa
Local aEmp := {;
	{'01', {;
		ENT_ZPI_PASSO1			,;
		ENT_ZPI_PASSO2			,;
		ENT_MONOF_ALIQZERO	,;
		ENT_TRIBUTADOS			,;
		ENT_DEVOLUCAO_ZF		,;
		ENT_DEVOLUCAO_ALC		,;
		SAI_ZPI_PASSO1			,;
		SAI_ZPI_PASSO2			,;
		SAI_MONOF_ALIQZERO	,;
		SAI_ZF					,;
		SAI_ALC					 ;
	}};
}
//array para definir cruzamento do CFOP com o BCC - Específico TTL
Local aCFxBCC := {}

ProcRegua(0)

//taxas do PIS e COFINS segundo configuração do sistema
nPIS := GetMV('MV_TXPIS')
nCOF := GetMV('MV_TXCOFIN')

SX6->(dbGoTop())
If !SX6->(dbSeek('  MY_CFENTPC'))
	RecLock('SX6',.T.)
	SX6->X6_VAR     := 'MY_CFENTPC'
	SX6->X6_TIPO    := 'C'
	SX6->X6_DESCRIC := 'Informe os CFOPs de entrada que deverao ser       '
	SX6->X6_DESC1   := 'contemplados na rotina customizada de Geracao do  '
	SX6->X6_DESC2   := 'PIS/COFINS. Ex: 1102;1403;1556                    '
	nPos := aScan(aCFEnt, {|x| x[1] == cEmpAnt })
	If nPos > 0
		cCFEnt := aCFEnt[nPos][2]
	EndIf
	SX6->X6_CONTEUD := cCFEnt
	SX6->X6_PROPRI  := 'U'
	SX6->(MsUnlock())
EndIf
SX6->(dbGoTop())
If !SX6->(dbSeek('  MY_CFSAIPC'))
	RecLock('SX6',.T.)
	SX6->X6_VAR     := 'MY_CFSAIPC'
	SX6->X6_TIPO    := 'C'
	SX6->X6_DESCRIC := 'Informe os CFOPs de saida que deverao ser         '
	SX6->X6_DESC1   := 'contemplados na rotina customizada de Geracao do  '
	SX6->X6_DESC2   := 'PIS/COFINS. Ex: 5102;5405;5656                    '
	nPos := aScan(aCFSai, {|x| x[1] == cEmpAnt })
	If nPos > 0
		cCFSai := aCFSai[nPos][2]
	EndIf
	SX6->X6_CONTEUD := cCFSai
	SX6->X6_PROPRI  := 'U'
	SX6->(MsUnlock())
EndIf
SX6->(dbGoTop())
If !SX6->(dbSeek('  MY_CFBCCPC'))
	RecLock('SX6',.T.)
	SX6->X6_VAR     := 'MY_CFBCCPC'
	SX6->X6_TIPO    := 'C'
	SX6->X6_DESCRIC := 'Informe os BCCs x CFOPs para serem utilizados no  '
	SX6->X6_DESC1   := 'cálculo de crédito customizado do PIS/COFINS TTL. '
	SX6->X6_DESC2   := 'Ex: 02=1126-2126-1407-2407;04=1254-2254           '
	SX6->X6_CONTEUD := cCFBCC
	SX6->X6_PROPRI  := 'U'
	SX6->(MsUnlock())
EndIf
SX6->(dbGoTop())
If !SX6->(dbSeek('  MY_CFDEVPC'))
	RecLock('SX6',.T.)
	SX6->X6_VAR     := 'MY_CFDEVPC'
	SX6->X6_TIPO    := 'C'
	SX6->X6_DESCRIC := 'Informe os CFOPs de devolucao que deverao ser     '
	SX6->X6_DESC1   := 'contemplados na rotina customizada de Geracao do  '
	SX6->X6_DESC2   := 'PIS/COFINS. Ex: 5202;6202;5210;6210               '
	SX6->X6_CONTEUD := cCFDev
	SX6->X6_PROPRI  := 'U'
	SX6->(MsUnlock())
EndIf

cCFEnt := U_MyGeraIn(GetMV('MY_CFENTPC'))
cCFSai := U_MyGeraIn(GetMV('MY_CFSAIPC'))
cCFBCC := GetMV('MY_CFBCCPC')
cCFDev := U_MyGeraIn(GetMV('MY_CFDEVPC'))

//criando array de cruzamento CFOP x BCC
aAux1 := Separa(cCFBCC, ';')
nMaxI := Len(aAux1)
For nI := 1 to nMaxI
	//nI = Cada bloco
	aAux2 := Separa(aAux1[nI], '=')
	If Len(aAux2) == 2
		//01 = BCC
		//02 = Conjunto de CFOPs
		aAux3 := Separa(aAux2[2], '-')
		nMaxJ := Len(aAux3)
		For nJ := 1 to nMaxJ
			//nJ = Cada CFOP
			aAdd(aCFxBCC, {aAux3[nJ], aAux2[1]})
		Next nJ
	EndIf
Next nI

//Limpando apuração
nPos := LIMPA_APURACAO
aDesc[nPos] := 'Limpando apuração..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_BASECOF = 0,"
cQry += CRLF + "     FT_BASEPIS = 0,"
cQry += CRLF + "     FT_VALCOF  = 0,"
cQry += CRLF + "     FT_VALPIS  = 0,"
cQry += CRLF + "     FT_BRETCOF = 0,"
cQry += CRLF + "     FT_BRETPIS = 0,"
cQry += CRLF + "     FT_VRETCOF = 0,"
cQry += CRLF + "     FT_VRETPIS = 0,"
cQry += CRLF + "     FT_CSTCOF  = '',"
cQry += CRLF + "     FT_CSTPIS  = '',"
cQry += CRLF + "     FT_CODBCC  = '',"
cQry += CRLF + "     FT_INDNTFR = '',"
cQry += CRLF + "     FT_TNATREC = '',"
cQry += CRLF + "     FT_CNATREC = '',"
cQry += CRLF + "     FT_GRUPONC = '',"
cQry += CRLF + "     FT_DTFIMNT = '',"
cQry += CRLF + "     FT_ALIQCOF = 0,"
cQry += CRLF + "     FT_ALIQPIS = 0,"
cQry += CRLF + "     FT_BASIMP5 = 0,"
cQry += CRLF + "     FT_BASIMP6 = 0,"
cQry += CRLF + "     FT_VALIMP5 = 0,"
cQry += CRLF + "     FT_VALIMP6 = 0,"
cQry += CRLF + "     FT_ALQIMP5 = 0,"
cQry += CRLF + "     FT_ALQIMP6 = 0"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
aQry[nPos] := cQry

//NCM - SB1 > SFT
nPos := ATUALIZA_NCM
aDesc[nPos] := 'Atualizando NCM..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_POSIPI = SB1.B1_POSIPI"
cQry += CRLF + " FROM " + RetSqlName('SFT') + " AS SFT,"
cQry += CRLF + "      " + RetSqlName('SB1') + " AS SB1"
cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SB1.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SFT.FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND SB1.B1_FILIAL = '" + xFilial('SB1') + "'"
cQry += CRLF + "   AND LEFT(SFT.FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND RTRIM(SFT.FT_PRODUTO) = RTRIM(SB1.B1_COD)"
aQry[nPos] := cQry

/* 
 * Entrada
 */
//Atualizando NCM, CST, Codigo e Tabela de Natureza de Receita - ZPI > SFT (SEM DATA FINAL)
nPos := ENT_ZPI_PASSO1
aDesc[nPos] := 'Entrada - Atualizando SFT x ZPI - Passo 1..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_POSIPI  = ZPI.ZPI_NCM,"
cQry += CRLF + "     FT_TNATREC = ZPI.ZPI_TNATRE,"
cQry += CRLF + "     FT_CNATREC = ZPI.ZPI_CNAREC,"
cQry += CRLF + "     FT_DTFIMNT = ZPI.ZPI_DTFIMN,"
cQry += CRLF + "     FT_CSTPIS  = ZPI.ZPI_CSTENT,"
cQry += CRLF + "     FT_CSTCOF  = ZPI.ZPI_CSTENT"
cQry += CRLF + " FROM " + RetSqlName('SFT') + " AS SFT,"
cQry += CRLF + "      " + RetSqlName('SB1') + " AS SB1,"
cQry += CRLF + "      " + RetSqlName('ZPI') + " AS ZPI"
cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SB1.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND ZPI.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SFT.FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND SB1.B1_FILIAL = '" + xFilial('SB1') + "'"
cQry += CRLF + "   AND ZPI.ZPI_FILIAL = '" + xFilial('ZPI') + "'"
cQry += CRLF + "   AND LEFT(SFT.FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND RTRIM(SFT.FT_CFOP) IN " + cCFEnt
cQry += CRLF + "   AND SFT.FT_TIPOMOV = 'E'"
cQry += CRLF + "   AND RTRIM(SFT.FT_PRODUTO) = RTRIM(SB1.B1_COD)"
cQry += CRLF + "   AND RTRIM(ZPI.ZPI_NCM) = RTRIM(SB1.B1_POSIPI)"
cQry += CRLF + "   AND RTRIM(ZPI.ZPI_EX_NCM) = RTRIM(SB1.B1_EX_NCM)"
cQry += CRLF + "   AND SFT.FT_ENTRADA >= ZPI.ZPI_DTININ"
cQry += CRLF + "   AND LEN(ZPI.ZPI_DTFIMN) = 0"
aQry[nPos] := cQry

//Atualizando NCM, CST, Codigo e Tabela de Natureza de Receita - ZPI > SFT (COM DATA FINAL)
nPos := ENT_ZPI_PASSO2
aDesc[nPos] := 'Entrada - Atualizando SFT x ZPI - Passo 2..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_POSIPI  = ZPI.ZPI_NCM,"
cQry += CRLF + "     FT_TNATREC = ZPI.ZPI_TNATRE,"
cQry += CRLF + "     FT_CNATREC = ZPI.ZPI_CNAREC,"
cQry += CRLF + "     FT_DTFIMNT = ZPI.ZPI_DTFIMN,"
cQry += CRLF + "     FT_CSTPIS  = ZPI.ZPI_CSTENT,"
cQry += CRLF + "     FT_CSTCOF  = ZPI.ZPI_CSTENT"
cQry += CRLF + " FROM " + RetSqlName('SFT') + " AS SFT,"
cQry += CRLF + "      " + RetSqlName('SB1') + " AS SB1,"
cQry += CRLF + "      " + RetSqlName('ZPI') + " AS ZPI"
cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SB1.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND ZPI.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SFT.FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND SB1.B1_FILIAL = '" + xFilial('SB1') + "'"
cQry += CRLF + "   AND ZPI.ZPI_FILIAL = '" + xFilial('ZPI') + "'"
cQry += CRLF + "   AND LEFT(SFT.FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND RTRIM(SFT.FT_CFOP) IN " + cCFEnt
cQry += CRLF + "   AND SFT.FT_TIPOMOV = 'E'"
cQry += CRLF + "   AND RTRIM(SFT.FT_PRODUTO) = RTRIM(SB1.B1_COD)"
cQry += CRLF + "   AND RTRIM(ZPI.ZPI_NCM) = RTRIM(SB1.B1_POSIPI)"
cQry += CRLF + "   AND RTRIM(ZPI.ZPI_EX_NCM) = RTRIM(SB1.B1_EX_NCM)"
cQry += CRLF + "   AND SFT.FT_ENTRADA >= ZPI.ZPI_DTININ"
cQry += CRLF + "   AND SFT.FT_ENTRADA <= ZPI.ZPI_DTFIMN"
aQry[nPos] := cQry

//Modifica CST e Valores para situações genéricas
nPos := ENT_GENERICAS
aDesc[nPos] := 'Entrada - Situações genéricas..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_CSTPIS  = '98',"
cQry += CRLF + "     FT_CSTCOF  = '98',"
cQry += CRLF + "     FT_BASECOF = 0,"
cQry += CRLF + "     FT_BASEPIS = 0,"
cQry += CRLF + "     FT_VALCOF  = 0,"
cQry += CRLF + "     FT_VALPIS  = 0,"
cQry += CRLF + "     FT_ALIQCOF = 0,"
cQry += CRLF + "     FT_ALIQPIS = 0,"
cQry += CRLF + "     FT_BASIMP5 = 0,"
cQry += CRLF + "     FT_BASIMP6 = 0,"
cQry += CRLF + "     FT_VALIMP5 = 0,"
cQry += CRLF + "     FT_VALIMP6 = 0,"
cQry += CRLF + "     FT_ALQIMP5 = 0,"
cQry += CRLF + "     FT_ALQIMP6 = 0"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
//cQry += CRLF + "   AND RTRIM(FT_CFOP) NOT IN " + cCFEnt
//cQry += CRLF + "   AND RTRIM(FT_CFOP) NOT IN ('1253','2253','1254','2254','1353','2353')"
cQry += CRLF + "   AND LEN(FT_TNATREC) = 0"
aQry[nPos] := cQry

//Modifica CST e Valores para produtos Monofásicos e Aliq. Zero
nPos := ENT_MONOF_ALIQZERO
aDesc[nPos] := 'Entrada - Monofásicos e Aliq. Zero..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_BASECOF = FT_VALCONT,"
cQry += CRLF + "     FT_BASEPIS = FT_VALCONT,"
cQry += CRLF + "     FT_VALCOF  = 0,"
cQry += CRLF + "     FT_VALPIS  = 0,"
cQry += CRLF + "     FT_ALIQCOF = 0,"
cQry += CRLF + "     FT_ALIQPIS = 0,"
cQry += CRLF + "     FT_BASIMP5 = 0,"
cQry += CRLF + "     FT_BASIMP6 = 0,"
cQry += CRLF + "     FT_VALIMP5 = 0,"
cQry += CRLF + "     FT_VALIMP6 = 0,"
cQry += CRLF + "     FT_ALQIMP5 = 0,"
cQry += CRLF + "     FT_ALQIMP6 = 0"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
cQry += CRLF + "   AND RTRIM(FT_CFOP) IN " + cCFEnt
cQry += CRLF + "   AND LEN(FT_TNATREC) > 0"
aQry[nPos] := cQry

//Modifica CST e Valores para produtos Tributados
nPos := ENT_TRIBUTADOS
aDesc[nPos] := 'Entrada - Tributados..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_CSTPIS  = '50',"
cQry += CRLF + "     FT_CSTCOF  = '50',"
cQry += CRLF + "     FT_CODBCC  = '01',"
cQry += CRLF + "     FT_BASECOF = FT_VALCONT,"
cQry += CRLF + "     FT_BASEPIS = FT_VALCONT,"
cQry += CRLF + "     FT_VALPIS  = ROUND((FT_VALCONT * (" + cValToChar(nPIS) + " / 100)),2),"
cQry += CRLF + "     FT_VALCOF  = ROUND((FT_VALCONT * (" + cValToChar(nCOF) + " / 100)),2),"
cQry += CRLF + "     FT_ALIQPIS = " + cValToChar(nPIS) + ","
cQry += CRLF + "     FT_ALIQCOF = " + cValToChar(nCOF)
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
cQry += CRLF + "   AND ("
cQry += CRLF + "        RTRIM(FT_CFOP) IN " + cCFEnt
cQry += CRLF + "     OR RTRIM(FT_CFOP) IN " + cCFFre
cQry += CRLF + "   )"
cQry += CRLF + "   AND LEN(FT_TNATREC) = 0"
aQry[nPos] := cQry

//Modifica CST e Valores para produtos Tributados - Específico TTL
nPos := ENT_TRIBUTADOS_TTL
aDesc[nPos] := 'Entrada - Tributados TTL..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_CSTPIS  = '50',"
cQry += CRLF + "     FT_CSTCOF  = '50',"
cQry += CRLF + "     FT_CODBCC  = CASE FT_CFOP"
nMaxI := Len(aCFxBCC)
For nI := 1 to nMaxI
	cQry += CRLF + "       WHEN '" + aCFxBCC[nI][1] + "' THEN '" + aCFxBCC[nI][2] + "'"
Next nI
cQry += CRLF + "       ELSE ''"
cQry += CRLF + "     END,"
cQry += CRLF + "     FT_BASECOF = FT_VALCONT,"
cQry += CRLF + "     FT_BASEPIS = FT_VALCONT,"
cQry += CRLF + "     FT_VALPIS  = ROUND((FT_VALCONT * (" + cValToChar(nPIS) + " / 100)),2),"
cQry += CRLF + "     FT_VALCOF  = ROUND((FT_VALCONT * (" + cValToChar(nCOF) + " / 100)),2),"
cQry += CRLF + "     FT_ALIQPIS = " + cValToChar(nPIS) + ","
cQry += CRLF + "     FT_ALIQCOF = " + cValToChar(nCOF)
cQry += CRLF + " FROM " + RetSqlName('SFT') + " AS SFT"
cQry += CRLF + " LEFT JOIN " + RetSqlName('SB1') + " AS SB1"
cQry += CRLF + " ON  SB1.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND SB1.B1_FILIAL = '" + xFilial('SB1') + "'"
cQry += CRLF + " AND SB1.B1_COD = SFT.FT_PRODUTO"
cQry += CRLF + " LEFT JOIN " + RetSqlName('SZ3') + " AS SZ3"
cQry += CRLF + " ON  SZ3.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND SZ3.Z3_FILIAL = '" + xFilial('SZ3') + "'"
cQry += CRLF + " AND SZ3.Z3_COD = SB1.B1_GRPCTB"
cQry += CRLF + " LEFT JOIN " + RetSqlName('CT1') + " AS CT1Z3"
cQry += CRLF + " ON  CT1Z3.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND CT1Z3.CT1_FILIAL = '" + xFilial('CT1') + "'"
cQry += CRLF + " AND CT1Z3.CT1_CONTA = SZ3.Z3_CTCUSTO"
cQry += CRLF + " LEFT JOIN " + RetSqlName('SD1') + " AS SD1"
cQry += CRLF + " ON  SD1.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND SD1.D1_FILIAL = '" + xFilial('SD1') + "'"
cQry += CRLF + " AND SD1.D1_DOC = SFT.FT_NFISCAL"
cQry += CRLF + " AND SD1.D1_SERIE = SFT.FT_SERIE"
cQry += CRLF + " AND SD1.D1_FORNECE = SFT.FT_CLIEFOR"
cQry += CRLF + " AND SD1.D1_LOJA = SFT.FT_LOJA"
cQry += CRLF + " AND SD1.D1_ITEM = SFT.FT_ITEM"
cQry += CRLF + " LEFT JOIN " + RetSqlName('CTT') + " AS CTT"
cQry += CRLF + " ON  CTT.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND CTT.CTT_FILIAL = '" + xFilial('CTT') + "'"
cQry += CRLF + " AND RTRIM(CTT.CTT_CUSTO) = LEFT(RTRIM(SD1.D1_CC),3)"
cQry += CRLF + " AND CTT.CTT_CLASSE = '1'"
cQry += CRLF + " LEFT JOIN " + RetSqlName('SF1') + " AS SF1"
cQry += CRLF + " ON  SF1.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND SF1.F1_FILIAL = '" + xFilial('SF1') + "'"
cQry += CRLF + " AND SF1.F1_DOC = SD1.D1_DOC"
cQry += CRLF + " AND SF1.F1_SERIE = SD1.D1_SERIE"
cQry += CRLF + " AND SF1.F1_FORNECE = SD1.D1_FORNECE"
cQry += CRLF + " AND SF1.F1_LOJA = SD1.D1_LOJA"
cQry += CRLF + " LEFT JOIN " + RetSqlName('SE2') + " AS SE2"
cQry += CRLF + " ON  SE2.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND SE2.E2_FILIAL = '" + xFilial('SE2') + "'"
cQry += CRLF + " AND SE2.E2_PREFIXO = SF1.F1_PREFIXO"
cQry += CRLF + " AND SE2.E2_NUM = SF1.F1_DUPL"
cQry += CRLF + " AND SE2.E2_FORNECE = SF1.F1_FORNECE"
cQry += CRLF + " AND SE2.E2_LOJA = SF1.F1_LOJA"
cQry += CRLF + " AND SE2.E2_PARCELA IN ('','001')"
cQry += CRLF + " LEFT JOIN " + RetSqlName('SED') + " AS SED"
cQry += CRLF + " ON  SED.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND SED.ED_FILIAL = '" + xFilial('SED') + "'"
cQry += CRLF + " AND SED.ED_CODIGO = SE2.E2_NATUREZ"
cQry += CRLF + " LEFT JOIN " + RetSqlName('CT1') + " AS CT1ED"
cQry += CRLF + " ON  CT1ED.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND CT1ED.CT1_FILIAL = '" + xFilial('CT1') + "'"
cQry += CRLF + " AND CT1ED.CT1_CONTA = SED.ED_CONTAC"
cQry += CRLF + " LEFT JOIN " + RetSqlName('SA2') + " AS SA2"
cQry += CRLF + " ON  SA2.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND SA2.A2_FILIAL = '" + xFilial('SA2') + "'"
cQry += CRLF + " AND SA2.A2_COD = SFT.FT_CLIEFOR"
cQry += CRLF + " AND SA2.A2_LOJA = SFT.FT_LOJA"
cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SFT.FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(SFT.FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND SFT.FT_TIPOMOV = 'E'"
cQry += CRLF + "   AND ("
cQry += CRLF + "        RTRIM(SFT.FT_CFOP) IN " + cCFEnt
cQry += CRLF + "     OR RTRIM(SFT.FT_CFOP) IN " + cCFFre
cQry += CRLF + "   )"
cQry += CRLF + "   AND LEN(SFT.FT_TNATREC) = 0"
cQry += CRLF + "   AND CTT.CTT_TDCRPC = 'S'"
cQry += CRLF + "   AND ("
cQry += CRLF + "     ("
cQry += CRLF + "           SZ3.Z3_CTCUSTO <> ''"
cQry += CRLF + "       AND CT1Z3.CT1_TDCRPC = 'S'"
cQry += CRLF + "     ) OR ("
cQry += CRLF + "           SZ3.Z3_CTCUSTO = ''"
cQry += CRLF + "       AND SE2.E2_NATUREZ <> ''"
cQry += CRLF + "       AND SED.ED_CONTAC <> ''"
cQry += CRLF + "       AND CT1ED.CT1_TDCRPC = 'S'"
cQry += CRLF + "     )"
cQry += CRLF + "   )"
cQry += CRLF + "   AND ("
cQry += CRLF + "     ("
cQry += CRLF + "       ("
cQry += CRLF + "            CT1Z3.CT1_CONTA = '313030019'"
cQry += CRLF + "         OR CT1ED.CT1_CONTA = '313030019'"
cQry += CRLF + "       ) AND SA2.A2_TDCRPC = 'S'"
cQry += CRLF + "     ) OR ("
cQry += CRLF + "       ("
cQry += CRLF + "           CT1Z3.CT1_CONTA <> '313030019'"
cQry += CRLF + "        OR CT1Z3.CT1_CONTA IS NULL"
cQry += CRLF + "       ) AND ("
cQry += CRLF + "           CT1ED.CT1_CONTA <> '313030019'"
cQry += CRLF + "        OR CT1ED.CT1_CONTA IS NULL"
cQry += CRLF + "       )"
cQry += CRLF + "     )"
cQry += CRLF + "   )"
aQry[nPos] := cQry

//Modifica Base de Cálculo do Crédito e Indicador da Natureza de Frete - Geral
nPos := ENT_FRETE_GERAL
aDesc[nPos] := 'Entrada - Frete (1353/2353) Geral..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_INDNTFR = '9'"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
cQry += CRLF + "   AND RTRIM(FT_CFOP) IN " + cCFFre
aQry[nPos] := cQry

//Modifica Base de Cálculo do Crédito e Indicador da Natureza de Frete - CST 50
nPos := ENT_FRETE_CST50
aDesc[nPos] := 'Entrada - Frete (1353/2353) CST 50..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_INDNTFR = '2',"
cQry += CRLF + "     FT_CODBCC  = '13'"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
cQry += CRLF + "   AND RTRIM(FT_CFOP) IN " + cCFFre
cQry += CRLF + "   AND FT_CSTCOF = '50'"
aQry[nPos] := cQry

//Modifica Base de Cálculo do Crédito das notas de Devolução
nPos := ENT_DEVOLUCAO
aDesc[nPos] := 'Entrada - Devolução..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_CODBCC = '12'"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
cQry += CRLF + "   AND RTRIM(FT_TIPO) IN ('D')"
aQry[nPos] := cQry

//Modifica CST e Valores das notas de Energia Elétrica
nPos := ENT_ENERGIA
aDesc[nPos] := 'Entrada - Energia Elétrica (1253/2253/1254/2254)..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_CSTPIS  = '50',"
cQry += CRLF + "     FT_CSTCOF  = '50',"
cQry += CRLF + "     FT_CODBCC  = '04',"
cQry += CRLF + "     FT_BASECOF = FT_VALCONT,"
cQry += CRLF + "     FT_BASEPIS = FT_VALCONT,"
cQry += CRLF + "     FT_VALPIS  = ROUND((FT_VALCONT * (" + cValToChar(nPIS) + " / 100)),2),"
cQry += CRLF + "     FT_VALCOF  = ROUND((FT_VALCONT * (" + cValToChar(nCOF) + " / 100)),2),"
cQry += CRLF + "     FT_ALIQPIS = " + cValToChar(nPIS) + ","
cQry += CRLF + "     FT_ALIQCOF = " + cValToChar(nCOF)
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
cQry += CRLF + "   AND RTRIM(FT_CFOP) IN " + cCFEne
aQry[nPos] := cQry

//Modifica CST e Valores para Pessoa Física
nPos := ENT_PF
aDesc[nPos] := 'Entrada - Pessoa Física..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_CSTPIS  = '98',"
cQry += CRLF + "     FT_CSTCOF  = '98',"
cQry += CRLF + "     FT_BASECOF = 0,"
cQry += CRLF + "     FT_BASEPIS = 0,"
cQry += CRLF + "     FT_VALCOF  = 0,"
cQry += CRLF + "     FT_VALPIS  = 0,"
cQry += CRLF + "     FT_ALIQCOF = 0,"
cQry += CRLF + "     FT_ALIQPIS = 0,"
cQry += CRLF + "     FT_BASIMP5 = 0,"
cQry += CRLF + "     FT_BASIMP6 = 0,"
cQry += CRLF + "     FT_VALIMP5 = 0,"
cQry += CRLF + "     FT_VALIMP6 = 0,"
cQry += CRLF + "     FT_ALQIMP5 = 0,"
cQry += CRLF + "     FT_ALQIMP6 = 0"
cQry += CRLF + " FROM " + RetSqlName('SFT') + " AS SFT,"
cQry += CRLF + "      " + RetSqlName('SA2') + " AS SA2"
cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SA2.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SFT.FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND SA2.A2_FILIAL = '" + xFilial('SA2') + "'"
cQry += CRLF + "   AND SFT.FT_CLIEFOR = SA2.A2_COD"
cQry += CRLF + "   AND SFT.FT_LOJA = SA2.A2_LOJA"
cQry += CRLF + "   AND RTRIM(SA2.A2_TIPO) = 'F'"
cQry += CRLF + "   AND RTRIM(SFT.FT_TIPO) NOT IN ('D')"
cQry += CRLF + "   AND LEFT(SFT.FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND SFT.FT_TIPOMOV = 'E'"
aQry[nPos] := cQry

//Modifica CST e Valores para Pessoa Física (Devolução)
nPos := ENT_PF_DEVOLUCAO
aDesc[nPos] := 'Entrada - Pessoa Física (Devolução)..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_CSTPIS  = '98',"
cQry += CRLF + "     FT_CSTCOF  = '98',"
cQry += CRLF + "     FT_BASECOF = 0,"
cQry += CRLF + "     FT_BASEPIS = 0,"
cQry += CRLF + "     FT_VALCOF  = 0,"
cQry += CRLF + "     FT_VALPIS  = 0,"
cQry += CRLF + "     FT_ALIQCOF = 0,"
cQry += CRLF + "     FT_ALIQPIS = 0,"
cQry += CRLF + "     FT_BASIMP5 = 0,"
cQry += CRLF + "     FT_BASIMP6 = 0,"
cQry += CRLF + "     FT_VALIMP5 = 0,"
cQry += CRLF + "     FT_VALIMP6 = 0,"
cQry += CRLF + "     FT_ALQIMP5 = 0,"
cQry += CRLF + "     FT_ALQIMP6 = 0"
cQry += CRLF + " FROM " + RetSqlName('SFT') + " AS SFT,"
cQry += CRLF + "      " + RetSqlName('SA1') + " AS SA1"
cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SA1.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SFT.FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND SA1.A1_FILIAL = '" + xFilial('SA1') + "'"
cQry += CRLF + "   AND SFT.FT_CLIEFOR = SA1.A1_COD"
cQry += CRLF + "   AND SFT.FT_LOJA = SA1.A1_LOJA"
cQry += CRLF + "   AND RTRIM(SA1.A1_PESSOA) = 'F'"
cQry += CRLF + "   AND RTRIM(SFT.FT_TIPO) IN ('D')"
cQry += CRLF + "   AND LEFT(SFT.FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND SFT.FT_TIPOMOV = 'E'"
aQry[nPos] := cQry

//Modifica CST, Tab+Cod.Nat.Rec. e Valores para Devolução Zona Franca AM
nPos := ENT_DEVOLUCAO_ZF
aDesc[nPos] := 'Entrada - Devolução Zona Franca AM..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_CSTPIS  = '73',"
cQry += CRLF + "     FT_CSTCOF  = '73',"
cQry += CRLF + "     FT_TNATREC = '4313',"
cQry += CRLF + "     FT_CNATREC = '908',"
cQry += CRLF + "     FT_BASECOF = FT_VALCONT,"
cQry += CRLF + "     FT_BASEPIS = FT_VALCONT,"
cQry += CRLF + "     FT_VALPIS  = 0,"
cQry += CRLF + "     FT_VALCOF  = 0,"
cQry += CRLF + "     FT_ALIQPIS = 0,"
cQry += CRLF + "     FT_ALIQCOF = 0"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
cQry += CRLF + "   AND FT_TIPO IN ('D')"
cQry += CRLF + "   AND FT_ESTADO = 'AM'"
cQry += CRLF + "   AND RTRIM(FT_CFOP) IN " + cCFEnt
aQry[nPos] := cQry

//Modifica CST, Tab+Cod.Nat.Rec. e Valores para Devolução Área Livre Comércio AP
nPos := ENT_DEVOLUCAO_ALC
aDesc[nPos] := 'Entrada - Devolução Área Livre Comércio AP..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_CSTPIS  = '73',"
cQry += CRLF + "     FT_CSTCOF  = '73',"
cQry += CRLF + "     FT_TNATREC = '4313',"
cQry += CRLF + "     FT_CNATREC = '909',"
cQry += CRLF + "     FT_BASECOF = FT_VALCONT,"
cQry += CRLF + "     FT_BASEPIS = FT_VALCONT,"
cQry += CRLF + "     FT_VALPIS  = 0,"
cQry += CRLF + "     FT_VALCOF  = 0,"
cQry += CRLF + "     FT_ALIQPIS = 0,"
cQry += CRLF + "     FT_ALIQCOF = 0"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
cQry += CRLF + "   AND FT_TIPO IN ('D')"
cQry += CRLF + "   AND FT_ESTADO = 'AP'"
cQry += CRLF + "   AND RTRIM(FT_CFOP) IN " + cCFEnt
aQry[nPos] := cQry

//Cálculo para Produtos com ST
nPos := ENT_SITTRIB
aDesc[nPos] := 'Entrada - Substituição Tributária..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_BASECOF = FT_VALCONT - FT_ICMSRET,"
cQry += CRLF + "     FT_BASEPIS = FT_VALCONT - FT_ICMSRET,"
cQry += CRLF + "     FT_VALPIS  = ROUND(((FT_VALCONT - FT_ICMSRET) * (" + cValToChar(nPIS) + " / 100)),2),"
cQry += CRLF + "     FT_VALCOF  = ROUND(((FT_VALCONT - FT_ICMSRET) * (" + cValToChar(nCOF) + " / 100)),2),"
cQry += CRLF + "     FT_ALIQPIS = " + cValToChar(nPIS) + ","
cQry += CRLF + "     FT_ALIQCOF = " + cValToChar(nCOF)
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_CFOP IN " + cCFSub
cQry += CRLF + "   AND FT_ICMSRET > 0"
cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
cQry += CRLF + "   AND LEN(FT_TNATREC) = 0"
aQry[nPos] := cQry

//limpandos valores para documentos inutilizados
nPos := ENT_INUTILIZADAS
aDesc[nPos] := 'Entrada - Inutilizadas..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_BASECOF = 0,"
cQry += CRLF + "     FT_BASEPIS = 0,"
cQry += CRLF + "     FT_VALCOF  = 0,"
cQry += CRLF + "     FT_VALPIS  = 0,"
cQry += CRLF + "     FT_BRETCOF = 0,"
cQry += CRLF + "     FT_BRETPIS = 0,"
cQry += CRLF + "     FT_VRETCOF = 0,"
cQry += CRLF + "     FT_VRETPIS = 0,"
cQry += CRLF + "     FT_CSTCOF  = '',"
cQry += CRLF + "     FT_CSTPIS  = '',"
cQry += CRLF + "     FT_CODBCC  = '',"
cQry += CRLF + "     FT_INDNTFR = '',"
cQry += CRLF + "     FT_TNATREC = '',"
cQry += CRLF + "     FT_CNATREC = '',"
cQry += CRLF + "     FT_GRUPONC = '',"
cQry += CRLF + "     FT_DTFIMNT = '',"
cQry += CRLF + "     FT_ALIQCOF = 0,"
cQry += CRLF + "     FT_ALIQPIS = 0,"
cQry += CRLF + "     FT_BASIMP5 = 0,"
cQry += CRLF + "     FT_BASIMP6 = 0,"
cQry += CRLF + "     FT_VALIMP5 = 0,"
cQry += CRLF + "     FT_VALIMP6 = 0,"
cQry += CRLF + "     FT_ALQIMP5 = 0,"
cQry += CRLF + "     FT_ALQIMP6 = 0"
cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
cQry += CRLF + " LEFT JOIN " + RetSqlName('SF3') + " SF3"
cQry += CRLF + " ON  SF3.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND F3_FILIAL = '" + xFilial('SF3') + "'"
cQry += CRLF + " AND F3_NFISCAL = FT_NFISCAL"
cQry += CRLF + " AND F3_SERIE = FT_SERIE"
cQry += CRLF + " AND F3_CLIEFOR = FT_CLIEFOR"
cQry += CRLF + " AND F3_LOJA = FT_LOJA"
cQry += CRLF + " AND F3_CFO = FT_CFOP"
cQry += CRLF + " AND F3_TIPO = FT_TIPO"
cQry += CRLF + " AND F3_IDENTFT = FT_IDENTF3"
cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND LEN(FT_DTCANC) > 0"
cQry += CRLF + "   AND (FT_OBSERV LIKE '%CANCEL%' OR FT_OBSERV LIKE '%INUTIL%')"
cQry += CRLF + "   AND F3_CODRSEF = '102'"
cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
aQry[nPos] := cQry
  
//Transferindo cálculo (SD1)
nPos := ENT_SD1
aDesc[nPos] := 'Entrada - Transferindo cálculo (SD1)..'
cQry := CRLF + " UPDATE " + RetSqlName('SD1')
cQry += CRLF + " SET D1_BASIMP6 = SFT.FT_BASEPIS,"
cQry += CRLF + "     D1_ALQIMP6 = SFT.FT_ALIQPIS,"
cQry += CRLF + "     D1_VALIMP6 = SFT.FT_VALPIS,"
cQry += CRLF + "     D1_BASIMP5 = SFT.FT_BASECOF,"
cQry += CRLF + "     D1_ALQIMP5 = SFT.FT_ALIQCOF,"
cQry += CRLF + "     D1_VALIMP5 = SFT.FT_VALCOF"
cQry += CRLF + " FROM " + RetSqlName('SD1') + " SD1,"
cQry += CRLF + "      " + RetSqlName('SFT') + " SFT"
cQry += CRLF + " WHERE SD1.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SFT.FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND SD1.D1_FILIAL = '" + xFilial('SD1') + "'"
cQry += CRLF + "   AND SD1.D1_DOC = SFT.FT_NFISCAL"
cQry += CRLF + "   AND SD1.D1_SERIE = SFT.FT_SERIE"
cQry += CRLF + "   AND SD1.D1_FORNECE = SFT.FT_CLIEFOR"
cQry += CRLF + "   AND SD1.D1_LOJA = SFT.FT_LOJA"
cQry += CRLF + "   AND SD1.D1_ITEM = SFT.FT_ITEM"
cQry += CRLF + "   AND SD1.D1_COD = SFT.FT_PRODUTO"
cQry += CRLF + "   AND LEFT(SFT.FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND SFT.FT_TIPOMOV = 'E'"
aQry[nPos] := cQry

//Transferindo cálculo (SF1)
nPos := ENT_SF1
aDesc[nPos] := 'Entrada - Transferindo cálculo (SF1)..'
cQry += CRLF + " UPDATE " + RetSqlName('SF1')
cQry += CRLF + " SET F1_BASIMP6 = ("
cQry += CRLF + "       SELECT SUM(FT_BASEPIS)"
cQry += CRLF + "       FROM " + RetSqlName('SFT') + " SFT1"
cQry += CRLF + "       WHERE SFT1.D_E_L_E_T_ <> '*'"
cQry += CRLF + "         AND F1_FILIAL  = SFT1.FT_FILIAL"
cQry += CRLF + "         AND F1_DOC     = SFT1.FT_NFISCAL"
cQry += CRLF + "         AND F1_SERIE   = SFT1.FT_SERIE"
cQry += CRLF + "         AND F1_FORNECE = SFT1.FT_CLIEFOR"
cQry += CRLF + "         AND F1_LOJA    = SFT1.FT_LOJA"
cQry += CRLF + "         AND SFT1.FT_TIPOMOV = 'E'"
cQry += CRLF + "       GROUP BY SFT1.FT_FILIAL,"
cQry += CRLF + "                SFT1.FT_NFISCAL,"
cQry += CRLF + "                SFT1.FT_SERIE,"
cQry += CRLF + "                SFT1.FT_CLIEFOR,"
cQry += CRLF + "                SFT1.FT_LOJA"
cQry += CRLF + "     ),"
cQry += CRLF + "     F1_VALIMP6 = ("
cQry += CRLF + "       SELECT SUM(FT_VALPIS)"
cQry += CRLF + "       FROM " + RetSqlName('SFT') + " SFT2"
cQry += CRLF + "       WHERE SFT2.D_E_L_E_T_ <> '*'"
cQry += CRLF + "         AND F1_FILIAL  = SFT2.FT_FILIAL"
cQry += CRLF + "         AND F1_DOC     = SFT2.FT_NFISCAL"
cQry += CRLF + "         AND F1_SERIE   = SFT2.FT_SERIE"
cQry += CRLF + "         AND F1_FORNECE = SFT2.FT_CLIEFOR"
cQry += CRLF + "         AND F1_LOJA    = SFT2.FT_LOJA"
cQry += CRLF + "         AND SFT2.FT_TIPOMOV = 'E'"
cQry += CRLF + "       GROUP BY SFT2.FT_FILIAL,"
cQry += CRLF + "                SFT2.FT_NFISCAL,"
cQry += CRLF + "                SFT2.FT_SERIE,"
cQry += CRLF + "                SFT2.FT_CLIEFOR,"
cQry += CRLF + "                SFT2.FT_LOJA"
cQry += CRLF + "     ),"
cQry += CRLF + "     F1_BASIMP5 = ("
cQry += CRLF + "       SELECT SUM(FT_BASECOF)"
cQry += CRLF + "       FROM " + RetSqlName('SFT') + " SFT3"
cQry += CRLF + "       WHERE SFT3.D_E_L_E_T_ <> '*'"
cQry += CRLF + "         AND F1_FILIAL  = SFT3.FT_FILIAL"
cQry += CRLF + "         AND F1_DOC     = SFT3.FT_NFISCAL"
cQry += CRLF + "         AND F1_SERIE   = SFT3.FT_SERIE"
cQry += CRLF + "         AND F1_FORNECE = SFT3.FT_CLIEFOR"
cQry += CRLF + "         AND F1_LOJA    = SFT3.FT_LOJA"
cQry += CRLF + "         AND SFT3.FT_TIPOMOV = 'E'"
cQry += CRLF + "       GROUP BY SFT3.FT_FILIAL,"
cQry += CRLF + "                SFT3.FT_NFISCAL,"
cQry += CRLF + "                SFT3.FT_SERIE,"
cQry += CRLF + "                SFT3.FT_CLIEFOR,"
cQry += CRLF + "                SFT3.FT_LOJA"
cQry += CRLF + "     ),"
cQry += CRLF + "     F1_VALIMP5 = ("
cQry += CRLF + "       SELECT SUM(FT_VALCOF)"
cQry += CRLF + "       FROM " + RetSqlName('SFT') + " SFT4"
cQry += CRLF + "       WHERE SFT4.D_E_L_E_T_ <> '*'"
cQry += CRLF + "         AND F1_FILIAL  = SFT4.FT_FILIAL"
cQry += CRLF + "         AND F1_DOC     = SFT4.FT_NFISCAL"
cQry += CRLF + "         AND F1_SERIE   = SFT4.FT_SERIE"
cQry += CRLF + "         AND F1_FORNECE = SFT4.FT_CLIEFOR"
cQry += CRLF + "         AND F1_LOJA    = SFT4.FT_LOJA"
cQry += CRLF + "         AND SFT4.FT_TIPOMOV = 'E'"
cQry += CRLF + "       GROUP BY SFT4.FT_FILIAL,"
cQry += CRLF + "                SFT4.FT_NFISCAL,"
cQry += CRLF + "                SFT4.FT_SERIE,"
cQry += CRLF + "                SFT4.FT_CLIEFOR,"
cQry += CRLF + "                SFT4.FT_LOJA"
cQry += CRLF + "     )"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND F1_FILIAL = '" + xFilial('SF1') + "'"
cQry += CRLF + "   AND LEFT(F1_DTDIGIT,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
aQry[nPos] := cQry

/* 
 * Saídas
 */
//Atualizando NCM, CST, Codigo e Tabela de Natureza de Receita - ZPI > SFT (SEM DATA FINAL)
nPos := SAI_ZPI_PASSO1
aDesc[nPos] := 'Saída - Atualizando SFT x ZPI - Passo 1..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_POSIPI  = ZPI.ZPI_NCM,"
cQry += CRLF + "     FT_TNATREC = ZPI.ZPI_TNATRE,"
cQry += CRLF + "     FT_CNATREC = ZPI.ZPI_CNAREC,"
cQry += CRLF + "     FT_DTFIMNT = ZPI.ZPI_DTFIMN,"
cQry += CRLF + "     FT_CSTPIS  = ZPI.ZPI_CSTSAI,"
cQry += CRLF + "     FT_CSTCOF  = ZPI.ZPI_CSTSAI"
cQry += CRLF + " FROM " + RetSqlName('SFT') + " AS SFT,"
cQry += CRLF + "      " + RetSqlName('SB1') + " AS SB1,"
cQry += CRLF + "      " + RetSqlName('ZPI') + " AS ZPI"
cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SB1.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND ZPI.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SFT.FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND SB1.SB1_FILIAL = '" + xFilial('SB1') + "'"
cQry += CRLF + "   AND ZPI.ZPI_FILIAL = '" + xFilial('ZPI') + "'"
cQry += CRLF + "   AND LEFT(SFT.FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND RTRIM(SFT.FT_CFOP) IN " + cCFSai
cQry += CRLF + "   AND SFT.FT_TIPOMOV = 'S'"
cQry += CRLF + "   AND RTRIM(SFT.FT_PRODUTO) = RTRIM(SB1.B1_COD)"
cQry += CRLF + "   AND RTRIM(ZPI.ZPI_NCM) = RTRIM(SB1.B1_POSIPI)"
cQry += CRLF + "   AND RTRIM(ZPI.ZPI_EX_NCM) = RTRIM(SB1.B1_EX_NCM)"
cQry += CRLF + "   AND SFT.FT_ENTRADA >= ZPI.ZPI_DTININ"
cQry += CRLF + "   AND LEN(ZPI.ZPI_DTFIMN) = 0"
aQry[nPos] := cQry

//Atualizando NCM, CST, Codigo e Tabela de Natureza de Receita - ZPI > SFT (COM DATA FINAL)
nPos := SAI_ZPI_PASSO2
aDesc[nPos] := 'Saída - Atualizando SFT x ZPI - Passo 2..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_POSIPI  = ZPI.ZPI_NCM,"
cQry += CRLF + "     FT_TNATREC = ZPI.ZPI_TNATRE,"
cQry += CRLF + "     FT_CNATREC = ZPI.ZPI_CNAREC,"
cQry += CRLF + "     FT_DTFIMNT = ZPI.ZPI_DTFIMN,"
cQry += CRLF + "     FT_CSTPIS  = ZPI.ZPI_CSTSAI,"
cQry += CRLF + "     FT_CSTCOF  = ZPI.ZPI_CSTSAI"
cQry += CRLF + " FROM " + RetSqlName('SFT') + " AS SFT,"
cQry += CRLF + "      " + RetSqlName('SB1') + " AS SB1,"
cQry += CRLF + "      " + RetSqlName('ZPI') + " AS ZPI"
cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SB1.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND ZPI.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SFT.FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND SB1.SB1_FILIAL = '" + xFilial('SB1') + "'"
cQry += CRLF + "   AND ZPI.ZPI_FILIAL = '" + xFilial('ZPI') + "'"
cQry += CRLF + "   AND LEFT(SFT.FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND RTRIM(SFT.FT_CFOP) IN " + cCFSai
cQry += CRLF + "   AND SFT.FT_TIPOMOV = 'S'"
cQry += CRLF + "   AND RTRIM(SFT.FT_PRODUTO) = RTRIM(SB1.B1_COD)"
cQry += CRLF + "   AND RTRIM(ZPI.ZPI_NCM) = RTRIM(SB1.B1_POSIPI)"
cQry += CRLF + "   AND RTRIM(ZPI.ZPI_EX_NCM) = RTRIM(SB1.B1_EX_NCM)"
cQry += CRLF + "   AND SFT.FT_ENTRADA >= ZPI.ZPI_DTININ"
cQry += CRLF + "   AND SFT.FT_ENTRADA <= ZPI.ZPI_DTFIMN"
aQry[nPos] := cQry

//Modifica CST e Valores para demais situações genéricas
nPos := SAI_GENERICAS
aDesc[nPos] := 'Saída - Situações genéricas..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_CSTPIS  = '49',"
cQry += CRLF + "     FT_CSTCOF  = '49',"
cQry += CRLF + "     FT_BASECOF = 0,"
cQry += CRLF + "     FT_BASEPIS = 0,"
cQry += CRLF + "     FT_VALCOF  = 0,"
cQry += CRLF + "     FT_VALPIS  = 0,"
cQry += CRLF + "     FT_ALIQCOF = 0,"
cQry += CRLF + "     FT_ALIQPIS = 0,"
cQry += CRLF + "     FT_BASIMP5 = 0,"
cQry += CRLF + "     FT_BASIMP6 = 0,"
cQry += CRLF + "     FT_VALIMP5 = 0,"
cQry += CRLF + "     FT_VALIMP6 = 0,"
cQry += CRLF + "     FT_ALQIMP5 = 0,"
cQry += CRLF + "     FT_ALQIMP6 = 0"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
cQry += CRLF + "   AND RTRIM(FT_CFOP) NOT IN " + cCFSai
cQry += CRLF + "   AND LEN(FT_TNATREC) = 0"
aQry[nPos] := cQry

//Modifica CST e Valores para produtos Monofásicos e Aliq. Zero
nPos := SAI_MONOF_ALIQZERO
aDesc[nPos] := 'Saída - Monofásicos e Aliq. Zero..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_BASECOF = FT_VALCONT,"
cQry += CRLF + "     FT_BASEPIS = FT_VALCONT,"
cQry += CRLF + "     FT_VALCOF  = 0,"
cQry += CRLF + "     FT_VALPIS  = 0,"
cQry += CRLF + "     FT_ALIQCOF = 0,"
cQry += CRLF + "     FT_ALIQPIS = 0,"
cQry += CRLF + "     FT_BASIMP5 = 0,"
cQry += CRLF + "     FT_BASIMP6 = 0,"
cQry += CRLF + "     FT_VALIMP5 = 0,"
cQry += CRLF + "     FT_VALIMP6 = 0,"
cQry += CRLF + "     FT_ALQIMP5 = 0,"
cQry += CRLF + "     FT_ALQIMP6 = 0"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
cQry += CRLF + "   AND RTRIM(FT_CFOP) IN " + cCFSai
cQry += CRLF + "   AND LEN(FT_TNATREC) > 0"
aQry[nPos] := cQry

//Modifica CST e Valores para produtos Tributados
nPos := SAI_TRIBUTADOS
aDesc[nPos] := 'Saída - Tributados..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_CSTPIS  = '01',"
cQry += CRLF + "     FT_CSTCOF  = '01',"
cQry += CRLF + "     FT_BASECOF = FT_VALCONT,"
cQry += CRLF + "     FT_BASEPIS = FT_VALCONT,"
cQry += CRLF + "     FT_VALPIS  = ROUND((FT_VALCONT * (" + cValToChar(nPIS) + " / 100)),2),"
cQry += CRLF + "     FT_VALCOF  = ROUND((FT_VALCONT * (" + cValToChar(nCOF) + " / 100)),2),"
cQry += CRLF + "     FT_ALIQPIS = " + cValToChar(nPIS) + ","
cQry += CRLF + "     FT_ALIQCOF = " + cValToChar(nCOF)
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
cQry += CRLF + "   AND RTRIM(FT_CFOP) IN " + cCFSai
cQry += CRLF + "   AND LEN(FT_TNATREC) = 0"
aQry[nPos] := cQry

//Modifica CST e Valores para Notas de serviço
nPos := SAI_SERVICO
aDesc[nPos] := 'Saída - Notas de serviço..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_CSTPIS  = '01',"
cQry += CRLF + "     FT_CSTCOF  = '01',"
cQry += CRLF + "     FT_BASECOF = FT_VALCONT,"
cQry += CRLF + "     FT_BASEPIS = FT_VALCONT,"
cQry += CRLF + "     FT_VALPIS  = ROUND((FT_VALCONT * (" + cValToChar(nPIS) + " / 100)),2),"
cQry += CRLF + "     FT_VALCOF  = ROUND((FT_VALCONT * (" + cValToChar(nCOF) + " / 100)),2),"
cQry += CRLF + "     FT_ALIQPIS = " + cValToChar(nPIS) + ","
cQry += CRLF + "     FT_ALIQCOF = " + cValToChar(nCOF)
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
cQry += CRLF + "   AND RTRIM(FT_CFOP) IN " + cCFSer
cQry += CRLF + "   AND RTRIM(FT_ESPECIE) = 'NFS'"
aQry[nPos] := cQry

//Modifica CST, Tab+Cod.Nat.Rec. e Valores para Venda Zona Franca AM
nPos := SAI_ZF
aDesc[nPos] := 'Saída - Zona Franca AM..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_CSTPIS  = '06',"
cQry += CRLF + "     FT_CSTCOF  = '06',"
cQry += CRLF + "     FT_TNATREC = '4313',"
cQry += CRLF + "     FT_CNATREC = '908',"
cQry += CRLF + "     FT_BASECOF = FT_VALCONT,"
cQry += CRLF + "     FT_BASEPIS = FT_VALCONT,"
cQry += CRLF + "     FT_VALPIS  = 0,"
cQry += CRLF + "     FT_VALCOF  = 0,"
cQry += CRLF + "     FT_ALIQPIS = 0,"
cQry += CRLF + "     FT_ALIQCOF = 0"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
cQry += CRLF + "   AND FT_ESTADO = 'AM'"
cQry += CRLF + "   AND RTRIM(FT_CFOP) IN " + cCFSai
aQry[nPos] := cQry

//Modifica CST, Tab+Cod.Nat.Rec. e Valores para Venda Área Livre Comércio AP
nPos := SAI_ALC
aDesc[nPos] := 'Saída - Área Livre Comércio AP..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_CSTPIS  = '06',"
cQry += CRLF + "     FT_CSTCOF  = '06',"
cQry += CRLF + "     FT_TNATREC = '4313',"
cQry += CRLF + "     FT_CNATREC = '909',"
cQry += CRLF + "     FT_BASECOF = FT_VALCONT,"
cQry += CRLF + "     FT_BASEPIS = FT_VALCONT,"
cQry += CRLF + "     FT_VALPIS  = 0,"
cQry += CRLF + "     FT_VALCOF  = 0,"
cQry += CRLF + "     FT_ALIQPIS = 0,"
cQry += CRLF + "     FT_ALIQCOF = 0"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
cQry += CRLF + "   AND FT_ESTADO = 'AP'"
cQry += CRLF + "   AND RTRIM(FT_CFOP) IN " + cCFSai
aQry[nPos] := cQry

//Cálculo para Produtos com ST
nPos := SAI_SITTRIB
aDesc[nPos] := 'Saída - Substituição Tributária..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_BASECOF = FT_VALCONT - FT_ICMSRET,"
cQry += CRLF + "     FT_BASEPIS = FT_VALCONT - FT_ICMSRET,"
cQry += CRLF + "     FT_VALPIS  = ROUND(((FT_VALCONT - FT_ICMSRET) * (" + cValToChar(nPIS) + " / 100)),2),"
cQry += CRLF + "     FT_VALCOF  = ROUND(((FT_VALCONT - FT_ICMSRET) * (" + cValToChar(nCOF) + " / 100)),2),"
cQry += CRLF + "     FT_ALIQPIS = " + cValToChar(nPIS) + ","
cQry += CRLF + "     FT_ALIQCOF = " + cValToChar(nCOF)
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND RTRIM(FT_CFOP) IN " + cCFDev
cQry += CRLF + "   AND FT_ICMSRET > 0"
cQry += CRLF + "   AND FT_TIPO IN ('D')"
cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
cQry += CRLF + "   AND LEN(FT_TNATREC) = 0"
aQry[nPos] := cQry

//Saída - Cálculo para Devolução
nPos := SAI_DEVOLUCAO
aDesc[nPos] := 'Saída - Devolução..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_BASECOF = FT_VALCONT,"
cQry += CRLF + "     FT_BASEPIS = FT_VALCONT,"
cQry += CRLF + "     FT_CSTPIS  = '49',"
cQry += CRLF + "     FT_CSTCOF  = '49',"
cQry += CRLF + "     FT_VALCOF  = 0,"
cQry += CRLF + "     FT_VALPIS  = 0,"
cQry += CRLF + "     FT_ALIQCOF = 0,"
cQry += CRLF + "     FT_ALIQPIS = 0,"
cQry += CRLF + "     FT_BASIMP5 = 0,"
cQry += CRLF + "     FT_BASIMP6 = 0,"
cQry += CRLF + "     FT_VALIMP5 = 0,"
cQry += CRLF + "     FT_VALIMP6 = 0,"
cQry += CRLF + "     FT_ALQIMP5 = 0,"
cQry += CRLF + "     FT_ALQIMP6 = 0"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
cQry += CRLF + "   AND RTRIM(FT_CFOP) IN " + cCFDev
cQry += CRLF + "   AND FT_TIPO IN ('D')"
aQry[nPos] := cQry

//limpando valores para documentos inutilizados
nPos := SAI_INUTILIZADAS
aDesc[nPos] := 'Saída - Inutilizadas..'
cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_BASECOF = 0,"
cQry += CRLF + "     FT_BASEPIS = 0,"
cQry += CRLF + "     FT_VALCOF  = 0,"
cQry += CRLF + "     FT_VALPIS  = 0,"
cQry += CRLF + "     FT_BRETCOF = 0,"
cQry += CRLF + "     FT_BRETPIS = 0,"
cQry += CRLF + "     FT_VRETCOF = 0,"
cQry += CRLF + "     FT_VRETPIS = 0,"
cQry += CRLF + "     FT_CSTCOF  = '',"
cQry += CRLF + "     FT_CSTPIS  = '',"
cQry += CRLF + "     FT_CODBCC  = '',"
cQry += CRLF + "     FT_INDNTFR = '',"
cQry += CRLF + "     FT_TNATREC = '',"
cQry += CRLF + "     FT_CNATREC = '',"
cQry += CRLF + "     FT_GRUPONC = '',"
cQry += CRLF + "     FT_DTFIMNT = '',"
cQry += CRLF + "     FT_ALIQCOF = 0,"
cQry += CRLF + "     FT_ALIQPIS = 0,"
cQry += CRLF + "     FT_BASIMP5 = 0,"
cQry += CRLF + "     FT_BASIMP6 = 0,"
cQry += CRLF + "     FT_VALIMP5 = 0,"
cQry += CRLF + "     FT_VALIMP6 = 0,"
cQry += CRLF + "     FT_ALQIMP5 = 0,"
cQry += CRLF + "     FT_ALQIMP6 = 0"
cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
cQry += CRLF + " LEFT JOIN " + RetSqlName('SF3') + " SF3"
cQry += CRLF + " ON  SF3.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND F3_FILIAL = '" + xFilial('SF3') + "'"
cQry += CRLF + " AND F3_NFISCAL = FT_NFISCAL"
cQry += CRLF + " AND F3_SERIE = FT_SERIE"
cQry += CRLF + " AND F3_CLIEFOR = FT_CLIEFOR"
cQry += CRLF + " AND F3_LOJA = FT_LOJA"
cQry += CRLF + " AND F3_CFO = FT_CFOP"
cQry += CRLF + " AND F3_TIPO = FT_TIPO"
cQry += CRLF + " AND F3_IDENTFT = FT_IDENTF3"
cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND LEN(FT_DTCANC) > 0"
cQry += CRLF + "   AND (FT_OBSERV LIKE '%CANCEL%' OR FT_OBSERV LIKE '%INUTIL%')"
cQry += CRLF + "   AND F3_CODRSEF = '102'"
cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
aQry[nPos] := cQry

//Transferindo cálculo (SD2)
nPos := SAI_SD2
aDesc[nPos] := 'Entrada - Transferindo cálculo (SD2)..'
cQry := CRLF + " UPDATE " + RetSqlName('SD2')
cQry += CRLF + " SET D2_BASIMP6 = SFT.FT_BASEPIS,"
cQry += CRLF + "     D2_ALQIMP6 = SFT.FT_ALIQPIS,"
cQry += CRLF + "     D2_VALIMP6 = SFT.FT_VALPIS,"
cQry += CRLF + "     D2_BASIMP5 = SFT.FT_BASECOF,"
cQry += CRLF + "     D2_ALQIMP5 = SFT.FT_ALIQCOF,"
cQry += CRLF + "     D2_VALIMP5 = SFT.FT_VALCOF"
cQry += CRLF + " FROM " + RetSqlName('SD2') + " SD2,"
cQry += CRLF + "      " + RetSqlName('SFT') + " SFT"
cQry += CRLF + " WHERE SD2.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SFT.FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND SD2.D2_FILIAL = '" + xFilial('SD2') + "'"
cQry += CRLF + "   AND SD2.D2_DOC = FT_NFISCAL"
cQry += CRLF + "   AND SD2.D2_SERIE = FT_SERIE"
cQry += CRLF + "   AND SD2.D2_CLIENTE = FT_CLIEFOR"
cQry += CRLF + "   AND SD2.D2_LOJA = FT_LOJA"
cQry += CRLF + "   AND SD2.D2_ITEM = FT_ITEM"
cQry += CRLF + "   AND SD2.D2_COD = FT_PRODUTO"
cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
aQry[nPos] := cQry

//Transferindo cálculo (SF2)
nPos := SAI_SF2
aDesc[nPos] := 'Entrada - Transferindo cálculo (SF2)..'
cQry += CRLF + " UPDATE " + RetSqlName('SF2')
cQry += CRLF + " SET F2_BASIMP6 = ("
cQry += CRLF + "       SELECT SUM(FT_BASEPIS)"
cQry += CRLF + "       FROM " + RetSqlName('SFT') + " SFT1"
cQry += CRLF + "       WHERE SFT1.D_E_L_E_T_ <> '*'"
cQry += CRLF + "         AND F2_FILIAL  = SFT1.FT_FILIAL"
cQry += CRLF + "         AND F2_DOC     = SFT1.FT_NFISCAL"
cQry += CRLF + "         AND F2_SERIE   = SFT1.FT_SERIE"
cQry += CRLF + "         AND F2_CLIENTE = SFT1.FT_CLIEFOR"
cQry += CRLF + "         AND F2_LOJA    = SFT1.FT_LOJA"
cQry += CRLF + "         AND SFT1.FT_TIPOMOV = 'S'"
cQry += CRLF + "       GROUP BY SFT1.FT_FILIAL,"
cQry += CRLF + "                SFT1.FT_NFISCAL,"
cQry += CRLF + "                SFT1.FT_SERIE,"
cQry += CRLF + "                SFT1.FT_CLIEFOR,"
cQry += CRLF + "                SFT1.FT_LOJA"
cQry += CRLF + "     ),"
cQry += CRLF + "     F2_VALIMP6 = ("
cQry += CRLF + "       SELECT SUM(FT_VALPIS)"
cQry += CRLF + "       FROM " + RetSqlName('SFT') + " SFT2"
cQry += CRLF + "       WHERE SFT2.D_E_L_E_T_ <> '*'"
cQry += CRLF + "         AND F2_FILIAL  = SFT2.FT_FILIAL"
cQry += CRLF + "         AND F2_DOC     = SFT2.FT_NFISCAL"
cQry += CRLF + "         AND F2_SERIE   = SFT2.FT_SERIE"
cQry += CRLF + "         AND F2_CLIENTE = SFT2.FT_CLIEFOR"
cQry += CRLF + "         AND F2_LOJA    = SFT2.FT_LOJA"
cQry += CRLF + "         AND SFT2.FT_TIPOMOV = 'S'"
cQry += CRLF + "       GROUP BY SFT2.FT_FILIAL,"
cQry += CRLF + "                SFT2.FT_NFISCAL,"
cQry += CRLF + "                SFT2.FT_SERIE,"
cQry += CRLF + "                SFT2.FT_CLIEFOR,"
cQry += CRLF + "                SFT2.FT_LOJA"
cQry += CRLF + "     ),"
cQry += CRLF + "     F2_BASIMP5 = ("
cQry += CRLF + "       SELECT SUM(FT_BASECOF)"
cQry += CRLF + "       FROM " + RetSqlName('SFT') + " SFT3"
cQry += CRLF + "       WHERE SFT3.D_E_L_E_T_ <> '*'"
cQry += CRLF + "         AND F2_FILIAL  = SFT3.FT_FILIAL"
cQry += CRLF + "         AND F2_DOC     = SFT3.FT_NFISCAL"
cQry += CRLF + "         AND F2_SERIE   = SFT3.FT_SERIE"
cQry += CRLF + "         AND F2_CLIENTE = SFT3.FT_CLIEFOR"
cQry += CRLF + "         AND F2_LOJA    = SFT3.FT_LOJA"
cQry += CRLF + "         AND SFT3.FT_TIPOMOV = 'S'"
cQry += CRLF + "       GROUP BY SFT3.FT_FILIAL,"
cQry += CRLF + "                SFT3.FT_NFISCAL,"
cQry += CRLF + "                SFT3.FT_SERIE,"
cQry += CRLF + "                SFT3.FT_CLIEFOR,"
cQry += CRLF + "                SFT3.FT_LOJA"
cQry += CRLF + "     ),"
cQry += CRLF + "     F2_VALIMP5 = ("
cQry += CRLF + "       SELECT SUM(FT_VALCOF)"
cQry += CRLF + "       FROM " + RetSqlName('SFT') + " SFT4"
cQry += CRLF + "       WHERE SFT4.D_E_L_E_T_ <> '*'"
cQry += CRLF + "         AND F2_FILIAL  = SFT4.FT_FILIAL"
cQry += CRLF + "         AND F2_DOC     = SFT4.FT_NFISCAL"
cQry += CRLF + "         AND F2_SERIE   = SFT4.FT_SERIE"
cQry += CRLF + "         AND F2_CLIENTE = SFT4.FT_CLIEFOR"
cQry += CRLF + "         AND F2_LOJA    = SFT4.FT_LOJA"
cQry += CRLF + "         AND SFT4.FT_TIPOMOV = 'S'"
cQry += CRLF + "       GROUP BY SFT4.FT_FILIAL,"
cQry += CRLF + "                SFT4.FT_NFISCAL,"
cQry += CRLF + "                SFT4.FT_SERIE,"
cQry += CRLF + "                SFT4.FT_CLIEFOR,"
cQry += CRLF + "                SFT4.FT_LOJA"
cQry += CRLF + "     )"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND F2_FILIAL = '" + xFilial('SF2') + "'"
cQry += CRLF + "   AND LEFT(F2_EMISSAO,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
aQry[nPos] := cQry

#ifdef NAO_EXECUTA
x:=0
Return Nil
#endif

ProcRegua(nTam)

Begin Transaction
	For nI := 1 to nTam
		lExecuta := .T.
		
		nPos := aScan(aEmp, {|x| x[1] == cEmpAnt })
		If nPos > 0
			//existe exceção no array de empresas
			//verifica se não deve executar para esta empresa
			//através do nI que é a posição atual do array que está
			//diretamente ligada com os defines do início da rotina
			nPos := aScan(aEmp[nPos][2], nI)
			If nPos > 0
				lExecuta := .F.
			EndIf
		EndIf
		
		If lExecuta .and. nI == ATUALIZA_NCM
			If !MsgYesNo('Deseja atualizar o NCM no Livro Fiscal de acordo com o Cadastro de Produto atual?')
				lNCM := .F.
				lExecuta := .F.
			EndIf
		EndIf
		
		If lExecuta
			If aDesc[nI] <> Nil
				IncProc(cValToChar(nI) + '/' + cValToChar(nTam) + ' - ' + aDesc[nI])
			Else
				IncProc()
			EndIf
			If aQry[nI] <> Nil
				cQry := CRLF + aQry[nI]
				nRet := TCSQLExec(cQry)
				If nRet <> 0
					Aviso('Erro ' + cValToChar(nI) + '/' + cValToChar(nTam),cQry + CRLF + CRLF + TCSQLError(),{'OK'})
					DisarmTransaction()
					lErro := .T.
					Exit
				EndIf
			Endif
		Else
			IncProc()
		EndIf
	Next nI
End Transaction

If lErro
	Alert('O processamento foi abortado devido ao erro.')
Else
	U_MyLog('MyPisCof', '', Iif(lNCM,'Atualizou NCM',''),,'Período: ' + MV_PAR01 + ' até ' + MV_PAR02)
EndIf

Return Nil

/* ---------------- */

Static Function CriaSX1(cPerg)

Local nTamGrp := Len(SX1->X1_GRUPO)
Local aHelpPor := {}, aHelpEng := {}, aHelpSpa := {}
Local cNome

aHelpPor := {}
aAdd(aHelpPor, 'Informe o ano/mes inicial para       ')
aAdd(aHelpPor, 'cálculo do PIS/COFINS. Ex: 201201    ')
cNome := 'Do Ano Mes (Ex: 201201)'
PutSx1(PadR(cPerg,nTamGrp), '01', cNome, cNome, cNome,;
'MV_CH1', 'C', 6, 0, 0, 'G', '', '', '', '', 'MV_PAR01',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe o ano/mes final para         ')
aAdd(aHelpPor, 'cálculo do PIS/COFINS. Ex: 201203    ')
cNome := 'Ate Ano Mes (Ex: 201203)'
PutSx1(PadR(cPerg,nTamGrp), '02', cNome, cNome, cNome,;
'MV_CH2', 'C', 6, 0, 0, 'G', '', '', '', '', 'MV_PAR02',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
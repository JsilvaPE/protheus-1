#include 'rwmake.ch'
#include 'protheus.ch'

#define CF_FILIAL   01
#define CF_CFOP     02
#define CF_CST      03
#define CF_VALCONT  04
#define CF_VALITEM  05
#define CF_BASEPIS  06
#define CF_BASECOF  07
#define CF_VALPIS   08
#define CF_VALCOF   09
#define CF_CALPIS   10
#define CF_CALCOF   11
#define CF_ICMSRET  12
#define CF_IPI      13
#define CF_DESCONT  14
#define CF_FRETE    15
#define CF_DESPESA  16
#define CF_SEGURO   17
#define CF_ULTIMO   18

#define CFG_CFOP     01
#define CFG_CST      02
#define CFG_VALCONT  03
#define CFG_VALITEM  04
#define CFG_BASEPIS  05
#define CFG_BASECOF  06
#define CFG_VALPIS   07
#define CFG_VALCOF   08
#define CFG_CALPIS   09
#define CFG_CALCOF   10
#define CFG_ICMSRET  11
#define CFG_IPI      12
#define CFG_DESCONT  13
#define CFG_FRETE    14
#define CFG_DESPESA  15
#define CFG_SEGURO   16
#define CFG_ULTIMO   17

#define CST_CST      01
#define CST_VALCONT  02
#define CST_VALITEM  03
#define CST_BASEPIS  04
#define CST_BASECOF  05
#define CST_VALPIS   06
#define CST_VALCOF   07
#define CST_CALPIS   08
#define CST_CALCOF   09
#define CST_ICMSRET  10
#define CST_IPI      11
#define CST_DESCONT  12
#define CST_FRETE    13
#define CST_DESPESA  14
#define CST_SEGURO   15
#define CST_ULTIMO   16

#define CNAT_CST     01
#define CNAT_TNATREC 02
#define CNAT_CNATREC 03
#define CNAT_VALITEM 04
#define CNAT_ULTIMO  05

#define CBCC_CST      01
#define CBCC_CODBCC   02
#define CBCC_BASEPIS  03
#define CBCC_BASECOF  04
#define CBCC_VALPIS   05
#define CBCC_VALCOF   06
#define CBCC_ULTIMO   07

#define SOMA_VALCONT  01
#define SOMA_VALITEM  02
#define SOMA_BASEPIS  03
#define SOMA_BASECOF  04
#define SOMA_VALPIS   05
#define SOMA_VALCOF   06
#define SOMA_CALPIS   07
#define SOMA_CALCOF   08
#define SOMA_ICMSRET  09
#define SOMA_IPI      10
#define SOMA_DESCONT  11
#define SOMA_FRETE    12
#define SOMA_DESPESA  13
#define SOMA_SEGURO   14
#define SOMA_ULTIMO   15

#define NAT_NAT       01
#define NAT_CST       02
#define NAT_CODBCC    03
#define NAT_VALOR     04
#define NAT_ULTIMO    05

#define NATG_NAT       01
#define NATG_CST       02
#define NATG_CODBCC    03
#define NATG_VALOR     04
#define NATG_BASEPIS   05
#define NATG_BASECOF   06
#define NATG_VALPIS    07
#define NATG_VALCOF    08
#define NATG_ULTIMO    09

#define ATFA_CST     01
#define ATFA_CODBCC  02
#define ATFA_ID      03
#define ATFA_USO     04
#define ATFA_ORIGEM  05
#define ATFA_MESANO  06
#define ATFA_BASEPIS 07
#define ATFA_BASECOF 08
#define ATFA_VALPIS  09
#define ATFA_VALCOF  10
#define ATFA_ULTIMO  11

#define ATFAG_CST     01
#define ATFAG_CODBCC  02
#define ATFAG_ID      03
#define ATFAG_USO     04
#define ATFAG_ORIGEM  05
#define ATFAG_MESANO  06
#define ATFAG_BASEPIS 07
#define ATFAG_BASECOF 08
#define ATFAG_VALPIS  09
#define ATFAG_VALCOF  10
#define ATFAG_ULTIMO  11

#define ATFD_CST     01
#define ATFD_CODBCC  02
#define ATFD_ID      03
#define ATFD_USO     04
#define ATFD_ORIGEM  05
#define ATFD_MESANO  06
#define ATFD_BASEPIS 07
#define ATFD_BASECOF 08
#define ATFD_VALPIS  09
#define ATFD_VALCOF  10
#define ATFD_ULTIMO  11

#define ATFDG_CST     01
#define ATFDG_CODBCC  02
#define ATFDG_ID      03
#define ATFDG_USO     04
#define ATFDG_ORIGEM  05
#define ATFDG_MESANO  06
#define ATFDG_BASEPIS 07
#define ATFDG_BASECOF 08
#define ATFDG_VALPIS  09
#define ATFDG_VALCOF  10
#define ATFDG_ULTIMO  11

#define APU_CON       01
#define APU_CON_ACR   02
#define APU_CON_RED   03
#define APU_CRE       04
#define APU_CRE_ACR   05
#define APU_CRE_RED   06
#define APU_ULTIMO_01 07

#define APU_VALPIS    01
#define APU_VALCOF    02
#define APU_CALPIS    03
#define APU_CALCOF    04
#define APU_ULTIMO_02 05

#define AJUCON_TIPO_CANCELAMENTO 01
#define AJUCON_TIPO_ANULACAO     02

#define AJUCON_TIPO      01
#define AJUCON_FILIAL    02
#define AJUCON_ESPECIE   03
#define AJUCON_ENTRADA   04
#define AJUCON_SERIE     05
#define AJUCON_DOCUMENTO 06
#define AJUCON_VALCONT   07
#define AJUCON_VALITEM   08
#define AJUCON_BASEPIS   09
#define AJUCON_BASECOF   10
#define AJUCON_VALPIS    11
#define AJUCON_VALCOF    12
#define AJUCON_ULTIMO    13

#define AJUCRE_TIPO_DEVOLUCAO 01

#define AJUCRE_TIPO      01
#define AJUCRE_FILIAL    02
#define AJUCRE_SDOC      03
#define AJUCRE_SSERIE    04
#define AJUCRE_SENTRADA  05
#define AJUCRE_SVALCONT  06
#define AJUCRE_STOTAL    07
#define AJUCRE_EDOC      08
#define AJUCRE_ESERIE    09
#define AJUCRE_EENTRADA  10
#define AJUCRE_ECST      11
#define AJUCRE_EVALCONT  12
#define AJUCRE_EBASEPIS  13
#define AJUCRE_EBASECOF  14
#define AJUCRE_EVALPIS   15
#define AJUCRE_EVALCOF   16
#define AJUCRE_MONOFALQZ 17
#define AJUCRE_PERIODO   18
#define AJUCRE_ULTIMO    19

#define DVCOM_CFOP    01
#define DVCOM_CST     02
#define DVCOM_TNATREC 03
#define DVCOM_CNATREC 04
#define DVCOM_CODBCC  05
#define DVCOM_VALITEM 06
#define DVCOM_BASEPIS 07
#define DVCOM_BASECOF 08
#define DVCOM_VALPIS  09
#define DVCOM_VALCOF  10
#define DVCOM_DOCS    11
#define DVCOM_ULTIMO  12

Static aIndics := FGetIndics() //para uso das funções CredAntPis e CredAntCof copiadas do SPEDPISCOF.prw

///////////////////////////////////////////////////////////////////////////////
User Function MyApuPC()
///////////////////////////////////////////////////////////////////////////////
// Data : 16/07/2013
// User : Thieres Tembra
// Desc : Emite o relatório de apuração do PIS/COFINS
// Ação : A rotina emite o relatório por CFOP e por CST da tabela SFT
//        e exporta o resultado para o excel.
///////////////////////////////////////////////////////////////////////////////

Local cTitulo := 'Apuração PIS/COFINS (SFT)'
Local cPerg := '#MyApuPC'
Local aArea := GetArea()
Local aAreaSM0 := SM0->(GetArea())
Local nI, nJ
//salva filial logada
Local cFilSave := cFilAnt

CriaSX1(cPerg)

If !Pergunte(cPerg, .T., cTitulo)
	Return Nil
End If

If MV_PAR01 == Nil .or. MV_PAR01 > 12 .or. MV_PAR01 < 1
	Alert('Informe um mês válido para geração do relatório.')
	Return Nil
ElseIf MV_PAR02 == Nil .or. MV_PAR02 < 1000
	Alert('Informe um ano válido para geração do relatório.')
	Return Nil
EndIf

Private _aApura
Private _cMesAtu := StrZero(MV_PAR02,4) + StrZero(MV_PAR01,2)
Private _cMesAnt := ''

If MV_PAR01 - 1 == 0
	_cMesAnt := StrZero(MV_PAR02 - 1,4) + '12'
Else
	_cMesAnt := StrZero(MV_PAR02,4) + StrZero(MV_PAR01 - 1,2)
EndIf

//inicializando array de apuração final
_aApura := Array(APU_ULTIMO_01 - 1)
For nI := APU_CON to APU_ULTIMO_01 - 1
	_aApura[nI] := Array(APU_ULTIMO_02 - 1)
	For nJ := APU_VALPIS to APU_ULTIMO_02 - 1
		_aApura[nI][nJ] := 0
	Next nJ
Next nI

Processa({|| Executa(cTitulo) },cTitulo,'Realizando consulta...')

SM0->(RestArea(aAreaSM0))
RestArea(aArea)

//restaura filial logada
cFilAnt := cFilSave

Return Nil

/* -------------- */

Static Function Executa(cTitulo)

Local cQry
Local cRet, cAux, cFAnt
Local cArq := 'ApuPC'
Local aExcel := {}
Local aCST, aSomaE, aSomaS, aCFOP, aCFOPG, aNatG, aAtfAG, aAtfDG
Local aCNat, aCNatG
Local aCBcc, aCBccG
Local nCnt, nPos
Local cCFAnt
Local cFil := MV_PAR03
Local nSomaCF
Local nCntCF
Local aAux
Local cDescCF
Local aDev

Private _aCSTG
Private _aAjuConG
Private _aAjuCreG
Private _aDvComG

ProcRegua(0)

cQry := CRLF + " SELECT "
cQry += CRLF + "        FT_FILIAL FILIAL"
cQry += CRLF + "       ,FT_CFOP CFOP"
cQry += CRLF + "       ,FT_CSTPIS CST"
cQry += CRLF + "       ,FT_TNATREC TNATREC"
cQry += CRLF + "       ,FT_CNATREC CNATREC"
cQry += CRLF + "       ,FT_CODBCC CODBCC"
cQry += CRLF + "       ,ROUND(SUM(FT_VALCONT),2) VALCONT"
cQry += CRLF + "       ,ROUND(SUM(CASE FT_AGREG WHEN 'I' THEN FT_TOTAL+FT_VALICM ELSE FT_TOTAL END),2) VALITEM"
cQry += CRLF + "       ,ROUND(SUM(FT_BASEPIS),2) BASEPIS"
cQry += CRLF + "       ,ROUND(SUM(FT_BASECOF),2) BASECOF"
cQry += CRLF + "       ,ROUND(SUM(FT_VALPIS),2) VALPIS"
cQry += CRLF + "       ,ROUND(SUM(FT_VALCOF),2) VALCOF"
cQry += CRLF + "       ,CASE ROUND(SUM(FT_VALPIS),2) WHEN 0 THEN 0 ELSE CEILING(ROUND(SUM(FT_BASEPIS),2) * " + cValToChar(MV_PAR07) + ")/100 END CALPIS"
cQry += CRLF + "       ,CASE ROUND(SUM(FT_VALCOF),2) WHEN 0 THEN 0 ELSE CEILING(ROUND(SUM(FT_BASECOF),2) * " + cValToChar(MV_PAR08) + ")/100 END CALCOF"
cQry += CRLF + "       ,ROUND(SUM(FT_ICMSRET),2) ICMSRET"
cQry += CRLF + "       ,ROUND(SUM(FT_VALIPI),2) IPI"
cQry += CRLF + "       ,ROUND(SUM(FT_DESCONT),2) DESCONT"
cQry += CRLF + "       ,ROUND(SUM(FT_FRETE),2) FRETE"
cQry += CRLF + "       ,ROUND(SUM(FT_DESPESA-(FT_SEGURO+FT_FRETE)),2) DESPESA"
cQry += CRLF + "       ,ROUND(SUM(FT_SEGURO),2) SEGURO"
cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
cQry += CRLF + " LEFT JOIN SF3010 SF3"
cQry += CRLF + " ON  SF3.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND F3_FILIAL = FT_FILIAL"
cQry += CRLF + " AND F3_NFISCAL = FT_NFISCAL"
cQry += CRLF + " AND F3_SERIE = FT_SERIE"
cQry += CRLF + " AND F3_CLIEFOR = FT_CLIEFOR"
cQry += CRLF + " AND F3_LOJA = FT_LOJA"
cQry += CRLF + " AND F3_CFO = FT_CFOP"
cQry += CRLF + " AND F3_TIPO = FT_TIPO"
cQry += CRLF + " AND F3_IDENTFT = FT_IDENTF3"
cQry += CRLF + " WHERE LEFT(FT_ENTRADA,6) = '" + _cMesAtu + "'"
If MV_PAR12 == 2
	//todos os cancelados
	cQry += CRLF + "   AND LEN(FT_DTCANC) = 0 "
	cQry += CRLF + "   AND FT_OBSERV NOT LIKE '%INUTIL%'"
	cQry += CRLF + "   AND FT_OBSERV NOT LIKE '%CANCEL%'"
ElseIf MV_PAR12 == 1
	//somente cancelados dentro do período
	cQry += CRLF + "   AND ("
	cQry += CRLF + "     ("
	cQry += CRLF + "           LEN(FT_DTCANC) = 0 "
	cQry += CRLF + "       AND FT_OBSERV NOT LIKE '%INUTIL%'"
	cQry += CRLF + "       AND FT_OBSERV NOT LIKE '%CANCEL%'"
	cQry += CRLF + "     ) OR ("
	cQry += CRLF + "           LEN(FT_DTCANC) > 0 "
	cQry += CRLF + "       AND FT_OBSERV LIKE '%CANCEL%'"
	cQry += CRLF + "       AND LEFT(FT_DTCANC,6) > '" + _cMesAtu + "'"
	cQry += CRLF + "       AND F3_CODRSEF = '101'"
	cQry += CRLF + "     )"
	cQry += CRLF + "   )"
EndIf
cQry += CRLF + "   AND SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
If AllTrim(MV_PAR05) <> ''
	cQry += CRLF + "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR05))
EndIf
If AllTrim(MV_PAR06) <> ''
	cQry += CRLF + "   AND FT_CSTPIS IN "+U_MyGeraIn(AllTrim(MV_PAR06))
EndIf
cQry += CRLF + " GROUP BY FT_FILIAL, FT_CFOP, FT_CSTPIS, FT_TNATREC, FT_CNATREC, FT_CODBCC "
cQry += CRLF + " ORDER BY FT_FILIAL, FT_CFOP, FT_CSTPIS, FT_TNATREC, FT_CNATREC, FT_CODBCC "
//Aviso('cQry',cQry+CRLF+CRLF+CRLF,{'ok'})
cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSFT',.T.)

nCnt := 0
SSFT->(dbEval({||nCnt++}))
SSFT->(dbGoTop())

ProcRegua(nCnt)
aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' às '+Time()+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Mês: '+StrZero(MV_PAR01,2)+' - Ano: '+StrZero(MV_PAR02,4)+' - Filial: '+MV_PAR03+' até '+MV_PAR04})
If AllTrim(MV_PAR05) <> ''
	aAdd(aExcel, {'Somente CFOPs: '+AllTrim(MV_PAR05)})
EndIf
If AllTrim(MV_PAR06) <> ''
	aAdd(aExcel, {'Somente CSTs: '+AllTrim(MV_PAR06)})
EndIf
aAdd(aExcel, {'Alíquota PIS (coluna Calculado): '+Transform(MV_PAR07, '@E 9.99')})
aAdd(aExcel, {'Alíquota COFINS (coluna Calculado): '+Transform(MV_PAR08, '@E 9.99')})
aAdd(aExcel, {'Considera títulos: '+Iif(MV_PAR09==1,'Sim','Não')})
aAdd(aExcel, {'Considera ativo aquisição: '+Iif(MV_PAR10==1,'Sim','Não')})
aAdd(aExcel, {'Considera ativo depreciação: '+Iif(MV_PAR11==1,'Sim','Não')})
aAdd(aExcel, {'Considera cancelados: '+Iif(MV_PAR12==1,'Dentro do período','Todos')})

cFAnt  := ''
aCFOP  := {}
aCFOPG := {}
aNatG  := {}
aCST   := {}
aCNat  := {}
aCBcc  := {}
aCNatG := {}
aCBccG := {}
aAtfAG  := {}
aAtfDG  := {}

_aCSTG := {}
_aAjuConG := {}
_aAjuCreG := {}
_aDvComG := {}

While !SSFT->(Eof())
	If cFAnt <> SSFT->FILIAL 
		//se mudou a filial e não está no início, imprime apuração e soma por CST
		If cFAnt <> ''
			PorCFOP(aExcel, aCFOP, aCST, aCNat, aNatG, aCBcc, aCBccG, aAtfAG, aAtfDG, cFAnt)
		EndIf
		
		//inicia nova empresa
		aAdd(aExcel, {''})
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cEmpAnt+SSFT->FILIAL))
		
		cAux := 'Empresa: '+cEmpAnt+'/'+SSFT->FILIAL+'-'+AllTrim(SM0->M0_NOME)+' / '+AllTrim(SM0->M0_FILIAL)
		IncProc(cAux)
		
		cAux += ' - CNPJ: '+Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')
		aAdd(aExcel, {cAux})
	Else
		IncProc()
	EndIf
	
	//agrupando por CFOP
	nPos := aScan(aCFOP, {|x| x[CF_CFOP] == SSFT->CFOP .and. x[CF_CST] == SSFT->CST})
	If nPos == 0
		aAux := Array(CF_ULTIMO-1)
		aAux[CF_FILIAL]  := SSFT->FILIAL
		aAux[CF_CFOP]    := SSFT->CFOP
		aAux[CF_CST]     := SSFT->CST
		aAux[CF_VALCONT] := SSFT->VALCONT
		aAux[CF_VALITEM] := SSFT->VALITEM
		aAux[CF_BASEPIS] := SSFT->BASEPIS
		aAux[CF_BASECOF] := SSFT->BASECOF
		aAux[CF_VALPIS]  := SSFT->VALPIS
		aAux[CF_VALCOF]  := SSFT->VALCOF
		aAux[CF_CALPIS]  := SSFT->CALPIS
		aAux[CF_CALCOF]  := SSFT->CALCOF
		aAux[CF_ICMSRET] := SSFT->ICMSRET
		aAux[CF_IPI]     := SSFT->IPI
		aAux[CF_DESCONT] := SSFT->DESCONT
		aAux[CF_FRETE]   := SSFT->FRETE
		aAux[CF_DESPESA] := SSFT->DESPESA
		aAux[CF_SEGURO]  := SSFT->SEGURO
		aAdd(aCFOP, aClone(aAux))
	Else
		aCFOP[nPos][CF_VALCONT] += SSFT->VALCONT
		aCFOP[nPos][CF_VALITEM] += SSFT->VALITEM
		aCFOP[nPos][CF_BASEPIS] += SSFT->BASEPIS
		aCFOP[nPos][CF_BASECOF] += SSFT->BASECOF
		aCFOP[nPos][CF_VALPIS]  += SSFT->VALPIS
		aCFOP[nPos][CF_VALCOF]  += SSFT->VALCOF
		aCFOP[nPos][CF_CALPIS]  += SSFT->CALPIS
		aCFOP[nPos][CF_CALCOF]  += SSFT->CALCOF
		aCFOP[nPos][CF_ICMSRET] += SSFT->ICMSRET
		aCFOP[nPos][CF_IPI]     += SSFT->IPI
		aCFOP[nPos][CF_DESCONT] += SSFT->DESCONT
		aCFOP[nPos][CF_FRETE]   += SSFT->FRETE
		aCFOP[nPos][CF_DESPESA] += SSFT->DESPESA
		aCFOP[nPos][CF_SEGURO]  += SSFT->SEGURO
	EndIf
	
	//agrupando por CFOP geral
	nPos := aScan(aCFOPG, {|x| x[CFG_CFOP] == SSFT->CFOP .and. x[CFG_CST] == SSFT->CST})
	If nPos == 0
		aAux := Array(CFG_ULTIMO-1)
		aAux[CFG_CFOP]    := SSFT->CFOP
		aAux[CFG_CST]     := SSFT->CST
		aAux[CFG_VALCONT] := SSFT->VALCONT
		aAux[CFG_VALITEM] := SSFT->VALITEM
		aAux[CFG_BASEPIS] := SSFT->BASEPIS
		aAux[CFG_BASECOF] := SSFT->BASECOF
		aAux[CFG_VALPIS]  := SSFT->VALPIS
		aAux[CFG_VALCOF]  := SSFT->VALCOF
		aAux[CFG_CALPIS]  := SSFT->CALPIS
		aAux[CFG_CALCOF]  := SSFT->CALCOF
		aAux[CFG_ICMSRET] := SSFT->ICMSRET
		aAux[CFG_IPI]     := SSFT->IPI
		aAux[CFG_DESCONT] := SSFT->DESCONT
		aAux[CFG_FRETE]   := SSFT->FRETE
		aAux[CFG_DESPESA] := SSFT->DESPESA
		aAux[CFG_SEGURO]  := SSFT->SEGURO
		aAdd(aCFOPG, aClone(aAux))
	Else
		aCFOPG[nPos][CFG_VALCONT] += SSFT->VALCONT
		aCFOPG[nPos][CFG_VALITEM] += SSFT->VALITEM
		aCFOPG[nPos][CFG_BASEPIS] += SSFT->BASEPIS
		aCFOPG[nPos][CFG_BASECOF] += SSFT->BASECOF
		aCFOPG[nPos][CFG_VALPIS]  += SSFT->VALPIS
		aCFOPG[nPos][CFG_VALCOF]  += SSFT->VALCOF
		aCFOPG[nPos][CFG_CALPIS]  += SSFT->CALPIS
		aCFOPG[nPos][CFG_CALCOF]  += SSFT->CALCOF
		aCFOPG[nPos][CFG_ICMSRET] += SSFT->ICMSRET
		aCFOPG[nPos][CFG_IPI]     += SSFT->IPI
		aCFOPG[nPos][CFG_DESCONT] += SSFT->DESCONT
		aCFOPG[nPos][CFG_FRETE]   += SSFT->FRETE
		aCFOPG[nPos][CFG_DESPESA] += SSFT->DESPESA
		aCFOPG[nPos][CFG_SEGURO]  += SSFT->SEGURO
	EndIf
	
	//agrupando por CST
	nPos := aScan(aCST, {|x| x[CST_CST] == SSFT->CST})
	If nPos == 0
		aAux := Array(CST_ULTIMO-1)
		aAux[CST_CST]     := SSFT->CST
		aAux[CST_VALCONT] := SSFT->VALCONT
		aAux[CST_VALITEM] := SSFT->VALITEM
		aAux[CST_BASEPIS] := SSFT->BASEPIS
		aAux[CST_BASECOF] := SSFT->BASECOF
		aAux[CST_VALPIS]  := SSFT->VALPIS
		aAux[CST_VALCOF]  := SSFT->VALCOF
		aAux[CST_CALPIS]  := SSFT->CALPIS
		aAux[CST_CALCOF]  := SSFT->CALCOF
		aAux[CST_ICMSRET] := SSFT->ICMSRET
		aAux[CST_IPI]     := SSFT->IPI
		aAux[CST_DESCONT] := SSFT->DESCONT
		aAux[CST_FRETE]   := SSFT->FRETE
		aAux[CST_DESPESA] := SSFT->DESPESA
		aAux[CST_SEGURO]  := SSFT->SEGURO
		aAdd(aCST, aClone(aAux))
	Else
		aCST[nPos][CST_VALCONT] += SSFT->VALCONT
		aCST[nPos][CST_VALITEM] += SSFT->VALITEM
		aCST[nPos][CST_BASEPIS] += SSFT->BASEPIS
		aCST[nPos][CST_BASECOF] += SSFT->BASECOF
		aCST[nPos][CST_VALPIS]  += SSFT->VALPIS
		aCST[nPos][CST_VALCOF]  += SSFT->VALCOF
		aCST[nPos][CST_CALPIS]  += SSFT->CALPIS
		aCST[nPos][CST_CALCOF]  += SSFT->CALCOF
		aCST[nPos][CST_ICMSRET] += SSFT->ICMSRET
		aCST[nPos][CST_IPI]     += SSFT->IPI
		aCST[nPos][CST_DESCONT] += SSFT->DESCONT
		aCST[nPos][CST_FRETE]   += SSFT->FRETE
		aCST[nPos][CST_DESPESA] += SSFT->DESPESA
		aCST[nPos][CST_SEGURO]  += SSFT->SEGURO
	EndIf
	
	If AllTrim(SSFT->TNATREC+SSFT->CNATREC) <> ''
		//agrupando por CST+TNATREC+CNATREC
		nPos := aScan(aCNat, {|x| x[CNAT_CST] == SSFT->CST .and. x[CNAT_TNATREC] == SSFT->TNATREC .and. x[CNAT_CNATREC] == SSFT->CNATREC})
		If nPos == 0
			aAux := Array(CNAT_ULTIMO-1)
			aAux[CNAT_CST]     := SSFT->CST
			aAux[CNAT_TNATREC] := SSFT->TNATREC
			aAux[CNAT_CNATREC] := SSFT->CNATREC
			aAux[CNAT_VALITEM] := SSFT->VALITEM
			aAdd(aCNat, aClone(aAux))
		Else
			aCNat[nPos][CNAT_VALITEM] += SSFT->VALITEM
		EndIf
		
		//agrupando por CST+TNATREC+CNATREC geral
		nPos := aScan(aCNatG, {|x| x[CNAT_CST] == SSFT->CST .and. x[CNAT_TNATREC] == SSFT->TNATREC .and. x[CNAT_CNATREC] == SSFT->CNATREC})
		If nPos == 0
			aAux := Array(CNAT_ULTIMO-1)
			aAux[CNAT_CST]     := SSFT->CST
			aAux[CNAT_TNATREC] := SSFT->TNATREC
			aAux[CNAT_CNATREC] := SSFT->CNATREC
			aAux[CNAT_VALITEM] := SSFT->VALITEM
			aAdd(aCNatG, aClone(aAux))
		Else
			aCNatG[nPos][CNAT_VALITEM] += SSFT->VALITEM
		EndIf
	EndIf
	
	If AllTrim(SSFT->CODBCC) <> ''
		//agrupando por CST+CODBCC
		nPos := aScan(aCBcc, {|x| x[CBCC_CST] == SSFT->CST .and. x[CBCC_CODBCC] == SSFT->CODBCC})
		If nPos == 0
			aAux := Array(CBCC_ULTIMO-1)
			aAux[CBCC_CST]     := SSFT->CST
			aAux[CBCC_CODBCC]  := SSFT->CODBCC
			aAux[CBCC_BASEPIS] := SSFT->BASEPIS
			aAux[CBCC_BASECOF] := SSFT->BASECOF
			aAux[CBCC_VALPIS]  := SSFT->VALPIS
			aAux[CBCC_VALCOF]  := SSFT->VALCOF
			aAdd(aCBcc, aClone(aAux))
		Else
			aCBcc[nPos][CBCC_BASEPIS] += SSFT->BASEPIS
			aCBcc[nPos][CBCC_BASECOF] += SSFT->BASECOF
			aCBcc[nPos][CBCC_VALPIS]  += SSFT->VALPIS
			aCBcc[nPos][CBCC_VALCOF]  += SSFT->VALCOF
		EndIf
	
		//agrupando por CST+CODBCC geral
		nPos := aScan(aCBccG, {|x| x[CBCC_CST] == SSFT->CST .and. x[CBCC_CODBCC] == SSFT->CODBCC})
		If nPos == 0
			aAux := Array(CBCC_ULTIMO-1)
			aAux[CBCC_CST]     := SSFT->CST
			aAux[CBCC_CODBCC]  := SSFT->CODBCC
			aAux[CBCC_BASEPIS] := SSFT->BASEPIS
			aAux[CBCC_BASECOF] := SSFT->BASECOF
			aAux[CBCC_VALPIS]  := SSFT->VALPIS
			aAux[CBCC_VALCOF]  := SSFT->VALCOF
			aAdd(aCBccG, aClone(aAux))
		Else
			aCBccG[nPos][3] += SSFT->BASEPIS
			aCBccG[nPos][4] += SSFT->BASECOF
			aCBccG[nPos][5] += SSFT->VALPIS
			aCBccG[nPos][6] += SSFT->VALCOF
		EndIf
	EndIf
	
	cFAnt := SSFT->FILIAL
	SSFT->(dbSkip())
EndDo

SSFT->(dbCloseArea())

//filial final
PorCFOP(aExcel, aCFOP, aCST, aCNat, aNatG, aCBcc, aCBccG, aAtfAG, aAtfDG, cFAnt)

//resumo geral da empresa
aAdd(aExcel, {''})
cAux := 'Total Empresa: '+cEmpAnt+'-'+AllTrim(SM0->M0_NOME)
IncProc(cAux)
aAdd(aExcel, {cAux})
aAdd(aExcel, {'CFOP', 'CST', 'Valor Contábil', 'Valor do Item', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS', 'ICMS Retido', 'IPI', 'Desconto', 'Frete', 'Despesa', 'Seguro', 'Descrição'})

cCFAnt := ''
aSomaE := Array(SOMA_ULTIMO-1)
aSomaS := Array(SOMA_ULTIMO-1)
aFill(aSomaE, 0)
aFill(aSomaS, 0)
aCST   := {}

nSomaCF := 0
nCntCF  := 0

aSort(aCFOPG,,,{|x,y| x[CFG_CFOP]+x[CFG_CST] < y[CFG_CFOP]+y[CFG_CST]})

nMax := Len(aCFOPG)
For nI := 1 to nMax
	If cCFAnt <> ''
		If cCFAnt <> aCFOPG[nI][CFG_CFOP]
			If nCntCF > 1
				aAdd(aExcel, {'','SOMA',nSomaCF})
			EndIf
			nSomaCF := 0
			nCntCF  := 0
		EndIf
		If cCFAnt < '5000' .and. aCFOPG[nI][CFG_CFOP] >= '5000'
			Total(aExcel,'E',aSomaE)
		EndIf
		If cCFAnt >= '5000' .and. aCFOPG[nI][CFG_CFOP] < '5000'
			Total(aExcel,'S',aSomaS)
		EndIf
	EndIf
		
	//                                     X5_FILIAL      + X5_TABELA + X5_CHAVE
	cDescCF := AllTrim(Posicione('SX5', 1, xFilial('SX5') + '13'      + PadR(aCFOPG[nI][CFG_CFOP],6), 'X5_DESCRI'))
	
	aAdd(aExcel, {aCFOPG[nI][CFG_CFOP]   ,;
	              aCFOPG[nI][CFG_CST]    ,;
	              aCFOPG[nI][CFG_VALCONT],;
	              aCFOPG[nI][CFG_VALITEM],;
	              aCFOPG[nI][CFG_BASEPIS],;
	              aCFOPG[nI][CFG_BASECOF],;
	              aCFOPG[nI][CFG_VALPIS] ,;
	              aCFOPG[nI][CFG_VALCOF] ,;
	              aCFOPG[nI][CFG_ICMSRET],;
	              aCFOPG[nI][CFG_IPI]    ,;
	              aCFOPG[nI][CFG_DESCONT],;
	              aCFOPG[nI][CFG_FRETE]  ,;
	              aCFOPG[nI][CFG_DESPESA],;
	              aCFOPG[nI][CFG_SEGURO] ,;
	              cDescCF                 ;
	})
	
	//removendo devolução de compras DENTRO do período do array de CFOPs
	aDev := {0,0,0,0,''}
	nMaxJ := Len(_aDvComG)
	For nJ := 1 to nMaxJ
		If _aDvComG[nJ][DVCOM_CFOP] == aCFOPG[nI][CFG_CFOP] .and. _aDvComG[nJ][DVCOM_CST] == aCFOPG[nI][CFG_CST]
			aDev[1] += _aDvComG[nJ][DVCOM_BASEPIS]
			aDev[2] += _aDvComG[nJ][DVCOM_BASECOF]
			aDev[3] += _aDvComG[nJ][DVCOM_VALPIS]
			aDev[4] += _aDvComG[nJ][DVCOM_VALCOF]
			aDev[5] += Iif(AllTrim(aDev[5])<>'',', ','') + _aDvComG[nJ][DVCOM_DOCS]
		EndIf
	Next nJ
	
	If aDev[1] > 0 .or. aDev[2] > 0 .or. aDev[3] > 0 .or. aDev[4] > 0
		aCFOPG[nI][CFG_BASEPIS] -= aDev[1]
		aCFOPG[nI][CFG_BASECOF] -= aDev[2]
		aCFOPG[nI][CFG_VALPIS]  -= aDev[3]
		aCFOPG[nI][CFG_VALCOF]  -= aDev[4]
		aCFOPG[nI][CFG_CALPIS]  -= aDev[3]
		aCFOPG[nI][CFG_CALCOF]  -= aDev[4]
		
		aAdd(aExcel, {'Devolução',;
		              '',;
		              0,;
		              0,;
		              aDev[1],;
		              aDev[2],;
		              aDev[3],;
		              aDev[4],;
		              'Docs: ' + aDev[5];
		})
		
		aAdd(aExcel, {aCFOPG[nI][CFG_CFOP]   ,;
		              aCFOPG[nI][CFG_CST]    ,;
		              aCFOPG[nI][CFG_VALCONT],;
		              aCFOPG[nI][CFG_VALITEM],;
		              aCFOPG[nI][CFG_BASEPIS],;
		              aCFOPG[nI][CFG_BASECOF],;
		              aCFOPG[nI][CFG_VALPIS] ,;
		              aCFOPG[nI][CFG_VALCOF] ,;
		              aCFOPG[nI][CFG_ICMSRET],;
		              aCFOPG[nI][CFG_IPI]    ,;
		              aCFOPG[nI][CFG_DESCONT],;
		              aCFOPG[nI][CFG_FRETE]  ,;
		              aCFOPG[nI][CFG_DESPESA],;
		              aCFOPG[nI][CFG_SEGURO] ,;
		              cDescCF                 ;
		})
	EndIf
	
	nSomaCF += aCFOPG[nI][CFG_VALCONT]
	nCntCF++
	
	//somando valores
	If aCFOPG[nI][CFG_CFOP] < '5000'
		aSomaE[SOMA_VALCONT] += aCFOPG[nI][CFG_VALCONT]
		aSomaE[SOMA_VALITEM] += aCFOPG[nI][CFG_VALITEM]
		aSomaE[SOMA_BASEPIS] += aCFOPG[nI][CFG_BASEPIS]
		aSomaE[SOMA_BASECOF] += aCFOPG[nI][CFG_BASECOF]
		aSomaE[SOMA_VALPIS]  += aCFOPG[nI][CFG_VALPIS]
		aSomaE[SOMA_VALCOF]  += aCFOPG[nI][CFG_VALCOF]
		aSomaE[SOMA_CALPIS]  += aCFOPG[nI][CFG_CALPIS]
		aSomaE[SOMA_CALCOF]  += aCFOPG[nI][CFG_CALCOF]
		aSomaE[SOMA_ICMSRET] += aCFOPG[nI][CFG_ICMSRET]
		aSomaE[SOMA_IPI]     += aCFOPG[nI][CFG_IPI]
		aSomaE[SOMA_DESCONT] += aCFOPG[nI][CFG_DESCONT]
		aSomaE[SOMA_FRETE]   += aCFOPG[nI][CFG_FRETE]
		aSomaE[SOMA_DESPESA] += aCFOPG[nI][CFG_DESPESA]
		aSomaE[SOMA_SEGURO]  += aCFOPG[nI][CFG_SEGURO]
	Else
		aSomaS[SOMA_VALCONT] += aCFOPG[nI][CFG_VALCONT]
		aSomaS[SOMA_VALITEM] += aCFOPG[nI][CFG_VALITEM]
		aSomaS[SOMA_BASEPIS] += aCFOPG[nI][CFG_BASEPIS]
		aSomaS[SOMA_BASECOF] += aCFOPG[nI][CFG_BASECOF]
		aSomaS[SOMA_VALPIS]  += aCFOPG[nI][CFG_VALPIS]
		aSomaS[SOMA_VALCOF]  += aCFOPG[nI][CFG_VALCOF]
		aSomaS[SOMA_CALPIS]  += aCFOPG[nI][CFG_CALPIS]
		aSomaS[SOMA_CALCOF]  += aCFOPG[nI][CFG_CALCOF]
		aSomaS[SOMA_ICMSRET] += aCFOPG[nI][CFG_ICMSRET]
		aSomaS[SOMA_IPI]     += aCFOPG[nI][CFG_IPI]
		aSomaS[SOMA_DESCONT] += aCFOPG[nI][CFG_DESCONT]
		aSomaS[SOMA_FRETE]   += aCFOPG[nI][CFG_FRETE]
		aSomaS[SOMA_DESPESA] += aCFOPG[nI][CFG_DESPESA]
		aSomaS[SOMA_SEGURO]  += aCFOPG[nI][CFG_SEGURO]
	EndIf
	
	//agrupando por CST
	nPos := aScan(aCST, {|x| x[CST_CST] == aCFOPG[nI][CFG_CST]})
	If nPos == 0
		aAux := Array(CST_ULTIMO-1)
		aAux[CST_CST]     := aCFOPG[nI][CFG_CST]
		aAux[CST_VALCONT] := aCFOPG[nI][CFG_VALCONT]
		aAux[CST_VALITEM] := aCFOPG[nI][CFG_VALITEM]
		aAux[CST_BASEPIS] := aCFOPG[nI][CFG_BASEPIS]
		aAux[CST_BASECOF] := aCFOPG[nI][CFG_BASECOF]
		aAux[CST_VALPIS]  := aCFOPG[nI][CFG_VALPIS]
		aAux[CST_VALCOF]  := aCFOPG[nI][CFG_VALCOF]
		aAux[CST_CALPIS]  := aCFOPG[nI][CFG_CALPIS]
		aAux[CST_CALCOF]  := aCFOPG[nI][CFG_CALCOF]
		aAux[CST_ICMSRET] := aCFOPG[nI][CFG_ICMSRET]
		aAux[CST_IPI]     := aCFOPG[nI][CFG_IPI]
		aAux[CST_DESCONT] := aCFOPG[nI][CFG_DESCONT]
		aAux[CST_FRETE]   := aCFOPG[nI][CFG_FRETE]
		aAux[CST_DESPESA] := aCFOPG[nI][CFG_DESPESA]
		aAux[CST_SEGURO]  := aCFOPG[nI][CFG_SEGURO]
		aAdd(aCST, aClone(aAux))
	Else
		aCST[nPos][CST_VALCONT] += aCFOPG[nI][CFG_VALCONT]
		aCST[nPos][CST_VALITEM] += aCFOPG[nI][CFG_VALITEM]
		aCST[nPos][CST_BASEPIS] += aCFOPG[nI][CFG_BASEPIS]
		aCST[nPos][CST_BASECOF] += aCFOPG[nI][CFG_BASECOF]
		aCST[nPos][CST_VALPIS]  += aCFOPG[nI][CFG_VALPIS]
		aCST[nPos][CST_VALCOF]  += aCFOPG[nI][CFG_VALCOF]
		aCST[nPos][CST_CALPIS]  += aCFOPG[nI][CFG_CALPIS]
		aCST[nPos][CST_CALCOF]  += aCFOPG[nI][CFG_CALCOF]
		aCST[nPos][CST_ICMSRET] += aCFOPG[nI][CFG_ICMSRET]
		aCST[nPos][CST_IPI]     += aCFOPG[nI][CFG_IPI]
		aCST[nPos][CST_DESCONT] += aCFOPG[nI][CFG_DESCONT]
		aCST[nPos][CST_FRETE]   += aCFOPG[nI][CFG_FRETE]
		aCST[nPos][CST_DESPESA] += aCFOPG[nI][CFG_DESPESA]
		aCST[nPos][CST_SEGURO]  += aCFOPG[nI][CFG_SEGURO]
	EndIf
	
	cCFAnt := aCFOPG[nI][CFG_CFOP]
Next nI

//não é necessário remover devolução de compras DENTRO do período do array de CSTs
//pois o mesmo é criado após remover as devoluções do array de CFOPs
	
//imprime total final
If cCFAnt < '5000'
	Total(aExcel,'E',aSomaE)
ElseIf cCFAnt >= '5000'
	Total(aExcel,'S',aSomaS)
EndIf	
//limpa somas
LimpaSoma(aSomaE,aSomaS)
PorCST(aExcel,aCST,.F.,'Somente CFOPs',.F.)


If MV_PAR09 == 1
	//considera títulos
	Titulos(aExcel,aCST,aNatG,,,.T.)
	PorCST(aExcel,aCST,.F.,'Somente Títulos',.F.)
EndIf

If MV_PAR10 == 1
	//considera ativo aquisição
	AtivoA(aExcel,aCST,,,aAtfAG,.T.)
	PorCST(aExcel,aCST,.F.,'Somente Ativo [Aquisição]',.F.)
EndIf

If MV_PAR11 == 1
	//considera ativo depreciação
	AtivoD(aExcel,aCST,,,aAtfDG,.T.)
	PorCST(aExcel,aCST,.F.,'Somente Ativo [Depreciação]',.F.)
EndIf

PorCST(aExcel,_aCSTG,.T.,'CFOPs + Títulos + Ativo [Aquisição] + Ativo [Depreciação]',.T.,.T.)

AjuConCan(aExcel,cFAnt,.T.)
AjuConAnu(aExcel,cFAnt,.T.)
AjuCreDev(aExcel,cFAnt,.T.)

ApuFinal(aExcel)

//não é necessário remover devolução de compras DENTRO do período do array de Natureza de Receita
//pois só são estornadas as devoluções de CST 50 e este CST não se aplica aos registros com Natureza de Receita

//removendo devolução de compras DENTRO do período do array de Base de Cálculo de Crédito
nMax := Len(aCBccG)
For nI := 1 to nMax
	aDev := {0,0,0,0}
	nMaxJ := Len(_aDvComG)
	For nJ := 1 to nMaxJ
		If _aDvComG[nJ][DVCOM_CST] == aCBccG[nI][CBCC_CST] .and. _aDvComG[nJ][DVCOM_CODBCC] == aCBccG[nI][CBCC_CODBCC]
			aDev[1] += _aDvComG[nJ][DVCOM_BASEPIS]
			aDev[2] += _aDvComG[nJ][DVCOM_BASECOF]
			aDev[3] += _aDvComG[nJ][DVCOM_VALPIS]
			aDev[4] += _aDvComG[nJ][DVCOM_VALCOF]
		EndIf
	Next nJ
	
	If aDev[1] > 0 .or. aDev[2] > 0 .or. aDev[3] > 0 .or. aDev[4] > 0
		aCBccG[nI][CBCC_BASEPIS] -= aDev[1]
		aCBccG[nI][CBCC_BASECOF] -= aDev[2]
		aCBccG[nI][CBCC_VALPIS]  -= aDev[3]
		aCBccG[nI][CBCC_VALCOF]  -= aDev[4]
	EndIf
Next nI

PorCNAT(aExcel,aCNatG)
PorCBCC(aExcel,aCBccG)

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

Static Function Total(aExcel,cES,aSoma)

aAdd(aExcel, {Iif(cES=='E','ENTRADAS','SAÍDAS'), '',;
              aSoma[SOMA_VALCONT],;
              aSoma[SOMA_VALITEM],;
              aSoma[SOMA_BASEPIS],;
              aSoma[SOMA_BASECOF],;
              aSoma[SOMA_VALPIS] ,;
              aSoma[SOMA_VALCOF] ,;
              aSoma[SOMA_ICMSRET],;
              aSoma[SOMA_IPI]    ,;
              aSoma[SOMA_DESCONT],;
              aSoma[SOMA_FRETE]  ,;
              aSoma[SOMA_DESPESA],;
              aSoma[SOMA_SEGURO]  ;
})
aAdd(aExcel, {''})

Return Nil

/* -------------- */

Static Function LimpaSoma(aSomaE,aSomaS)

aSomaE := Array(SOMA_ULTIMO-1)
aSomaS := Array(SOMA_ULTIMO-1)
aFill(aSomaE, 0)
aFill(aSomaS, 0)

Return Nil

/* -------------- */

Static Function PorCST(aExcel,aCST,lAjusta,cTipo,lFinal,lApura)

Local nI, nMax, nPos
Local nCalPIS, nCalCOF
Local nDifPIS, nDifCOF
Local cDescCST
Local aAux

nMax := Len(aCST)

If ValType(lAjusta) == 'U'
	lAjusta := .F.
EndIf

If ValType(lFinal) == 'U'
	lFinal := .F.
EndIf

If ValType(lApura) == 'U'
	lApura := .F.
EndIf

If ValType(cTipo) == 'U'
	cTipo := '-'
EndIf

//desabilitado ajuste por enquanto
lAjusta := .F.

aSort(aCST,,,{|x,y| x[CST_CST] < y[CST_CST]})

If lFinal
	aAdd(aExcel, {'Detalhamento CST (' + cTipo + ')'})
	aAdd(aExcel, {'CST', 'Valor Contábil', 'Valor do Item', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Calculado PIS', 'Valor COFINS', 'Calculado COFINS', 'ICMS Retido', 'IPI', 'Desconto', 'Frete', 'Despesa', 'Seguro', 'Descrição'})
Else
	aAdd(aExcel, {'','Detalhamento CST (' + cTipo + ')'})
	aAdd(aExcel, {'','CST', 'Valor Contábil', 'Valor do Item', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Calculado PIS', 'Valor COFINS', 'Calculado COFINS', 'ICMS Retido', 'IPI', 'Desconto', 'Frete', 'Despesa', 'Seguro', 'Descrição'})
EndIf
For nI := 1 to nMax
	nCalPIS := Iif(aCST[nI][CST_VALPIS]==0,0,Ceiling(aCST[nI][CST_BASEPIS]*MV_PAR07)/100)
	nCalCOF := Iif(aCST[nI][CST_VALCOF]==0,0,Ceiling(aCST[nI][CST_BASECOF]*MV_PAR08)/100)
	
	//                                   X5_FILIAL      + X5_TABELA + X5_CHAVE
	cDescCST := AllTrim(Posicione('SX5', 1, xFilial('SX5') + 'SX'      + PadR(aCST[nI][CST_CST],6), 'X5_DESCRI'))
	
	aAux := {}
	If !lFinal
		aAdd(aAux, '')
	EndIf
	aAdd(aAux, aCST[nI][CST_CST])
	aAdd(aAux, aCST[nI][CST_VALCONT])
	aAdd(aAux, aCST[nI][CST_VALITEM])
	aAdd(aAux, aCST[nI][CST_BASEPIS])
	aAdd(aAux, aCST[nI][CST_BASECOF])
	aAdd(aAux, aCST[nI][CST_VALPIS])
	aAdd(aAux, nCalPIS)
	aAdd(aAux, aCST[nI][CST_VALCOF])
	aAdd(aAux, nCalCOF)
	aAdd(aAux, aCST[nI][CST_ICMSRET])
	aAdd(aAux, aCST[nI][CST_IPI])
	aAdd(aAux, aCST[nI][CST_DESCONT])
	aAdd(aAux, aCST[nI][CST_FRETE])
	aAdd(aAux, aCST[nI][CST_DESPESA])
	aAdd(aAux, aCST[nI][CST_SEGURO])
	aAdd(aAux, cDescCST)
	aAdd(aExcel, aClone(aAux))
	
	If lAjusta
		nDifPIS := nCalPIS - aCST[nI][CST_VALPIS]
		nDifCOF := nCalCOF - aCST[nI][CST_VALCOF]
		
		If nDifPIS <> 0 .or. nDifCOF <> 0
			If MsgYesNo('CST PIS/COFINS: ' + aCST[nI][CST_CST] + CRLF + CRLF +;
			'Calculado PIS: ' + cValToChar(nCalPIS) + CRLF +;
			'Valor PIS: ' + cValToChar(aCST[nI][CST_VALPIS]) + CRLF + CRLF +;
			'Calculado COFINS: ' + cValToChar(nCalCOF) + CRLF +;
			'Valor COFINS: ' + cValToChar(aCST[nI][CST_VALCOF]) + CRLF + CRLF+;
			'Foi encontrado diferença entre o calculado em tempo de execução' + CRLF +;
			'e o salvo no sistema. Deseja ajustar esta diferença?')
				If MV_PAR09 == 1
					Alert('Você emitiu o relatório considerando títulos financeiros. '+;
					'A diferença encontrada pode ser devido a soma dos valores dos títulos, '+;
					'logo não será possível ajustar. Gere o relatório novamente com a opção '+;
					'"Considera títulos" como "Não" e verifique se a diferença continua sendo '+;
					'apresentada. Caso sim, você poderá ajustar sem problemas.')
				Else
					AjuDif(aCST[nI][CST_CST],nDifPIS,nDifCOF)
				EndIf
			EndIf
		EndIf
	EndIf
	
	//salvando no vetor de CST geral
	If !lFinal
		nPos := aScan(_aCSTG, {|x| x[CST_CST] == aCST[nI][CST_CST]})
		If nPos == 0
			aAux := Array(CST_ULTIMO-1)
			aAux[CST_CST]     := aCST[nI][CST_CST]
			aAux[CST_VALCONT] := aCST[nI][CST_VALCONT]
			aAux[CST_VALITEM] := aCST[nI][CST_VALITEM]
			aAux[CST_BASEPIS] := aCST[nI][CST_BASEPIS]
			aAux[CST_BASECOF] := aCST[nI][CST_BASECOF]
			aAux[CST_VALPIS]  := aCST[nI][CST_VALPIS]
			aAux[CST_VALCOF]  := aCST[nI][CST_VALCOF]
			aAux[CST_CALPIS]  := aCST[nI][CST_CALPIS]
			aAux[CST_CALCOF]  := aCST[nI][CST_CALCOF]
			aAux[CST_ICMSRET] := aCST[nI][CST_ICMSRET]
			aAux[CST_IPI]     := aCST[nI][CST_IPI]
			aAux[CST_DESCONT] := aCST[nI][CST_DESCONT]
			aAux[CST_FRETE]   := aCST[nI][CST_FRETE]
			aAux[CST_DESPESA] := aCST[nI][CST_DESPESA]
			aAux[CST_SEGURO]  := aCST[nI][CST_SEGURO]
			aAdd(_aCSTG, aClone(aAux))
		Else
			_aCSTG[nPos][CST_VALCONT] += aCST[nI][CST_VALCONT]
			_aCSTG[nPos][CST_VALITEM] += aCST[nI][CST_VALITEM]
			_aCSTG[nPos][CST_BASEPIS] += aCST[nI][CST_BASEPIS]
			_aCSTG[nPos][CST_BASECOF] += aCST[nI][CST_BASECOF]
			_aCSTG[nPos][CST_VALPIS]  += aCST[nI][CST_VALPIS]
			_aCSTG[nPos][CST_VALCOF]  += aCST[nI][CST_VALCOF]
			_aCSTG[nPos][CST_CALPIS]  += aCST[nI][CST_CALPIS]
			_aCSTG[nPos][CST_CALCOF]  += aCST[nI][CST_CALCOF]
			_aCSTG[nPos][CST_ICMSRET] += aCST[nI][CST_ICMSRET]
			_aCSTG[nPos][CST_IPI]     += aCST[nI][CST_IPI]
			_aCSTG[nPos][CST_DESCONT] += aCST[nI][CST_DESCONT]
			_aCSTG[nPos][CST_FRETE]   += aCST[nI][CST_FRETE]
			_aCSTG[nPos][CST_DESPESA] += aCST[nI][CST_DESPESA]
			_aCSTG[nPos][CST_SEGURO]  += aCST[nI][CST_SEGURO]
		EndIf
	EndIf
	
	If lApura
		//realizando apuração
		//se for 01 é débito, soma na apuração
		//se for 50 é crédito, diminui na apuração
		If aCST[nI][CST_CST] == '01'
			_aApura[APU_CON][APU_VALPIS] += aCST[nI][CST_VALPIS]
			_aApura[APU_CON][APU_VALCOF] += aCST[nI][CST_VALCOF]
			_aApura[APU_CON][APU_CALPIS] += nCalPIS
			_aApura[APU_CON][APU_CALCOF] += nCalCOF
		ElseIf aCST[nI][CST_CST] == '50'
			_aApura[APU_CRE][APU_VALPIS] += aCST[nI][CST_VALPIS]
			_aApura[APU_CRE][APU_VALCOF] += aCST[nI][CST_VALCOF]
			_aApura[APU_CRE][APU_CALPIS] += nCalPIS
			_aApura[APU_CRE][APU_CALCOF] += nCalCOF
		EndIf
	EndIf
Next nI
aAdd(aExcel, {''})

aCST := {}

Return Nil

/* -------------- */

Static Function PorCNAT(aExcel,aCNat)

Local nI, nMax
Local cDesc := ''
nMax := Len(aCNat)

aSort(aCNat,,,{|x,y| x[CNAT_CST]+x[CNAT_TNATREC]+x[CNAT_CNATREC] < y[CNAT_CST]+y[CNAT_TNATREC]+y[CNAT_CNATREC]})

aAdd(aExcel, {'Detalhamento Natureza Monofásicos'})
aAdd(aExcel, {'CST', 'TNatRec', 'CNatRec', 'Valor do Item', 'Descrição'})
For nI := 1 to nMax
	//                                   CCZ_FILIAL     + CCZ_TABELA                      + CCZ_COD
	cDesc := AllTrim(Posicione('CCZ', 1, xFilial('CCZ') + PadR(aCNat[nI][CNAT_TNATREC],4) + PadR(aCNat[nI][CNAT_CNATREC],3), 'CCZ_DESC'))
	
	aAdd(aExcel, {aCNat[nI][CNAT_CST], aCNat[nI][CNAT_TNATREC], aCNat[nI][CNAT_CNATREC], aCNat[nI][CNAT_VALITEM], cDesc})
Next nI
aAdd(aExcel, {''})
aCNat := {}

Return Nil

/* -------------- */

Static Function PorCBCC(aExcel,aCBcc)

Local nI, nMax
Local cDesc := ''
nMax := Len(aCBcc)

aSort(aCBcc,,,{|x,y| x[CBCC_CST]+x[CBCC_CODBCC] < y[CBCC_CST]+y[CBCC_CODBCC]})

aAdd(aExcel, {'Detalhamento Base de Cálculo de Crédito'})
aAdd(aExcel, {'CST', 'CodBcc', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS', 'Descrição'})
For nI := 1 to nMax
	//                                   X5_FILIAL      + X5_TABELA + X5_CHAVE
	cDesc := AllTrim(Posicione('SX5', 1, xFilial('SX5') + 'MZ'      + PadR(aCBcc[nI][CBCC_CODBCC],6), 'X5_DESCRI'))
	
	aAdd(aExcel, {aCBcc[nI][CBCC_CST], aCBcc[nI][CBCC_CODBCC], aCBcc[nI][CBCC_BASEPIS], aCBcc[nI][CBCC_BASECOF], aCBcc[nI][CBCC_VALPIS], aCBcc[nI][CBCC_VALCOF], cDesc})
Next nI
aAdd(aExcel, {''})
aCBcc := {}

Return Nil

/* -------------- */

Static Function AjuDif(cCST,nDifPIS,nDifCOF)

Local cQry := ''
Local nPIS := Iif(nDifPIS==0,0,Iif(nDifPIS>0,0.01,-0.01))
Local nCOF := Iif(nDifCOF==0,0,Iif(nDifCOF>0,0.01,-0.01))
Local nTotPIS := 0
Local nTotCOF := 0

cQry := CRLF + " SELECT R_E_C_N_O_ AS RECNUM"
cQry += CRLF + " FROM " + RetSqlName('SFT')
cQry += CRLF + " WHERE LEFT(FT_ENTRADA,6) = '"+_cMesAtu+"'"
cQry += CRLF + "   AND LEN(FT_DTCANC) = 0 "
cQry += CRLF + "   AND FT_OBSERV NOT LIKE '%INUTIL%'"
cQry += CRLF + "   AND FT_OBSERV NOT LIKE '%CANCEL%'"
cQry += CRLF + "   AND D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
cQry += CRLF + "   AND FT_CSTPIS = '"+cCST+"'"
cQry += CRLF + "   AND FT_VALPIS > 0"
cQry += CRLF + "   AND FT_VALCOF > 0"
If AllTrim(MV_PAR05) <> ''
	cQry += CRLF + "   AND FT_CFOP IN "+U_MyGeraIn(AllTrim(MV_PAR05))
EndIf
cQry += CRLF + " ORDER BY FT_VALPIS DESC, FT_VALCOF DESC"

cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MDIF',.T.)
While !MDIF->(Eof())
	SFT->(dbGoTo(MDIF->RECNUM))
	
	If (SFT->FT_VALPIS + nPIS) > 0 .and. nTotPIS <> nDifPIS
		RecLock('SFT',.F.)
		SFT->FT_VALPIS += nPIS
		SFT->(MsUnlock())
		nTotPIS += nPIS
	EndIf
	
	If (SFT->FT_VALCOF + nCOF) > 0 .and. nTotCOF <> nDifCOF
		RecLock('SFT',.F.)
		SFT->FT_VALCOF += nCOF
		SFT->(MsUnlock())
		nTotCOF += nCOF
	EndIf
	
	If nTotPIS == nDifPIS .and. nTotCOF == nDifCOF
		Exit
	EndIf
	
	MDIF->(dbSkip())
	
	If MDIF->(Eof())
		MDIF->(dbGoTop())
	EndIf
EndDo
MDIF->(dbCloseArea())

MsgAlert('CST PIS/COFINS ' + cCST + ' - Diferença ajustada com sucesso!')

Return Nil

/* -------------- */

Static Function Titulos(aExcel,aCST,aNatG,aCBcc,aCBccG,lGeral,cFAnt)

Local cQry := ''
Local nBasePis
Local nBaseCof
Local nValPis
Local nValCof
Local nPos
Local nI
Local nMax
Local cTab, cNat, cCST, cBCC, nVlr, nRec
Local aRegs   := {}
Local aVlrNat := {}
Local aAux
Local cDescNat

aAdd(aExcel, {'Títulos Financeiros (Pagar/Receber)'})
aAdd(aExcel, {'Natureza', 'CST', 'CodBCC', 'Valor Título', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS', 'Descrição'})

If ValType(lGeral) == 'U'
	lGeral := .F.
EndIf

If !lGeral
	If ExistBlock('MyF100')
		//COM MyF100
		//         MyF100(cFil    , dData1  , dData2  , cFilAte , cFilCST          )
		aRegs := U_MyF100(cFAnt,U_MyDia(1,MV_PAR01,MV_PAR02),U_MyDia(2,MV_PAR01,MV_PAR02),,AllTrim(MV_PAR06))
		
		nMax := Len(aRegs)
		For nI := 1 to nMax
			cTab := aRegs[nI][01] //01 - Tabela
			cNat := aRegs[nI][02] //02 - Natureza
			cCC  := aRegs[nI][03] //03 - Centro de Custo
			cCST := aRegs[nI][04] //04 - CST
			cBCC := aRegs[nI][05] //05 - BCC
			nVlr := aRegs[nI][06] //06 - Valor
			nRec := aRegs[nI][07] //07 - RecNo
			
			nPos := aScan(aVlrNat, {|x| x[NAT_NAT] == cNat .and. x[NAT_CST] == cCST .and. x[NAT_CODBCC] == cBCC})
			If nPos == 0
				aAux := Array(NAT_ULTIMO-1)
				aAux[NAT_NAT]    := cNat
				aAux[NAT_CST]    := cCST
				aAux[NAT_CODBCC] := cBCC
				aAux[NAT_VALOR]  := nVlr
				aAdd(aVlrNat, aClone(aAux))
			Else
				aVlrNat[nPos][NAT_VALOR] += nVlr
			EndIf
		Next nI
		
		nMax := Len(aVlrNat)
		For nI := 1 to nMax
			nBasePis := aVlrNat[nI][NAT_VALOR]
			nBaseCof := aVlrNat[nI][NAT_VALOR]
			
			nValPis  := Round(nBasePis * MV_PAR07 / 100,2)
			nValCof  := Round(nBaseCof * MV_PAR08 / 100,2)
			
			cDescNat := AllTrim(Posicione('SED', 1, xFilial('SED') + aVlrNat[nI][NAT_NAT], 'ED_DESCRIC'))
			
			aAdd(aExcel, {aVlrNat[nI][NAT_NAT]   ,;
			              aVlrNat[nI][NAT_CST]   ,;
			              aVlrNat[nI][NAT_CODBCC],;
			              aVlrNat[nI][NAT_VALOR] ,;
			              nBasePis               ,;
			              nBaseCof               ,;
			              nValPis                ,;
			              nValCof                ,;
			              cDescNat                ;
			})
			
			//somando por Natureza geral
			nPos := aScan(aNatG, {|x| x[NATG_NAT] == aVlrNat[nI][NAT_NAT] .and. x[NATG_CST] == aVlrNat[nI][NAT_CST] .and. x[NATG_CODBCC] == aVlrNat[nI][NAT_CODBCC]})
			If nPos == 0
				aAux := Array(NATG_ULTIMO-1)
				aAux[NATG_NAT]     := aVlrNat[nI][NAT_NAT]
				aAux[NATG_CST]     := aVlrNat[nI][NAT_CST]
				aAux[NATG_CODBCC]  := aVlrNat[nI][NAT_CODBCC]
				aAux[NATG_VALOR]   := aVlrNat[nI][NAT_VALOR]
				aAux[NATG_BASEPIS] := nBasePis
				aAux[NATG_BASECOF] := nBaseCof
				aAux[NATG_VALPIS]  := nValPis
				aAux[NATG_VALCOF]  := nValCof
				aAdd(aNatG, aClone(aAux))
			Else
				aNatG[nPos][NATG_VALOR]   += aVlrNat[nI][NAT_VALOR]
				aNatG[nPos][NATG_BASEPIS] += nBasePis
				aNatG[nPos][NATG_BASECOF] += nBaseCof
				aNatG[nPos][NATG_VALPIS]  += nValPis
				aNatG[nPos][NATG_VALCOF]  += nValCof
			EndIf
			
			//agrupando por CST
			nPos := aScan(aCST, {|x| x[CST_CST] == aVlrNat[nI][NAT_CST]})
			If nPos == 0
				aAux := Array(CST_ULTIMO-1)
				aAux[CST_CST]     := aVlrNat[nI][NAT_CST]
				aAux[CST_VALCONT] := aVlrNat[nI][NAT_VALOR]
				aAux[CST_VALITEM] := aVlrNat[nI][NAT_VALOR]
				aAux[CST_BASEPIS] := nBasePis
				aAux[CST_BASECOF] := nBaseCof
				aAux[CST_VALPIS]  := nValPis
				aAux[CST_VALCOF]  := nValCof
				aAux[CST_CALPIS]  := nValPis
				aAux[CST_CALCOF]  := nValCof
				aAux[CST_ICMSRET] := 0
				aAux[CST_IPI]     := 0
				aAux[CST_DESCONT] := 0
				aAux[CST_FRETE]   := 0
				aAux[CST_DESPESA] := 0
				aAux[CST_SEGURO]  := 0
				aAdd(aCST, aClone(aAux))
			Else
				aCST[nPos][CST_VALCONT] += aVlrNat[nI][NAT_VALOR]
				aCST[nPos][CST_VALITEM] += aVlrNat[nI][NAT_VALOR]
				aCST[nPos][CST_BASEPIS] += nBasePis
				aCST[nPos][CST_BASECOF] += nBaseCof
				aCST[nPos][CST_VALPIS]  += nValPis
				aCST[nPos][CST_VALCOF]  += nValCof
				aCST[nPos][CST_CALPIS]  += nValPis
				aCST[nPos][CST_CALCOF]  += nValCof
				aCST[nPos][CST_ICMSRET] += 0
				aCST[nPos][CST_IPI]     += 0
				aCST[nPos][CST_DESCONT] += 0
				aCST[nPos][CST_FRETE]   += 0
				aCST[nPos][CST_DESPESA] += 0
				aCST[nPos][CST_SEGURO]  += 0
			EndIf
			
			If AllTrim(aVlrNat[nI][NAT_CODBCC]) <> ''
				//agrupando por CST+CODBCC
				nPos := aScan(aCBcc, {|x| x[CBCC_CST] == aVlrNat[nI][NAT_CST] .and. x[CBCC_CODBCC] == aVlrNat[nI][NAT_CODBCC]})
				If nPos == 0
					aAux := Array(CBCC_ULTIMO-1)
					aAux[CBCC_CST]     := aVlrNat[nI][NAT_CST]
					aAux[CBCC_CODBCC]  := aVlrNat[nI][NAT_CODBCC]
					aAux[CBCC_BASEPIS] := nBasePis
					aAux[CBCC_BASECOF] := nBaseCof
					aAux[CBCC_VALPIS]  := nValPis
					aAux[CBCC_VALCOF]  := nValCof
					aAdd(aCBcc, aClone(aAux))
				Else
					aCBcc[nPos][CBCC_BASEPIS] += nBasePis
					aCBcc[nPos][CBCC_BASECOF] += nBaseCof
					aCBcc[nPos][CBCC_VALPIS]  += nValPis
					aCBcc[nPos][CBCC_VALCOF]  += nValCof
				EndIf
			
				//agrupando por CST+CODBCC geral
				nPos := aScan(aCBccG, {|x| x[CBCC_CST] == aVlrNat[nI][NAT_CST] .and. x[CBCC_CODBCC] == aVlrNat[nI][NAT_CODBCC]})
				If nPos == 0
					aAux := Array(CBCC_ULTIMO-1)
					aAux[CBCC_CST]     := aVlrNat[nI][NAT_CST]
					aAux[CBCC_CODBCC]  := aVlrNat[nI][NAT_CODBCC]
					aAux[CBCC_BASEPIS] := nBasePis
					aAux[CBCC_BASECOF] := nBaseCof
					aAux[CBCC_VALPIS]  := nValPis
					aAux[CBCC_VALCOF]  := nValCof
					aAdd(aCBccG, aClone(aAux))
				Else
					aCBccG[nPos][CBCC_BASEPIS] += nBasePis
					aCBccG[nPos][CBCC_BASECOF] += nBaseCof
					aCBccG[nPos][CBCC_VALPIS]  += nValPis
					aCBccG[nPos][CBCC_VALCOF]  += nValCof
				EndIf
			EndIf
		Next nI
	Else
		//SEM MyF100
		cQry := CRLF + " SELECT ED_CODIGO"
		cQry += CRLF + "       ,ED_CSTPIS"
		cQry += CRLF + "       ,ED_CLASFIS AS CODBCC"
		cQry += CRLF + "       ,ED_REDPIS"
		cQry += CRLF + "       ,ED_REDCOF"
		cQry += CRLF + "       ,ED_PCAPPIS"
		cQry += CRLF + "       ,ED_PCAPCOF"
		cQry += CRLF + "       ,ED_DESCRIC"
		cQry += CRLF + "       ,ROUND(SUM(E1_VALOR),2) AS VALOR" 
		cQry += CRLF + " FROM " + RetSqlName('SE1') + " SE1,"
		cQry += CRLF + "      " + RetSqlName('SED') + " SED"
		cQry += CRLF + " WHERE SED.D_E_L_E_T_ <> '*'"
		cQry += CRLF + "   AND SE1.D_E_L_E_T_ <> '*'"
		cQry += CRLF + "   AND E1_FILIAL = '"+cFAnt+"'"
		cQry += CRLF + "   AND ED_FILIAL = '"+Iif(AllTrim(xFilial('SED'))=='','',cFAnt)+"'"
		cQry += CRLF + "   AND E1_NATUREZ = ED_CODIGO"
		cQry += CRLF + "   AND LEFT(E1_EMISSAO,6) = '"+_cMesAtu+"'"
		cQry += CRLF + "   AND ED_CSTPIS <> ''"
		If AllTrim(MV_PAR06) <> ''
			cQry += CRLF + "   AND ED_CSTPIS IN "+U_MyGeraIn(AllTrim(MV_PAR06))
		EndIf
		cQry += CRLF + " GROUP BY ED_CODIGO"
		cQry += CRLF + "         ,ED_CSTPIS" 
		cQry += CRLF + "         ,ED_CLASFIS" 
		cQry += CRLF + "         ,ED_REDPIS"
		cQry += CRLF + "         ,ED_REDCOF"
		cQry += CRLF + "         ,ED_PCAPPIS"
		cQry += CRLF + "         ,ED_PCAPCOF"
		cQry += CRLF + "         ,ED_DESCRIC"
		cQry += CRLF + " UNION ALL"
		cQry += CRLF + " SELECT ED_CODIGO"
		cQry += CRLF + "       ,ED_CSTPIS" 
		cQry += CRLF + "       ,ED_CLASFIS AS CODBCC" 	
		cQry += CRLF + "       ,ED_REDPIS"
		cQry += CRLF + "       ,ED_REDCOF"
		cQry += CRLF + "       ,ED_PCAPPIS"
		cQry += CRLF + "       ,ED_PCAPCOF"
		cQry += CRLF + "       ,ED_DESCRIC"
		cQry += CRLF + "       ,ROUND(SUM(E2_VALOR),2) AS VALOR" 
		cQry += CRLF + " FROM " + RetSqlName('SE2') + " SE2,"
		cQry += CRLF + "      " + RetSqlName('SED') + " SED"
		cQry += CRLF + " WHERE SED.D_E_L_E_T_ <> '*'"
		cQry += CRLF + "   AND SE2.D_E_L_E_T_ <> '*'"
		cQry += CRLF + "   AND E2_FILIAL = '"+cFAnt+"'"
		cQry += CRLF + "   AND ED_FILIAL = '"+Iif(AllTrim(xFilial('SED'))=='','',cFAnt)+"'"
		cQry += CRLF + "   AND E2_NATUREZ = ED_CODIGO"
		cQry += CRLF + "   AND LEFT(E2_EMISSAO,6) = '"+_cMesAtu+"'"
		cQry += CRLF + "   AND ED_CSTPIS <> ''"
		If AllTrim(MV_PAR06) <> ''
			cQry += CRLF + "   AND ED_CSTPIS IN "+U_MyGeraIn(AllTrim(MV_PAR06))
		EndIf
		cQry += CRLF + " GROUP BY ED_CODIGO"
		cQry += CRLF + "         ,ED_CSTPIS" 
		cQry += CRLF + "         ,ED_CLASFIS" 
		cQry += CRLF + "         ,ED_REDPIS"
		cQry += CRLF + "         ,ED_REDCOF"
		cQry += CRLF + "         ,ED_PCAPPIS"
		cQry += CRLF + "         ,ED_PCAPCOF"
		cQry += CRLF + "         ,ED_DESCRIC"
		cQry += CRLF + " ORDER BY 1,2,3"

		cQry := ChangeQuery(cQry)
		dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MTIT',.T.)
		While !MTIT->(Eof())
			nBasePis := Round(MTIT->VALOR*(100-MTIT->ED_REDPIS)/100,2)
			nBaseCof := Round(MTIT->VALOR*(100-MTIT->ED_REDCOF)/100,2)
			
			nValPis  := Round(nBasePis * MTIT->ED_PCAPPIS / 100,2)
			nValCof  := Round(nBaseCof * MTIT->ED_PCAPCOF / 100,2)
			
			aAdd(aExcel, {MTIT->ED_CODIGO, MTIT->ED_CSTPIS, MTIT->CODBCC, MTIT->VALOR, nBasePis, nBaseCof, nValPis, nValCof, AllTrim(MTIT->ED_DESCRIC)})
			
			//somando por Natureza geral
			nPos := aScan(aNatG, {|x| x[NATG_NAT] == MTIT->ED_CODIGO .and. x[NATG_CST] == MTIT->ED_CSTPIS .and. x[NATG_CODBCC] == MTIT->CODBCC})
			If nPos == 0
				aAux := Array(NATG_ULTIMO-1)
				aAux[NATG_NAT]     := MTIT->ED_CODIGO
				aAux[NATG_CST]     := MTIT->ED_CSTPIS
				aAux[NATG_CODBCC]  := MTIT->CODBCC
				aAux[NATG_VALOR]   := MTIT->VALOR
				aAux[NATG_BASEPIS] := nBasePis
				aAux[NATG_BASECOF] := nBaseCof
				aAux[NATG_VALPIS]  := nValPis
				aAux[NATG_VALCOF]  := nValCof
				aAdd(aNatG, aClone(aAux))
			Else
				aNatG[nPos][NATG_VALOR]   += MTIT->VALOR
				aNatG[nPos][NATG_BASEPIS] += nBasePis
				aNatG[nPos][NATG_BASECOF] += nBaseCof
				aNatG[nPos][NATG_VALPIS]  += nValPis
				aNatG[nPos][NATG_VALCOF]  += nValCof
			EndIf
			
			//agrupando por CST
			nPos := aScan(aCST, {|x| x[CST_CST] == MTIT->ED_CSTPIS})
			If nPos == 0
				aAux := Array(CST_ULTIMO-1)
				aAux[CST_CST]     := MTIT->ED_CSTPIS
				aAux[CST_VALCONT] := MTIT->VALOR
				aAux[CST_VALITEM] := MTIT->VALOR
				aAux[CST_BASEPIS] := nBasePis
				aAux[CST_BASECOF] := nBaseCof
				aAux[CST_VALPIS]  := nValPis
				aAux[CST_VALCOF]  := nValCof
				aAux[CST_CALPIS]  := nValPis
				aAux[CST_CALCOF]  := nValCof
				aAux[CST_ICMSRET] := 0
				aAux[CST_IPI]     := 0
				aAux[CST_DESCONT] := 0
				aAux[CST_FRETE]   := 0
				aAux[CST_DESPESA] := 0
				aAux[CST_SEGURO]  := 0
				aAdd(aCST, aClone(aAux))
			Else
				aCST[nPos][CST_VALCONT] += MTIT->VALOR
				aCST[nPos][CST_VALITEM] += MTIT->VALOR
				aCST[nPos][CST_BASEPIS] += nBasePis
				aCST[nPos][CST_BASECOF] += nBaseCof
				aCST[nPos][CST_VALPIS]  += nValPis
				aCST[nPos][CST_VALCOF]  += nValCof
				aCST[nPos][CST_CALPIS]  += nValPis
				aCST[nPos][CST_CALCOF]  += nValCof
				aCST[nPos][CST_ICMSRET] += 0
				aCST[nPos][CST_IPI]     += 0
				aCST[nPos][CST_DESCONT] += 0
				aCST[nPos][CST_FRETE]   += 0
				aCST[nPos][CST_DESPESA] += 0
				aCST[nPos][CST_SEGURO]  += 0
			EndIf
			
			If AllTrim(MTIT->CODBCC) <> ''
				//agrupando por CST+CODBCC
				nPos := aScan(aCBcc, {|x| x[CBCC_CST] == MTIT->ED_CSTPIS .and. x[CBCC_CODBCC] == MTIT->CODBCC})
				If nPos == 0
					aAux := Array(CBCC_ULTIMO-1)
					aAux[CBCC_CST]     := MTIT->ED_CSTPIS
					aAux[CBCC_CODBCC]  := MTIT->CODBCC
					aAux[CBCC_BASEPIS] := nBasePis
					aAux[CBCC_BASECOF] := nBaseCof
					aAux[CBCC_VALPIS]  := nValPis
					aAux[CBCC_VALCOF]  := nValCof
					aAdd(aCBcc, aClone(aAux))
				Else
					aCBcc[nPos][CBCC_BASEPIS] += nBasePis
					aCBcc[nPos][CBCC_BASECOF] += nBaseCof
					aCBcc[nPos][CBCC_VALPIS]  += nValPis
					aCBcc[nPos][CBCC_VALCOF]  += nValCof
				EndIf
			
				//agrupando por CST+CODBCC geral
				nPos := aScan(aCBccG, {|x| x[CBCC_CST] == MTIT->ED_CSTPIS .and. x[CBCC_CODBCC] == MTIT->CODBCC})
				If nPos == 0
					aAux := Array(CBCC_ULTIMO-1)
					aAux[CBCC_CST]     := MTIT->ED_CSTPIS
					aAux[CBCC_CODBCC]  := MTIT->CODBCC
					aAux[CBCC_BASEPIS] := nBasePis
					aAux[CBCC_BASECOF] := nBaseCof
					aAux[CBCC_VALPIS]  := nValPis
					aAux[CBCC_VALCOF]  := nValCof
					aAdd(aCBccG, aClone(aAux))
				Else
					aCBccG[nPos][CBCC_BASEPIS] += nBasePis
					aCBccG[nPos][CBCC_BASECOF] += nBaseCof
					aCBccG[nPos][CBCC_VALPIS]  += nValPis
					aCBccG[nPos][CBCC_VALCOF]  += nValCof
				EndIf
			EndIf
			
			MTIT->(dbSkip())
		EndDo
		MTIT->(dbCloseArea())
	EndIf
Else
	aSort(aNatG,,,{|x,y| x[NATG_NAT]+x[NATG_CST]+x[NATG_CODBCC] < y[NATG_NAT]+y[NATG_CST]+y[NATG_CODBCC]})
	
	nMax := Len(aNatG)
	For nI := 1 to nMax
		cDescNat := AllTrim(Posicione('SED', 1, xFilial('SED') + aNatG[nI][NATG_NAT], 'ED_DESCRIC'))
		aAdd(aExcel, {aNatG[nI][NATG_NAT]    ,;
		              aNatG[nI][NATG_CST]    ,;
		              aNatG[nI][NATG_CODBCC] ,;
		              aNatG[nI][NATG_VALOR]  ,;
		              aNatG[nI][NATG_BASEPIS],;
		              aNatG[nI][NATG_BASECOF],;
		              aNatG[nI][NATG_VALPIS] ,;
		              aNatG[nI][NATG_VALCOF] ,;
		              cDescNat                ;
		})
		
		//agrupando por CST
		nPos := aScan(aCST, {|x| x[CST_CST] == aNatG[nI][NATG_CST]})
		If nPos == 0
			aAux := Array(CST_ULTIMO-1)
			aAux[CST_CST]     := aNatG[nI][NATG_CST]
			aAux[CST_VALCONT] := aNatG[nI][NATG_VALOR]
			aAux[CST_VALITEM] := aNatG[nI][NATG_VALOR]
			aAux[CST_BASEPIS] := aNatG[nI][NATG_BASEPIS]
			aAux[CST_BASECOF] := aNatG[nI][NATG_BASECOF]
			aAux[CST_VALPIS]  := aNatG[nI][NATG_VALPIS]
			aAux[CST_VALCOF]  := aNatG[nI][NATG_VALCOF]
			aAux[CST_CALPIS]  := aNatG[nI][NATG_VALPIS]
			aAux[CST_CALCOF]  := aNatG[nI][NATG_VALCOF]
			aAux[CST_ICMSRET] := 0
			aAux[CST_IPI]     := 0
			aAux[CST_DESCONT] := 0
			aAux[CST_FRETE]   := 0
			aAux[CST_DESPESA] := 0
			aAux[CST_SEGURO]  := 0
			aAdd(aCST, aClone(aAux))
		Else
			aCST[nPos][CST_VALCONT] += aNatG[nI][NATG_VALOR]
			aCST[nPos][CST_VALITEM] += aNatG[nI][NATG_VALOR]
			aCST[nPos][CST_BASEPIS] += aNatG[nI][NATG_BASEPIS]
			aCST[nPos][CST_BASECOF] += aNatG[nI][NATG_BASECOF]
			aCST[nPos][CST_VALPIS]  += aNatG[nI][NATG_VALPIS]
			aCST[nPos][CST_VALCOF]  += aNatG[nI][NATG_VALCOF]
			aCST[nPos][CST_CALPIS]  += aNatG[nI][NATG_VALPIS]
			aCST[nPos][CST_CALCOF]  += aNatG[nI][NATG_VALCOF]
			aCST[nPos][CST_ICMSRET] += 0
			aCST[nPos][CST_IPI]     += 0
			aCST[nPos][CST_DESCONT] += 0
			aCST[nPos][CST_FRETE]   += 0
			aCST[nPos][CST_DESPESA] += 0
			aCST[nPos][CST_SEGURO]  += 0
		EndIf
	Next nI
EndIf

aAdd(aExcel, {''})

Return Nil

/* -------------- */

Static Function AtivoA(aExcel,aCST,aCBcc,aCBccG,aAtfAG,lGeral,cFAnt)

Local cAliasF130
Local aResult
Local aAtfA := {}
Local nPos, nI, nMax, nTot, nMaxF
Local aAux
Local cDescId, cDescUso
Local cMes, cMesIni, cMesFim
Local aMes := {}
Local nMes, nAno

aAdd(aExcel, {'Ativo Imobilizado - Operações Geradoras de Créditos - Valores de Aquisição'})
aAdd(aExcel, {'CST', 'CodBCC', 'Identificação', 'Utilização', 'Origem', 'Mês/Ano Aquisição', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS', 'Descrição Identificação', 'Descrição Utilização'})

If ValType(lGeral) == 'U'
	lGeral := .F.
EndIf

If !lGeral
	//por filial
	nMaxF := 0
	
	cMesIni := _cMesAtu
	cMesFim := _cMesAtu
	cMes := cMesIni
	While cMes <= cMesFim
		aAdd(aMes, cMes)
		If Right(cMes,2) == '12'
			cMes := StrZero(Val(Left(cMes,4))+1,4) + '01'
		Else
			cMes := Left(cMes,4) + StrZero(Val(Right(cMes,2))+1,2)
		EndIf
	EndDo
	
	nMax := Len(aMes)
	For nI := 1 to nMax
		nMes := Val(Right(aMes[nI],2))
		nAno := Val(Left(aMes[nI],4))
		
		cAliasF130 := GetNextAlias()
		aResult := _AtfRegF130(cFAnt,U_MyDia(1,nMes,nAno),U_MyDia(2,nMes,nAno),"          ","ZZZZZZZZZZ",cAliasF130)
		
		If Len(aResult) > 0
			cAliasF130 := aResult[1,2]
			
			nTot := 0
			(cAliasF130)->(dbEval({ || nTot++ }))
			(cAliasF130)->(dbGoTop())
			nMaxF += nTot
			
			While !(cAliasF130)->(Eof())
				nPos := aScan(aAtfA, {|x| x[1] == StrZero((cAliasF130)->CST_PIS,2) .and. x[2] == (cAliasF130)->NAT_BC_CRE .and. x[3] == StrZero((cAliasF130)->IDENT_BEM,2) .and. x[4] == StrZero((cAliasF130)->IND_UTIL_B,1) .and. x[5] == (cAliasF130)->IND_ORIG_C .and. x[6] == StrZero((cAliasF130)->MES_OPER_A,6) })
				If nPos == 0
					aAux := Array(ATFA_ULTIMO-1)
					aAux[ATFA_CST]     := StrZero((cAliasF130)->CST_PIS,2)
					aAux[ATFA_CODBCC]  := (cAliasF130)->NAT_BC_CRE
					aAux[ATFA_ID]      := StrZero((cAliasF130)->IDENT_BEM,2)
					aAux[ATFA_USO]     := StrZero((cAliasF130)->IND_UTIL_B,1)
					aAux[ATFA_ORIGEM]  := (cAliasF130)->IND_ORIG_C
					aAux[ATFA_MESANO]  := StrZero((cAliasF130)->MES_OPER_A,6)
					aAux[ATFA_BASEPIS] := (cAliasF130)->VL_BC_PIS
					aAux[ATFA_BASECOF] := (cAliasF130)->VL_BC_COFI
					aAux[ATFA_VALPIS]  := (cAliasF130)->VL_PIS
					aAux[ATFA_VALCOF]  := (cAliasF130)->VL_COFINS
					aAdd(aAtfA, aClone(aAux))
				Else
					aAtfA[nPos][ATFA_BASEPIS] += (cAliasF130)->VL_BC_PIS
					aAtfA[nPos][ATFA_BASECOF] += (cAliasF130)->VL_BC_COFI
					aAtfA[nPos][ATFA_VALPIS]  += (cAliasF130)->VL_PIS
					aAtfA[nPos][ATFA_VALCOF]  += (cAliasF130)->VL_COFINS
				EndIf
				
				//geral
				nPos := aScan(aAtfAG, {|x| x[1] == StrZero((cAliasF130)->CST_PIS,2) .and. x[2] == (cAliasF130)->NAT_BC_CRE .and. x[3] == StrZero((cAliasF130)->IDENT_BEM,2) .and. x[4] == StrZero((cAliasF130)->IND_UTIL_B,1) .and. x[5] == (cAliasF130)->IND_ORIG_C .and. x[6] == StrZero((cAliasF130)->MES_OPER_A,6) })
				If nPos == 0
					aAux := Array(ATFAG_ULTIMO-1)
					aAux[ATFAG_CST]     := StrZero((cAliasF130)->CST_PIS,2)
					aAux[ATFAG_CODBCC]  := (cAliasF130)->NAT_BC_CRE
					aAux[ATFAG_ID]      := StrZero((cAliasF130)->IDENT_BEM,2)
					aAux[ATFAG_USO]     := StrZero((cAliasF130)->IND_UTIL_B,1)
					aAux[ATFAG_ORIGEM]  := (cAliasF130)->IND_ORIG_C
					aAux[ATFAG_MESANO]  := StrZero((cAliasF130)->MES_OPER_A,6)
					aAux[ATFAG_BASEPIS] := (cAliasF130)->VL_BC_PIS
					aAux[ATFAG_BASECOF] := (cAliasF130)->VL_BC_COFI
					aAux[ATFAG_VALPIS]  := (cAliasF130)->VL_PIS
					aAux[ATFAG_VALCOF]  := (cAliasF130)->VL_COFINS
					aAdd(aAtfAG, aClone(aAux))
				Else
					aAtfAG[nPos][ATFAG_BASEPIS] += (cAliasF130)->VL_BC_PIS
					aAtfAG[nPos][ATFAG_BASECOF] += (cAliasF130)->VL_BC_COFI
					aAtfAG[nPos][ATFAG_VALPIS]  += (cAliasF130)->VL_PIS
					aAtfAG[nPos][ATFAG_VALCOF]  += (cAliasF130)->VL_COFINS
				EndIf
				
				If AllTrim((cAliasF130)->NAT_BC_CRE) <> ''
					//agrupando por CST+CODBCC
					nPos := aScan(aCBcc, {|x| x[CBCC_CST] == StrZero((cAliasF130)->CST_PIS,2) .and. x[CBCC_CODBCC] == (cAliasF130)->NAT_BC_CRE})
					If nPos == 0
						aAux := Array(CBCC_ULTIMO-1)
						aAux[CBCC_CST]     := StrZero((cAliasF130)->CST_PIS,2)
						aAux[CBCC_CODBCC]  := (cAliasF130)->NAT_BC_CRE
						aAux[CBCC_BASEPIS] := (cAliasF130)->VL_BC_PIS
						aAux[CBCC_BASECOF] := (cAliasF130)->VL_BC_COFI
						aAux[CBCC_VALPIS]  := (cAliasF130)->VL_PIS
						aAux[CBCC_VALCOF]  := (cAliasF130)->VL_COFINS
						aAdd(aCBcc, aClone(aAux))
					Else
						aCBcc[nPos][CBCC_BASEPIS] += (cAliasF130)->VL_BC_PIS
						aCBcc[nPos][CBCC_BASECOF] += (cAliasF130)->VL_BC_COFI
						aCBcc[nPos][CBCC_VALPIS]  += (cAliasF130)->VL_PIS
						aCBcc[nPos][CBCC_VALCOF]  += (cAliasF130)->VL_COFINS
					EndIf
				
					//agrupando por CST+CODBCC geral
					nPos := aScan(aCBccG, {|x| x[CBCC_CST] == StrZero((cAliasF130)->CST_PIS,2) .and. x[CBCC_CODBCC] == (cAliasF130)->NAT_BC_CRE})
					If nPos == 0
						aAux := Array(CBCC_ULTIMO-1)
						aAux[CBCC_CST]     := StrZero((cAliasF130)->CST_PIS,2)
						aAux[CBCC_CODBCC]  := (cAliasF130)->NAT_BC_CRE
						aAux[CBCC_BASEPIS] := (cAliasF130)->VL_BC_PIS
						aAux[CBCC_BASECOF] := (cAliasF130)->VL_BC_COFI
						aAux[CBCC_VALPIS]  := (cAliasF130)->VL_PIS
						aAux[CBCC_VALCOF]  := (cAliasF130)->VL_COFINS
						aAdd(aCBccG, aClone(aAux))
					Else
						aCBccG[nPos][CBCC_BASEPIS] += (cAliasF130)->VL_BC_PIS
						aCBccG[nPos][CBCC_BASECOF] += (cAliasF130)->VL_BC_COFI
						aCBccG[nPos][CBCC_VALPIS]  += (cAliasF130)->VL_PIS
						aCBccG[nPos][CBCC_VALCOF]  += (cAliasF130)->VL_COFINS
					EndIf
				EndIf
					
				(cAliasF130)->(dbSkip())
			EndDo
			
			(cAliasF130)->(dbCloseArea())
		EndIf
	Next nI
	
	If nMaxF == 0
		//não existem registros
		aAdd(aExcel, {''})
		Return Nil
	EndIf
	
	aSort(aAtfA,,,{|x,y| x[ATFA_CST]+x[ATFA_CODBCC]+x[ATFA_ID]+x[ATFA_USO]+x[ATFA_ORIGEM]+x[ATFA_MESANO] < y[ATFA_CST]+y[ATFA_CODBCC]+y[ATFA_ID]+y[ATFA_USO]+y[ATFA_ORIGEM]+y[ATFA_MESANO] })
	nMax := Len(aAtfA)
	For nI := 1 to nMax
		//                                      X5_FILIAL      + X5_TABELA + X5_CHAVE
		cDescId  := AllTrim(Posicione('SN0', 1, xFilial('SN0') + '11'      + PadR(aAtfA[nI][ATFA_ID],15), 'N0_DESC01'))
		cDescUso := AllTrim(Posicione('SN0', 1, xFilial('SN0') + '12'      + PadR(aAtfA[nI][ATFA_USO],15), 'N0_DESC01'))
		aAdd(aExcel, {;
			aAtfA[nI][ATFA_CST]     ,;
			aAtfA[nI][ATFA_CODBCC]  ,;
			aAtfA[nI][ATFA_ID]      ,;
			aAtfA[nI][ATFA_USO]     ,;
			aAtfA[nI][ATFA_ORIGEM]  ,;
			aAtfA[nI][ATFA_MESANO]  ,;
			aAtfA[nI][ATFA_BASEPIS] ,;
			aAtfA[nI][ATFA_BASECOF] ,;
			aAtfA[nI][ATFA_VALPIS]  ,;
			aAtfA[nI][ATFA_VALCOF]  ,;
		  	cDescId               ,;
		  	cDescUso               ;
		})
		
		//agrupando por CST
		nPos := aScan(aCST, {|x| x[CST_CST] == aAtfA[nI][ATFA_CST]})
		If nPos == 0
			aAux := Array(CST_ULTIMO-1)
			aAux[CST_CST]     := aAtfA[nI][ATFA_CST]
			aAux[CST_VALCONT] := aAtfA[nI][ATFA_BASEPIS]
			aAux[CST_VALITEM] := aAtfA[nI][ATFA_BASEPIS]
			aAux[CST_BASEPIS] := aAtfA[nI][ATFA_BASEPIS]
			aAux[CST_BASECOF] := aAtfA[nI][ATFA_BASECOF]
			aAux[CST_VALPIS]  := aAtfA[nI][ATFA_VALPIS]
			aAux[CST_VALCOF]  := aAtfA[nI][ATFA_VALCOF]
			aAux[CST_CALPIS]  := aAtfA[nI][ATFA_VALPIS]
			aAux[CST_CALCOF]  := aAtfA[nI][ATFA_VALCOF]
			aAux[CST_ICMSRET] := 0
			aAux[CST_IPI]     := 0
			aAux[CST_DESCONT] := 0
			aAux[CST_FRETE]   := 0
			aAux[CST_DESPESA] := 0
			aAux[CST_SEGURO]  := 0
			aAdd(aCST, aClone(aAux))
		Else
			aCST[nPos][CST_VALCONT] += aAtfA[nI][ATFA_BASEPIS]
			aCST[nPos][CST_VALITEM] += aAtfA[nI][ATFA_BASEPIS]
			aCST[nPos][CST_BASEPIS] += aAtfA[nI][ATFA_BASEPIS]
			aCST[nPos][CST_BASECOF] += aAtfA[nI][ATFA_BASECOF]
			aCST[nPos][CST_VALPIS]  += aAtfA[nI][ATFA_VALPIS]
			aCST[nPos][CST_VALCOF]  += aAtfA[nI][ATFA_VALCOF]
			aCST[nPos][CST_CALPIS]  += aAtfA[nI][ATFA_VALPIS]
			aCST[nPos][CST_CALCOF]  += aAtfA[nI][ATFA_VALCOF]
			aCST[nPos][CST_ICMSRET] += 0
			aCST[nPos][CST_IPI]     += 0
			aCST[nPos][CST_DESCONT] += 0
			aCST[nPos][CST_FRETE]   += 0
			aCST[nPos][CST_DESPESA] += 0
			aCST[nPos][CST_SEGURO]  += 0
		EndIf
	Next nI
Else
	//geral - total empresa
	aSort(aAtfAG,,,{|x,y| x[ATFAG_CST]+x[ATFAG_CODBCC]+x[ATFAG_ID]+x[ATFAG_USO]+x[ATFAG_ORIGEM]+x[ATFAG_MESANO] < y[ATFAG_CST]+y[ATFAG_CODBCC]+y[ATFAG_ID]+y[ATFAG_USO]+y[ATFAG_ORIGEM]+y[ATFAG_MESANO] })
	nMax := Len(aAtfAG)
	For nI := 1 to nMax
		//                                      X5_FILIAL      + X5_TABELA + X5_CHAVE
		cDescId  := AllTrim(Posicione('SN0', 1, xFilial('SN0') + '11'      + PadR(aAtfAG[nI][ATFAG_ID],15), 'N0_DESC01'))
		cDescUso := AllTrim(Posicione('SN0', 1, xFilial('SN0') + '12'      + PadR(aAtfAG[nI][ATFAG_USO],15), 'N0_DESC01'))
		aAdd(aExcel, {;
			aAtfAG[nI][ATFAG_CST]     ,;
			aAtfAG[nI][ATFAG_CODBCC]  ,;
			aAtfAG[nI][ATFAG_ID]      ,;
			aAtfAG[nI][ATFAG_USO]     ,;
			aAtfAG[nI][ATFAG_ORIGEM]  ,;
			aAtfAG[nI][ATFAG_MESANO]  ,;
			aAtfAG[nI][ATFAG_BASEPIS] ,;
			aAtfAG[nI][ATFAG_BASECOF] ,;
			aAtfAG[nI][ATFAG_VALPIS]  ,;
			aAtfAG[nI][ATFAG_VALCOF]  ,;
		  	cDescId               ,;
		  	cDescUso               ;
		})
		
		//agrupando por CST
		nPos := aScan(aCST, {|x| x[CST_CST] == aAtfAG[nI][ATFAG_CST]})
		If nPos == 0
			aAux := Array(CST_ULTIMO-1)
			aAux[CST_CST]     := aAtfAG[nI][ATFAG_CST]
			aAux[CST_VALCONT] := aAtfAG[nI][ATFAG_BASEPIS]
			aAux[CST_VALITEM] := aAtfAG[nI][ATFAG_BASEPIS]
			aAux[CST_BASEPIS] := aAtfAG[nI][ATFAG_BASEPIS]
			aAux[CST_BASECOF] := aAtfAG[nI][ATFAG_BASECOF]
			aAux[CST_VALPIS]  := aAtfAG[nI][ATFAG_VALPIS]
			aAux[CST_VALCOF]  := aAtfAG[nI][ATFAG_VALCOF]
			aAux[CST_CALPIS]  := aAtfAG[nI][ATFAG_VALPIS]
			aAux[CST_CALCOF]  := aAtfAG[nI][ATFAG_VALCOF]
			aAux[CST_ICMSRET] := 0
			aAux[CST_IPI]     := 0
			aAux[CST_DESCONT] := 0
			aAux[CST_FRETE]   := 0
			aAux[CST_DESPESA] := 0
			aAux[CST_SEGURO]  := 0
			aAdd(aCST, aClone(aAux))
		Else
			aCST[nPos][CST_VALCONT] += aAtfAG[nI][ATFAG_BASEPIS]
			aCST[nPos][CST_VALITEM] += aAtfAG[nI][ATFAG_BASEPIS]
			aCST[nPos][CST_BASEPIS] += aAtfAG[nI][ATFAG_BASEPIS]
			aCST[nPos][CST_BASECOF] += aAtfAG[nI][ATFAG_BASECOF]
			aCST[nPos][CST_VALPIS]  += aAtfAG[nI][ATFAG_VALPIS]
			aCST[nPos][CST_VALCOF]  += aAtfAG[nI][ATFAG_VALCOF]
			aCST[nPos][CST_CALPIS]  += aAtfAG[nI][ATFAG_VALPIS]
			aCST[nPos][CST_CALCOF]  += aAtfAG[nI][ATFAG_VALCOF]
			aCST[nPos][CST_ICMSRET] += 0
			aCST[nPos][CST_IPI]     += 0
			aCST[nPos][CST_DESCONT] += 0
			aCST[nPos][CST_FRETE]   += 0
			aCST[nPos][CST_DESPESA] += 0
			aCST[nPos][CST_SEGURO]  += 0
		EndIf
	Next nI
EndIf

aAdd(aExcel, {''})

Return Nil

/* -------------- */

Static Function AtivoD(aExcel,aCST,aCBcc,aCBccG,aAtfDG,lGeral,cFAnt)

Local cAliasF120
Local aResult, aProcItem
Local aAtfD := {}
Local nPos, nI, nMax, nTot, nMaxF
Local aAux
Local cDescId, cDescUso
Local cMes, cMesIni, cMesFim
Local aMes := {}
Local nMes, nAno
Local cCSTCRED := '50/51/52/53/54/55/56/60/61/62/63/64/65/66/67'

aAdd(aExcel, {'Ativo Imobilizado - Operações Geradoras de Créditos - Valores de Depreciação'})
aAdd(aExcel, {'CST', 'CodBCC', 'Identificação', 'Utilização', 'Origem', 'Mês/Ano Referência', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS', 'Descrição Identificação', 'Descrição Utilização'})

If ValType(lGeral) == 'U'
	lGeral := .F.
EndIf

If !lGeral
	//por filial
	nMaxF := 0
	
	cMesIni := _cMesAtu
	cMesFim := _cMesAtu
	cMes := cMesIni
	While cMes <= cMesFim
		aAdd(aMes, cMes)
		If Right(cMes,2) == '12'
			cMes := StrZero(Val(Left(cMes,4))+1,4) + '01'
		Else
			cMes := Left(cMes,4) + StrZero(Val(Right(cMes,2))+1,2)
		EndIf
	EndDo
	
	nMax := Len(aMes)
	For nI := 1 to nMax
		nMes := Val(Right(aMes[nI],2))
		nAno := Val(Left(aMes[nI],4))
		cMes := Right(aMes[nI],2) + Left(aMes[nI],4)
		
		cAliasF120 := GetNextAlias()
		aProcItem := {'          ','ZZZZZZZZZZ',CTOD(''),U_MyDia(2,nMes,nAno),cAliasF120}
		aResult := _DeprecAtivo(U_MyDia(1,nMes,nAno),aProcItem[4],.T.,.F.,aProcItem,,.F.,'09/11',cFAnt,.F.)
		
		(cAliasF120)->(dbSetOrder(1))
		(cAliasF120)->(dbGoTop())
		
		If !(cAliasF120)->(Eof()) .and. (cAliasF120)->(FieldPos('NATBCCRED')) > 0 .and. Len(aResult) > 0
			cAliasF120 := aResult[1,2]
			
			nTot := 0
			(cAliasF120)->(dbEval({ || nTot++ }))
			(cAliasF120)->(dbGoTop())
			nMaxF += nTot
			
			While !(cAliasF120)->(Eof())
			
				If (cAliasF120)->CSTPIS $ cCSTCRED .or. (cAliasF120)->CSTCOFINS $ cCSTCRED
					nPos := aScan(aAtfD, {|x| x[1] == (cAliasF120)->CSTPIS .and. x[2] == (cAliasF120)->NATBCCRED .and. x[3] == (cAliasF120)->INDBEMIMOB .and. x[4] == (cAliasF120)->INDUTILBEM .and. x[5] == (cAliasF120)->INDORIGCRD .and. x[6] == cMes })
					If nPos == 0
						aAux := Array(ATFD_ULTIMO-1)
						aAux[ATFD_CST]     := (cAliasF120)->CSTPIS
						aAux[ATFD_CODBCC]  := (cAliasF120)->NATBCCRED
						aAux[ATFD_ID]      := (cAliasF120)->INDBEMIMOB
						aAux[ATFD_USO]     := (cAliasF120)->INDUTILBEM
						aAux[ATFD_ORIGEM]  := (cAliasF120)->INDORIGCRD
						aAux[ATFD_MESANO]  := cMes
						aAux[ATFD_BASEPIS] := (cAliasF120)->VLRBCPIS
						aAux[ATFD_BASECOF] := (cAliasF120)->VLRBCCOFIN
						aAux[ATFD_VALPIS]  := (cAliasF120)->VLRPIS
						aAux[ATFD_VALCOF]  := (cAliasF120)->VLRCOFINS
						aAdd(aAtfD, aClone(aAux))
					Else
						aAtfD[nPos][ATFD_BASEPIS] += (cAliasF120)->VLRBCPIS
						aAtfD[nPos][ATFD_BASECOF] += (cAliasF120)->VLRBCCOFIN
						aAtfD[nPos][ATFD_VALPIS]  += (cAliasF120)->VLRPIS
						aAtfD[nPos][ATFD_VALCOF]  += (cAliasF120)->VLRCOFINS
					EndIf
					
					//geral
					nPos := aScan(aAtfDG, {|x| x[1] == (cAliasF120)->CSTPIS .and. x[2] == (cAliasF120)->NATBCCRED .and. x[3] == (cAliasF120)->INDBEMIMOB .and. x[4] == (cAliasF120)->INDUTILBEM .and. x[5] == (cAliasF120)->INDORIGCRD .and. x[6] == cMes })
					If nPos == 0
						aAux := Array(ATFDG_ULTIMO-1)
						aAux[ATFDG_CST]     := (cAliasF120)->CSTPIS
						aAux[ATFDG_CODBCC]  := (cAliasF120)->NATBCCRED
						aAux[ATFDG_ID]      := (cAliasF120)->INDBEMIMOB
						aAux[ATFDG_USO]     := (cAliasF120)->INDUTILBEM
						aAux[ATFDG_ORIGEM]  := (cAliasF120)->INDORIGCRD
						aAux[ATFDG_MESANO]  := cMes
						aAux[ATFDG_BASEPIS] := (cAliasF120)->VLRBCPIS
						aAux[ATFDG_BASECOF] := (cAliasF120)->VLRBCCOFIN
						aAux[ATFDG_VALPIS]  := (cAliasF120)->VLRPIS
						aAux[ATFDG_VALCOF]  := (cAliasF120)->VLRCOFINS
						aAdd(aAtfDG, aClone(aAux))
					Else
						aAtfDG[nPos][ATFDG_BASEPIS] += (cAliasF120)->VLRBCPIS
						aAtfDG[nPos][ATFDG_BASECOF] += (cAliasF120)->VLRBCCOFIN
						aAtfDG[nPos][ATFDG_VALPIS]  += (cAliasF120)->VLRPIS
						aAtfDG[nPos][ATFDG_VALCOF]  += (cAliasF120)->VLRCOFINS
					EndIf
					
					If AllTrim((cAliasF120)->NATBCCRED) <> ''
						//agrupando por CST+CODBCC
						nPos := aScan(aCBcc, {|x| x[CBCC_CST] == (cAliasF120)->CSTPIS .and. x[CBCC_CODBCC] == (cAliasF120)->NATBCCRED})
						If nPos == 0
							aAux := Array(CBCC_ULTIMO-1)
							aAux[CBCC_CST]     := (cAliasF120)->CSTPIS
							aAux[CBCC_CODBCC]  := (cAliasF120)->NATBCCRED
							aAux[CBCC_BASEPIS] := (cAliasF120)->VLRBCPIS
							aAux[CBCC_BASECOF] := (cAliasF120)->VLRBCCOFIN
							aAux[CBCC_VALPIS]  := (cAliasF120)->VLRPIS
							aAux[CBCC_VALCOF]  := (cAliasF120)->VLRCOFINS
							aAdd(aCBcc, aClone(aAux))
						Else
							aCBcc[nPos][CBCC_BASEPIS] += (cAliasF120)->VLRBCPIS
							aCBcc[nPos][CBCC_BASECOF] += (cAliasF120)->VLRBCCOFIN
							aCBcc[nPos][CBCC_VALPIS]  += (cAliasF120)->VLRPIS
							aCBcc[nPos][CBCC_VALCOF]  += (cAliasF120)->VLRCOFINS
						EndIf
					
						//agrupando por CST+CODBCC geral
						nPos := aScan(aCBccG, {|x| x[CBCC_CST] == (cAliasF120)->CSTPIS .and. x[CBCC_CODBCC] == (cAliasF120)->NATBCCRED})
						If nPos == 0
							aAux := Array(CBCC_ULTIMO-1)
							aAux[CBCC_CST]     := (cAliasF120)->CSTPIS
							aAux[CBCC_CODBCC]  := (cAliasF120)->NATBCCRED
							aAux[CBCC_BASEPIS] := (cAliasF120)->VLRBCPIS
							aAux[CBCC_BASECOF] := (cAliasF120)->VLRBCCOFIN
							aAux[CBCC_VALPIS]  := (cAliasF120)->VLRPIS
							aAux[CBCC_VALCOF]  := (cAliasF120)->VLRCOFINS
							aAdd(aCBccG, aClone(aAux))
						Else
							aCBccG[nPos][CBCC_BASEPIS] += (cAliasF120)->VLRBCPIS
							aCBccG[nPos][CBCC_BASECOF] += (cAliasF120)->VLRBCCOFIN
							aCBccG[nPos][CBCC_VALPIS]  += (cAliasF120)->VLRPIS
							aCBccG[nPos][CBCC_VALCOF]  += (cAliasF120)->VLRCOFINS
						EndIf
					EndIf
				EndIf
					
				(cAliasF120)->(dbSkip())
			EndDo
			
			(cAliasF120)->(dbCloseArea())
		EndIf
	Next nI
	
	If nMaxF == 0
		//não existem registros
		aAdd(aExcel, {''})
		Return Nil
	EndIf
	
	aSort(aAtfD,,,{|x,y| x[ATFD_CST]+x[ATFD_CODBCC]+x[ATFD_ID]+x[ATFD_USO]+x[ATFD_ORIGEM]+x[ATFD_MESANO] < y[ATFD_CST]+y[ATFD_CODBCC]+y[ATFD_ID]+y[ATFD_USO]+y[ATFD_ORIGEM]+y[ATFD_MESANO] })
	nMax := Len(aAtfD)
	For nI := 1 to nMax
		//                                      X5_FILIAL      + X5_TABELA + X5_CHAVE
		cDescId  := AllTrim(Posicione('SN0', 1, xFilial('SN0') + '11'      + PadR(aAtfD[nI][ATFD_ID],15), 'N0_DESC01'))
		cDescUso := AllTrim(Posicione('SN0', 1, xFilial('SN0') + '12'      + PadR(aAtfD[nI][ATFD_USO],15), 'N0_DESC01'))
		aAdd(aExcel, {;
			aAtfD[nI][ATFD_CST]     ,;
			aAtfD[nI][ATFD_CODBCC]  ,;
			aAtfD[nI][ATFD_ID]      ,;
			aAtfD[nI][ATFD_USO]     ,;
			aAtfD[nI][ATFD_ORIGEM]  ,;
			aAtfD[nI][ATFD_MESANO]  ,;
			aAtfD[nI][ATFD_BASEPIS] ,;
			aAtfD[nI][ATFD_BASECOF] ,;
			aAtfD[nI][ATFD_VALPIS]  ,;
			aAtfD[nI][ATFD_VALCOF]  ,;
		  	cDescId               ,;
		  	cDescUso               ;
		})
		
		//agrupando por CST
		nPos := aScan(aCST, {|x| x[CST_CST] == aAtfD[nI][ATFD_CST]})
		If nPos == 0
			aAux := Array(CST_ULTIMO-1)
			aAux[CST_CST]     := aAtfD[nI][ATFD_CST]
			aAux[CST_VALCONT] := aAtfD[nI][ATFD_BASEPIS]
			aAux[CST_VALITEM] := aAtfD[nI][ATFD_BASEPIS]
			aAux[CST_BASEPIS] := aAtfD[nI][ATFD_BASEPIS]
			aAux[CST_BASECOF] := aAtfD[nI][ATFD_BASECOF]
			aAux[CST_VALPIS]  := aAtfD[nI][ATFD_VALPIS]
			aAux[CST_VALCOF]  := aAtfD[nI][ATFD_VALCOF]
			aAux[CST_CALPIS]  := aAtfD[nI][ATFD_VALPIS]
			aAux[CST_CALCOF]  := aAtfD[nI][ATFD_VALCOF]
			aAux[CST_ICMSRET] := 0
			aAux[CST_IPI]     := 0
			aAux[CST_DESCONT] := 0
			aAux[CST_FRETE]   := 0
			aAux[CST_DESPESA] := 0
			aAux[CST_SEGURO]  := 0
			aAdd(aCST, aClone(aAux))
		Else
			aCST[nPos][CST_VALCONT] += aAtfD[nI][ATFD_BASEPIS]
			aCST[nPos][CST_VALITEM] += aAtfD[nI][ATFD_BASEPIS]
			aCST[nPos][CST_BASEPIS] += aAtfD[nI][ATFD_BASEPIS]
			aCST[nPos][CST_BASECOF] += aAtfD[nI][ATFD_BASECOF]
			aCST[nPos][CST_VALPIS]  += aAtfD[nI][ATFD_VALPIS]
			aCST[nPos][CST_VALCOF]  += aAtfD[nI][ATFD_VALCOF]
			aCST[nPos][CST_CALPIS]  += aAtfD[nI][ATFD_VALPIS]
			aCST[nPos][CST_CALCOF]  += aAtfD[nI][ATFD_VALCOF]
			aCST[nPos][CST_ICMSRET] += 0
			aCST[nPos][CST_IPI]     += 0
			aCST[nPos][CST_DESCONT] += 0
			aCST[nPos][CST_FRETE]   += 0
			aCST[nPos][CST_DESPESA] += 0
			aCST[nPos][CST_SEGURO]  += 0
		EndIf
	Next nI
Else
	//geral - total empresa
	aSort(aAtfDG,,,{|x,y| x[ATFDG_CST]+x[ATFDG_CODBCC]+x[ATFDG_ID]+x[ATFDG_USO]+x[ATFDG_ORIGEM]+x[ATFDG_MESANO] < y[ATFDG_CST]+y[ATFDG_CODBCC]+y[ATFDG_ID]+y[ATFDG_USO]+y[ATFDG_ORIGEM]+y[ATFDG_MESANO] })
	nMax := Len(aAtfDG)
	For nI := 1 to nMax
		//                                      X5_FILIAL      + X5_TABELA + X5_CHAVE
		cDescId  := AllTrim(Posicione('SN0', 1, xFilial('SN0') + '11'      + PadR(aAtfDG[nI][ATFDG_ID],15), 'N0_DESC01'))
		cDescUso := AllTrim(Posicione('SN0', 1, xFilial('SN0') + '12'      + PadR(aAtfDG[nI][ATFDG_USO],15), 'N0_DESC01'))
		aAdd(aExcel, {;
			aAtfDG[nI][ATFDG_CST]     ,;
			aAtfDG[nI][ATFDG_CODBCC]  ,;
			aAtfDG[nI][ATFDG_ID]      ,;
			aAtfDG[nI][ATFDG_USO]     ,;
			aAtfDG[nI][ATFDG_ORIGEM]  ,;
			aAtfDG[nI][ATFDG_MESANO]  ,;
			aAtfDG[nI][ATFDG_BASEPIS] ,;
			aAtfDG[nI][ATFDG_BASECOF] ,;
			aAtfDG[nI][ATFDG_VALPIS]  ,;
			aAtfDG[nI][ATFDG_VALCOF]  ,;
		  	cDescId               ,;
		  	cDescUso               ;
		})
		
		//agrupando por CST
		nPos := aScan(aCST, {|x| x[CST_CST] == aAtfDG[nI][ATFDG_CST]})
		If nPos == 0
			aAux := Array(CST_ULTIMO-1)
			aAux[CST_CST]     := aAtfDG[nI][ATFDG_CST]
			aAux[CST_VALCONT] := aAtfDG[nI][ATFDG_BASEPIS]
			aAux[CST_VALITEM] := aAtfDG[nI][ATFDG_BASEPIS]
			aAux[CST_BASEPIS] := aAtfDG[nI][ATFDG_BASEPIS]
			aAux[CST_BASECOF] := aAtfDG[nI][ATFDG_BASECOF]
			aAux[CST_VALPIS]  := aAtfDG[nI][ATFDG_VALPIS]
			aAux[CST_VALCOF]  := aAtfDG[nI][ATFDG_VALCOF]
			aAux[CST_CALPIS]  := aAtfDG[nI][ATFDG_VALPIS]
			aAux[CST_CALCOF]  := aAtfDG[nI][ATFDG_VALCOF]
			aAux[CST_ICMSRET] := 0
			aAux[CST_IPI]     := 0
			aAux[CST_DESCONT] := 0
			aAux[CST_FRETE]   := 0
			aAux[CST_DESPESA] := 0
			aAux[CST_SEGURO]  := 0
			aAdd(aCST, aClone(aAux))
		Else
			aCST[nPos][CST_VALCONT] += aAtfDG[nI][ATFDG_BASEPIS]
			aCST[nPos][CST_VALITEM] += aAtfDG[nI][ATFDG_BASEPIS]
			aCST[nPos][CST_BASEPIS] += aAtfDG[nI][ATFDG_BASEPIS]
			aCST[nPos][CST_BASECOF] += aAtfDG[nI][ATFDG_BASECOF]
			aCST[nPos][CST_VALPIS]  += aAtfDG[nI][ATFDG_VALPIS]
			aCST[nPos][CST_VALCOF]  += aAtfDG[nI][ATFDG_VALCOF]
			aCST[nPos][CST_CALPIS]  += aAtfDG[nI][ATFDG_VALPIS]
			aCST[nPos][CST_CALCOF]  += aAtfDG[nI][ATFDG_VALCOF]
			aCST[nPos][CST_ICMSRET] += 0
			aCST[nPos][CST_IPI]     += 0
			aCST[nPos][CST_DESCONT] += 0
			aCST[nPos][CST_FRETE]   += 0
			aCST[nPos][CST_DESPESA] += 0
			aCST[nPos][CST_SEGURO]  += 0
		EndIf
	Next nI
EndIf

aAdd(aExcel, {''})

Return Nil

/* -------------- */

Static Function PorCFOP(aExcel, aCFOP, aCST, aCNat, aNatG, aCBcc, aCBccG, aAtfAG, aAtfDG, cFAnt)

Local cAux
Local nI, nJ, nMax, nMaxJ, nPos
Local aDev
Local aSomaE, aSomaS
Local cCFAnt
Local nSomaCF
Local nCntCF
Local cDescCF
Local aDvCom := {}

//troca variável pública cFilAnt para uso correto do xFilial por funções internas do Protheus
cFilAnt := cFAnt

//verifica as devoluções dentro do período da filial de notas que geraram crédito (CST 50)
DevCom(aDvCom,cFAnt)

aAdd(aExcel, {'CFOP', 'CST', 'Valor Contábil', 'Valor do Item', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS', 'ICMS Retido', 'IPI', 'Desconto', 'Frete', 'Despesa', 'Seguro', 'Descrição'})

nMax := Len(aCFOP)
If nMax > 0
	cCFAnt := ''
	aSomaE := Array(SOMA_ULTIMO-1)
	aSomaS := Array(SOMA_ULTIMO-1)
	aFill(aSomaE, 0)
	aFill(aSomaS, 0)
	
	nSomaCF := 0
	nCntCF  := 0
	
	For nI := 1 to nMax
		If cCFAnt <> ''
			If cCFAnt <> aCFOP[nI][CF_CFOP]
				If nCntCF > 1
					aAdd(aExcel, {'','SOMA',nSomaCF})
				EndIf
				nSomaCF := 0
				nCntCF  := 0
			EndIf
			If cCFAnt < '5000' .and. aCFOP[nI][CF_CFOP] >= '5000'
				Total(aExcel,'E',aSomaE)
			EndIf
			If cCFAnt >= '5000' .and. aCFOP[nI][CF_CFOP] < '5000'
				Total(aExcel,'S',aSomaS)
			EndIf
		EndIf
		
		//                                     X5_FILIAL      + X5_TABELA + X5_CHAVE
		cDescCF := AllTrim(Posicione('SX5', 1, xFilial('SX5') + '13'      + PadR(aCFOP[nI][CF_CFOP],6), 'X5_DESCRI'))
		
		aAdd(aExcel, {aCFOP[nI][CF_CFOP]   ,;
		              aCFOP[nI][CF_CST]    ,;
		              aCFOP[nI][CF_VALCONT],;
		              aCFOP[nI][CF_VALITEM],;
		              aCFOP[nI][CF_BASEPIS],;
		              aCFOP[nI][CF_BASECOF],;
		              aCFOP[nI][CF_VALPIS] ,;
		              aCFOP[nI][CF_VALCOF] ,;
		              aCFOP[nI][CF_ICMSRET],;
		              aCFOP[nI][CF_IPI]    ,;
		              aCFOP[nI][CF_DESCONT],;
		              aCFOP[nI][CF_FRETE]  ,;
		              aCFOP[nI][CF_DESPESA],;
		              aCFOP[nI][CF_SEGURO] ,;
		              cDescCF               ;
		})
		
		//removendo devolução de compras DENTRO do período do array de CFOPs
		aDev := {0,0,0,0,''}
		nMaxJ := Len(aDvCom)
		For nJ := 1 to nMaxJ
			If aDvCom[nJ][DVCOM_CFOP] == aCFOP[nI][CF_CFOP] .and. aDvCom[nJ][DVCOM_CST] == aCFOP[nI][CF_CST]
				aDev[1] += aDvCom[nJ][DVCOM_BASEPIS]
				aDev[2] += aDvCom[nJ][DVCOM_BASECOF]
				aDev[3] += aDvCom[nJ][DVCOM_VALPIS]
				aDev[4] += aDvCom[nJ][DVCOM_VALCOF]
				aDev[5] += Iif(AllTrim(aDev[5])<>'',', ','') + aDvCom[nJ][DVCOM_DOCS]
			EndIf
		Next nJ
		
		If aDev[1] > 0 .or. aDev[2] > 0 .or. aDev[3] > 0 .or. aDev[4] > 0
			aCFOP[nI][CF_BASEPIS] -= aDev[1]
			aCFOP[nI][CF_BASECOF] -= aDev[2]
			aCFOP[nI][CF_VALPIS]  -= aDev[3]
			aCFOP[nI][CF_VALCOF]  -= aDev[4]
			aCFOP[nI][CF_CALPIS]  -= aDev[3]
			aCFOP[nI][CF_CALCOF]  -= aDev[4]
			
			aAdd(aExcel, {'Devolução',;
			              '',;
			              0,;
			              0,;
			              aDev[1],;
			              aDev[2],;
			              aDev[3],;
			              aDev[4],;
			              'Docs: ' + aDev[5];
			})
			
			aAdd(aExcel, {aCFOP[nI][CF_CFOP]   ,;
			              aCFOP[nI][CF_CST]    ,;
			              aCFOP[nI][CF_VALCONT],;
			              aCFOP[nI][CF_VALITEM],;
			              aCFOP[nI][CF_BASEPIS],;
			              aCFOP[nI][CF_BASECOF],;
			              aCFOP[nI][CF_VALPIS] ,;
			              aCFOP[nI][CF_VALCOF] ,;
			              aCFOP[nI][CF_ICMSRET],;
			              aCFOP[nI][CF_IPI]    ,;
			              aCFOP[nI][CF_DESCONT],;
			              aCFOP[nI][CF_FRETE]  ,;
			              aCFOP[nI][CF_DESPESA],;
			              aCFOP[nI][CF_SEGURO] ,;
			              cDescCF               ;
			})
		EndIf
		
		nSomaCF += aCFOP[nI][CF_VALCONT]
		nCntCF++
		
		//somando valores
		If aCFOP[nI][CF_CFOP] < '5000'
			aSomaE[SOMA_VALCONT] += aCFOP[nI][CF_VALCONT]
			aSomaE[SOMA_VALITEM] += aCFOP[nI][CF_VALITEM]
			aSomaE[SOMA_BASEPIS] += aCFOP[nI][CF_BASEPIS]
			aSomaE[SOMA_BASECOF] += aCFOP[nI][CF_BASECOF]
			aSomaE[SOMA_VALPIS]  += aCFOP[nI][CF_VALPIS]
			aSomaE[SOMA_VALCOF]  += aCFOP[nI][CF_VALCOF]
			aSomaE[SOMA_CALPIS]  += aCFOP[nI][CF_CALPIS]
			aSomaE[SOMA_CALCOF]  += aCFOP[nI][CF_CALCOF]
			aSomaE[SOMA_ICMSRET] += aCFOP[nI][CF_ICMSRET]
			aSomaE[SOMA_IPI]     += aCFOP[nI][CF_IPI]
			aSomaE[SOMA_DESCONT] += aCFOP[nI][CF_DESCONT]
			aSomaE[SOMA_FRETE]   += aCFOP[nI][CF_FRETE]
			aSomaE[SOMA_DESPESA] += aCFOP[nI][CF_DESPESA]
			aSomaE[SOMA_SEGURO]  += aCFOP[nI][CF_SEGURO]
		Else
			aSomaS[SOMA_VALCONT] += aCFOP[nI][CF_VALCONT]
			aSomaS[SOMA_VALITEM] += aCFOP[nI][CF_VALITEM]
			aSomaS[SOMA_BASEPIS] += aCFOP[nI][CF_BASEPIS]
			aSomaS[SOMA_BASECOF] += aCFOP[nI][CF_BASECOF]
			aSomaS[SOMA_VALPIS]  += aCFOP[nI][CF_VALPIS]
			aSomaS[SOMA_VALCOF]  += aCFOP[nI][CF_VALCOF]
			aSomaS[SOMA_CALPIS]  += aCFOP[nI][CF_CALPIS]
			aSomaS[SOMA_CALCOF]  += aCFOP[nI][CF_CALCOF]
			aSomaS[SOMA_ICMSRET] += aCFOP[nI][CF_ICMSRET]
			aSomaS[SOMA_IPI]     += aCFOP[nI][CF_IPI]
			aSomaS[SOMA_DESCONT] += aCFOP[nI][CF_DESCONT]
			aSomaS[SOMA_FRETE]   += aCFOP[nI][CF_FRETE]
			aSomaS[SOMA_DESPESA] += aCFOP[nI][CF_DESPESA]
			aSomaS[SOMA_SEGURO]  += aCFOP[nI][CF_SEGURO]
		EndIf
		
		cCFAnt := aCFOP[nI][CF_CFOP]
	Next nI
	
	//imprime total
	If cCFAnt < '5000'
		Total(aExcel,'E',aSomaE)
	ElseIf cCFAnt >= '5000'
		Total(aExcel,'S',aSomaS)
	EndIf	
	
	//removendo devolução de compras DENTRO do período do array de CSTs
	nMax := Len(aCST)
	For nI := 1 to nMax
		aDev := {0,0,0,0}
		nMaxJ := Len(aDvCom)
		For nJ := 1 to nMaxJ
			If aDvCom[nJ][DVCOM_CST] == aCST[nI][CST_CST]
				aDev[1] += aDvCom[nJ][DVCOM_BASEPIS]
				aDev[2] += aDvCom[nJ][DVCOM_BASECOF]
				aDev[3] += aDvCom[nJ][DVCOM_VALPIS]
				aDev[4] += aDvCom[nJ][DVCOM_VALCOF]
			EndIf
		Next nJ
		
		If aDev[1] > 0 .or. aDev[2] > 0 .or. aDev[3] > 0 .or. aDev[4] > 0
			aCST[nI][CST_BASEPIS] -= aDev[1]
			aCST[nI][CST_BASECOF] -= aDev[2]
			aCST[nI][CST_VALPIS]  -= aDev[3]
			aCST[nI][CST_VALCOF]  -= aDev[4]
			aCST[nI][CST_CALPIS]  -= aDev[3]
			aCST[nI][CST_CALCOF]  -= aDev[4]
		EndIf
	Next nI
		
	//limpa somas
	LimpaSoma(aSomaE,aSomaS)
	PorCST(aExcel,aCST,.F.,'Somente CFOPs',.F.)
EndIf

If MV_PAR09 == 1
	//considera títulos
	Titulos(aExcel,aCST,aNatG,aCBcc,aCBccG,,cFAnt)
	PorCST(aExcel,aCST,.F.,'Somente Títulos',.F.)
EndIf

If MV_PAR10 == 1
	//considera ativo aquisição
	AtivoA(aExcel,aCST,aCBcc,aCBccG,aAtfAG,,cFAnt)
	PorCST(aExcel,aCST,.F.,'Somente Ativo [Aquisição]',.F.)
EndIf

If MV_PAR11 == 1
	//considera ativo depreciação
	AtivoD(aExcel,aCST,aCBcc,aCBccG,aAtfDG,,cFAnt)
	PorCST(aExcel,aCST,.F.,'Somente Ativo [Depreciação]',.F.)
EndIf

PorCST(aExcel,_aCSTG,.T.,'CFOPs + Títulos + Ativo [Aquisição] + Ativo [Depreciação]',.T.)

AjuConCan(aExcel,cFAnt)
AjuConAnu(aExcel,cFAnt)
AjuCreDev(aExcel,cFAnt)

//não é necessário remover devolução de compras DENTRO do período do array de Natureza de Receita
//pois só são estornadas as devoluções de CST 50 e este CST não se aplica aos registros com Natureza de Receita

//removendo devolução de compras DENTRO do período do array de Base de Cálculo de Crédito
nMax := Len(aCBcc)
For nI := 1 to nMax
	aDev := {0,0,0,0}
	nMaxJ := Len(aDvCom)
	For nJ := 1 to nMaxJ
		If aDvCom[nJ][DVCOM_CST] == aCBcc[nI][CBCC_CST] .and. aDvCom[nJ][DVCOM_CODBCC] == aCBcc[nI][CBCC_CODBCC]
			aDev[1] += aDvCom[nJ][DVCOM_BASEPIS]
			aDev[2] += aDvCom[nJ][DVCOM_BASECOF]
			aDev[3] += aDvCom[nJ][DVCOM_VALPIS]
			aDev[4] += aDvCom[nJ][DVCOM_VALCOF]
		EndIf
	Next nJ
	
	If aDev[1] > 0 .or. aDev[2] > 0 .or. aDev[3] > 0 .or. aDev[4] > 0
		aCBcc[nI][CBCC_BASEPIS] -= aDev[1]
		aCBcc[nI][CBCC_BASECOF] -= aDev[2]
		aCBcc[nI][CBCC_VALPIS]  -= aDev[3]
		aCBcc[nI][CBCC_VALCOF]  -= aDev[4]
	EndIf
Next nI
	
PorCNAT(aExcel,aCNat)
PorCBCC(aExcel,aCBcc)

aCFOP := {}

Return Nil

/* -------------- */

Static Function AjuConCan(aExcel, cFAnt, lGeral)

Local cQry
Local nSomaPis := 0
Local nSomaCof := 0
Local nI, nJ, nMax
Local aAux

Default lGeral := .F.

If !lGeral
	cQry := CRLF + " SELECT"
	cQry += CRLF + "        FT_ESPECIE"
	cQry += CRLF + "       ,FT_ENTRADA"
	cQry += CRLF + "       ,FT_SERIE"
	cQry += CRLF + "       ,FT_NFISCAL"
	cQry += CRLF + "       ,FT_CLIEFOR"
	cQry += CRLF + "       ,FT_LOJA"
	cQry += CRLF + "       ,ROUND(SUM(FT_VALCONT),2) VALCONT"
	cQry += CRLF + "       ,ROUND(SUM(CASE FT_AGREG WHEN 'I' THEN FT_TOTAL+FT_VALICM ELSE FT_TOTAL END),2) VALITEM"
	cQry += CRLF + "       ,ROUND(SUM(FT_BASEPIS),2) BASEPIS"
	cQry += CRLF + "       ,ROUND(SUM(FT_BASECOF),2) BASECOF"
	cQry += CRLF + "       ,ROUND(SUM(FT_VALPIS),2) VALPIS"
	cQry += CRLF + "       ,ROUND(SUM(FT_VALCOF),2) VALCOF"
	cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
	cQry += CRLF + " LEFT JOIN SF3010 SF3"
	cQry += CRLF + " ON  SF3.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND F3_FILIAL = '" + cFAnt + "'"
	cQry += CRLF + " AND F3_NFISCAL = FT_NFISCAL"
	cQry += CRLF + " AND F3_SERIE = FT_SERIE"
	cQry += CRLF + " AND F3_CLIEFOR = FT_CLIEFOR"
	cQry += CRLF + " AND F3_LOJA = FT_LOJA"
	cQry += CRLF + " AND F3_CFO = FT_CFOP"
	cQry += CRLF + " AND F3_TIPO = FT_TIPO"
	cQry += CRLF + " AND F3_IDENTFT = FT_IDENTF3"
	cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL = '" + cFAnt + "'"
	cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) = '" + _cMesAnt + "'"
	cQry += CRLF + "   AND LEN(FT_DTCANC) > 0"
	cQry += CRLF + "   AND FT_OBSERV LIKE '%CANCEL%'"
	cQry += CRLF + "   AND LEFT(FT_DTCANC,6) = '" + _cMesAtu + "'"
	cQry += CRLF + "   AND ("
	cQry += CRLF + "     ("
	cQry += CRLF + "           F3_CODRSEF = '101'"
	cQry += CRLF + "       AND FT_ESPECIE IN ('SPED','CTE')"
	cQry += CRLF + "     ) OR ("
	cQry += CRLF + "           F3_CODRSEF = ''"
	cQry += CRLF + "       AND FT_ESPECIE NOT IN ('SPED','CTE')"
	cQry += CRLF + "     )"
	cQry += CRLF + "   )"
	cQry += CRLF + "   AND FT_CSTPIS = '01'"
	cQry += CRLF + " GROUP BY FT_ESPECIE, FT_ENTRADA, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA"
	cQry += CRLF + " ORDER BY FT_ESPECIE, FT_ENTRADA, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA"
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'AJUCON',.T.)
EndIf

aAdd(aExcel, {'Documentos Cancelados (Estorno) - Ajuste da Contribuição para o PIS/COFINS Apurado'})
If !lGeral
	aAdd(aExcel, {'Espécie', 'Entrada', 'Série', 'Documento', 'Valor Contábil', 'Valor do Item', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
Else
	aAdd(aExcel, {'Filial', 'Espécie', 'Entrada', 'Série', 'Documento', 'Valor Contábil', 'Valor do Item', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
EndIf

If !lGeral
	While !AJUCON->(Eof())
		aAdd(aExcel, {AJUCON->FT_ESPECIE, DTOC(STOD(AJUCON->FT_ENTRADA)), AJUCON->FT_SERIE, AJUCON->FT_NFISCAL, AJUCON->VALCONT, AJUCON->VALITEM, AJUCON->BASEPIS, AJUCON->BASECOF, AJUCON->VALPIS, AJUCON->VALCOF})
		aAdd(_aAjuConG, {AJUCON_TIPO_CANCELAMENTO, cFAnt, AJUCON->FT_ESPECIE, DTOC(STOD(AJUCON->FT_ENTRADA)), AJUCON->FT_SERIE, AJUCON->FT_NFISCAL, AJUCON->VALCONT, AJUCON->VALITEM, AJUCON->BASEPIS, AJUCON->BASECOF, AJUCON->VALPIS, AJUCON->VALCOF})
		nSomaPis += AJUCON->VALPIS
		nSomaCof += AJUCON->VALCOF
		AJUCON->(dbSkip())
	EndDo
	AJUCON->(dbCloseArea())
Else
	nMax := Len(_aAjuConG)
	For nI := 1 to nMax
		If _aAjuConG[nI][AJUCON_TIPO] == AJUCON_TIPO_CANCELAMENTO
			aAux := {}
			For nJ := AJUCON_TIPO+1 to AJUCON_ULTIMO-1
				aAdd(aAux, _aAjuConG[nI][nJ])
			Next nJ
			aAdd(aExcel, aClone(aAux))
			nSomaPis += _aAjuConG[nI][AJUCON_VALPIS]
			nSomaCof += _aAjuConG[nI][AJUCON_VALCOF]
		EndIf
	Next nI
EndIf

If !lGeral
	aAdd(aExcel, {'', '', '', '', '', '', 'Valor total do ajuste', '', nSomaPis, nSomaCof})
Else
	aAdd(aExcel, {'','', '', '', '', '', '', 'Valor total do ajuste', '', nSomaPis, nSomaCof})
EndIf
aAdd(aExcel, {''})

If lGeral
	_aApura[APU_CON_RED][APU_VALPIS] += nSomaPis
	_aApura[APU_CON_RED][APU_VALCOF] += nSomaCof
	_aApura[APU_CON_RED][APU_CALPIS] += nSomaPis
	_aApura[APU_CON_RED][APU_CALCOF] += nSomaCof
EndIf

Return Nil

/* -------------- */

Static Function AjuConAnu(aExcel, cFAnt, lGeral)

Local cQry
Local nSomaPis := 0
Local nSomaCof := 0
Local nI, nJ, nMax
Local aAux
Local nBasePis, nBaseCof, nValPis, nValCof

Default lGeral := .F.

If !lGeral
	cQry := CRLF + " SELECT"
	cQry += CRLF + "        FT_ESPECIE"
	cQry += CRLF + "       ,FT_ENTRADA"
	cQry += CRLF + "       ,FT_SERIE"
	cQry += CRLF + "       ,FT_NFISCAL"
	cQry += CRLF + "       ,FT_CLIEFOR"
	cQry += CRLF + "       ,FT_LOJA"
	cQry += CRLF + "       ,ROUND(SUM(FT_VALCONT),2) VALCONT"
	cQry += CRLF + "       ,ROUND(SUM(CASE FT_AGREG WHEN 'I' THEN FT_TOTAL+FT_VALICM ELSE FT_TOTAL END),2) VALITEM"
	cQry += CRLF + "       ,ROUND(SUM(FT_BASEPIS),2) BASEPIS"
	cQry += CRLF + "       ,ROUND(SUM(FT_BASECOF),2) BASECOF"
	cQry += CRLF + "       ,ROUND(SUM(FT_VALPIS),2) VALPIS"
	cQry += CRLF + "       ,ROUND(SUM(FT_VALCOF),2) VALCOF"
	cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
	cQry += CRLF + " LEFT JOIN SF3010 SF3"
	cQry += CRLF + " ON  SF3.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND F3_FILIAL = '" + cFAnt + "'"
	cQry += CRLF + " AND F3_NFISCAL = FT_NFISCAL"
	cQry += CRLF + " AND F3_SERIE = FT_SERIE"
	cQry += CRLF + " AND F3_CLIEFOR = FT_CLIEFOR"
	cQry += CRLF + " AND F3_LOJA = FT_LOJA"
	cQry += CRLF + " AND F3_CFO = FT_CFOP"
	cQry += CRLF + " AND F3_TIPO = FT_TIPO"
	cQry += CRLF + " AND F3_IDENTFT = FT_IDENTF3"
	cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL = '" + cFAnt + "'"
	cQry += CRLF + "   AND LEFT(FT_ENTRADA,6) = '" + _cMesAtu + "'"
	If MV_PAR12 == 2
		//todos os cancelados
		cQry += CRLF + "   AND LEN(FT_DTCANC) = 0 "
		cQry += CRLF + "   AND FT_OBSERV NOT LIKE '%INUTIL%'"
		cQry += CRLF + "   AND FT_OBSERV NOT LIKE '%CANCEL%'"
	ElseIf MV_PAR12 == 1
		//somente cancelados dentro do período
		cQry += CRLF + "   AND ("
		cQry += CRLF + "     ("
		cQry += CRLF + "           LEN(FT_DTCANC) = 0 "
		cQry += CRLF + "       AND FT_OBSERV NOT LIKE '%INUTIL%'"
		cQry += CRLF + "       AND FT_OBSERV NOT LIKE '%CANCEL%'"
		cQry += CRLF + "     ) OR ("
		cQry += CRLF + "           LEN(FT_DTCANC) > 0 "
		cQry += CRLF + "       AND FT_OBSERV LIKE '%CANCEL%'"
		cQry += CRLF + "       AND LEFT(FT_DTCANC,6) > '" + _cMesAtu + "'"
		cQry += CRLF + "       AND F3_CODRSEF = '101'"
		cQry += CRLF + "     )"
		cQry += CRLF + "   )"
	EndIf
	cQry += CRLF + "   AND FT_CFOP IN ('1206','2206')"
	cQry += CRLF + " GROUP BY FT_ESPECIE, FT_ENTRADA, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA"
	cQry += CRLF + " ORDER BY FT_ESPECIE, FT_ENTRADA, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA"
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'AJUCON',.T.)
EndIf

aAdd(aExcel, {'Documentos Anulados (Estorno) - Ajuste da Contribuição para o PIS/COFINS Apurado'})
If !lGeral
	aAdd(aExcel, {'Espécie', 'Entrada', 'Série', 'Documento', 'Valor Contábil', 'Valor do Item', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
Else
	aAdd(aExcel, {'Filial', 'Espécie', 'Entrada', 'Série', 'Documento', 'Valor Contábil', 'Valor do Item', 'Base PIS', 'Base COFINS', 'Valor PIS', 'Valor COFINS'})
EndIf

If !lGeral
	While !AJUCON->(Eof())
		//documentos anulados possuem CST 98 logo não têm cálculo de PIS/COFINS
		//entretanto o valor contábil é tomado como base pois na TTL esses documentos
		//são referentes a anulações de CT-e e portanto devem ser estornados
		nBasePis := AJUCON->VALCONT
		nBaseCof := AJUCON->VALCONT
		nValPis  := Round((nBasePis * MV_PAR07) / 100, 2)
		nValCof  := Round((nBaseCof * MV_PAR08) / 100, 2)
		
		aAdd(aExcel,    {                             AJUCON->FT_ESPECIE, DTOC(STOD(AJUCON->FT_ENTRADA)), AJUCON->FT_SERIE, AJUCON->FT_NFISCAL, AJUCON->VALCONT, AJUCON->VALITEM, nBasePis, nBaseCof, nValPis, nValCof})
		aAdd(_aAjuConG, {AJUCON_TIPO_ANULACAO, cFAnt, AJUCON->FT_ESPECIE, DTOC(STOD(AJUCON->FT_ENTRADA)), AJUCON->FT_SERIE, AJUCON->FT_NFISCAL, AJUCON->VALCONT, AJUCON->VALITEM, nBasePis, nBaseCof, nValPis, nValCof})
		nSomaPis += nValPis
		nSomaCof += nValCof
		AJUCON->(dbSkip())
	EndDo
	AJUCON->(dbCloseArea())
Else
	nMax := Len(_aAjuConG)
	For nI := 1 to nMax
		If _aAjuConG[nI][AJUCON_TIPO] == AJUCON_TIPO_ANULACAO
			aAux := {}
			For nJ := AJUCON_TIPO+1 to AJUCON_ULTIMO-1
				aAdd(aAux, _aAjuConG[nI][nJ])
			Next nJ
			aAdd(aExcel, aClone(aAux))
			nSomaPis += _aAjuConG[nI][AJUCON_VALPIS]
			nSomaCof += _aAjuConG[nI][AJUCON_VALCOF]
		EndIf
	Next nI
EndIf

If !lGeral
	aAdd(aExcel, {'', '', '', '', '', '', 'Valor total do ajuste', '', nSomaPis, nSomaCof})
Else
	aAdd(aExcel, {'','', '', '', '', '', '', 'Valor total do ajuste', '', nSomaPis, nSomaCof})
EndIf
aAdd(aExcel, {''})

If lGeral
	_aApura[APU_CON_RED][APU_VALPIS] += nSomaPis
	_aApura[APU_CON_RED][APU_VALCOF] += nSomaCof
	_aApura[APU_CON_RED][APU_CALPIS] += nSomaPis
	_aApura[APU_CON_RED][APU_CALCOF] += nSomaCof
EndIf

Return Nil

/* -------------- */

Static Function AjuCreDev(aExcel, cFAnt, lGeral)

Local cQry
Local nSomaPis := 0
Local nSomaCof := 0
Local nI, nJ, nMax
Local aAux
Local cAux, cPeriodo
Local nPerPis, nPerCof, nBasePis, nBaseCof, nValPis, nValCof

Default lGeral := .F.

If !lGeral
	cQry := U_MyQDvCom(U_MyDia(1,MV_PAR01,MV_PAR02),U_MyDia(2,MV_PAR01,MV_PAR02),cFAnt,cFAnt,,,'50')
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'AJUCRE',.T.)
EndIf

aAdd(aExcel, {'Documentos de Devolução (Estorno) - Ajuste do Crédito para o PIS/COFINS Apurado'})
If !lGeral
	aAdd(aExcel, {;
		'Dados da NF de Devolução (SFT)','','','','',;
		'Dados da NF de Entrada (SFT)';
	})
	aAdd(aExcel, {;
		'Número','Série','Data Entrada','Valor Contábil','Valor do Item',;
		'Número','Série','Data Entrada','CST','Valor Contábil','Base PIS Devolvido', 'Base COFINS Devolvido', 'Valor PIS Devolvido', 'Valor COFINS Devolvido',;
		'Monof/AliqZero','Período';
	})
Else
	aAdd(aExcel, {;
		'',;
		'Dados da NF de Devolução (SFT)','','','','',;
		'Dados da NF de Entrada (SFT)';
	})
	aAdd(aExcel, {;
		'Filial',;
		'Número','Série','Data Entrada','Valor Contábil','Valor do Item',;
		'Número','Série','Data Entrada','CST','Valor Contábil','Base PIS Devolvido', 'Base COFINS Devolvido', 'Valor PIS Devolvido', 'Valor COFINS Devolvido',;
		'Monof/AliqZero','Período';
	})
EndIf

If !lGeral
	While !AJUCRE->(Eof())
		If Left(AJUCRE->SFTS_ENTRADA, 6) <> Left(AJUCRE->SFTE_ENTRADA, 6)
			//somente considera devoluções FORA do período para estorno do crédito.
			//as devoluções DENTRO do período terão sua contribuição anulada
			//(FT_BASEPIS/FT_VALPIS/FT_BASECOF/FT_VALCOF=0) pela função PorCFOP
			nPerPis := 0
			nPerCof := 0
			
			If AJUCRE->SFTS_BPIS > 0 .and. AJUCRE->SFTS_BPIS <= AJUCRE->SFTE_BPIS
				nPerPis := AJUCRE->SFTS_BPIS / AJUCRE->SFTE_BPIS
			Else
				nPerPis := ((AJUCRE->SFTS_QTD * 100) / AJUCRE->SFTE_QTD ) / 100
			EndIf
			
			If AJUCRE->SFTS_BCOF > 0 .and. AJUCRE->SFTS_BCOF <= AJUCRE->SFTE_BCOF
				nPerCof := AJUCRE->SFTS_BCOF / AJUCRE->SFTE_BCOF
			Else
				nPerCof := ((AJUCRE->SFTS_QTD * 100) / AJUCRE->SFTE_QTD ) / 100
			EndIf
			
			If AJUCRE->SFTS_QTD == AJUCRE->SFTE_QTD
				nBasePis := AJUCRE->SFTE_BPIS
				nBaseCof := AJUCRE->SFTE_BCOF
				nValPis := AJUCRE->SFTE_VPIS
				nValCof := AJUCRE->SFTE_VCOF
			Else
				nBasePis := Round(AJUCRE->SFTE_BPIS * nPerPis,2)
				nBaseCof := Round(AJUCRE->SFTE_BCOF * nPerCof,2)
				nValPis := Round(AJUCRE->SFTE_VPIS * nPerPis,2)
				nValCof := Round(AJUCRE->SFTE_VCOF * nPerCof,2)
			EndIf
		
			cPeriodo := 'FORA'
			
			cAux := 'Não'
			If AllTrim(AJUCRE->ZPI_NCM) <> ''
				cAux := 'Sim'
			EndIf
			
			aAdd(aExcel, {;
				AJUCRE->SFTS_DOC,AJUCRE->SFTS_SERIE,DTOC(STOD(AJUCRE->SFTS_ENTRADA)),AJUCRE->SFTS_VALCONT,AJUCRE->SFTS_TOTAL,;
				AJUCRE->SFTE_DOC,AJUCRE->SFTE_SERIE,DTOC(STOD(AJUCRE->SFTE_ENTRADA)),AJUCRE->SFTE_CSTPIS,AJUCRE->SFTE_VALCONT,nBasePis,nBaseCof,nValPis,nValCof,;
				cAux,cPeriodo;
			})
			aAdd(_aAjuCreG, {;
				AJUCRE_TIPO_DEVOLUCAO,;
				cFAnt,;
				AJUCRE->SFTS_DOC,AJUCRE->SFTS_SERIE,DTOC(STOD(AJUCRE->SFTS_ENTRADA)),AJUCRE->SFTS_VALCONT,AJUCRE->SFTS_TOTAL,;
				AJUCRE->SFTE_DOC,AJUCRE->SFTE_SERIE,DTOC(STOD(AJUCRE->SFTE_ENTRADA)),AJUCRE->SFTE_CSTPIS,AJUCRE->SFTE_VALCONT,nBasePis,nBaseCof,nValPis,nValCof,;
				cAux,cPeriodo;
			})
			
			nSomaPis += nValPis
			nSomaCof += nValCof
		EndIf
		AJUCRE->(dbSkip())
	EndDo
	AJUCRE->(dbCloseArea())
Else
	nMax := Len(_aAjuCreG)
	For nI := 1 to nMax
		If _aAjuCreG[nI][AJUCRE_TIPO] == AJUCRE_TIPO_DEVOLUCAO
			aAux := {}
			For nJ := AJUCRE_TIPO+1 to AJUCRE_ULTIMO-1
				aAdd(aAux, _aAjuCreG[nI][nJ])
			Next nJ
			aAdd(aExcel, aClone(aAux))
			nSomaPis += _aAjuCreG[nI][AJUCRE_EVALPIS]
			nSomaCof += _aAjuCreG[nI][AJUCRE_EVALCOF]
		EndIf
	Next nI
EndIf

If !lGeral
	aAdd(aExcel, {'','','', '', '', '', '', '', '', '', 'Valor total do ajuste', '', nSomaPis, nSomaCof})
Else
	aAdd(aExcel, {'','','', '', '', '', '', '', '', '', '', 'Valor total do ajuste', '', nSomaPis, nSomaCof})
EndIf
aAdd(aExcel, {''})

If lGeral
	_aApura[APU_CRE_RED][APU_VALPIS] += nSomaPis
	_aApura[APU_CRE_RED][APU_VALCOF] += nSomaCof
	_aApura[APU_CRE_RED][APU_CALPIS] += nSomaPis
	_aApura[APU_CRE_RED][APU_CALCOF] += nSomaCof
EndIf

Return Nil

/* -------------- */

Static Function DevCom(aDvCom,cFAnt)

Local cQry
Local nPos
Local aAux := {}
Local nPerPis, nPerCof, nBasePis, nBaseCof, nValPis, nValCof

cQry := U_MyQDvCom(U_MyDia(1,MV_PAR01,MV_PAR02),U_MyDia(2,MV_PAR01,MV_PAR02),cFAnt,cFAnt,,,'50')
cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'DVCOM',.T.)

While !DVCOM->(Eof())
	If Left(DVCOM->SFTS_ENTRADA, 6) == Left(DVCOM->SFTE_ENTRADA, 6)
		//somente considera devoluções DENTRO do período para anulação
		//(FT_BASEPIS/FT_VALPIS/FT_BASECOF/FT_VALCOF=0) da contribuição.
		//as devoluções FORA do período terão seu crédito estornado (AjuCreDev)
		
		nPerPis := 0
		nPerCof := 0
		
		If DVCOM->SFTS_BPIS > 0 .and. DVCOM->SFTS_BPIS <= DVCOM->SFTE_BPIS
			nPerPis := DVCOM->SFTS_BPIS / DVCOM->SFTE_BPIS
		Else
			nPerPis := ((DVCOM->SFTS_QTD * 100) / DVCOM->SFTE_QTD ) / 100
		EndIf
		
		If DVCOM->SFTS_BCOF > 0 .and. DVCOM->SFTS_BCOF <= DVCOM->SFTE_BCOF
			nPerCof := DVCOM->SFTS_BCOF / DVCOM->SFTE_BCOF
		Else
			nPerCof := ((DVCOM->SFTS_QTD * 100) / DVCOM->SFTE_QTD ) / 100
		EndIf
		
		If DVCOM->SFTS_QTD == DVCOM->SFTE_QTD
			nBasePis := DVCOM->SFTE_BPIS
			nBaseCof := DVCOM->SFTE_BCOF
			nValPis := DVCOM->SFTE_VPIS
			nValCof := DVCOM->SFTE_VCOF
		Else
			nBasePis := Round(DVCOM->SFTE_BPIS * nPerPis,2)
			nBaseCof := Round(DVCOM->SFTE_BCOF * nPerCof,2)
			nValPis := Round(DVCOM->SFTE_VPIS * nPerPis,2)
			nValCof := Round(DVCOM->SFTE_VCOF * nPerCof,2)
		EndIf
		
		nPos := aScan(aDvCom, {|x| x[DVCOM_CFOP] == DVCOM->SFTE_CFOP .and. x[DVCOM_CST] == DVCOM->SFTE_CSTPIS .and. x[DVCOM_TNATREC] == DVCOM->SFTE_TNATREC .and. x[DVCOM_CNATREC] == DVCOM->SFTE_CNATREC .and. x[DVCOM_CODBCC] == DVCOM->SFTE_CODBCC })
		If nPos == 0
			aAux := Array(DVCOM_ULTIMO-1)
			aAux[DVCOM_CFOP]    := DVCOM->SFTE_CFOP
			aAux[DVCOM_CST]     := DVCOM->SFTE_CSTPIS
			aAux[DVCOM_TNATREC] := DVCOM->SFTE_TNATREC
			aAux[DVCOM_CNATREC] := DVCOM->SFTE_CNATREC
			aAux[DVCOM_CODBCC]  := DVCOM->SFTE_CODBCC
			aAux[DVCOM_VALITEM] := DVCOM->SFTE_VALITEM
			aAux[DVCOM_BASEPIS] := nBasePis
			aAux[DVCOM_BASECOF] := nBaseCof
			aAux[DVCOM_VALPIS]  := nValPis
			aAux[DVCOM_VALCOF]  := nValCof
			aAux[DVCOM_DOCS]    := AllTrim(DVCOM->SFTE_DOC)
			aAdd(aDvCom, aClone(aAux))
		Else
			aDvCom[nPos][DVCOM_VALITEM] += DVCOM->SFTE_VALITEM
			aDvCom[nPos][DVCOM_BASEPIS] += nBasePis
			aDvCom[nPos][DVCOM_BASECOF] += nBaseCof
			aDvCom[nPos][DVCOM_VALPIS]  += nValPis
			aDvCom[nPos][DVCOM_VALCOF]  += nValCof
			aDvCom[nPos][DVCOM_DOCS]    += ', ' + AllTrim(DVCOM->SFTE_DOC)
		EndIf
		
		nPos := aScan(_aDvComG, {|x| x[DVCOM_CFOP] == DVCOM->SFTE_CFOP .and. x[DVCOM_CST] == DVCOM->SFTE_CSTPIS .and. x[DVCOM_TNATREC] == DVCOM->SFTE_TNATREC .and. x[DVCOM_CNATREC] == DVCOM->SFTE_CNATREC .and. x[DVCOM_CODBCC] == DVCOM->SFTE_CODBCC })
		If nPos == 0
			aAux := Array(DVCOM_ULTIMO-1)
			aAux[DVCOM_CFOP]    := DVCOM->SFTE_CFOP
			aAux[DVCOM_CST]     := DVCOM->SFTE_CSTPIS
			aAux[DVCOM_TNATREC] := DVCOM->SFTE_TNATREC
			aAux[DVCOM_CNATREC] := DVCOM->SFTE_CNATREC
			aAux[DVCOM_CODBCC]  := DVCOM->SFTE_CODBCC
			aAux[DVCOM_VALITEM] := DVCOM->SFTE_VALITEM
			aAux[DVCOM_BASEPIS] := nBasePis
			aAux[DVCOM_BASECOF] := nBaseCof
			aAux[DVCOM_VALPIS]  := nValPis
			aAux[DVCOM_VALCOF]  := nValCof
			aAux[DVCOM_DOCS]    := AllTrim(DVCOM->SFTE_DOC)
			aAdd(_aDvComG, aClone(aAux))
		Else
			_aDvComG[nPos][DVCOM_VALITEM] += DVCOM->SFTE_VALITEM
			_aDvComG[nPos][DVCOM_BASEPIS] += nBasePis
			_aDvComG[nPos][DVCOM_BASECOF] += nBaseCof
			_aDvComG[nPos][DVCOM_VALPIS]  += nValPis
			_aDvComG[nPos][DVCOM_VALCOF]  += nValCof
			_aDvComG[nPos][DVCOM_DOCS]    += ', ' + AllTrim(DVCOM->SFTE_DOC)
		EndIf
	EndIf
	DVCOM->(dbSkip())
EndDo
DVCOM->(dbCloseArea())

Return Nil

/* -------------- */

Static Function ApuFinal(aExcel)

Local nI, nJ

Local nCrdValPis := _aApura[APU_CRE][APU_VALPIS] + _aApura[APU_CRE_ACR][APU_VALPIS] - _aApura[APU_CRE_RED][APU_VALPIS]
Local nCrdValCof := _aApura[APU_CRE][APU_VALCOF] + _aApura[APU_CRE_ACR][APU_VALCOF] - _aApura[APU_CRE_RED][APU_VALCOF]
Local nCrdCalPis := _aApura[APU_CRE][APU_CALPIS] + _aApura[APU_CRE_ACR][APU_CALPIS] - _aApura[APU_CRE_RED][APU_CALPIS]
Local nCrdCalCof := _aApura[APU_CRE][APU_CALCOF] + _aApura[APU_CRE_ACR][APU_CALCOF] - _aApura[APU_CRE_RED][APU_CALCOF]

Local nSldValPis := 0
Local nSldValCof := 0
Local nSldCalPis := 0
Local nSldCalCof := 0

Local nCrdPisAnt := 0
Local nCrdCofAnt := 0

Local nTotContrb := 0

Local aReg1100 := {}
Local aReg1500 := {}
Local cPer := DTOS(LastDay(STOD(_cMesAtu + '01')))

/*
 * PIS
 */
 
//procurando créditos anteriores
nTotContrb := _aApura[APU_CON][APU_VALPIS] + _aApura[APU_CON_ACR][APU_VALPIS] - _aApura[APU_CON_RED][APU_VALPIS]
PCCredAnt(cPer,@aReg1100,@aReg1500,@nTotContrb,'PIS')
CredAntPis(cPer,@aReg1100,@nTotContrb,.T.)

nMax := Len(aReg1100)
For nI := 1 to nMax
	If Left(cPer,6) > Right(aReg1100[nI][2],4)+Left(aReg1100[nI][2],2)
		nCrdPisAnt += aReg1100[nI][13]
	EndIf
Next nI

CalcApu(@nSldValPis, @nCrdPisAnt, APU_VALPIS)
CalcApu(@nSldCalPis, @nCrdPisAnt, APU_CALPIS)

/*
 * COFINS
 */
 
//procurando créditos anteriores
nTotContrb := _aApura[APU_CON][APU_VALCOF] + _aApura[APU_CON_ACR][APU_VALCOF] - _aApura[APU_CON_RED][APU_VALCOF]
PCCredAnt(cPer,@aReg1100,@aReg1500,@nTotContrb,'COF')
CredAntCof(cPer,@aReg1500,@nTotContrb,.T.)

nMax := Len(aReg1500)
For nI := 1 to nMax
	If Left(cPer,6) <> Right(aReg1500[nI][2],4)+Left(aReg1500[nI][2],2)
		nCrdCofAnt += aReg1500[nI][13]
	EndIf
Next nI

CalcApu(@nSldValCof, @nCrdCofAnt, APU_VALCOF)
CalcApu(@nSldCalCof, @nCrdCofAnt, APU_CALCOF)
	
aAdd(aExcel, {'Demonstração dos Créditos Apurados no Período'})
aAdd(aExcel, {'Descrição','Relação','Valor PIS','Valor COFINS','Calculado PIS','Calculado COFINS'})
aAdd(aExcel, {;
	'5. Valor Total do Crédito Apurado',;
	'CST 50',;
	_aApura[APU_CRE][APU_VALPIS],;
	_aApura[APU_CRE][APU_VALCOF],;
	_aApura[APU_CRE][APU_CALPIS],;
	_aApura[APU_CRE][APU_CALCOF];
})
aAdd(aExcel, {;
	'6. Valor Total dos Ajustes de Acréscimo',;
	'',;
	_aApura[APU_CRE_ACR][APU_VALPIS],;
	_aApura[APU_CRE_ACR][APU_VALCOF],;
	_aApura[APU_CRE_ACR][APU_CALPIS],;
	_aApura[APU_CRE_ACR][APU_CALCOF];
})
aAdd(aExcel, {;
	'7. Valor Total dos Ajustes de Redução',;
	'Estornos',;
	_aApura[APU_CRE_RED][APU_VALPIS],;
	_aApura[APU_CRE_RED][APU_VALCOF],;
	_aApura[APU_CRE_RED][APU_CALPIS],;
	_aApura[APU_CRE_RED][APU_CALCOF];
})
aAdd(aExcel, {;
	'9. Valor Total do Crédito Disponível no Período (5 + 6 - 7)',;
	'',;
	nCrdValPis,;
	nCrdValCof,;
	nCrdCalPis,;
	nCrdCalCof;
})
aAdd(aExcel, {;
	'10. Valor do Crédito Disponível, Descontado da Contribuição Apurada no Período',;
	'',;
	nCrdValPis - nSldValPis,;
	nCrdValCof - nSldValCof,;
	nCrdCalPis - nSldCalPis,;
	nCrdCalCof - nSldCalCof;
})
aAdd(aExcel, {;
	'11. Saldo de Crédito a Utilizar em Períodos Futuros',;
	'',;
	nSldValPis,;
	nSldValCof,;
	nSldCalPis,;
	nSldCalCof;
})

aAdd(aExcel, {''})
aAdd(aExcel, {'Consolidação da Contribuição para o PIS/PASEP e COFINS do Período'})
aAdd(aExcel, {'Descrição','Relação','Valor PIS','Valor COFINS','Calculado PIS','Calculado COFINS'})
aAdd(aExcel, {;
	'Valor Total da Contribuição Antes dos Ajustes',;
	'CST 01',;
	_aApura[APU_CON][APU_VALPIS],;
	_aApura[APU_CON][APU_VALCOF],;
	_aApura[APU_CON][APU_CALPIS],;
	_aApura[APU_CON][APU_CALCOF];
})
aAdd(aExcel, {;
	'Valor Total dos Ajustes de Acréscimo',;
	'',;
	_aApura[APU_CON_ACR][APU_VALPIS],;
	_aApura[APU_CON_ACR][APU_VALCOF],;
	_aApura[APU_CON_ACR][APU_CALPIS],;
	_aApura[APU_CON_ACR][APU_CALCOF];
})
aAdd(aExcel, {;
	'Valor Total dos Ajustes de Redução',;
	'Estornos',;
	_aApura[APU_CON_RED][APU_VALPIS],;
	_aApura[APU_CON_RED][APU_VALCOF],;
	_aApura[APU_CON_RED][APU_CALPIS],;
	_aApura[APU_CON_RED][APU_CALCOF];
})
aAdd(aExcel, {;
	'Valor Total da Contribuição Não Cumulativa Apurada no Período',;
	'',;
	_aApura[APU_CON][APU_VALPIS] + _aApura[APU_CON_ACR][APU_VALPIS] - _aApura[APU_CON_RED][APU_VALPIS],;
	_aApura[APU_CON][APU_VALCOF] + _aApura[APU_CON_ACR][APU_VALCOF] - _aApura[APU_CON_RED][APU_VALCOF],;
	_aApura[APU_CON][APU_CALPIS] + _aApura[APU_CON_ACR][APU_CALPIS] - _aApura[APU_CON_RED][APU_CALPIS],;
	_aApura[APU_CON][APU_CALCOF] + _aApura[APU_CON_ACR][APU_CALCOF] - _aApura[APU_CON_RED][APU_CALCOF];
})
aAdd(aExcel, {;
	'Valor do Crédito Descontado, Apurado no Próprio Período da Escrituração',;
	'',;
	nCrdValPis - nSldValPis,;
	nCrdValCof - nSldValCof,;
	nCrdCalPis - nSldCalPis,;
	nCrdCalCof - nSldCalCof;
})
aAdd(aExcel, {;
	'Valor do Crédito Descontado, Apurado em Período de Apuração Anterior',;
	'',;
	nCrdPisAnt,;
	nCrdCofAnt,;
	nCrdPisAnt,;
	nCrdCofAnt;
})
aAdd(aExcel, {;
	'Valor Total da Contribuição Não Cumulativa Devida (a Recolher/Pagar)',;
	'',;
	(_aApura[APU_CON][APU_VALPIS] + _aApura[APU_CON_ACR][APU_VALPIS] - _aApura[APU_CON_RED][APU_VALPIS]) - (nCrdValPis - nSldValPis) - nCrdPisAnt,;
	(_aApura[APU_CON][APU_VALCOF] + _aApura[APU_CON_ACR][APU_VALCOF] - _aApura[APU_CON_RED][APU_VALCOF]) - (nCrdValCof - nSldValCof) - nCrdCofAnt,;
	(_aApura[APU_CON][APU_CALPIS] + _aApura[APU_CON_ACR][APU_CALPIS] - _aApura[APU_CON_RED][APU_CALPIS]) - (nCrdCalPis - nSldCalPis) - nCrdPisAnt,;
	(_aApura[APU_CON][APU_CALCOF] + _aApura[APU_CON_ACR][APU_CALCOF] - _aApura[APU_CON_RED][APU_CALCOF]) - (nCrdCalCof - nSldCalCof) - nCrdCofAnt;
})
aAdd(aExcel, {''})

//zerando valores
For nI := APU_CON to APU_ULTIMO_01 - 1
	For nJ := APU_VALPIS to APU_ULTIMO_02 - 1
		_aApura[nI][nJ] := 0
	Next nJ
Next nI

Return Nil

/* -------------- */

Static Function CalcApu(nSld, nAnt, nTipo)

Local nTot
Local nSld

nTot := _aApura[APU_CON][nTipo] + _aApura[APU_CON_ACR][nTipo] - _aApura[APU_CON_RED][nTipo]
nSld := _aApura[APU_CRE][nTipo] + _aApura[APU_CRE_ACR][nTipo] - _aApura[APU_CRE_RED][nTipo]
If nAnt < nTot
	//contribuição maior, utiliza todo o crédito anterior
	nTot := nTot - nAnt
	If nSld >= nTot
		//contribuição menor ou igual, utiliza somente o necessário do crédito do período (total da contribuição)
		nSld := nSld - nTot
	Else
		nSld := 0
	EndIf
Else
	nAnt := nTot
EndIf

Return Nil

/* -------------- */

//Funções copiadas do fonte SPEDPISCOF.prw
Static Function PCCredAnt(cPer,aReg1100,aReg1500,nTotContrb,cTributo)

Local nCont			:= 0
Local aOrdCodCre	:= {}
Local cOrdCodCre	:= ""

aOrdCodCre:= MontOrdCre()

IF cTributo == "PIS"

	//Primeiro irá buscar os créditos conforme a ordem informada pelo cliente.
	For nCont:=1 to len(aOrdCodCre)
		//Chama CredAntPis para processar registro 1100 dos valores de créditos de períodos anteriores na ordem informado pelo cliente
		CredAntPis(cPer,@aReg1100,@nTotContrb,.F.,aOrdCodCre[nCont])		
	
		//Guardo os códigos de créditos processados para poder excluir posteriormente
		cOrdCodCre += aOrdCodCre[nCont]+ "/"
	Next nCont    
	
	//Chama CredAntPis para processar os valores de créditos de períodos anteriores dos demais códigos que não foram informados pelo cliente.
	//Se algum códigos não foi informado então não irá se creditar de valores atrelados a estes códigos.
	CredAntPis(cPer,@aReg1100,@nTotContrb,.F.,"",cOrdCodCre)
ElseIF cTributo == "COF"
	//Primeiro irá buscar os créditos conforme a ordem informada pelo cliente.
	For nCont:=1 to len(aOrdCodCre)
		//Chama CredAntPis para processar registro 1100 dos valores de créditos de períodos anteriores na ordem informado pelo cliente
		CredAntCof(cPer,@aReg1500,@nTotContrb,.F.,aOrdCodCre[nCont])		
	
		//Guardo os códigos de créditos processados para poder excluir posteriormente
		cOrdCodCre += aOrdCodCre[nCont]+ "/"
	Next nCont    
	
	//Chama CredAntPis para processar os valores de créditos de períodos anteriores dos demais códigos que não foram informados pelo cliente.
	//Se algum códigos não foi informado então não irá se creditar de valores atrelados a estes códigos.
	CredAntCof(cPer,@aReg1500,@nTotContrb,.F.,"",cOrdCodCre)		
EndIF

Return

Static Function CredAntPis(cPer,aReg1100,nTotContrb,lMesAtual,cCodCred,cCodCredEx)

Local cAliasCCY :="CCY"
Local dPriDia	:=firstday(sTod(cPer))-1	
Local cPerAnt := cvaltochar(strzero(month(dPriDia),2)) + cvaltochar(year(dPriDia )) 
Local cPerAtu := cvaltochar(strzero(month(sTod(cPer) ) ,2)) + cvaltochar(year(sTod(cPer) )) 
Local cCnpj   := ""
Local cOriCre := ""
Local nCredUti		:=0  //Credito Utilizado
Local lRefer    := CCY->(FieldPos("CCY_ANO")) > 0 .And. CCY->(FieldPos("CCY_MES")) > 0  .And. CCY->(FieldPos("CCY_UTIANT")) > 0
Local cRefer    := ""
Local cOrderBy  := "%ORDER BY CCY.CCY_PERIOD, CCY.CCY_COD%"
Local nUtil		:= 0
Local lCG4		:= aIndics[23] .And. CG4->(FieldPos("CG4_COD"))>0 .And. CG4->(FieldPos("CG4_PER"))>0 .And. CCY->(FieldPos("CCY_REANTE")) > 0  .And. CCY->(FieldPos("CCY_COANTE")) > 0
Local nRessar	:= 0
Local nComp		:= 0
Local nRessaAnt	:= 0
Local nCompAnt	:= 0
Local cMV_BCCR	:= SuperGetMv("MV_CODTPCR",,"201#202#203#204#208#301#302#303#304#307#308")
Local cMV_BCCC	:= SuperGetMv("MV_CODTPCC",,"301#302#303#304#308")
Local lCNPJ    := CCY->(FieldPos("CCY_CNPJ")) > 0
Local nVlCrd1100 := 0

DEFAULT lMesAtual :=.F.  
DEFAULT cCodCred  :=""
DEFAULT cCodCredEx := ""
//Se houver algum código em cCodCredEx, são códigos que não irão se apropriar do crédito, somente irá gerar 1100 e transportar seu valor para próximo mês.

If lMesAtual
	cPerAnt:=cPerAtu
EndIf

DbSelectArea (cAliasCCY)

If lRefer
	(cAliasCCY)->(DbSetOrder (3))
Else
	(cAliasCCY)->(DbSetOrder (1))
EndIf

#IFDEF TOP
    If (TcSrvType ()<>"AS/400")
    	cAliasCCY	:=	GetNextAlias()

    	cFiltro := "%"
       	cCampos := "%"
       	If lMesAtual .And. CCY->(FieldPos("CCY_LEXTEM")) > 0
    		cFiltro += "CCY.CCY_LEXTEM = 0 AND"
	    	cCampos += ", CCY.CCY_LEXTEM"
    	EndIf
   		//Se houver código em cCodCred então deverá trazer somente os valores de créditos deste código, obedecendo a ordem definida pelo cliente. 
   		If Len(cCodCred) > 0
    		cFiltro += "CCY.CCY_COD = '"  +cCodCred+  "' AND "  		
   		EndIF

        If lRefer
        	cCampos += ", CCY.CCY_UTIANT, CCY.CCY_ANO, CCY.CCY_MES "
        	cOrderBy  := "%ORDER BY CCY.CCY_PERIOD, CCY.CCY_ANO, CCY.CCY_MES , CCY.CCY_COD%"
		EndIf
		IF lCNPJ
        	cCampos += ", CCY.CCY_CNPJ, CCY.CCY_ORICRE"		
		EnDIF
		If lCG4 //Valores de ressarcimento e compensação
        	cCampos += ", CCY.CCY_REANTE, CCY.CCY_COANTE, CCY.CCY_RESSA ,CCY.CCY_COMP "
		EndIf
		cFiltro += "%"    		
		cCampos += "%"

    	BeginSql Alias cAliasCCY

			SELECT
				CCY.CCY_PERIOD, CCY.CCY_COD, CCY.CCY_TOTCRD, CCY.CCY_CREDUT, CCY.CCY_CRDISP, CCY.CCY_LEXTEM
				%Exp:cCampos%
			FROM
				%Table:CCY% CCY
			WHERE
				CCY.CCY_FILIAL=%xFilial:CCY% AND
				CCY.CCY_PERIOD  = %Exp:cPerAnt% AND
				CCY.CCY_CRDISP > 0 AND
				%Exp:cFiltro%
				CCY.%NotDel%

			%Exp:cOrderBy%
			
		EndSql
	Else                
#ENDIF
	    cIndex	:= CriaTrab(NIL,.F.)                   
	    cFiltro	:= 'CCY_FILIAL=="'+xFilial ("CCY")+'".And.'
	   	cFiltro += 'CCY_CRDISP > 0 .AND. CCY_PERIOD =="'+ cPerAnt + '"'
   	   	If lMesAtual .And. CCY->(FieldPos("CCY_LEXTEM")) > 0
		   	cFiltro += ' .AND. CCY_LEXTEM = 0'
		EndIf
		If Len(cCodCred) > 0
		   	cFiltro += ' .AND. CCY_COD == "' +cCodCred + '"'
    	EndIF
      	    IndRegua (cAliasCCY, cIndex, CCY->(IndexKey ()),, cFiltro)
      	    nIndex := RetIndex(cAliasCCY)
                                                             
		#IFNDEF TOP
			DbSetIndex (cIndex+OrdBagExt ())
		#ENDIF

		DbSelectArea (cAliasCCY)
	    DbSetOrder (nIndex+1)
#IFDEF TOP
	Endif
#ENDIF

DbSelectArea (cAliasCCY)
(cAliasCCY)->(DbGoTop ())
ProcRegua ((cAliasCCY)->(RecCount ()))
Do While !(cAliasCCY)->(Eof ())
    IF !(cAliasCCY)->CCY_COD $ cCodCredEx
	    If lRefer
	        cRefer 	:= (cAliasCCY)->CCY_MES + (cAliasCCY)->CCY_ANO
	        nUtil	:= (cAliasCCY)->CCY_UTIANT
	    Else
	      	cRefer 	:= cPerAnt
	      	nUtil	:= (cAliasCCY)->CCY_CREDUT
	    EndIf
	    If lCG4 .And. !lMesAtual
	    	If CG4->(MsSeek(xFilial("CG4")+"0"+cPerAtu+cRefer+(cAliasCCY)->CCY_COD ))
	    		If ( CG4->CG4_VALORR + CG4->CG4_VALORC ) <= (cAliasCCY)->CCY_CRDISP
		    		If Alltrim((cAliasCCY)->CCY_COD)$cMV_BCCR
		    	   		nRessar := CG4->CG4_VALORR
		    	   	EndIf
		    	   	If Alltrim((cAliasCCY)->CCY_COD)$cMV_BCCC
		    	   		nComp	:= CG4->CG4_VALORC
		    	   	EndIf
		    	EndIf
	    	EndIf
	        nRessaAnt	:= (cAliasCCY)->CCY_REANTE + (cAliasCCY)->CCY_RESSA
	        nCompAnt	:= (cAliasCCY)->CCY_COANTE + (cAliasCCY)->CCY_COMP
	    EndIf
	    IF lCNPJ
			cCnpj	:=(cAliasCCY)->CCY_CNPJ	
			cOriCre :=(cAliasCCY)->CCY_ORICRE
			IF Empty(cOriCre)
				cOriCre:= "01"			
			EndIF
	    EndIF
	    
	   // Tratamento para que o registro 1100 seja gerado com os valores dos creditos extemporaneos.
	   If (cAliasCCY)->CCY_TOTCRD > 0
	   		nVlCrd1100 := (cAliasCCY)->CCY_TOTCRD
	  	Else
	  		nVlCrd1100 := (cAliasCCY)->CCY_LEXTEM
	  	EndIf 
	  	
		Reg1100(@aReg1100,cPerAnt,cCnpj,(cAliasCCY)->CCY_COD,nVlCrd1100,nUtil,@Iif(lMesAtual,0,nTotContrb),@nCredUti,cPerAtu,lMesAtual,0,0,cRefer,nRessar,nComp,nRessaAnt,nCompAnt,cOriCre)
	EndIF
	(cAliasCCY)->(DbSkip ())
	nRessar		:= 0
	nComp		:= 0
	nRessaAnt	:= 0
	nCompAnt	:= 0
EndDo

#IFDEF TOP
	If (TcSrvType ()<>"AS/400")
		DbSelectArea (cAliasCCY)
		(cAliasCCY)->(DbCloseArea ())
	Else
#ENDIF
		RetIndex("CCY")
#IFDEF TOP
	EndIf
#ENDIF

Return

Static Function CredAntCof(cPer,aReg1500,nTotContrb, lMesAtual,cCodCred,cCodCredEx)

Local cAliasCCW :="CCW"
Local dPriDia	:=firstday(sTod(cPer))-1	
Local cPerAnt := cvaltochar(strzero(month(dPriDia),2)) + cvaltochar(year(dPriDia)) 
Local cPerAtu := cvaltochar(strzero(month(sTod(cPer) ) ,2)) + cvaltochar(year(sTod(cPer) )) 
Local cCnpj   := ""
Local cOriCre := ""
Local nCredUti		:=0  //Credito Utilizado
Local lRefer    := CCW->(FieldPos("CCW_ANO")) > 0 .And. CCW->(FieldPos("CCW_MES")) > 0 .And. CCW->(FieldPos("CCW_UTIANT")) > 0
Local cRefer    := ""
Local cOrderBy  := "%ORDER BY CCW.CCW_PERIOD, CCW.CCW_COD%"
Local nUtil		:= 0
Local lCG4		:= aIndics[23] .And. CG4->(FieldPos("CG4_COD"))>0 .And. CG4->(FieldPos("CG4_PER"))>0 .And. CCW->(FieldPos("CCW_REANTE")) > 0  .And. CCW->(FieldPos("CCW_COANTE")) > 0
Local nRessar	:= 0
Local nComp		:= 0
Local nRessaAnt	:= 0
Local nCompAnt	:= 0
Local cMV_BCCR	:= SuperGetMv("MV_CODTPCR",,"201#202#203#204#208#301#302#303#304#307#308")
Local cMV_BCCC	:= SuperGetMv("MV_CODTPCC",,"301#302#303#304#308")
Local lCNPJ    := CCW->(FieldPos("CCW_CNPJ")) > 0
Local nVlCrd1500 := 0

Default lMesAtual:= .F.
DEFAULT cCodCred  	:=""
DEFAULT cCodCredEx 	:= ""

If lMesAtual
	cPerAnt :=cPerAtu
EndIF

DbSelectArea (cAliasCCW)

If lRefer
	(cAliasCCW)->(DbSetOrder (3))
Else
	(cAliasCCW)->(DbSetOrder (1))
EndIf

#IFDEF TOP
    If (TcSrvType ()<>"AS/400")
    	cAliasCCW	:=	GetNextAlias()
    	
	    cFiltro := "%"		
    	cCampos := "%"
       	If lMesAtual .And. CCW->(FieldPos("CCW_LEXTEM")) > 0
    		cFiltro += "CCW.CCW_LEXTEM = 0 AND"
	    	cCampos += ", CCW.CCW_LEXTEM" 
    	EndIf
   		//Se houver código em cCodCred então deverá trazer somente os valores de créditos deste código, obedecendo a ordem definida pelo cliente. 
   		If Len(cCodCred) > 0
    		cFiltro += "CCW.CCW_COD = '"  +cCodCred+  "' AND "  		
   		EndIF
		If lRefer
        	cCampos += ", CCW.CCW_UTIANT, CCW.CCW_ANO, CCW.CCW_MES "
        	// Faço da forma abaixo transformar MMAAAA em AAAAMM para que a ordem fique correta. Exemplo: 11/2012,12/2011,01/2012,02/2012
        	cOrderBy  := "%ORDER BY CCW.CCW_PERIOD, CCW.CCW_ANO, CCW.CCW_MES , CCW.CCW_COD%"
		EndIf
		IF lCNPJ
        	cCampos += ", CCW.CCW_CNPJ, CCW.CCW_ORICRE"		
		EnDIF
		If lCG4 //Valores de ressarcimento e compensação
        	cCampos += ", CCW.CCW_REANTE, CCW.CCW_COANTE, CCW.CCW_RESSA ,CCW.CCW_COMP "
		EndIf
		
		cFiltro += "%"		
    	cCampos += "%"
    	
    	BeginSql Alias cAliasCCW
			
			SELECT				
				CCW.CCW_PERIOD, CCW.CCW_COD, CCW.CCW_TOTCRD, CCW.CCW_CREDUT, CCW.CCW_CRDISP, CCW_LEXTEM 
				%Exp:cCampos%
			FROM 
				%Table:CCW% CCW 
			WHERE 					
				CCW.CCW_FILIAL=%xFilial:CCW% AND 				
				CCW.CCW_PERIOD  = %Exp:cPerAnt% AND	
				CCW.CCW_CRDISP > 0 AND		
				%Exp:cFiltro%
				CCW.%NotDel%			

			%Exp:cOrderBy%
			
		EndSql
	Else
#ENDIF
	    cIndex	:= CriaTrab(NIL,.F.)
	    cFiltro	:= 'CCW_FILIAL=="'+xFilial ("CCW")+'".And.'
	   	cFiltro += 'CCW_CRDISP > 0 .AND. CCW_PERIOD =="'+ cPerAnt + '"' 
	   	If lMesAtual .And. CCW->(FieldPos("CCW_LEXTEM")) > 0
		   	cFiltro += ' .AND. CCW_LEXTEM = 0'
		EndIf
   		If Len(cCodCred) > 0
		   	cFiltro += ' .AND. CCW_COD == "' +cCodCred + '"'
    	EndIF
	    IndRegua (cAliasCCW, cIndex, CCW->(IndexKey ()),, cFiltro)
	    nIndex := RetIndex(cAliasCCW)

		#IFNDEF TOP
			DbSetIndex (cIndex+OrdBagExt ())
		#ENDIF
		
		DbSelectArea (cAliasCCW)
	    DbSetOrder (nIndex+1)
#IFDEF TOP
	Endif
#ENDIF

DbSelectArea (cAliasCCW)
(cAliasCCW)->(DbGoTop ())
ProcRegua ((cAliasCCW)->(RecCount ()))
Do While !(cAliasCCW)->(Eof ())
    IF !(cAliasCCW)->CCW_COD $ cCodCredEx
	    If lRefer
	        cRefer 	:= (cAliasCCW)->CCW_MES + (cAliasCCW)->CCW_ANO
	        nUtil	:= (cAliasCCW)->CCW_UTIANT
	    Else
	      	cRefer := cPerAnt
	        nUtil	:= (cAliasCCW)->CCW_CREDUT
	    EndIf
	    If lCG4 .And. !lMesAtual
	    	If CG4->(MsSeek(xFilial("CG4")+"1"+cPerAtu+cRefer+(cAliasCCW)->CCW_COD ))
	    		If ( CG4->CG4_VALORR + CG4->CG4_VALORC ) <= (cAliasCCW)->CCW_CRDISP
		    		If Alltrim((cAliasCCW)->CCW_COD)$cMV_BCCR
		    	   		nRessar := CG4->CG4_VALORR
		    	   	EndIf
		    	   	If Alltrim((cAliasCCW)->CCW_COD)$cMV_BCCC
		    	   		nComp	:= CG4->CG4_VALORC
		    	   	EndIf
		    	EndIf
	    	EndIf
	        nRessaAnt	:= (cAliasCCW)->CCW_REANTE + (cAliasCCW)->CCW_RESSA
	        nCompAnt	:= (cAliasCCW)->CCW_COANTE + (cAliasCCW)->CCW_COMP
	    EndIf

	    IF lCNPJ
			cCnpj	:=(cAliasCCW)->CCW_CNPJ	
			cOriCre :=(cAliasCCW)->CCW_ORICRE
			IF Empty(cOriCre)
				cOriCre:= "01"			
			EndIF
	    EndIF
	    
	     
	   // Tratamento para que o registro 1500 seja gerado com os valores dos creditos extemporaneos.
	   If (cAliasCCW)->CCW_TOTCRD > 0
	   		nVlCrd1500 := (cAliasCCW)->CCW_TOTCRD
	  	Else
	  		nVlCrd1500 := (cAliasCCW)->CCW_LEXTEM
	  	EndIf  
	    
		Reg1500(@aReg1500,cPerAnt,cCnpj,(cAliasCCW)->CCW_COD,nVlCrd1500,nUtil,@Iif(lMesAtual,0,nTotContrb),@nCredUti,cPerAtu,lMesAtual,0,0,cRefer,nRessar,nComp,nRessaAnt,nCompAnt,cOriCre)
	EndIF
	(cAliasCCW)->(DbSkip ())			
	nRessar		:= 0
	nComp		:= 0
	nRessaAnt	:= 0
	nCompAnt	:= 0
EndDo


#IFDEF TOP
	If (TcSrvType ()<>"AS/400")
		DbSelectArea (cAliasCCW)
		(cAliasCCW)->(DbCloseArea ())
	Else
#ENDIF
		RetIndex("CCW")			
#IFDEF TOP
	EndIf
#ENDIF 

Return

Static Function Reg1100(aReg1100,cPer,cCnpj,cCodCred,nValCred,nValDesc,nTotContrb,nCredUti,cPerAtu,lMesAtual,nCredExt,nPosExt,cRefer,nRessar,nComp,nRessaAnt,nCompAnt,cOriCre)

Local nPos			:= 0
Local nPos1100  	:= 0
Local nTotCpo8		:= 0
Local nTotCpo12		:= 0
Local nTotCpo13		:= 0
Local nTotCpo18		:= 0
Local cMV_BCCR	:= SuperGetMv("MV_CODTPCR",,"201#202#203#204#208#301#302#303#304#307#308")
Local cMV_BCCC	:= SuperGetMv("MV_CODTPCC",,"301#302#303#304#308")
Local nCpo14		:= 0
Local nCpo15		:= 0
Local nCrdMesAtu	:= 0
Local nCrdMesAnt	:= 0

DEFAULT lMesAtual	:= .F.
DEFAULT nValCred	:= 0
DEFAULT nCredExt	:= 0
DEFAULT nPosExt		:= 0
DEFAULT cRefer		:= ""
DEFAULT nRessar		:= 0
DEFAULT nComp		:= 0
DEFAULT nRessaAnt	:= 0
DEFAULT nCompAnt	:= 0
DEFAULT cOriCre		:= "01"

If Empty(cRefer)
   cRefer := cPer
EndIf

If lMesAtual
	nCrdMesAtu	:= nValDesc
Else
	nCrdMesAnt	:= nValDesc
EndIF   


If Len(Trim(cOriCre)) == 0
   cOriCre		:= "01"   
EndIf


If nValCred > 0 .Or. nCredExt > 0
	nPos1100 := aScan (aReg1100, {|aX| aX[2]==cRefer .AND. ax[3] == cOriCre  .AND. ax[4] == cCnpj .AND. ax[5] == cCodCred})
	nPosExt := nPos1100
	If nPos1100 ==0 
		aAdd(aReg1100, {})
		nPos := Len(aReg1100)
		nPosExt := nPos
   		aAdd (aReg1100[nPos], "1100")						   	//01 - REG
		aAdd (aReg1100[nPos], cRefer)				   				//02 - PER_APU_CRED
		aAdd (aReg1100[nPos], cOriCre)						   		//03 - ORIG_CRED
		aAdd (aReg1100[nPos], cCnpj)						   	//04 - CNPJ_SUC
		aAdd (aReg1100[nPos], cCodCred)						   	//05 - COD_CRED
		aAdd (aReg1100[nPos], nValCred)					   		//06 - VL_CRED_APU
		aAdd (aReg1100[nPos], nCredExt)						   	//07 - VL_CRED_EXT_APU
		nTotCpo8 :=nValCred+nCredExt
		aAdd (aReg1100[nPos], nTotCpo8)					   		//08 - VL_TOT_CRED_APU
		aAdd (aReg1100[nPos], nCrdMesAnt)					   		//09 - VL_CRED_DESC_PA_ANT
		aAdd (aReg1100[nPos], Iif(cCodCred$cMV_BCCR,nRessaAnt,""))		//10 - VL_CRED_PER_PA_ANT
		aAdd (aReg1100[nPos], Iif(cCodCred$cMV_BCCC,nCompAnt,""))		//11 - VL_CRED_DCOMP_PA_ANT
		nTotCpo12:= nTotCpo8 - nCrdMesAnt - nRessaAnt - nCompAnt
		aAdd (aReg1100[nPos], nTotCpo12)				   		//12 - SD_CRED_DISP_EFD		
		
		If nTotContrb > 0 .AND. !lMesAtual		
			//If nCredUti < nTotContrb			
				If  nTotCpo12   <= nTotContrb // Total de credito do mes anterior for menor que a contribuição deste mes, utiliza o credito
					nTotCpo13 :=nTotCpo12	 //Utiliza todo o credito				
					nCredUti += nTotCpo13 
					nTotContrb -= nTotCpo13
				Else
					nTotCpo13 := nTotCpo12 - nTotContrb						
					nTotCpo13 := nTotCpo12 - nTotCpo13
					nCredUti += nTotCpo13 
					nTotContrb := 0
				EndIf                    
  			//EndIf
			//nCredUti += nTotCpo13 
		ElseIF lMesAtual
			nTotCpo13 := nCrdMesAtu		
		EndIF				

		aAdd (aReg1100[nPos], nTotCpo13)						 //13 - VL_CRED_DESC_EFD
		nTotCpo18 := nTotCpo12 - nTotCpo13 
		
		If (nRessar+nComp) <= nTotCpo18
			nTotCpo18 -= (nRessar+nComp)
			nCpo14		:= nRessar
			nCpo15		:= nComp
		Else
			nCpo14		:= 0
			nCpo15		:= 0
		EndIf
		
		aAdd (aReg1100[nPos], nCpo14)					   		//14 - VL_CRED_PER_EFD
		aAdd (aReg1100[nPos], nCpo15)					   		//15 - VL_CRED_DCOMP_EFD
		aAdd (aReg1100[nPos], 0)						   		//16 - VL_CRED_TRANS
		aAdd (aReg1100[nPos], 0)						   		//17 - VL_CRED_OUT
		aAdd (aReg1100[nPos], nTotCpo18)						//18 - SLD_CRED_FIM

//Removido Thieres Tembra. Não há necessidade de gerar Crédito Futuro pois não está gerando o arquivo
//		If nTotCpo18 > 0 .AND. !lMesAtual
//			CredFutPIS(cPerAtu,cCodCred, nValCred, nTotCpo13,nTotCpo18,nCredExt,cRefer,nValDesc,nCpo14,nCpo15,nRessaAnt,nCompAnt,aReg1100[nPos][3],aReg1100[nPos][4])
//		EndIF
	Else
	    If !lMesAtual
			aReg1100[nPos1100][6]	+= nValCred				   		//06 - VL_CRED_APU
			aReg1100[nPos1100][7]	+= nCredExt					   	//07 - VL_CRED_EXT_APU
			nTotCpo8 :=nValCred+nCredExt
			aReg1100[nPos1100][8]	+= nTotCpo8				   		//08 - VL_TOT_CRED_APU
			aReg1100[nPos1100][9]	+= nCrdMesAnt				   		//09 - VL_CRED_DESC_PA_ANT
			aReg1100[nPos1100][10]	+= Iif(cCodCred$cMV_BCCR,nRessaAnt,"")		//10 - VL_CRED_PER_PA_ANT
			aReg1100[nPos1100][11]	+= Iif(cCodCred$cMV_BCCC,nCompAnt,"")		//11 - VL_CRED_DCOMP_PA_ANT
			nTotCpo12:= nTotCpo8 - nCrdMesAnt - nRessaAnt - nCompAnt
			aReg1100[nPos1100][12]	+= nTotCpo12			   		//12 - SD_CRED_DISP_EFD
			If nTotContrb > 0 .AND. !lMesAtual		
//				If nCredUti < nTotContrb			
					If  nTotCpo12 <= nTotContrb // Total de credito do mes anterior for menor que a contribuição deste mes, utiliza o credito
						nTotCpo13 :=nTotCpo12	 //Utiliza todo o credito				
						nCredUti += nTotCpo13  
						nTotContrb -= nTotCpo13
					Else
						nTotCpo13 := nTotCpo12 - nTotContrb						
						nTotCpo13 := nTotCpo12 - nTotCpo13
						nCredUti += nTotCpo13 
						nTotContrb := 0
					EndIf                    
//				EndIF
			ElseIF lMesAtual
				nTotCpo13 := nCrdMesAtu
			EndIF		
			aReg1100[nPos1100][13] += nTotCpo13						//13 - VL_CRED_DESC_EFD
			nTotCpo18 := nTotCpo12 - nTotCpo13  
			
			If (nRessar+nComp) <= nTotCpo18
				nTotCpo18 -= (nRessar+nComp)
				nCpo14		:= nRessar
				nCpo15		:= nComp
			Else
				nCpo14		:= 0
				nCpo15		:= 0
			EndIf
			
			
			aReg1100[nPos1100][14] += nCpo14				   		//14 - VL_CRED_PER_EFD
			aReg1100[nPos1100][15] += nCpo15				   		//15 - VL_CRED_DCOMP_EFD
			aReg1100[nPos1100][16] += 0						   		//16 - VL_CRED_TRANS
			aReg1100[nPos1100][17] += 0						   		//17 - VL_CRED_OUT
			
			aReg1100[nPos1100][18] += nTotCpo18	
//Removido Thieres Tembra. Não há necessidade de gerar Crédito Futuro pois não está gerando o arquivo
//			If nTotCpo18 > 0 .AND. !lMesAtual
//				CredFutPIS(cPerAtu,cCodCred,nValCred,aReg1100[nPos1100][13],aReg1100[nPos1100][18],aReg1100[nPos1100][7],cRefer,nValDesc,nCpo14,nCpo15,nRessaAnt,nCompAnt,aReg1100[nPos1100][3],aReg1100[nPos1100][4])
//			EndIF
		EndIf	
	EndIF

EndIF	

Return()

Static Function Reg1500(aReg1500,cPer,cCnpj,cCodCred,nValCred,nValDesc,nTotContrb,nCredUti,cPerAtu,lMesAtual,nCredExt,nPosExt,cRefer,nRessar,nComp,nRessaAnt,nCompAnt,cOriCre)

Local nPos			:= 0
Local nPos1500  	:= 0
Local nTotCpo8		:= 0
Local nTotCpo12		:= 0
Local nTotCpo13		:= 0
Local nTotCpo18		:= 0
Local cMV_BCCR	:= SuperGetMv("MV_CODTPCR",,"201#202#203#204#208#301#302#303#304#307#308")
Local cMV_BCCC	:= SuperGetMv("MV_CODTPCC",,"301#302#303#304#308")
Local nCpo14		:= 0
Local nCpo15		:= 0
Local nCrdMesAtu	:= 0
Local nCrdMesAnt	:= 0

DEFAULT lMesAtual	:= .F.
DEFAULT nValCred	:= 0
DEFAULT nCredExt	:= 0
DEFAULT nPosExt		:= 0
DEFAULT cRefer		:= ""
DEFAULT nRessar		:= 0
DEFAULT nComp		:= 0
DEFAULT nRessaAnt	:= 0
DEFAULT nCompAnt	:= 0
DEFAULT cOriCre		:= "01"

If Empty(cRefer)
   cRefer := cPer
EndIf

If lMesAtual
	nCrdMesAtu	:= nValDesc
Else
	nCrdMesAnt	:= nValDesc
EndIF

If nValCred > 0 .Or. nCredExt > 0
	nPos1500 := aScan (aReg1500, {|aX| aX[2]==cRefer .AND. ax[3] == cOriCre .AND. ax[4] == cCnpj .AND. ax[5] == cCodCred})
	nPosExt	 := nPos1500
	IF nPos1500 ==0
		aAdd(aReg1500, {})
		nPos := Len(aReg1500)
		nPosExt := nPos
		aAdd (aReg1500[nPos], "1500")						   	//01 - REG
		aAdd (aReg1500[nPos], cRefer)			   				//02 - PER_APU_CRED
		aAdd (aReg1500[nPos], cOriCre)						    //03 - ORIG_CRED
		aAdd (aReg1500[nPos], cCnpj)						   	//04 - CNPJ_SUC
		aAdd (aReg1500[nPos], cCodCred)						   	//05 - COD_CRED
		aAdd (aReg1500[nPos], nValCred)					   		//06 - VL_CRED_APU
		aAdd (aReg1500[nPos], nCredExt)						   	//07 - VL_CRED_EXT_APU
		nTotCpo8 :=nValCred+nCredExt
		aAdd (aReg1500[nPos], nTotCpo8)					   		//08 - VL_TOT_CRED_APU
		aAdd (aReg1500[nPos], nCrdMesAnt)					   		//09 - VL_CRED_DESC_PA_ANT
		aAdd (aReg1500[nPos], Iif(cCodCred$cMV_BCCR,nRessaAnt,""))	//10 - VL_CRED_PER_PA_ANT
		aAdd (aReg1500[nPos], Iif(cCodCred$cMV_BCCC,nCompAnt,""))	//11 - VL_CRED_DCOMP_PA_ANT
		nTotCpo12:= nTotCpo8 - nCrdMesAnt - nRessaAnt - nCompAnt
		aAdd (aReg1500[nPos], nTotCpo12)				   		//12 - SD_CRED_DISP_EFD
		
		If nTotContrb > 0  .AND. !lMesAtual		
//			IF nCredUti < nTotContrb			
				If  nTotCpo12  <= nTotContrb // Total de credito do mes anterior for menor que a contribuição deste mes, utiliza o credito
					nTotCpo13 :=nTotCpo12	 //Utiliza todo o credito				
					nCredUti += nTotCpo13  
					nTotContrb -= nTotCpo13
				Else
					nTotCpo13 := nTotCpo12 - nTotContrb						
					nTotCpo13 := nTotCpo12 - nTotCpo13
					nCredUti += nTotCpo13 
					nTotContrb := 0
				EndIf                    
//			EndIF		
		ElseIF lMesAtual
			nTotCpo13 :=nCrdMesAtu		
		EndIF		
		
		aAdd (aReg1500[nPos], nTotCpo13)						 //13 - VL_CRED_DESC_EFD
        nTotCpo18 := nTotCpo12 - nTotCpo13

		If (nRessar+nComp) <= nTotCpo18
			nTotCpo18 -= (nRessar+nComp)
			nCpo14		:= nRessar
			nCpo15		:= nComp
		Else
			nCpo14		:= 0
			nCpo15		:= 0
		EndIf
		
		aAdd (aReg1500[nPos], nCpo14)						   		//14 - VL_CRED_PER_EFD
		aAdd (aReg1500[nPos], nCpo15)						   		//15 - VL_CRED_DCOMP_EFD
		aAdd (aReg1500[nPos], 0)						   		//16 - VL_CRED_TRANS
		aAdd (aReg1500[nPos], 0)						   		//17 - VL_CRED_OUT
		 
		aAdd (aReg1500[nPos], nTotCpo18)						//18 - SLD_CRED_FIM	
//Removido Thieres Tembra. Não há necessidade de gerar Crédito Futuro pois não está gerando o arquivo
//		If nTotCpo18 > 0 .AND. !lMesAtual
//			CredFutCof(cPerAtu,cCodCred, nValCred, nTotCpo13,nTotCpo18,nCredExt,cRefer,nValDesc,nCpo14,nCpo15,nRessaAnt,nCompAnt,aReg1500[nPos][3],aReg1500[nPos][4])
//		EndIF
	Else
		If !lMesAtual
			aReg1500[nPos1500][6]	+= nValCred				   		//06 - VL_CRED_APU
			aReg1500[nPos1500][7]	+= nCredExt					   	//07 - VL_CRED_EXT_APU
			nTotCpo8 :=nValCred+nCredExt
			aReg1500[nPos1500][8]	+= nTotCpo8				   		//08 - VL_TOT_CRED_APU
			aReg1500[nPos1500][9]	+= nCrdMesAnt				   		//09 - VL_CRED_DESC_PA_ANT
			aReg1500[nPos1500][10]	+= Iif(cCodCred$cMV_BCCR,nRessaAnt,"")	//10 - VL_CRED_PER_PA_ANT
			aReg1500[nPos1500][11]	+= Iif(cCodCred$cMV_BCCC,nCompAnt,"")	//11 - VL_CRED_DCOMP_PA_ANT
			nTotCpo12:= nTotCpo8 - nCrdMesAnt - nRessaAnt - nCompAnt
			aReg1500[nPos1500][12]	+= nTotCpo12			   		//12 - SD_CRED_DISP_EFD
			If nTotContrb > 0 .AND. !lMesAtual		
//				If nCredUti < nTotContrb			
					If  nTotCpo12  <= nTotContrb // Total de credito do mes anterior for menor que a contribuição deste mes, utiliza o credito
						nTotCpo13 := nTotCpo12	 //Utiliza todo o credito				
						nCredUti += nTotCpo13   
						nTotContrb -= nTotCpo13
					Else
						nTotCpo13 := nTotCpo12 - nTotContrb						
						nTotCpo13 := nTotCpo12 - nTotCpo13
						nCredUti += nTotCpo13 
						nTotContrb := 0
					EndIf                    
//				EndIF
			ElseIf lMesAtual
				nTotCpo13 :=nCrdMesAtu
			EndIF								

			aReg1500[nPos1500][13] += nTotCpo13						//13 - VL_CRED_DESC_EFD
			nTotCpo18 := nTotCpo12 - nTotCpo13  
			
			If (nRessar+nComp) <= nTotCpo18
				nTotCpo18 -= (nRessar+nComp)
				nCpo14		:= nRessar
				nCpo15		:= nComp
			Else
				nCpo14		:= 0
				nCpo15		:= 0
			EndIf
			
			aReg1500[nPos1500][14] += nCpo14				   		//14 - VL_CRED_PER_EFD
			aReg1500[nPos1500][15] += nCpo15				   		//15 - VL_CRED_DCOMP_EFD
			aReg1500[nPos1500][16] += 0						   		//16 - VL_CRED_TRANS
			aReg1500[nPos1500][17] += 0						   		//17 - VL_CRED_OUT
			
			aReg1500[nPos1500][18] += nTotCpo18	
//Removido Thieres Tembra. Não há necessidade de gerar Crédito Futuro pois não está gerando o arquivo
//			If nTotCpo18 > 0 .AND. !lMesAtual
//				CredFutCof(cPerAtu,cCodCred,nValCred,aReg1500[nPos1500][13],aReg1500[nPos1500][18],aReg1500[nPos1500][7],cRefer,nValDesc,nCpo14,nCpo15,nRessaAnt,nCompAnt,aReg1500[nPos1500][3],aReg1500[nPos1500][4])
//			EndIF
		EndIf		
	EndIF

EndIF

Return()

Static Function FGetIndics()
Local aRet := {	    AliasIndic("AIF"),;	//01 
					AliasIndic("CCW"),;	//02
					AliasIndic("CCX"),; //03
				 	AliasIndic("CCY"),; //04
				 	AliasIndic("CCZ"),; //05
				 	AliasIndic("CD3"),; //06
				 	AliasIndic("CD4"),; //07
				 	AliasIndic("CD5"),; //08
				 	AliasIndic("CD6"),; //09
				 	AliasIndic("CDG"),; //10
				 	AliasIndic("CDN"),; //11
				 	AliasIndic("CDT"),; //12
				 	AliasIndic("CE9"),; //13
				 	AliasIndic("CF2"),; //14 
				 	AliasIndic("CF3"),; //15
				 	AliasIndic("CF4"),; //16
				 	AliasIndic("CF5"),; //17
				 	AliasIndic("CF6"),; //18
				 	AliasIndic("CF7"),; //19
				 	AliasIndic("CF8"),; //20
				 	AliasIndic("CF9"),; //21
				 	AliasIndic("CG1"),; //22
				 	AliasIndic("CG4"),; //23 
				 	AliasIndic("CVB"),; //24
				 	AliasIndic("SFU"),; //25
				 	AliasIndic("SFV"),; //26
				 	AliasIndic("SFW"),; //27
				 	AliasIndic("SFX"),; //28
				 	AliasIndic("CFA"),; //29
				 	AliasIndic("CFB"),; //30
				 	AliasIndic("CD1")}	//31
Return aRet
//Fim das funções copiadas do font SPEDPISCOF.prw

/* -------------- */

Static Function CriaSX1(cPerg)

Local nTamGrp := Len(SX1->X1_GRUPO)
Local aHelpPor := {}, aHelpEng := {}, aHelpSpa := {}
Local cNome

aHelpPor := {}
aAdd(aHelpPor, 'Informe o mês para geração do        ')
aAdd(aHelpPor, 'relatório.                           ')
cNome := 'Mês'
PutSx1(PadR(cPerg,nTamGrp), '01', cNome, cNome, cNome,;
'MV_CH1', 'N', 2, 0, 0, 'G', '', '', '', '', 'MV_PAR01',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe o ano para geração do        ')
aAdd(aHelpPor, 'relatório.                           ')
cNome := 'Ano'
PutSx1(PadR(cPerg,nTamGrp), '02', cNome, cNome, cNome,;
'MV_CH2', 'N', 4, 0, 0, 'G', '', '', '', '', 'MV_PAR02',;
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
aAdd(aHelpPor, 'Informe os CSTs separados por ponto  ')
aAdd(aHelpPor, 'e vígula (;) a serem listados no     ')
aAdd(aHelpPor, 'relatório. Deixe em branco para      ')
aAdd(aHelpPor, 'considerar todos.                    ')
cNome := 'CSTs'
PutSx1(PadR(cPerg,nTamGrp), '06', cNome, cNome, cNome,;
'MV_CH6', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR06',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe a alíquota do PIS para o     ')
aAdd(aHelpPor, 'cálculo da coluna Calculado PIS.     ')
cNome := 'Aliq. PIS'
PutSx1(PadR(cPerg,nTamGrp), '07', cNome, cNome, cNome,;
'MV_CH7', 'N', 4, 2, 0, 'G', '', '', '', '', 'MV_PAR07',;
'', '', '', '1.65',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe a alíquota do COFINS para o  ')
aAdd(aHelpPor, 'cálculo da coluna Calculado COFINS.  ')
cNome := 'Aliq. COFINS'
PutSx1(PadR(cPerg,nTamGrp), '08', cNome, cNome, cNome,;
'MV_CH8', 'N', 4, 2, 0, 'G', '', '', '', '', 'MV_PAR08',;
'', '', '', '7.60',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe se deseja considerar os      ')
aAdd(aHelpPor, 'títulos financeiros no relatório. Se ')
aAdd(aHelpPor, 'esta opção estiver marcada como SIM e')
aAdd(aHelpPor, 'for encontrada alguma diferença entre')
aAdd(aHelpPor, 'o valor do PIS ou COFINS no sistema e')
aAdd(aHelpPor, 'o calculado em tempo de execução, não')
aAdd(aHelpPor, 'será possível realizar o ajuste.     ')
cNome := 'Considera títulos'
PutSx1(PadR(cPerg,nTamGrp), '09', cNome, cNome, cNome,;
'MV_CH9', 'C', 1, 0, 0, 'C', '', '', '', '', 'MV_PAR09',;
'Sim', 'Sim', 'Sim', '1',;
'Não', 'Não', 'Não',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe se deseja considerar os bens ')
aAdd(aHelpPor, 'incorporados ao ativo imobilizado    ')
aAdd(aHelpPor, 'através de aquisição.                ')
cNome := 'Considera ativo aquisição'
PutSx1(PadR(cPerg,nTamGrp), '10', cNome, cNome, cNome,;
'MV_CHA', 'C', 1, 0, 0, 'C', '', '', '', '', 'MV_PAR10',;
'Sim', 'Sim', 'Sim', '1',;
'Não', 'Não', 'Não',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe se deseja considerar os bens ')
aAdd(aHelpPor, 'incorporados ao ativo imobilizado    ')
aAdd(aHelpPor, 'através de depreciação.              ')
cNome := 'Considera ativo depreciação'
PutSx1(PadR(cPerg,nTamGrp), '11', cNome, cNome, cNome,;
'MV_CHB', 'C', 1, 0, 1, 'C', '', '', '', '', 'MV_PAR11',;
'Sim', 'Sim', 'Sim', '1',;
'Não', 'Não', 'Não',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe se deseja considerar os      ')
aAdd(aHelpPor, 'documentos cancelados dentro do      ')
aAdd(aHelpPor, 'período (comportamento padrão        ')
aAdd(aHelpPor, 'conforme layout EFD Contribuições) ou')
aAdd(aHelpPor, 'se deseja considerar todos os        ')
aAdd(aHelpPor, 'cancelados.                          ')
cNome := 'Considera cancelados'
PutSx1(PadR(cPerg,nTamGrp), '12', cNome, cNome, cNome,;
'MV_CHC', 'C', 1, 0, 1, 'C', '(MV_PAR12 == 1)', '', '', '', 'MV_PAR12',;
'Dentro período', 'Dentro período', 'Dentro período', '1',;
'Todos', 'Todos', 'Todos',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
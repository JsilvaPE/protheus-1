#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyQDvCom(dDtIni,dDtFim,cFilDe,cFilAte,cCFOP,cCFPad,cCST)
///////////////////////////////////////////////////////////////////////////////
// Data : 17/11/2014
// User : Thieres Tembra
// Desc : Query para retornar as devoluções de compras
// Ação : A rotina elabora query de notas fiscais de saída emitidas para
//        devolução de compras, considerando ambos os casos previstos na lei:
//        dentro do período e fora do período. A query suporta o filtro
//        por CFOP e por CST, e obtém os dados a partir da tabela SFT.
//
// OBS  : Utilizado nas queries do U_MyRDvCom e U_MyApuPC (Ajuste de Crédito).
///////////////////////////////////////////////////////////////////////////////

Local cQry
Default cFilDe := ''
Default cFilAte := 'zz'
Default cCFOP := ''
Default cCFPad := GetMV('MY_CFDEVPC')
Default cCST := ''

cQry := CRLF + " SELECT"
cQry += CRLF + "        SFTS.FT_FILIAL  AS SFTS_FILIAL"
cQry += CRLF + "       ,SFTS.FT_NFISCAL AS SFTS_DOC"
cQry += CRLF + "       ,SFTS.FT_SERIE   AS SFTS_SERIE"
cQry += CRLF + "       ,SFTS.FT_ENTRADA AS SFTS_ENTRADA"
cQry += CRLF + "       ,SFTS.FT_PRODUTO AS SFTS_PRODUTO"
cQry += CRLF + "       ,SFTS.FT_POSIPI  AS SFTS_POSIPI"
cQry += CRLF + "       ,SFTS.FT_TNATREC AS SFTS_TNATREC"
cQry += CRLF + "       ,SFTS.FT_CNATREC AS SFTS_CNATREC"
cQry += CRLF + "       ,SFTS.FT_QUANT   AS SFTS_QTD"
cQry += CRLF + "       ,SFTS.FT_CFOP    AS SFTS_CFOP"
cQry += CRLF + "       ,SFTS.FT_CSTPIS  AS SFTS_CSTPIS"
cQry += CRLF + "       ,SFTS.FT_VALCONT AS SFTS_VALCONT"
cQry += CRLF + "       ,SFTS.FT_TOTAL   AS SFTS_TOTAL"
cQry += CRLF + "       ,SFTS.FT_BASEPIS AS SFTS_BPIS"
cQry += CRLF + "       ,SFTS.FT_BASECOF AS SFTS_BCOF"
cQry += CRLF + "       ,SFTS.FT_VALPIS  AS SFTS_VPIS"
cQry += CRLF + "       ,SFTS.FT_VALCOF  AS SFTS_VCOF"
cQry += CRLF + "       ,SFTS.FT_NFORI   AS SFTS_NFORI"
cQry += CRLF + "       ,SFTS.FT_SERORI  AS SFTS_SERORI"
cQry += CRLF + "       ,SFTS.FT_ITEMORI AS SFTS_ITEMORI"
cQry += CRLF + "       ,SFTE.FT_NFISCAL AS SFTE_DOC"
cQry += CRLF + "       ,SFTE.FT_SERIE   AS SFTE_SERIE"
cQry += CRLF + "       ,SFTE.FT_ITEM    AS SFTE_ITEM"
cQry += CRLF + "       ,SFTE.FT_ENTRADA AS SFTE_ENTRADA"
cQry += CRLF + "       ,SFTE.FT_PRODUTO AS SFTE_PRODUTO"
cQry += CRLF + "       ,SFTE.FT_QUANT   AS SFTE_QTD"
cQry += CRLF + "       ,SFTE.FT_CFOP    AS SFTE_CFOP"
cQry += CRLF + "       ,SFTE.FT_CSTPIS  AS SFTE_CSTPIS"
cQry += CRLF + "       ,SFTE.FT_TNATREC AS SFTE_TNATREC"
cQry += CRLF + "       ,SFTE.FT_CNATREC AS SFTE_CNATREC"
cQry += CRLF + "       ,SFTE.FT_CODBCC  AS SFTE_CODBCC"
cQry += CRLF + "       ,SFTE.FT_VALCONT AS SFTE_VALCONT"
cQry += CRLF + "       ,CASE SFTE.FT_AGREG"
cQry += CRLF + "          WHEN 'I' THEN"
cQry += CRLF + "            SFTE.FT_TOTAL + SFTE.FT_VALICM"
cQry += CRLF + "          ELSE"
cQry += CRLF + "            SFTE.FT_TOTAL"
cQry += CRLF + "        END AS SFTE_VALITEM"
cQry += CRLF + "       ,SFTE.FT_BASEPIS AS SFTE_BPIS"
cQry += CRLF + "       ,SFTE.FT_VALPIS  AS SFTE_VPIS"
cQry += CRLF + "       ,SFTE.FT_BASECOF AS SFTE_BCOF"
cQry += CRLF + "       ,SFTE.FT_VALCOF  AS SFTE_VCOF"
cQry += CRLF + "       ,("
cQry += CRLF + "           SELECT TOP 1"
cQry += CRLF + "              ZPI_NCM"
cQry += CRLF + "           FROM " + RetSqlName('ZPI') + " ZPI"
cQry += CRLF + "           WHERE ZPI.D_E_L_E_T_ <> '*'"
cQry += CRLF + "             AND ZPI_FILIAL = " + Iif(AllTrim(xFilial('ZPI')) == '',"''","SFTS.FT_FILIAL")
cQry += CRLF + "             AND ZPI_NCM    = SFTS.FT_POSIPI"
cQry += CRLF + "             AND ("
cQry += CRLF + "                  SFTS.FT_ENTRADA BETWEEN ZPI_DTININ AND ZPI_DTFIMN"
cQry += CRLF + "               OR ("
cQry += CRLF + "                     SFTS.FT_ENTRADA > ZPI_DTININ"
cQry += CRLF + "                 AND ZPI_DTFIMN = ''"
cQry += CRLF + "               )"
cQry += CRLF + "             )"
cQry += CRLF + "        ) AS ZPI_NCM"
cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFTS"
cQry += CRLF + " LEFT JOIN " + RetSqlName('SFT') + " SFTE"
cQry += CRLF + " ON  SFTE.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND SFTE.FT_FILIAL  = SFTS.FT_FILIAL"
cQry += CRLF + " AND SFTE.FT_NFISCAL = SFTS.FT_NFORI"
cQry += CRLF + " AND SFTE.FT_SERIE   = SFTS.FT_SERORI"
cQry += CRLF + " AND SFTE.FT_ITEM    = SFTS.FT_ITEMORI"
cQry += CRLF + " AND SFTE.FT_PRODUTO = SFTS.FT_PRODUTO"
cQry += CRLF + " AND SFTE.FT_TIPOMOV = 'E'"
cQry += CRLF + " WHERE SFTS.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND LEN(SFTS.FT_DTCANC) = 0"
cQry += CRLF + "   AND SFTS.FT_OBSERV NOT LIKE '%INUTIL%'"
cQry += CRLF + "   AND SFTS.FT_OBSERV NOT LIKE '%CANCEL%'"
cQry += CRLF + "   AND SFTS.FT_TIPO = 'D'"
cQry += CRLF + "   AND SFTS.FT_TIPOMOV = 'S'"
cQry += CRLF + "   AND SFTS.FT_ENTRADA BETWEEN '" + DTOS(dDtIni) + "' AND '" + DTOS(dDtFim) + "'"
cQry += CRLF + "   AND SFTS.FT_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "'"
If AllTrim(cCFOP) <> ''
	cQry += CRLF + "   AND SFTS.FT_CFOP IN " + U_MyGeraIn(AllTrim(cCFOP))
Else
	//usuário deixou em branco, utiliza CFOPs padrão
	cQry += CRLF + "   AND SFTS.FT_CFOP IN " + U_MyGeraIn(AllTrim(cCFPad))
EndIf
If AllTrim(cCST) <> ''
	cQry += CRLF + "   AND SFTE.FT_CSTPIS IN " + U_MyGeraIn(AllTrim(cCST))
EndIf
cQry += CRLF + " ORDER BY SFTS.FT_FILIAL"
cQry += CRLF + "         ,SFTS.FT_ENTRADA"
cQry += CRLF + "         ,SFTS.FT_SERIE"
cQry += CRLF + "         ,SFTS.FT_NFISCAL"
cQry += CRLF + "         ,SFTS.FT_NFORI"
cQry += CRLF + "         ,SFTS.FT_SERORI"
cQry += CRLF + "         ,SFTS.FT_ITEMORI"
cQry += CRLF + "         ,SFTS.FT_PRODUTO"
cQry += CRLF + "         ,SFTE.FT_ENTRADA"
cQry += CRLF + "         ,SFTE.FT_SERIE"
cQry += CRLF + "         ,SFTE.FT_NFISCAL"
cQry += CRLF + "         ,SFTE.FT_PRODUTO"

Return cQry
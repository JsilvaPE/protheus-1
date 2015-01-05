#include 'rwmake.ch'
#include 'protheus.ch'

///////////////////////////////////////////////////////////////////////////////
User Function MyVldNCM(cNCM)
///////////////////////////////////////////////////////////////////////////////
// Data : 19/07/2014
// User : Thieres Tembra
// Desc : Valida o NCM com a tabela TIPI no cadastro do Produto
///////////////////////////////////////////////////////////////////////////////

Local lRet := .T.
Local cQry
Local nQtd := 0

Default cNCM := M->B1_POSIPI

If AllTrim(cNCM) == ''
	Return lRet
EndIf

cQry := CRLF + " SELECT"
cQry += CRLF + "    ZYD_COD"
cQry += CRLF + "   ,ZYD_VALID"
cQry += CRLF + "   ,ZYD_DESC"
cQry += CRLF + " FROM " + RetSqlName('ZYD')
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND ZYD_FILIAL = '" + xFilial('SYD') + "'"
cQry += CRLF + "   AND ZYD_COD = '" + cNCM + "'"
cQry += CRLF + "   AND ("
cQry += CRLF + "        ZYD_VALID = ''"
cQry += CRLF + "     OR ZYD_VALID >= '" + DTOS(Date()) + "'"
cQry += CRLF + "   )"

cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY',.T.)

MQRY->(dbEval({||nQtd++}))

MQRY->(dbCloseArea())

If nQtd == 0
	MsgAlert('O NCM informado (' + AllTrim(cNCM) + ') não existe ou está fora da validade conforme a tabela TIPI existente no sistema.')
	lRet := .F.
EndIf

Return lRet
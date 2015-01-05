#Include 'rwmake.ch'
#Include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyLog(cRotina, cAntes, cDepois, cMotivo, cAdd)
///////////////////////////////////////////////////////////////////////////////
// Data : 28/01/2013
// User : Walber Freire
// Desc : Função para criação de logs de acesso à rotinas.
// Ação : Possibilita a criação de logs de acesso para controle de execução de
//        rotinas.
///////////////////////////////////////////////////////////////////////////////

Local cMyAdd := ''

Default cMotivo := ''
Default cAdd := ''

If AllTrim(cAdd) <> ''
	cMyAdd := cAdd + ' - '
EndIf

	//Gerando log
	cQry := " INSERT INTO TD_LOG "
	cQry += " VALUES ( "
	cQry += "'" + cEmpAnt + "' ,"
	cQry += "'" + cFilAnt + "' ,"
	cQry += "'" + DTOS(Date()) + "' ,"
	cQry += "'" + Time() + "' ,"
	cQry += "'" + cUserName + "' ,"
	cQry += "'" + cRotina +"' ,"
	cQry += "'" + cAntes + "' ,"
	cQry += "'" + cDepois + "' ,"
	If AllTrim(cMotivo) == ''
		cQry += "'" + cMyAdd + U_MyInput('Motivo', 'Informe o motivo:', 'Preenchimento obrigatório.') + "'"
	Else
		cQry += "'" + cMyAdd + cMotivo + "'"
	EndIf
	cQry += ")"
	If TCSQLExec(cQry) < 0
	    Return MsgStop("TCSQLError() " + TCSQLError())
	EndIf
Return Nil

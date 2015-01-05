#include 'protheus.ch'

User Function MyXMLRel()

Local cArq := '', cError := '', cWarning := ''
Private _oMyXML := Nil

cArq := cGetFile('XML (*.xml)|*.xml', 'Selecione o XML do relatório a ser impresso', 1, 'SERVIDOR\myXMLRel', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NETWORKDRIVE ), .T., .T.)

If cArq == ''
	MsgAlert('Relatório cancelado.')
	Return Nil
EndIf

If !File(cArq)
	MsgAlert('Relatório inexistente.')
	Return Nil
EndIf

_oMyXML := XmlParserFile(cArq, '_', @cError, @cWarning)

If cError <> ''
	Alert(cError)
	Return Nil
EndIf

If cWarning <> ''
	MsgAlert(cWarning)
	If !MsgYesNo('Deseja continuar?')
		Return Nil
	EndIf
EndIf

If _oMyXML <> Nil
	If Type('_oMyXML:_myXMLRel') == 'U'
		Alert('[myXMLRel] - O XML selecionado está em um formato inválido.')
		Return Nil
	EndIf
	If Type('_oMyXML:_myXMLRel:_select') == 'U'
		Alert('[select] - O XML selecionado está em um formato inválido.')
		Return Nil
	EndIf
	If Type('_oMyXML:_myXMLRel:_select:_campo') == 'U'
		Alert('[campo] - O XML selecionado está em um formato inválido.')
		Return Nil
	EndIf
	If Type('_oMyXML:_myXMLRel:_select:_from') == 'U'
		Alert('[from] - O XML selecionado está em um formato inválido.')
		Return Nil
	EndIf
EndIf

Processa({|| Executa(cArq) }, 'myXMLRel', 'Processando..', .F.)

Return Nil

/*--------------------------------*/

Static Function Executa(cArq)

Local aExcel := {}
Local aAux := {}
Local aCpo := {}
Local cAux := ''
Local cQry := ''
Local nI, nJ, nMaxI, nMaxJ

ProcRegua(3)

IncProc('Imprimindo título..')
//título
If Type('_oMyXML:_myXMLRel:_nome') <> 'U'
	aAdd(aExcel, {_oMyXML:_myXMLRel:_nome:TEXT})
EndIf
aAdd(aExcel, {'Relatório gerado em ' + DTOC(Date()) + ' por ' + cUsername})
aAdd(aExcel, {'myXMLRel - Desenvolvido por Thieres Tembra'})

aAdd(aExcel, {})

IncProc('Imprimindo cabeçalho(s)..')
//cabeçalho(s)
If Type('_oMyXML:_myXMLRel:_cabecalho') <> 'U'
	//se existir - cabeçalho(s)
	If Type('_oMyXML:_myXMLRel:_cabecalho') == 'A'
		//se houver mais que 1 - cabeçalho
		nMaxI := Len(_oMyXML:_myXMLRel:_cabecalho)
		For nI := 1 to nMaxI
			If Type('_oMyXML:_myXMLRel:_cabecalho['+cValToChar(nI)+']:_campo') <> 'U'
				//se existir - campo(s)
				If Type('_oMyXML:_myXMLRel:_cabecalho['+cValToChar(nI)+']:_campo') == 'A'
					//se houver mais que 1 - campo
					nMaxJ := Len(_oMyXML:_myXMLRel:_cabecalho[nI]:_campo)
					aAux := {}
					For nJ := 1 to nMaxJ
						aAdd(aAux, _oMyXML:_myXMLRel:_cabecalho[nI]:_campo[nJ]:TEXT)
					Next nJ
					aAdd(aExcel, aClone(aAux))
				Else
					//se houver apenas 1 - campo
					aAdd(aExcel, {_oMyXML:_myXMLRel:_cabecalho[nI]:_campo:TEXT})
				EndIf
			EndIf
		Next nI
	Else
		//se houver apenas 1 - cabeçalho
		If Type('_oMyXML:_myXMLRel:_cabecalho:_campo') <> 'U'
			//se existir - campo(s)
			If Type('_oMyXML:_myXMLRel:_cabecalho:_campo') == 'A'
				//se houver mais que 1 - campo
				nMaxI := Len(_oMyXML:_myXMLRel:_cabecalho:_campo)
				aAux := {}
				For nI := 1 to nMaxI
					aAdd(aAux, _oMyXML:_myXMLRel:_cabecalho:_campo[nI]:TEXT)
				Next nI
				aAdd(aExcel, aClone(aAux))
			Else
				//se houver apenas 1 - campo
				aAdd(aExcel, {_oMyXML:_myXMLRel:_cabecalho:_campo:TEXT})
			EndIf
		EndIf
	EndIf
EndIf

IncProc('Montando query..')
cQry := " SELECT "
//preposição após select (TOP do SQL Server, por exemplo)
If Type('_oMyXML:_myXMLRel:_select:_preposicao') <> 'U'
	cQry += _oMyXML:_myXMLRel:_select:_preposicao:TEXT + " " + CRLF
Else
	cQry += CRLF
EndIf
//campo(s)
If Type('_oMyXML:_myXMLRel:_select:_campo') == 'A'
	//se houver mais que 1 - campo
	nMaxI := Len(_oMyXML:_myXMLRel:_select:_campo)
	aCpo := {}
	For nI := 1 to nMaxI
		cQry += "        " + FilRepl(TblRepl(_oMyXML:_myXMLRel:_select:_campo[nI]:TEXT))
		//verifica alias
		If Type('_oMyXML:_myXMLRel:_select:_campo['+cValToChar(nI)+']:_alias') <> 'U'
			//existe alias, salva alias como nome do campo e quebra linha
			aAdd(aCpo, _oMyXML:_myXMLRel:_select:_campo[nI]:_alias:TEXT)
			cQry += " " + _oMyXML:_myXMLRel:_select:_campo[nI]:_alias:TEXT
			If nI <> nMaxI
				cQry += ","
			EndIf
			cQry += " " + CRLF
		Else
			//não existe alias, salva nome do campo e quebra linha
			aAdd(aCpo, _oMyXML:_myXMLRel:_select:_campo[nI]:TEXT)
			If nI <> nMaxI
				cQry += ","
			EndIf
			cQry += " " + CRLF
		EndIf
	Next nI
Else
	//se houver apenas 1 - campo
	cQry += "        " + FilRepl(TblRepl(_oMyXML:_myXMLRel:_select:_campo:TEXT))
	//verifica alias
	If Type('_oMyXML:_myXMLRel:_select:_campo:_alias') <> 'U'
		//existe alias, salva alias como nome do campo e quebra linha
		aAdd(aCpo, _oMyXML:_myXMLRel:_select:_campo:_alias:TEXT)
		cQry += " " + _oMyXML:_myXMLRel:_select:_campo:_alias:TEXT + " " + CRLF
	Else
		//não existe alias, salva nome do campo e quebra linha
		aAdd(aCpo, _oMyXML:_myXMLRel:_select:_campo:TEXT)
		cQry += " " + CRLF
	EndIf
EndIf
//from
cQry += " FROM " + TblRepl(_oMyXML:_myXMLRel:_select:_from:TEXT)
//where
If Type('_oMyXML:_myXMLRel:_select:_where') <> 'U'
	If AllTrim(_oMyXML:_myXMLRel:_select:_where:TEXT) <> ''
		cQry += " WHERE " + FilRepl(TblRepl(_oMyXML:_myXMLRel:_select:_where:TEXT)) + " " + CRLF
	EndIf
EndIf
//group
If Type('_oMyXML:_myXMLRel:_select:_group') <> 'U'
	If AllTrim(_oMyXML:_myXMLRel:_select:_group:TEXT) <> ''
		cQry += " GROUP BY " + _oMyXML:_myXMLRel:_select:_group:TEXT + " " + CRLF
	EndIf
EndIf
//having
If Type('_oMyXML:_myXMLRel:_select:_having') <> 'U'
	If AllTrim(_oMyXML:_myXMLRel:_select:_having:TEXT) <> ''
		cQry += " HAVING " + _oMyXML:_myXMLRel:_select:_having:TEXT + " " + CRLF
	EndIf
EndIf
//order
If Type('_oMyXML:_myXMLRel:_select:_order') <> 'U'
	If AllTrim(_oMyXML:_myXMLRel:_select:_order:TEXT) <> ''
		cQry += " ORDER BY " + _oMyXML:_myXMLRel:_select:_order:TEXT + " " + CRLF
	EndIf
EndIf

Processa({|| Selecionando(cQry, aCpo, aExcel) }, 'myXMLRel', 'Selecionando registros..', .F.)

cAux := AllTrim(cGetFile('CSV (*.csv)|*.csv', 'Selecione o diretório onde será salvo o relatório', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NETWORKDRIVE, GETF_RETDIRECTORY ), .F., .T.))
If cAux <> ''
	cAux := SubStr(cAux, 1, RAt('\', cAux)) + SubStr(cArq, RAt('\', cArq)+1)
	cAux := Substr(cAux, 1, RAt('.', cAux)-1) + '-' + DTOS(Date()) + '-' + StrTran(Time(), ':', '') + '.csv'

	U_MyArrCsv(aExcel, cAux)
Else
	Alert('A geração do relatório foi cancelada!')
EndIf

Return Nil

/*--------------------------------*/

Static Function Selecionando(cQry, aCpo, aExcel)

Local nI, nMaxI
Local aAux

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY',.T.)
nI := 0
MQRY->(dbEval({|| nI++ }))
MQRY->(dbGoTop())
ProcRegua(nI)
IncProc('Selecionando registros..')
nMaxI := Len(aCpo)

While !MQRY->(Eof())
	aAux := {}
	For nI := 1 to nMaxI
		aAdd(aAux, &('MQRY->' + aCpo[nI]))
	Next nI
	aAdd(aExcel, aClone(aAux))
	
	MQRY->(dbSkip())
	IncProc()
EndDo

MQRY->(dbCloseArea())

Return Nil

/*--------------------------------*/

Static Function TblRepl(cStr)

Local cRet := cStr
Local nPos := 0

nPos := At('%table:', cRet)
While nPos > 0
	cRet := SubStr(cRet, 1, nPos-1) + RetSqlName(SubStr(cRet, nPos+7, 3)) + SubStr(cRet, nPos+11)
	nPos := At('%table:', cRet)
EndDo

Return cRet

Static Function FilRepl(cStr)

Local cRet := cStr
Local nPos := 0

nPos := At('%filial:', cRet)
While nPos > 0
	cRet := SubStr(cRet, 1, nPos-1) + xFilial(SubStr(cRet, nPos+8, 3)) + SubStr(cRet, nPos+12)
	nPos := At('%filial:', cRet)
EndDo

Return cRet

//TODO
//_aMyParam
Static Function ParamRepl(cStr)

Local cRet  := cStr
Local cAux  := ''
Local nPosI := 0
Local nPosF := 0

nPosI := At('%param:', cRet)
While nPosI > 0
	cAux  := SubStr(cRet, nPosI+7)
	nPosF := At('%', cAux)
	cAux  := SubStr(cAux, 1, nPosF-1)
	
	If Val(cAux) > Len(_aMyParam)
		Alert('Foi utilizado na query o parâmetro com sequêncial ' + cAux + ' mas o mesmo não foi informado na tag <parametros>.')
	EndIf
	
	cRet  := SubStr(cRet, 1, nPosI-1) + _aMyParam[Val(cAux)] + SubStr(cRet, nPosI+8+Len(cAux))
	nPosI := At('%param:', cRet)
EndDo

Return cRet
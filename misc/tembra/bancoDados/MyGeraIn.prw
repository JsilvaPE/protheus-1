///////////////////////////////////////////////////////////////////////////////
User Function MyGeraIn(cVar, cChar)
///////////////////////////////////////////////////////////////////////////////
// Data......: 19/03/2011
// Usuário...: Thieres Tembra
// Ação......: Gera string no formato (aaa,bbb,ccc) para utilizar no SQL
// Parâmetro.: cVar - String a ser analisada
//             cChar - Caractere separador
// Retorno...: String
///////////////////////////////////////////////////////////////////////////////
	Local cResult
	Local cCharF
	If cChar == Nil
		cCharF := ';'
	Else
		cCharF := cChar
	EndIf
	cResult := AllTrim(cVar)
	If Len(cCharF) > 1
		cResult := ''
	EndIf
	If cResult <> ''
		If Left(cResult, 1) == cCharF
			cResult := Right(cResult, Len(cResult)-1)
		EndIf
		If Right(cResult, 1) == cCharF
			cResult := Left(cResult, Len(cResult)-1)
		EndIf
		cResult := StrTran(cResult, cCharF, "','")
		cResult := "'"+cResult+"'"
	EndIf
Return '('+cResult+')'
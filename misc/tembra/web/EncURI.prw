User Function EncURI(cString)
	Local cResult := '', cLetra
	Local nI, nCount
	Local aChar, aURI
	Local lOk := .F.
	aChar := {;
		' '  , '#'  , '$'  , '%'  , '&'  , '+'  , ','  , '/'  , ':'  , ';'  , '='  , '?'  , '@'  ;
	}
	aURI := {;
		'%20', '%23', '%24', '%25', '%26', '%2B', '%2C', '%2F', '%3A', '%3B', '%3D', '%3F', '%40';
	}
	For nI := 1 to Len(cString)
		cLetra := SubStr(cString, nI, 1)
		nCount := 0
		lOk := .F.
		aEval(aChar, {|cLinha| nCount++,If(cLinha==cLetra,(cResult+=aURI[nCount],lOk:=.T.),.F.)})
		If !lOk
			cResult += cLetra
		EndIf
	Next nI
Return cResult

/*
		If cLetra == ' '
			cResult += '%20'
		ElseIf cLetra == '#'
			cResult += '%23'
		ElseIf cLetra == '$'
			cResult += '%24'
		ElseIf cLetra == '%'
			cResult += '%25'
		ElseIf cLetra == '&'
			cResult += '%26'
		ElseIf cLetra == '+'
			cResult += '%2B'
		ElseIf cLetra == ','
			cResult += '%2C'
		ElseIf cLetra == '/'
			cResult += '%2F'
		ElseIf cLetra == ':'
			cResult += '%3A'
		ElseIf cLetra == ';'
			cResult += '%3B'
		ElseIf cLetra == '='
			cResult += '%3D'
		ElseIf cLetra == '?'
			cResult += '%3F'
		ElseIf cLetra == '@'
			cResult += '%40'
		Else
			cResult += cLetra
		EndIf
*/
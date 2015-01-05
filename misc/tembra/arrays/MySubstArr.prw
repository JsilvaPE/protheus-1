////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function MySubstArr(aArray, cProcura, cSubst)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DATA       : 02/12/2010
// USER       : THIERES TEMBRA
// ACAO       : ANALISA UM ARRAY PROCURANDO POR UM VALOR cProcura E SUBSTITUINDO PELO VALOR cSubst INFORMADO
// RETORNO    : Array
// PARÂMETROS : aArray   - Array a ser analisado
//              cProcura - Texto a ser procurado, ou array com vários textos.
//              cSubst   - Texto para substituir, ou array com vários textos.
//
//              OBS: Caso seja informado um array para cProcura ou cSubst, obrigatoriamente o outro também deverá ser
//                   um array com a mesma quantidade de elementos. Caso isto não ocorra será retornado um array vazio.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	Local aRetorno := {}
	Local nI, nJ
	Local cLinha
	
	If ValType(cProcura) == 'C' .and. ValType(cSubst) == 'C'
		aEval(aArray, {|cLinha| aAdd(aRetorno, StrTran(cLinha, cProcura, cSubst))})
	ElseIf ValType(cProcura) == 'A' .and. ValType(cSubst) == 'A' .and. Len(cProcura) == Len(cSubst)
		For nI := 1 to Len(aArray)
			cLinha := aArray[nI]
			For nJ := 1 to Len(cProcura)
				cLinha := StrTran(cLinha, cProcura[nJ], cSubst[nJ])
			Next nJ
			aAdd(aRetorno, cLinha)
		Next nI
	EndIf
Return aRetorno
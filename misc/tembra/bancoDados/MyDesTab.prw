////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function MyDesTab(cAlias)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Data......: 28/11/2013
// Usu�rio...: Thieres Tembra
// A��o......: Converte um arquivo de trabalho para um vetor
// Par�metro.: cAlias - Alias do arquivo de trabalho a ser convertido
// Retorno...: Array
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Local aArr := {}
Local aAux := {}
Local nI, nTam, nRecNo

//verifica se o alias existe
If Select(cAlias) == 0
	Return aClone(aArr)
EndIf

//salva posi��o atual
nRecNo := (cAlias)->(RecNo())

//primeiro registro
(cAlias)->(dbGoTop())

//varre todos os campos at� que acabem
//para pegar quantidade total de campos
nTam := 1
While ValType((cAlias)->(FieldGet(nTam))) <> 'U'
	nTam++
EndDo
nTam--

//percorre todas as linhas
While !(cAlias)->(Eof())
	aAux := {}
	For nI := 1 to nTam
		//adiciona nome e conte�do do campo em um vetor auxiliar
		aAdd(aAux, {(cAlias)->(Field(nI)),(cAlias)->(FieldGet(nI))})
	Next nI
	//adiciona linha no vetor final
	aAdd(aArr, aClone(aAux))
	(cAlias)->(dbSkip())
EndDo

//retorna posi��o anterior
(cAlias)->(dbGoTo(nRecNo))

Return aClone(aArr)
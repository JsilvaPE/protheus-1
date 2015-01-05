////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function MyDia(nTipo,nMes,nAno)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Data : 08/02/2011
// User : Thieres Tembra
// Acao : Retorna o primeiro ou �ltimo dia do m�s
//
// Retorno: Data
//
// Par�metros:
//   nTipo - Tipo a ser retornado. Caso n�o seja um tipo v�lido, ser� retornado a data atual.
//     1 = Primeiro dia do m�s
//     2 = �ltimo dia do m�s
//
//   nMes - (Opcional) M�s a ser analisado. Caso n�o seja informado ser� analisado o m�s atual.
//   nAno - (Opcional) Ano a ser analisado. Caso n�o seja informado ser� analisado o ano atual.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	Local dData
	Local nMesA
	Local nAnoA
	
	Set Date BRIT
	
	If nMes == NIL
		nMesA := Month(Date())
	Else
		If nMes >= 1 .and. nMes <= 12
			nMesA := nMes
		Else
			nMesA := Month(Date())
		EndIf
	EndIf
	
	If nAno == NIL
		nAnoA := Year(Date())
	Else
		nAnoA := nAno
	EndIf
	
	If nTipo == 1
		dData := CTOD('01/'+StrZero(nMesA, 2)+'/'+cValToChar(nAnoA))
	ElseIf nTipo == 2
		If nMesA+1 <= 12
			dData := CTOD('01/'+StrZero(nMesA+1, 2)+'/'+cValToChar(nAnoA))-1
		Else
			dData := CTOD('01/01/'+cValToChar(nAnoA+1))-1
		EndIf
	Else
		dData := Date()
	EndIf
Return dData
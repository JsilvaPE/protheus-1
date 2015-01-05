////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function MyDia(nTipo,nMes,nAno)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Data : 08/02/2011
// User : Thieres Tembra
// Acao : Retorna o primeiro ou último dia do mês
//
// Retorno: Data
//
// Parâmetros:
//   nTipo - Tipo a ser retornado. Caso não seja um tipo válido, será retornado a data atual.
//     1 = Primeiro dia do mês
//     2 = Último dia do mês
//
//   nMes - (Opcional) Mês a ser analisado. Caso não seja informado será analisado o mês atual.
//   nAno - (Opcional) Ano a ser analisado. Caso não seja informado será analisado o ano atual.
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
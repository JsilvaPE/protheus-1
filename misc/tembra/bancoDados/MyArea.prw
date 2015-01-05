#include 'rwmake.ch'
#include 'protheus.ch'
User Function MyArea(aAreas, lSave)

Local uRet := Nil
Local aSvArea := {}
Local nI, nMax
Local aAux

Local cErrSave := '' +;
'[MyArea] Erro: Para salvar as �reas ' +;
'(segundo par�metro .T.), deve-se passar como ' +;
'primeiro par�metro da fun��o, um array de ' +;
'caracteres com os alias a serem salvos.'

Local cErrRest := '' +;
'[MyArea] Erro: Para restaurar as �reas ' +;
'(segundo par�metro .F.), deve-se passar como ' +;
'primeiro par�metro da fun��o, o array retornado ' +;
'pela pr�pria fun��o MyArea quando a mesma foi ' +;
'utilizada para salvar as �reas.'

Default aAreas := {}
Default lSave  := .T.

//verifica��es
If ValType(aAreas) <> 'A' .or. ValType(lSave) <> 'L'
	Alert('[MyArea] Erro: O primeiro par�metro deve ser do ' +;
	'tipo Array e o segundo par�metro deve ser do tipo L�gico.')
	Return uRet
EndIf

nMax := Len(aAreas)
//array do primeiro par�metro est� preenchido
If nMax > 0
	For nI := 1 to nMax
		//se for salvar as �reas
		If lSave
			//verifica se o primeiro par�metro � um array de caracteres
			If ValType(aAreas[nI]) <> 'C'
				Alert(cErrSave)
				Return uRet
			EndIf
		
		//se for restaurar as �reas
		Else
			//verifica se o primeiro par�metro � um array de array's (bidimensional)
			If ValType(aAreas[nI]) <> 'A'
				Alert(cErrRest)
				Return uRet
			Else
				//verifica se o array bidimensional possui 2 elementos
				If Len(aAreas[nI]) == 2
					//verifica se o 1o. elemento � caractere e o 2o. � um array
					If ValType(aAreas[nI][1]) <> 'C' .or. ValType(aAreas[nI][2]) <> 'A'
						Alert(cErrRest)
						Return uRet
					EndIf
				Else
					Alert(cErrRest)
					Return uRet
				EndIf
			EndIf
		EndIf
	Next nI
	
//array do primeiro par�metro est� vazio
Else
	//se estiver restaurando, encerra programa,
	//pois n�o h� nada a ser restaurado (array vazio)
	If !lSave
		Return uRet
	EndIf
EndIf

//opera��o

//salva a �rea atual e as �reas passadas por par�metro
If lSave
	aAdd(aSvArea, {'', GetArea()})
	
	For nI := 1 to nMax
		aAux := (aAreas[nI])->(GetArea())
		If aAux <> Nil
			aAdd(aSvArea, {aAreas[nI], aClone(aAux)})
		EndIf
	Next nI
	
	uRet := aClone(aSvArea)
	
//restaura as �reas passadas por par�metro e a �rea anterior
Else
	For nI := nMax to 1 Step -1
		If aAreas[nI][1] <> ''
			(aAreas[nI][1])->(RestArea(aAreas[nI][2]))
		Else
			RestArea(aAreas[nI][2])
		EndIf
	Next nI
EndIf

Return uRet
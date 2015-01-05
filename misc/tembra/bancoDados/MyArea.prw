#include 'rwmake.ch'
#include 'protheus.ch'
User Function MyArea(aAreas, lSave)

Local uRet := Nil
Local aSvArea := {}
Local nI, nMax
Local aAux

Local cErrSave := '' +;
'[MyArea] Erro: Para salvar as áreas ' +;
'(segundo parâmetro .T.), deve-se passar como ' +;
'primeiro parâmetro da função, um array de ' +;
'caracteres com os alias a serem salvos.'

Local cErrRest := '' +;
'[MyArea] Erro: Para restaurar as áreas ' +;
'(segundo parâmetro .F.), deve-se passar como ' +;
'primeiro parâmetro da função, o array retornado ' +;
'pela própria função MyArea quando a mesma foi ' +;
'utilizada para salvar as áreas.'

Default aAreas := {}
Default lSave  := .T.

//verificações
If ValType(aAreas) <> 'A' .or. ValType(lSave) <> 'L'
	Alert('[MyArea] Erro: O primeiro parâmetro deve ser do ' +;
	'tipo Array e o segundo parâmetro deve ser do tipo Lógico.')
	Return uRet
EndIf

nMax := Len(aAreas)
//array do primeiro parâmetro está preenchido
If nMax > 0
	For nI := 1 to nMax
		//se for salvar as áreas
		If lSave
			//verifica se o primeiro parâmetro é um array de caracteres
			If ValType(aAreas[nI]) <> 'C'
				Alert(cErrSave)
				Return uRet
			EndIf
		
		//se for restaurar as áreas
		Else
			//verifica se o primeiro parâmetro é um array de array's (bidimensional)
			If ValType(aAreas[nI]) <> 'A'
				Alert(cErrRest)
				Return uRet
			Else
				//verifica se o array bidimensional possui 2 elementos
				If Len(aAreas[nI]) == 2
					//verifica se o 1o. elemento é caractere e o 2o. é um array
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
	
//array do primeiro parâmetro está vazio
Else
	//se estiver restaurando, encerra programa,
	//pois não há nada a ser restaurado (array vazio)
	If !lSave
		Return uRet
	EndIf
EndIf

//operação

//salva a área atual e as áreas passadas por parâmetro
If lSave
	aAdd(aSvArea, {'', GetArea()})
	
	For nI := 1 to nMax
		aAux := (aAreas[nI])->(GetArea())
		If aAux <> Nil
			aAdd(aSvArea, {aAreas[nI], aClone(aAux)})
		EndIf
	Next nI
	
	uRet := aClone(aSvArea)
	
//restaura as áreas passadas por parâmetro e a área anterior
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
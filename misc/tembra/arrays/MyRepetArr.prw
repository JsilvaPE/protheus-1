////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function MyRepetArr(aArray, aEstrut)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DATA       : 02/12/2010
// USER       : THIERES TEMBRA
// ACAO       : ANALISA UM ARRAY PROCURANDO POR UMA ESTRUTURA DE REPETIÇÃO PREDEFINIDA.
//              QUANDO ENCONTRADA, REPETE A ESTRUTURA QUANTAS VEZES FOREM NECESSÁRIAS, SUBSTITUINDO OS VALORES INFORMADOS PELOS NOVOS.
// RETORNO    : Array
// PARÂMETROS :
//  aArray  - Array a ser analisado
//
//  aEstrut - Array de 3 posições, sendo as 2 primeiras do tipo caracter e a terceira do tipo array,
//            que informará a estrutura de repetição:
//              1) Marcação do início da repetição
//              2) Marcação do final da repetição
//              3) Array contendo subarrays com as variáveis a serem preenchidas e os textos para preenchimento
//                 na estrutura de repetição, para cada linha.
//
//            Exemplo: aItens1 := { {'{NUMERO}'   , '001'},;
//                                  {'{DESCRICAO}', 'TINTA'}}
//                     aItens2 := { {'{NUMERO}'   , '002'},;
//                                  {'{DESCRICAO}', 'PAPEL'}}
//                     aDadosR := { aItens1, aItens2 }
//                     aEstrut := {'{ITENS_INICIO}', '{ITENS_FINAL}', aDadosR}
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	Local aRetorno := {}, aRepete := {}, aAux := {}, aDAuxP := {}, aDAuxS := {}
	Local nI, nJ, nH, nTam1, nTam2, nFlag := 0
	Local cLinha, cNewLinha
	
	nTam1 := Len(aEstrut[1])
	nTam2 := Len(aEstrut[2])
	
	For nI := 1 to Len(aArray)
		cLinha := aArray[nI]
		If Left(cLinha, nTam1) == aEstrut[1]
			nFlag := 1
		ElseIf Left(cLinha, nTam2) == aEstrut[2]
			nFlag := 0
			For nJ := 1 to Len(aEstrut[3])
				aAux := aClone(aRepete)
				aDAuxP := {}
				aDAuxS := {}
				For nH := 1 to Len(aEstrut[3][nJ])
					aAdd(aDAuxP, aEstrut[3][nJ][nH][1])
					aAdd(aDAuxS, aEstrut[3][nJ][nH][2])
				Next nH
				aAux := U_MySubstArr(aAux, aDAuxP, aDAuxS)
				aEval(aAux, {|u| aAdd(aRetorno, u)})
			Next nJ
		Else
			If nFlag == 0
				aAdd(aRetorno, cLinha)
			Else
				aAdd(aRepete, cLinha)
			EndIf
		EndIf
	Next nI
Return aRetorno
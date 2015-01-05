////////////////////////////////////////////////////////////////////////////////
User Function MyDiaUtil(dData, nDias)
////////////////////////////////////////////////////////////////////////////////
// Data : 26/03/2011
// User : Thieres Tembra
// Acao : Recebe uma data e a quantidade de dias e devolve o próximo dia útil 
//        ou o anterior de acordo com a quantidade de dias informada.
//        Esta rotina não considera feriados.
//        Ela apenas ignora sábados e domingos.
//
// Retorno: Data
//
// Parâmetros:
//   dData - Data
//
//   nDias - (Opcional) Quantidade de dias a serem analisados. Padrão = 1
//           Caso esse valor seja 0 (zero) será devolvido a data informada.
////////////////////////////////////////////////////////////////////////////////
	Local dProx
	Local nDia := 1
	Local nI, nInc
	
	If nDias <> Nil
		nDia := nDias
	EndIf
	
	If nDia == 0
		dProx := dData
	ElseIf nDia < 0
		nInc := -1
	Else
		nInc := 1
	EndIf

	If dProx <> dData
		dProx := dData
		For nI := 1 to nDia
			dProx := dProx+nInc
			While DOW(dProx) == 1 .or. DOW(dProx) == 7
				dProx := dProx+nInc
			EndDo
		Next nI
	EndIf
Return dProx
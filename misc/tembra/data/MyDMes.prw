User Function MyDMes(dData1, dData2)
	Local nRet := 0
	Local nMes1, nMes2, nAno1, nAno2
	
	If dData1 <> Nil .and. dData2 <> Nil .and. ValType(dData1) == 'D' .and. ValType(dData2) == 'D' .and. dData2 > dData1
		nMes1 := Month(dData1)
		nMes2 := Month(dData2)
		nAno1 := Year(dData1)
		nAno2 := Year(dData2)
		
		nRet := (((nAno2 - nAno1) * 12) + nMes2) - nMes1 + 1
	EndIf
Return nRet
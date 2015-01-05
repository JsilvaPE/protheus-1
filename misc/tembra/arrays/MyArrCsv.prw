////////////////////////////////////////////////////////////////////////////////
User Function MyArrCsv(aExcelP, cArqP, cProgP, cTitulo)
////////////////////////////////////////////////////////////////////////////////
// DATA       : 02/05/2011
// USER       : THIERES TEMBRA
// ACAO       : Converte um array bidimensional em um arquivo CSV e abre o mesmo
//              utilizando o programa escolhido
//
// RETORNO    : Caractere
//              - Vazio significa sucesso
//              - Diferente de vazio, significa erro.
//                O retorno é a mensagem de erro.
//
// PARÂMETROS : aExcelP - Array a ser convertido
//              cArqP   - Arquivo a ser gerado com caminho completo
//              cProgP  - Programa a ser utilizado para abrir o arquivo gerado
//                        (Opcional) Padrão: excel.exe
//              cTitulo - Título da janela do programa
//                        (Opcional) Padrão: Aguarde
////////////////////////////////////////////////////////////////////////////////
	Local cRet := ''
	Local cMyTitle
	If cTitulo == Nil
		cMyTitle := 'Aguarde'
	Else
		cMyTitle := cTitulo
	EndIf
	Processa({|| cRet := Executa(aExcelP, cArqP, cProgP) }, cMyTitle, 'Gerando arquivo..', .F.)
Return cRet

Static Function Executa(aExcelP, cArqP, cProgP)
	Local nPos, nHdl, nI, nJ, nMax := 0
	Local cLinha, cTmp, cArq, cProg
	Local aExcel
	Local cNome := 'MyArrCsv - '
	
	If aExcelP == Nil
		Return cNome + 'Informe o array a ser convertido.'
	ElseIf ValType(aExcelP) <> 'A'
		Return cNome + 'O primeiro parâmetro deve ser do tipo array.'
	ElseIf Len(aExcelP) <> 0
		aExcel := aExcelP
	Else
		Return cNome + 'O tamanho do array deve ser maior que 0 (zero).'
	EndIf
	
	If cArqP == Nil
		Return cNome + 'Informe o caminho do arquivo a ser gerado.'
	ElseIf ValType(cArqP) <> 'C'
		Return cNome + 'O segundo parâmetro deve ser do tipo caractere.'
	ElseIf Len(cArqP) <> 0
		cArq := cArqP
	Else
		Return cNome + 'O caminho do arquivo deve ser maior que 0 (zero).'
	EndIf
	
	If cProgP == Nil
		cProg := 'excel.exe'
	ElseIf ValType(cProgP) <> 'C'
		Return cNome + 'O terceiro parâmetro deve ser do tipo caractere.'
	ElseIf Len(cProgP) <> 0
		cProg := cProgP
	Else
		Return cNome + 'O caminho do programa a ser aberto deve ser maior que 0 (zero).'
	EndIf
	
	nPos := Len(aExcel)
	nHdl := fCreate(cArq)
	If nHdl == -1
		Return cNome + 'Impossível escrever no arquivo: ' + cArq + chr(13) + chr(10) + 'Se o mesmo estiver aberto, por favor finalize.'
	EndIf
	
	ProcRegua(nPos+1)
	
	For nI := 1 to nPos
		IncProc()
		If aExcel[nI] <> Nil
			cLinha := ''
			nMax := Len(aExcel[nI])
			For nJ := 1 to nMax
				If ValType(aExcel[nI][nJ]) == 'N'
					aExcel[nI][nJ] := StrTran(cValToChar(cValToChar(aExcel[nI][nJ])), '.', ',')
				ElseIf ValType(aExcel[nI][nJ]) == 'C'
					cTmp := aExcel[nI][nJ]
					If AllTrim(cTmp) == ''
						aExcel[nI][nJ] := ''
					Else
						If (Left(cTmp,2) == '="' .and. Right(cTmp,1) == '"') .or. Left(cTmp,1) == chr(160)
							aExcel[nI][nJ] := aExcel[nI][nJ]
						Else
							aExcel[nI][nJ] := chr(160) + aExcel[nI][nJ]
						EndIf
					EndIf
				ElseIf ValType(aExcel[nI][nJ]) == 'D'
					aExcel[nI][nJ] := U_MyDataBR(DTOS(aExcel[nI][nJ]))
				ElseIf ValType(aExcel[nI][nJ]) == 'U'
					aExcel[nI][nJ] := '--UNDEFINED--'
				EndIf
				cTmp := StrTran(aExcel[nI][nJ], ';', ',')
				cLinha += cTmp
				If nJ < nMax
					cLinha += ';'
				EndIf
			Next nJ
			cLinha += chr(13)+chr(10)
			If fWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
				Alert('Erro ao escrever a linha:'+chr(13)+chr(10)+cLinha)
			EndIf
		Endif
	Next nI
	fClose(nHdl)
	
	IncProc()
	ShellExecute('open', cProg, cArq, '', 1)
Return ''
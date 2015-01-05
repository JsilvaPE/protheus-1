////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function MyBrwRel(aArq, aDados, aRepete, cVisual)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DATA : 02/12/2010
// USER : THIERES TEMBRA
// ACAO : EXIBE RELAT�RIO NO BROWSER (NAVEGADOR DE INTERNET)
//
// RETORNO: Nil      - Em caso de sucesso
//          Caracter - Informa��o, caso ocorra um erro
//
// PAR�METROS:
//   aArq - Array contendo subarrays de 3 posi��es do tipo caracter:
//            1) Destino
//            2) Caminho do arquivo local (a partir da pasta destino definido na primeira posi��o)
//			  3) Caminho do arquivo no servidor (a partir da pasta Protheus_Data)
//
//			OBS1: O primeiro subarray dever� conter obrigatoriamente o relat�rio a ser preenchido.
//                Os demais n�o s�o obrigat�rios e podem conter arquivos auxiliares como imagens e estilos.
//          OBS2: Pode-se passar diret�rios no segundo par�metro que a fun��o ir� cri�-lo localmente.
//
//          Exemplo: aArq := { {'C:\Windows\temp'         , '\arquivo.htm', '\relatorio_ie\arquivo.htm'},;
//                             {'C:\Windows\temp'         , '\auxiliar'   , nil},;
//                             {'C:\Windows\temp\auxiliar', '\logo.jpg'   , '\relatorio_ie\auxiliar\logo.jpg'} }
//
//  aDados - Array contendo subarrays de 2 posi��es do tipo caracter:
//             1) Vari�vel a ser preenchida
//             2) Texto para preencher
//
//           Exemplo: aDados := { {'{EMPRESA}', 'MINHA EMPRESA LTDA'},;
//                                {'{NOME}'   , 'FULANO DE TAL'},;
//                                {'{VALOR}'  , '8.900,98'}}
//
//  aRepete - (Opcional) Array contendo subarrays de 3 posi��es, sendo as 2 primeiras do tipo caracter e a terceira do tipo array,
//            que informar� estruturas de repeti��o, caso houver:
//              1) Marca��o do in�cio da repeti��o
//              2) Marca��o do final da repeti��o
//              3) Array contendo subarrays com a mesma estrutura do aDados, ou seja, contendo as vari�veis a serem preenchidas e
//                 os textos para preenchimento na estrutura de repeti��o, para cada linha.
//
//            Exemplo: aItens1 := { {'{NUMERO}'   , '001'},;
//                                  {'{DESCRICAO}', 'TINTA'}}
//                     aItens2 := { {'{NUMERO}'   , '002'},;
//                                  {'{DESCRICAO}', 'PAPEL'}}
//                     aDadosR := { aItens1, aItens2 }
//                     aRepete := { {'{ITENS_INICIO}', '{ITENS_FINAL}', aDadosR},;
//                                  {'{OUTRO_INICIO}', '{OUTRO_FINAL}', aDadosO}}
//
//  cVisual - (Opcional) Caminho local do visualizador do arquivo html.
//            Se este par�metro for ignorado, o programa ir� tentar copiar o arquivo MyBrwRel.exe da pasta Protheus_Data,
//            e exibir� o relat�rio neste execut�vel. Caso n�o seja poss�vel, o relat�rio ser� exibido no Internet Explorer.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	Local nI, nArq, nPosI, nPosF
	Local aNovo, aDAuxP := {}, aDAuxS := {}
	Local cArq, cLinha
	
	If Len(aArq) < 1 .or. ValType(aArq) != 'A'
		Return 'O primeiro par�metro deve ser um array com no m�nimo uma posi��o'
	EndIf
	
	cArq := aArq[1][1]+aArq[1][2]
	
	For nI := 1 to Len(aArq)
		If '.' $ aArq[nI][2]
			Delete File(aArq[nI][1]+aArq[nI][2])
		Else
			MakeDir(aArq[nI][1]+aArq[nI][2])
		EndIf
	Next nI
	
	For nI := 1 to Len(aArq)
		If '.' $ aArq[nI][2]
			CPYS2T(aArq[nI][3], aArq[nI][1], .T.)
		EndIf
	Next nI
	
	Delete File('C:\Windows\temp\MyBrwRel.exe')
	CPYS2T('\MyBrwRel.exe', 'C:\Windows\temp', .T.)
	
	aNovo := U_MyLeArq(cArq)
	For nI := 1 to Len(aDados)
		cLinha := StrTran(AllTrim(aDados[nI][2]), chr(13), '<br />')
		If Len(cLinha) == 0
			cLinha := '&nbsp;'
		EndIf
		aAdd(aDAuxP, aDados[nI][1])
		aAdd(aDAuxS, cLinha)
	Next nI
	aNovo := U_MySubstArr(aNovo, aDAuxP, aDAuxS)
	
	If aRepete != nil
		For nI := 1 to Len(aRepete)
			aNovo := U_MyRepetArr(aNovo, aRepete[nI])
		Next nI
	EndIf
	
	Delete File(cArq)
	
	nArq := fCreate(cArq)
	If fError() != 0
		Return 'Erro ao criar o arquivo: '+Str(fError())
	EndIf
	
	aEval(aNovo, {|cLinha| fWrite(nArq, cLinha, len(cLinha))})
	
	If !fClose(nArq)
		Return 'Erro ao fechar o arquivo: '+Str(fError())
	EndIf
	                                                    
	If cVisual != nil
		WaitRun(cVisual+' '+cArq, 1)
	ElseIf File('C:\Windows\temp\MyBrwRel.exe')
		WaitRun('C:\Windows\temp\MyBrwRel.exe '+cArq, 1)
	Else
		ShellExecute('open', 'iexplore.exe', cArq, '', 1)
	EndIf
Return Nil
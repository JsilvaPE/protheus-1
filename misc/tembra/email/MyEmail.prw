//#define TESTE
//#define EMAIL_TESTE 'thieres.tembra@transdourada.com.br'

/*User Function MyTDT()
	Local lEmail
	Local aDados := {}
	aAdd(aDados, 'cotacao@transdourada.com.br')
	aAdd(aDados, 'thierestembra@gmail.com')
	aAdd(aDados, 'teste de envio msiga')
	aAdd(aDados, 'corpo da mensagem'+chr(13)+chr(10)+'blablabla<br /><b>negrito</b>')
	
	lEmail := U_MyEmail('smtp.gmail.com', 465, 'cotacao@transdourada.com.br', 'c0t4w3b-', 'SSL', aDados)
	If lEmail
		Alert('Enviado')
	Else
		Alert('Erro ao enviar')
	EndIf
Return Nil*/

User Function MyEmail(cSMTP, nPort, cUser, cPass, cAuth, aDados)
	Local oSMTP := Nil
	Local nRet := 0, nI
	Local cFrom, cTo, cSubject, cBody, cCC, cBCC, aAnexo, nPrio
	Local lOk := .T.
	
	If ValType(aDados) == 'A'
		If ValType(aDados[1]) <> 'A'
			If Len(aDados) >= 4
				If( aDados[1] == Nil, lOk := .F.  , cFrom    := aDados[1] )
				If( aDados[2] == Nil, lOk := .F.  , cTo      := aDados[2] )
				If( aDados[3] == Nil, lOk := .F.  , cSubject := aDados[3] )
				If( aDados[4] == Nil, lOk := .F.  , cBody    := aDados[4] )
				If !lOk
					Return .F.
				EndIf
				If( Len(aDados) >= 5, (If( aDados[5] == Nil, cCC    := '', cCC      := aDados[5] )), cCC    := '' )
				If( Len(aDados) >= 6, (If( aDados[6] == Nil, cBCC   := '', cBCC     := aDados[6] )), cBCC   := '' )
				If( Len(aDados) >= 7, (If( aDados[7] == Nil, aAnexo := {}, aAnexo   := aDados[7] )), aAnexo := {} )
				If( Len(aDados) >= 8, (If( aDados[8] == Nil, nPrio  := 3 , nPrio    := aDados[8] )), nPrio  := 3  )
			Else
				Return .F.
			EndIf
		EndIf
	Else
		Return .F.
	EndIf
	
	oSMTP := TMailManager():New()
	If cAuth <> Nil
		If cAuth == 'SSL'
			oSMTP:SetUseSSL(.T.)
		ElseIf cAuth == 'TLS'
			oSMTP:SetUseTLS(.T.)
		EndIf
	EndIf
	
	oSMTP:Init('', cSMTP, cUser, cPass, , If(nPort==Nil,25,nPort))
	oSMTP:SetSMTPTimeOut(30)
	
	nRet := oSMTP:SMTPConnect()
	If nRet <> 0
		Return .F.
	EndIf
	
	nRet := oSMTP:SMTPAuth(cUser, cPass)
	If nRet <> 0
		Return .F.
	EndIf
	
	If ValType(aDados[1]) == 'A'
		For nI := 1 to Len(aDados)
			If Len(aDados[nI]) >= 4
				lOk := .T.
				If( aDados[nI][1] == Nil, lOk := .F.  , cFrom    := aDados[nI][1] )
				If( aDados[nI][2] == Nil, lOk := .F.  , cTo      := aDados[nI][2] )
				If( aDados[nI][3] == Nil, lOk := .F.  , cSubject := aDados[nI][3] )
				If( aDados[nI][4] == Nil, lOk := .F.  , cBody    := aDados[nI][4] )
				If lOk
					If( Len(aDados[nI]) >= 5, (If( aDados[nI][5] == Nil, cCC    := '', cCC      := aDados[nI][5] )), cCC    := '' )
					If( Len(aDados[nI]) >= 6, (If( aDados[nI][6] == Nil, cBCC   := '', cBCC     := aDados[nI][6] )), cBCC   := '' )
					If( Len(aDados[nI]) >= 7, (If( aDados[nI][7] == Nil, aAnexo := {}, aAnexo   := aDados[nI][7] )), aAnexo := {} )
					If( Len(aDados[nI]) >= 8, (If( aDados[nI][8] == Nil, nPrio  := 3 , nPrio    := aDados[nI][8] )), nPrio  := 3  )
				
					nRet := oSMTP:SendMail(cFrom, cTo, cSubject, cBody, cCC, cBCC, aAnexo, Len(aAnexo), nPrio)
					If nRet <> 0
						Alert('Erro ao enviar email #' + cValToChar(nI) + chr(13) + chr(10) + oSMTP:GetErrorString(nRet))
					EndIf
				EndIf
			EndIf
		Next nI
	Else                       
		#ifdef TESTE
			cTo  := EMAIL_TESTE
			cCC  := ''
			cBCC := ''
		#endif
		nRet := oSMTP:SendMail(cFrom, cTo, cSubject, cBody, cCC, cBCC, aAnexo, Len(aAnexo), nPrio)
		If nRet <> 0
			Alert('Erro ao enviar email' + chr(13) + chr(10) + oSMTP:GetErrorString(nRet))
			Return .F.
		EndIf
	EndIf
	
	nRet := oSMTP:SMTPDisconnect()
	If nRet <> 0
		Return .F.
	EndIf
Return .T.
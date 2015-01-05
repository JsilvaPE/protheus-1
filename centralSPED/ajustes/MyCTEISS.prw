#include 'rwmake.ch'
#include 'protheus.ch'
#include 'topconn.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyCTEISS()
///////////////////////////////////////////////////////////////////////////////
// Data : 
// User : Thieres Tembra
// Desc : Esta rotina modifica todos os registros da tabela SFT no Livro Fiscal
//        de sa�da que possuem a esp�cie CTE e est�o marcados como NOTA FISCAL
//        DE SERVI�O, para que assim sejam gerados os registros D190 no SPED
//        Fiscal.
//
//        OBS1: Esta rotina foi desenvolvida inicialmente para a gera��o do SPED
//        Fiscal de Novembro/2012 da Transdourada, CT-e s�rie 004.
//
//        OBS2: Ap�s cada ajuste dever� ser feito posteriormente a restaura��o.
//
//        OBS2: Somente o Administrador poder� executar a rotina.
///////////////////////////////////////////////////////////////////////////////
Local cTitulo := 'CTE com ISS'
Local cPerg := '#MyCTEISS '
Local aArea := GetArea()
Local aAreaSFT := SFT->(GetArea())

If Upper(AllTrim(cUserName)) <> 'ADMINISTRADOR'
	Alert('Rotina liberada somente para o Administrador.')
	Return Nil
ElseIf Aviso('Aten��o','Esta rotina ir� modificar todos os registros da tabela SFT ' +;
'no Livro Fiscal de sa�da que possuem a esp�cie CTE e est�o marcados como NOTA ' +;
'FISCAL DE SERVI�O, para que assim sejam gerados os registros D190 no SPED ' +;
'Fiscal. Deseja prosseguir?',{'Sim','N�o'}) == 2
	Return Nil
EndIf

CriaSX1(cPerg)

If !Pergunte(cPerg, .T., cTitulo)
	Return Nil
EndIf

If MV_PAR01 == Nil .or. MV_PAR01 == CTOD('') .or. MV_PAR02 == Nil .or. MV_PAR02 == CTOD('')
	Alert('Informe os per�odos a serem verificados.')
	Return Nil
ElseIf MV_PAR01 > MV_PAR02
	Alert('A data final deve ser maior que a data inicial.')
	Return Nil
EndIf

Processa({|| Executa() }, cTitulo, 'Aguarde...')

SFT->(RestArea(aAreaSFT))
RestArea(aArea)

Return Nil

/* ---------------- */

Static Function Executa()

//ajuste
If MV_PAR03 == 1
	If Ajusta()
		MsgAlert('Os registros foram ajustados com sucesso.')
	Else
		Alert('N�o foi poss�vel ajustar os registros.')
	EndIf
//restaura��o
ElseIf MV_PAR03 == 2
	If Restaura()
		MsgAlert('Os registros foram restaurados com sucesso.')
	Else
		Alert('N�o foi poss�vel restaurar os registros.')
	EndIf
EndIf

Return Nil

/* ---------------- */

Static Function Restaura(lVerifica)

Local lOk  := .F.
Local nQtd := 0
Local cQry
Local aQry := {}
Local aDesc := {}
Local lErro := .F.

cQry := CRLF + " SELECT"
cQry += CRLF + "        R_E_C_N_O_"
cQry += CRLF + " FROM " + RetSqlName('SFT')
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL  = 'my'"
cQry += CRLF + "   AND FT_MSFIL   = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
cQry += CRLF + "   AND FT_ESPECIE = 'CTE'"
cQry += CRLF + "   AND FT_TIPO    = 'S'"
cQry += CRLF + "   AND FT_TIPOMOV = 'S'"

cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQry),'MQRY',.T.)

MQRY->(dbEval({|| nQtd++ }))

If nQtd > 0
	lOk := .T.
	If !lVerifica
		//restaura de fato
		lOk := .F.
		
		//apaga filial preenchida relacionando com a filial my
		aAdd(aDesc, 'Apagando registros ajustados..')
		cQry := CRLF + " UPDATE SFTU"
		cQry += CRLF + " SET D_E_L_E_T_ = '*'"
		cQry += CRLF + "    ,R_E_C_D_E_L_ = SFTU.R_E_C_N_O_"
		cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFTU"
		cQry += CRLF + "     ," + RetSqlName('SFT') + " SFTA"
		cQry += CRLF + " WHERE SFTU.D_E_L_E_T_ <> '*'"
		cQry += CRLF + "   AND SFTA.D_E_L_E_T_ <> '*'"
		cQry += CRLF + "   AND SFTU.FT_FILIAL = '" + xFilial('SFT') + "'"
		cQry += CRLF + "   AND SFTA.FT_FILIAL = 'my'"
		cQry += CRLF + "   AND SFTA.FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
		cQry += CRLF + "   AND SFTA.FT_ESPECIE = 'CTE'"
		cQry += CRLF + "   AND SFTA.FT_TIPO    = 'S'"
		cQry += CRLF + "   AND SFTA.FT_TIPOMOV = 'S'"
		cQry += CRLF + "   AND SFTU.FT_FILIAL  = SFTA.FT_MSFIL"
		cQry += CRLF + "   AND SFTU.FT_TIPOMOV = SFTA.FT_TIPOMOV"
		cQry += CRLF + "   AND SFTU.FT_SERIE   = SFTA.FT_SERIE"
		cQry += CRLF + "   AND SFTU.FT_NFISCAL = SFTA.FT_NFISCAL"
		cQry += CRLF + "   AND SFTU.FT_CLIEFOR = SFTA.FT_CLIEFOR"
		cQry += CRLF + "   AND SFTU.FT_LOJA    = SFTA.FT_LOJA"
		cQry += CRLF + "   AND SFTU.FT_ITEM    = SFTA.FT_ITEM"
		cQry += CRLF + "   AND SFTU.FT_PRODUTO = SFTA.FT_PRODUTO"
		aAdd(aQry, cQry)
		
		//restaura filial my
		aAdd(aDesc, 'Restaurando registros originais..')
		cQry := CRLF + " UPDATE " + RetSqlName('SFT')
		cQry += CRLF + " SET FT_FILIAL = FT_MSFIL"
		cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
		cQry += CRLF + "   AND FT_FILIAL  = 'my'"
		cQry += CRLF + "   AND FT_MSFIL   = '" + xFilial('SFT') + "'"
		cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
		cQry += CRLF + "   AND FT_ESPECIE = 'CTE'"
		cQry += CRLF + "   AND FT_TIPO    = 'S'"
		cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
		aAdd(aQry, cQry)
		
		nTam := Len(aQry)
		
		ProcRegua(nTam)
		
		For nI := 1 to nTam
			IncProc('Restaurando: ' + cValToChar(nI) + '/' + cValToChar(nTam) + ' - ' + aDesc[nI])
			cQry := aQry[nI]
			nRet := TCSQLExec(cQry)
			If nRet <> 0
				MsgAlert('Erro Restaura��o ' + cValToChar(nI) + '/' + cValToChar(nTam) + ':' + cQry + CRLF + CRLF + TCSQLError())
				lErro := .T.
				Exit
			EndIf
		Next nI
		
		If !lErro
			lOk := .T.
		EndIf
	EndIf
Else
	If !lVerifica
		MsgAlert('N�o existem registros a serem restaurados no per�odo informado.')
	EndIf
EndIf

MQRY->(dbCloseArea())

Return lOk

/* ---------------- */

Static Function Ajusta()

Local lOk  := .F.
Local cQry
Local lErro := .F.
Local cFile

//verifica se h� algo a ser restaurado
If Restaura(.T.)
	//se houver n�o realiza ajuste
	MsgAlert('Existem registros referente ao per�odo informado pendentes ' +;
	'de serem restaurados. Enquanto n�o for executada a opera��o de ' +;
	'restaura��o no per�odo n�o ser� poss�vel realizar outro ajuste.')
Else
	//se n�o houver realiza o ajuste
	ProcRegua(4)
	
	//copia registros para arquivo dbf
	cQry := CRLF + " SELECT *"
	cQry += CRLF + " FROM " + RetSqlName('SFT')
	cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL  = '" + xFilial('SFT') + "'"
	cQry += CRLF + "   AND FT_FILIAL  = FT_MSFIL"
	cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQry += CRLF + "   AND FT_ESPECIE = 'CTE'"
	cQry += CRLF + "   AND FT_TIPO    = 'S'"
	cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
	
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQry),'MQRY',.T.)
	
	dbSelectArea('MQRY')
	Set Filter To
	MQRY->(dbGoTop())
	nQtd := 0
	MQRY->(dbEval({|| nQtd++ }))
	If nQtd > 0
		MQRY->(dbGoTop())
		IncProc('Ajustando: 1/4 - Copiando ' + cValToChar(nQtd) + ' registros..')
		cFile := '\mycteiss_' + DTOS(MV_PAR01) + '-' + DTOS(MV_PAR02) + '_' + DTOS(Date()) + '_' + StrTran(Time(),':','') + '.dbf'
		Copy To &(cFile) Via 'DBFCDX'
		MQRY->(dbCloseArea())
		
		//modifica registros copiados na tabela DBF
		IncProc('Ajustando: 2/4 - Modificando registros copiados..')
		dbUseArea(.T.,'DBFCDX',cFile,'MQRY',.T.)
		While !MQRY->(Eof())
			RecLock('MQRY', .F.)
			MQRY->FT_CODISS  := ''
			MQRY->FT_ALIQICM := 0
			MQRY->FT_BASEICM := 0
			MQRY->FT_VALICM  := 0
			MQRY->FT_OUTRICM := FT_VALCONT
			MQRY->FT_TIPO    := ''
			MQRY->FT_ALIQSOL := 0
			MQRY->(MsUnlock())
			
			MQRY->(dbSkip())
		EndDo
		MQRY->(dbCloseArea())
	
		//atualiza registros adicionando filial my
		cQry := CRLF + " UPDATE " + RetSqlName('SFT')
		cQry += CRLF + " SET FT_FILIAL = 'my'"
		cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
		cQry += CRLF + "   AND FT_FILIAL  = '" + xFilial('SFT') + "'"
		cQry += CRLF + "   AND FT_FILIAL  = FT_MSFIL"
		cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
		cQry += CRLF + "   AND FT_ESPECIE = 'CTE'"
		cQry += CRLF + "   AND FT_TIPO    = 'S'"
		cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
		
		IncProc('Ajustando: 3/4 - Adicionado flag de restaura��o..')
		nRet := TCSQLExec(cQry)
		If nRet <> 0
			MsgAlert('Erro Ajuste ' + cValToChar(nI) + '/' + cValToChar(nTam) + ':' + cQry + CRLF + CRLF + TCSQLError())
			lErro := .T.
		EndIf
		
		If !lErro
			//copiando novos registros modificados
			IncProc('Ajustando: 4/4 - Inserindo registros modificados..')
			dbSelectArea('SFT')
			Append From &(cFile)
			
			lOk := .T.
		EndIf
	Else
		MsgAlert('N�o existem registros a serem ajustados.')
		MQRY->(dbCloseArea())
	EndIf
EndIf

Return lOk

/* ---------------- */

Static Function CriaSX1(cPerg)

Local nTamGrp := Len(SX1->X1_GRUPO)
Local aHelpPor := {}, aHelpEng := {}, aHelpSpa := {}
Local cNome

aHelpPor := {}
aAdd(aHelpPor, 'Informe a data inicial/final para    ')
aAdd(aHelpPor, 'processamento das notas.             ')
cNome := 'Data inicial'
PutSx1(PadR(cPerg,nTamGrp), '01', cNome, cNome, cNome,;
'MV_CH1', 'D', 8, 0, 0, 'G', '', '', '', '', 'MV_PAR01',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

cNome := 'Data final'
PutSx1(PadR(cPerg,nTamGrp), '02', cNome, cNome, cNome,;
'MV_CH2', 'D', 8, 0, 0, 'G', '', '', '', '', 'MV_PAR02',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Selecione a opera��o que deseja      ')
aAdd(aHelpPor, 'efetuar.                             ')
cNome := 'Opera��o'
PutSx1(PadR(cPerg,nTamGrp), '03', cNome, cNome, cNome,;
'MV_CH3', 'N', 1, 0, 1, 'C', '', '', '', '', 'MV_PAR03',;
'Ajuste', 'Ajuste', 'Ajuste', '',;
'Restaura��o', 'Restaura��o', 'Restaura��o',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
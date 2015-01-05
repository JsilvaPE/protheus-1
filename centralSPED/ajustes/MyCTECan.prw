#include 'rwmake.ch'
#include 'protheus.ch'
#include 'topconn.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyCTECan()
///////////////////////////////////////////////////////////////////////////////
// Data : 06/11/14
// User : Thieres Tembra
// Desc : Esta rotina modifica todos os registros da tabela SFT no Livro Fiscal
//        de saída que possuem a espécie CTE e estão marcados como CANCELADOS,
//        para que assim sejam gerados os registros D200 no SPED PIS/COFINS
//        corretamente.
//
//        OBS1: Esta rotina foi desenvolvida inicialmente para a geração do SPED
//        PIS/COFINS de 2012/2013 da Transdourada, até que a TOTVS retire a
//        validação de 7 dias entre F3_ENTRADA e F3_DTCANC.
//
//        OBS2: Após cada ajuste deverá ser feito posteriormente a restauração.
//
//        OBS2: Somente o Administrador poderá executar a rotina.
///////////////////////////////////////////////////////////////////////////////
Local cTitulo := 'CTE Cancelados'
Local cPerg := '#MyCTECan '
Local aArea := GetArea()
Local aAreaSFT := SFT->(GetArea())

If Upper(AllTrim(cUserName)) <> 'ADMINISTRADOR'
	Alert('Rotina liberada somente para o Administrador.')
	Return Nil
ElseIf Aviso('Atenção','Esta rotina irá modificar todos os registros da tabela SFT ' +;
'no Livro Fiscal de saída que possuem a espécie CTE e estão marcados como CANCELADOS ' +;
'para que assim sejam gerados os registros D200 no SPED PIS/COFINS. ' +;
'Deseja prosseguir?',{'Sim','Não'}) == 2
	Return Nil
EndIf

CriaSX1(cPerg)

If !Pergunte(cPerg, .T., cTitulo)
	Return Nil
EndIf

If MV_PAR01 == Nil .or. MV_PAR01 == CTOD('') .or. MV_PAR02 == Nil .or. MV_PAR02 == CTOD('')
	Alert('Informe os períodos a serem verificados.')
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
		Alert('Não foi possível ajustar os registros.')
	EndIf
//restauração
ElseIf MV_PAR03 == 2
	If Restaura()
		MsgAlert('Os registros foram restaurados com sucesso.')
	Else
		Alert('Não foi possível restaurar os registros.')
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
cQry += CRLF + "   AND FT_FILIAL  = 'M' + RIGHT(FT_MSFIL,1)"
cQry += CRLF + "   AND FT_MSFIL   = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
cQry += CRLF + "   AND FT_ESPECIE = 'CTE'"
cQry += CRLF + "   AND FT_DTCANC  <> ''"
cQry += CRLF + "   AND FT_TIPOMOV = 'S'"

cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQry),'MQRY',.T.)

MQRY->(dbEval({|| nQtd++ }))

If nQtd > 0
	lOk := .T.
	If !lVerifica
		//restaura de fato
		lOk := .F.
		
		//restaura filial MN
		aAdd(aDesc, 'Restaurando registros originais..')
		cQry := CRLF + " UPDATE " + RetSqlName('SFT')
		cQry += CRLF + " SET FT_FILIAL = FT_MSFIL"
		cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
		cQry += CRLF + "   AND FT_FILIAL  = 'M' + RIGHT(FT_MSFIL,1)"
		cQry += CRLF + "   AND FT_MSFIL   = '" + xFilial('SFT') + "'"
		cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
		cQry += CRLF + "   AND FT_ESPECIE = 'CTE'"
		cQry += CRLF + "   AND FT_DTCANC  <> ''"
		cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
		aAdd(aQry, cQry)
		
		nTam := Len(aQry)
		
		ProcRegua(nTam)
		
		For nI := 1 to nTam
			IncProc('Restaurando: ' + cValToChar(nI) + '/' + cValToChar(nTam) + ' - ' + aDesc[nI])
			cQry := aQry[nI]
			nRet := TCSQLExec(cQry)
			If nRet <> 0
				MsgAlert('Erro Restauração ' + cValToChar(nI) + '/' + cValToChar(nTam) + ':' + cQry + CRLF + CRLF + TCSQLError())
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
		MsgAlert('Não existem registros a serem restaurados no período informado.')
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

//verifica se há algo a ser restaurado
If Restaura(.T.)
	//se houver não realiza ajuste
	MsgAlert('Existem registros referente ao período informado pendentes ' +;
	'de serem restaurados. Enquanto não for executada a operação de ' +;
	'restauração no período não será possível realizar outro ajuste.')
Else
	//se não houver realiza o ajuste
	ProcRegua(2)
	
	//copia registros para arquivo dbf
	cQry := CRLF + " SELECT *"
	cQry += CRLF + " FROM " + RetSqlName('SFT')
	cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL  = '" + xFilial('SFT') + "'"
	cQry += CRLF + "   AND FT_FILIAL  = FT_MSFIL"
	cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQry += CRLF + "   AND FT_ESPECIE = 'CTE'"
	cQry += CRLF + "   AND FT_DTCANC  <> ''"
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
		IncProc('Ajustando: 1/2 - Copiando ' + cValToChar(nQtd) + ' registros..')
		cFile := '\myctecan_' + DTOS(MV_PAR01) + '-' + DTOS(MV_PAR02) + '_' + DTOS(Date()) + '_' + StrTran(Time(),':','') + '.dbf'
		Copy To &(cFile) Via 'DBFCDX'
		MQRY->(dbCloseArea())
	
		//atualiza registros adicionando filial MN
		cQry := CRLF + " UPDATE " + RetSqlName('SFT')
		cQry += CRLF + " SET FT_FILIAL = 'M' + RIGHT(FT_MSFIL,1)"
		cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
		cQry += CRLF + "   AND FT_FILIAL  = '" + xFilial('SFT') + "'"
		cQry += CRLF + "   AND FT_FILIAL  = FT_MSFIL"
		cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
		cQry += CRLF + "   AND FT_ESPECIE = 'CTE'"
		cQry += CRLF + "   AND FT_DTCANC  <> ''"
		cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
		
		IncProc('Ajustando: 2/2 - Marcando registros..')
		nRet := TCSQLExec(cQry)
		If nRet <> 0
			MsgAlert('Erro Ajuste ' + cValToChar(nI) + '/' + cValToChar(nTam) + ':' + cQry + CRLF + CRLF + TCSQLError())
			lErro := .T.
		EndIf
		
		If !lErro
			lOk := .T.
		EndIf
	Else
		MsgAlert('Não existem registros a serem ajustados.')
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
aAdd(aHelpPor, 'Selecione a operação que deseja      ')
aAdd(aHelpPor, 'efetuar.                             ')
cNome := 'Operação'
PutSx1(PadR(cPerg,nTamGrp), '03', cNome, cNome, cNome,;
'MV_CH3', 'N', 1, 0, 1, 'C', '', '', '', '', 'MV_PAR03',;
'Ajuste', 'Ajuste', 'Ajuste', '',;
'Restauração', 'Restauração', 'Restauração',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
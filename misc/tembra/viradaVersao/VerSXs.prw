#include "rwmake.ch"
#include 'protheus.ch'
#include "tbiconn.ch"
#include "topconn.ch"
User Function VerSXs()

Local aSM0 := { }
Local nX   := nI := 0
Local nTipo := 0

MsOpenDbf(.T.,"DBFCDX","SIGAMAT.EMP", "NEWSM0",.T.,.F.)
DbSetIndex("SIGAMAT.IND")
Set Deleted On
SET(_SET_DELETED, .T.)

DbSelectArea("NEWSM0")
NEWSM0->( dbSetOrder(1) )
NEWSM0->( dbGotop() )
DO While ! NEWSM0->( Eof() )
	If NEWSM0->M0_CODFIL <> "01"
		NEWSM0->( dbSkip() )
		Loop
	Endif
	Aadd(aSM0   , { NEWSM0->M0_CODIGO,NEWSM0->M0_CODFIL } )
	NEWSM0->( dbSkip() )
EndDo
If Select("NEWSM0") > 0
	dbSelectArea("NEWSM0")
	NEWSM0->(dbCloseArea())
Endif

nTipo := Aviso('VerSXs - Opção','Escolha a rotina que deseja executar:',{'Pack','Gatilho','Recria','X3Propri','Indice','Sair'})
/*aTab := {;
{'CCX','CCZ','DTC','SB9','SE2','SE5','SI3','SN5','SRV','STA','TP5','TP9','TPF','TPH','TQ0','TQ1','TS8'},;
{'CCZ','RFG','SB9','SC7','SE2','SE5','SY1'},;
{'CCZ','SB9','SE2','SE5'},;
{'CCZ','SC7','SE2','SE5'},;
{'CCZ','SB9','SC1','SC7','SE2','SE5','SY1'},;
{'CCZ','RFG','SB9','SC7','SE2','SE5'},;
{'CC4','CC9','CCA','CCB','CCC','CCD','CCH','CCZ','CTK','CV3','CVA','SE2','SE5'},;
{'CCZ'},;
{'CCZ'},;
{'CCZ'},;
{'CCZ'},;
{'ACJ','SBM'};
}*/
aTab := {;
{},;
{'SC5'},;
{},;
{},;
{},;
{},;
{},;
{},;
{},;
{},;
{},;
{};
}
aPropri := {;
'AK1_FASE','AK1_JUSTM','AK1_CODJM','DD4_CODOBS','FIM_CODFOR',;
'FIM_FORLOJ','RAX_FILIAL','RAX_CODIGO','RAX_SEQUEN','RAX_ALIGNX',;
'RAX_POSICX','RAX_POSICY','RAX_TEXTO','RB6_ATUAL','RHG_FILIAL',;
'RHG_CODIGO','RHG_DESC','C5_VEICULO','D1_CRDZFM','E1_TITPAI',;
'E1_SEQBX','E2_PROCPCC','E2_FORNPAI','E6_PARCDES','GK_FILIAL',;
'GL_FILIAL','GM_FILIAL','LG_SERPDV','LX_ALIQICM','P0_NOVO',;
'RA_MENSIND','TL_ITEMOP','TAU_MISSAO','TAU_VISAO','TAU_VALORE',;
'TB0_NUMCER','TB2_CODTRA','TB2_DESTRA','TBA_NUMMTR','TC8_FILIAL',;
'TC8_CODPRO','TC8_CODRES','TC8_NOMRES','TC8_TIPO','TC8_QUANT',;
'TC8_UM','TC9_FILIAL','TT8_FILIAL','TT8_CODBEM','TT8_CODCOM',;
'TT8_NOMCOM','TT8_CAPMAX','TT8_MEDIA';
}

For nX:=1 To Len(aSM0)
	
	/*
	  ---- PACK ----
	*/
	If nTipo == 1
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv( aSM0[nX][1],"01",,,'COM',GetEnvServer())
		SetModulo( "SIGACOM", "COM" )
		SetHideInd(.T.)
		Sleep( 1000 )	// aguarda 1 segundos para que as jobs IPC subam.
		__cLogSiga := "NNNNNNN"
		
		If GetMV("MV_TTS") != "S"
			PutMV("MV_TTS","S")
		EndIf
		
		ConOut( "Empresa " + aSM0[nX][1] + ' PACK DOS SXS '+Dtoc(Date())+' - '+Time() )
		PackSXS() // efetua um pack em todas as tabelas sxs e sindex
	ElseIf nTipo == 2
		
		/*
		  ---- SX7 - Gatilhos ----
		*/
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv( aSM0[nX][1],"01",,,'COM',GetEnvServer())
		SetModulo( "SIGACOM", "COM" )
		SetHideInd(.T.)
		Sleep( 1000 )	// aguarda 1 segundos para que as jobs IPC subam.
		__cLogSiga := "NNNNNNN"
		
		ConOut( "Empresa " + aSM0[nX][1] + ' LIMPEZA DOS GATILHOS '+Dtoc(Date())+' - '+Time() )
		ValidaSx7() // valida os gatilhos duplicados
	ElseIf nTipo == 3
		/*
		  ---- RECRIA TABELAS ----
		*/
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv( aSM0[nX][1],"01",,,'COM',GetEnvServer())
		SetModulo( "SIGACOM", "COM" )
		SetHideInd(.T.)
		Sleep( 1000 )	// aguarda 1 segundos para que as jobs IPC subam.
		__cLogSiga := "NNNNNNN"
		
		aTables := aTab[nX]
		For nI := 1 To Len( aTables )
			
			cFile := aTables [nI]
			If Select(cFile) == 0
				ChkFile( cFile, .F., cFile )
			Endif
			DbSelectArea(cFile)
			DbCloseArea()
			
			Conout( "Recriando tabela " + RetSqlName(cFile) )
			Conout( "***********************" )
			GeraTabNova( cFile, RetSqlName(cFile) )
			Conout( "***********************" )
			Conout( "tabela Recriada  " + RetSqlName(cFile) )
			Conout( " " )
			
		Next nI
	ElseIf nTipo == 4
	
		/*
		  ---- SX3 - Dicionario de Dados - X3_PROPRI = S ----
		*/
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv( aSM0[nX][1],"01",,,'COM',GetEnvServer())
		SetModulo( "SIGACOM", "COM" )
		SetHideInd(.T.)
		Sleep( 1000 )	// aguarda 1 segundos para que as jobs IPC subam.
		__cLogSiga := "NNNNNNN"
		
		ConOut( "Empresa " + aSM0[nX][1] + ' X3_PROPRI = S '+Dtoc(Date())+' - '+Time() )
		PropriSx3() // modidica o campo X3_PROPRI para S
	ElseIf nTipo == 5
	
		/*
		  ---- SIX - Índices
		*/
		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv( aSM0[nX][1],"01",,,'COM',GetEnvServer())
		SetModulo( "SIGACOM", "COM" )
		SetHideInd(.T.)
		Sleep( 1000 )	// aguarda 1 segundos para que as jobs IPC subam.
		__cLogSiga := "NNNNNNN"
		
		ConOut( "Empresa " + aSM0[nX][1] + ' Verificando Indices '+Dtoc(Date())+' - '+Time() )
		VerSIX() // compara existencia dos indices de backup com os padrões do sistema
	EndIf
	DbCloseAll()
	
Next nX

Return

Static Function GeraTabNova(cAlias,cFile)
Local cSource := cFile
Local cTarget := cSource+"_CPY"
Local cAlias  := iif(cAlias=Nil,Left(cFile,3),cAlias)
Local aCampos := {}
Local lRECDEL := .F.
Local cQuery
Local cVar1   := ""
Local aCampo  := {}
Local nI      := 0

If TCCanOpen( cTarget )
	TcDelFile( cTarget )
Endif

SX2->( dbSeek(cAlias) )
If !Empty(SX2->X2_UNICO)
	lRECDEL := .T.
Endif

SX3->( dbSetOrder(1) )
SX3->( dbSeek(cAlias) )
Do While ! SX3->( Eof() ) .And. SX3->X3_ARQUIVO == cAlias
	If SX3->X3_CONTEXT # "V" .And. (cAlias)->( FieldPos(AllTrim(SX3->X3_CAMPO)) ) > 0
		If Ascan(aCampo, SX3->X3_CAMPO ) == 0
			AADD(aCampo, SX3->X3_CAMPO )
			AADD(aCampos, { AllTrim(SX3->X3_CAMPO), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
		Else
			// o campo do SX3 duplicado sera excluido
			RecLock("SX3", .F.)
			SX3->(dbDelete())
			SX3->(MsUnlock())
		Endif
	EndIf
	SX3->( dbSkip() )
EndDo

If Len(aCampos) == 0
	Return
Endif

dbCreate( cTarget, aCampos, __cRDD)
If lRECDEL
	cVar1 := "ALTER TABLE "+cTarget+" ADD R_E_C_D_E_L_ INT NOT NULL CONSTRAINT "+cTarget+"_R_E_C_D_E_L__DF DEFAULT '    ' "
	TCSqlExec( cVar1 )
endif
TCRefresh( cTarget )

cQuery    := "INSERT INTO " + cTarget + " ( "

cTmpQuery    := ""
For nI := 1 To Len( aCampos )
	cTmpQuery    += aCampos[ nI, 1 ] + ", "
Next
cTmpQuery += "D_E_L_E_T_, R_E_C_N_O_"+iif(lRECDEL," ,R_E_C_D_E_L_ ","")+" ) "

cTmpQuery += "SELECT "
For nI := 1 To Len( aCampos )
	cTmpQuery += aCampos[ nI, 1 ] + ", "
Next
cTmpQuery += "D_E_L_E_T_, R_E_C_N_O_"+iif(lRECDEL," ,R_E_C_D_E_L_ "," ")

cQuery += cTmpQuery + " FROM  " + cSource

cRecno := GetNextAlias()
__cQuery    := "SELECT Count(0) AS PASSO FROM " + cSource + " (NOLOCK) "
dbUseArea(.T., __cRDD, TCGenQry(,,__cQuery), cRecno, .F., .T.)

nPasso := Int(((cRecno)->PASSO/1024 )) + 1
(cRecno)->(DbCloseArea())

cRecno := GetNextAlias()
__cQuery := "SELECT MIN(R_E_C_N_O_) MIN_RECNO, MAX(R_E_C_N_O_) MAX_RECNO FROM " + cSource + " (NOLOCK) "
dbUseArea(.T., __cRDD, TCGenQry(,,__cQuery), cRecno, .F., .T.)

nMin := (cRecno)->MIN_RECNO
nMax := (cRecno)->MAX_RECNO
(cRecno)->(DbCloseArea())

If nMax > 0
	lGerou := .T.
	__cQuery := cQuery
	For nReg := nMin To nMax Step 1024
		nRegIni := nReg
		nRegFim := nReg + 1023
		cQuery  := __cQuery + " WHERE R_E_C_N_O_ BETWEEN " + AllTrim(Str(nRegIni)) + " AND " + AllTrim(Str(nRegFim))
		if TCSqlExec( cQuery ) <> 0
			UserException( "Erro " + Chr(10) + TCSqlError() )
		endif
	Next
EndIf

TCRefresh( cSource )
TCRefresh( cTarget )

cRecno := GetNextAlias()
__cQuery := "SELECT Count(0) AS ORIGEM FROM " + cSource + " (NOLOCK) "
dbUseArea(.T., __cRDD, TCGenQry(,,__cQuery), cRecno, .F., .T.)
nOrigem := (cRecno)->ORIGEM
(cRecno)->(DbCloseArea())

cRecno := GetNextAlias()
__cQuery := "SELECT Count(0) AS DESTINO FROM " + cTarget + " (NOLOCK) "
dbUseArea(.T., __cRDD, TCGenQry(,,__cQuery), cRecno, .F., .T.)
nDestino := (cRecno)->DESTINO
(cRecno)->(DbCloseArea())

If nOrigem <> nDestino
	final("divergencia na tabela " + cSource )
Else // sucesso
	If Select(cAlias) > 0
		(cAlias)->( dbCloseArea() )
	Endif
	
	If TcDelFile( cSource )
		
		DbSelectArea(cAlias)
		If lRECDEL
			cVar1 := "ALTER TABLE "+cTarget+" ADD R_E_C_D_E_L_ INT NOT NULL CONSTRAINT "+cTarget+"_R_E_C_D_E_L__DF DEFAULT '    ' "
			TCSqlExec( cVar1 )
			cVar1 := "ALTER TABLE "+cSource+" ADD R_E_C_D_E_L_ INT NOT NULL CONSTRAINT "+cSource+"_R_E_C_D_E_L__DF DEFAULT '    ' "
			TCSqlExec( cVar1 )
		endif
		
		cRecno := GetNextAlias()
		__cQuery := "SELECT MIN(R_E_C_N_O_) MIN_RECNO, MAX(R_E_C_N_O_) MAX_RECNO FROM " + cTarget + " (NOLOCK) "
		dbUseArea(.T., __cRDD, TCGenQry(,,__cQuery), cRecno, .F., .T.)
		
		nMin   := (cRecno)->MIN_RECNO
		nMax   := (cRecno)->MAX_RECNO
		nPasso := (cRecno)->MAX_RECNO - (cRecno)->MIN_RECNO
		(cRecno)->(DbCloseArea())
		
		__cQuery := "INSERT INTO " + cSource + " ( " + cTmpQuery + " " + " FROM  " + cTarget
		For nReg := nMin To nMax Step 1024
			nRegIni := nReg
			nRegFim := nReg + 1023
			cQuery  := __cQuery + " WHERE R_E_C_N_O_ BETWEEN " + AllTrim(Str(nRegIni)) + " AND " + AllTrim(Str(nRegFim))
			ConOut( " REGISTROS " + AllTrim(Str(nRegIni)) + " AND " + AllTrim(Str(nRegFim)) + " DA TABELA " + cSource )
			TCSqlExec( cQuery ) <> 0
		Next
		
		(cAlias)->( DbCloseArea() )
		TcDelFile( cTarget )
		
	Endif
	
Endif

Return

Static Function PackSXS(lPack)
Local aSX := { 'SX1','SX2','SX3','SX4','SX6','SX7','SX9','SXA','SXB','SXD','SXG','SXK','SXM','SXO','SXP','SXQ','SXR','SXS','SXT','SIX' }

Local cVar, cDBFFile, cIDXFile, xx

lPack := iif(lPack==Nil,.T.,lPack)

For xx := 1 To Len(aSX)
	DbSelectArea(cVar)
Next xx

For xx := 1 To Len(aSX)
	cVar := aSX[xx]
	cDBFFile := UPPER(cVar + cEmpAnt + "0" + GetDBExtension())
	cIDXFile := UPPER(cVar + cEmpAnt + "0" + RetIndExt())
	If cVar == "SIX" .And. ! File(cDBFFile)
		cDBFFile := UPPER("SINDEX" + GetDBExtension())
		cIDXFile := UPPER("SINDEX" + RetIndExt())
	Endif
	If File(cDBFFile) .And. File(cIDXFile)
		DbSelectArea(cVar)
		(cVar)->(DbCloseArea())
		If lPack .And. MsOpenDbf(.T.,__LocalDriver,cDBFFile, cVar,.F.,.F.) // EXCLUSIVO
			dbClearFilter()
			Pack
			(cVar)->(DbCloseArea())
			If File( cIDXFile )
				fErase( cIDXFile )
			EndIf
		Endif
	Endif
Next xx

Return

Static Function ValidaSx7()
Local aCampo  := {}
Local cX7_REGRA, cX7_CDOMIN, cX7_TIPO, cX7_SEEK, cX7_ALIAS, cX7_ORDEM, cX7_CHAVE, cX7_CONDIC

SX7->( dbSetOrder(1) )
SX7->( dbGoTop() )

cX7_REGRA  := SX7->X7_REGRA
cX7_CDOMIN := SX7->X7_CDOMIN
cX7_TIPO   := SX7->X7_TIPO
cX7_SEEK   := SX7->X7_SEEK
cX7_ALIAS  := SX7->X7_ALIAS
cX7_ORDEM  := SX7->X7_ORDEM
cX7_CHAVE  := SX7->X7_CHAVE
cX7_CONDIC := SX7->X7_CONDIC

Do While ! SX7->( Eof() )
	If Ascan(aCampo, SX7->(X7_CAMPO+X7_SEQUENC) ) == 0
		AADD(aCampo, SX7->(X7_CAMPO+X7_SEQUENC) )
		cX7_REGRA  := SX7->X7_REGRA
		cX7_CDOMIN := SX7->X7_CDOMIN
		cX7_TIPO   := SX7->X7_TIPO
		cX7_SEEK   := SX7->X7_SEEK
		cX7_ALIAS  := SX7->X7_ALIAS
		cX7_ORDEM  := SX7->X7_ORDEM
		cX7_CHAVE  := SX7->X7_CHAVE
		cX7_CONDIC := SX7->X7_CONDIC
	Else
		// o gatilho duplicado sera excluido
		If cX7_REGRA == SX7->X7_REGRA .And. cX7_CDOMIN == SX7->X7_CDOMIN .And. cX7_TIPO  == SX7->X7_TIPO  .And. ;
			cX7_SEEK  == SX7->X7_SEEK  .And. cX7_ALIAS  == SX7->X7_ALIAS  .And. cX7_ORDEM == SX7->X7_ORDEM .And. ;
			cX7_CHAVE == SX7->X7_CHAVE .And. cX7_CONDIC == SX7->X7_CONDIC
			ConOut( "Emp: "+cEmpant+" SX7 duplicado " + SX7->(X7_CAMPO+" - "+X7_SEQUENC) + ' - ' + Dtoc(Date())+' - '+Time() )
			RecLock("SX7", .F.)
			SX7->(dbDelete())
			SX7->(MsUnlock())
		Endif
	EndIf
	SX7->( dbSkip() )
EndDo

Return

Static Function PropriSx3()

SX3->( dbGoTop() )
While !SX3->(Eof())
	If aScan(aPropri, AllTrim(SX3->X3_CAMPO)) <> 0 .and. SX3->X3_PROPRI <> 'S'
		ConOut( "Emp: "+cEmpant+" SX3 campo " + AllTrim(SX3->X3_CAMPO) + ' alterado - ' + Dtoc(Date())+' - '+Time() )
		RecLock("SX3", .F.)
		SX3->X3_PROPRI := 'S'
		SX3->(MsUnlock())
	EndIf
	SX3->(dbSkip())
EndDo

Return

Static Function VerSIX()

Local cLinha := ''
Local nArq1 := fCreate('\system\BKP-PRE-VIRADA\SIX\'+cEmpAnt+'-Identico.txt')
Local nArq2 := fCreate('\system\BKP-PRE-VIRADA\SIX\'+cEmpAnt+'-ChaveIgual-OrdemDif.txt')
Local nArq3 := fCreate('\system\BKP-PRE-VIRADA\SIX\'+cEmpAnt+'-ChaveDif-OrdemIgual.txt')

cLinha := 'Apagar os índices abaixo do arquivo backup' + CRLF + CRLF
If fWrite(nArq1, cLinha, Len(cLinha)) <> Len(cLinha)
	Alert('Erro ao escrever no Arq1: ' + CRLF + cLinha)
EndIf

cLinha := 'Verificar a utilização dos índices abaixo em fontes customizados, ' + CRLF + 'alterar a ordem nos mesmos e apagar os índices abaixo do arquivo backup' + CRLF + CRLF
If fWrite(nArq2, cLinha, Len(cLinha)) <> Len(cLinha)
	Alert('Erro ao escrever no Arq2: ' + CRLF + cLinha)
EndIf

cLinha := 'Verificar no SIX padrão a próxima ordem disponível para os índices ' + CRLF + 'abaixo. Verificar a utilização dos índices em fontes customizados, alterar a ordem nos mesmos nos fontes e no arquivo backup' + CRLF + CRLF
If fWrite(nArq3, cLinha, Len(cLinha)) <> Len(cLinha)
	Alert('Erro ao escrever no Arq3: ' + CRLF + cLinha)
EndIf

dbUseArea(.T.,'DBFCDX','\system\BKP-PRE-VIRADA\SIX\SIX'+cEmpAnt+'01.DBF','MSIX',.F.,.F.)
While !MSIX->(Eof())
	SIX->(dbGoTop())
	While !SIX->(Eof())
		If SIX->INDICE == MSIX->INDICE
			If SIX->CHAVE == MSIX->CHAVE
				If SIX->ORDEM == MSIX->ORDEM
					cLinha := MSIX->INDICE + '-' + MSIX->ORDEM + '-' + MSIX->CHAVE + CRLF
					If fWrite(nArq1, cLinha, Len(cLinha)) <> Len(cLinha)
						Alert('Erro ao escrever no Arq1: ' + CRLF + cLinha)
					EndIf
				Else
					cLinha := MSIX->INDICE + '-' + MSIX->ORDEM + '-' + MSIX->CHAVE + '  --> Nova ordem: ' + SIX->ORDEM + CRLF
					If fWrite(nArq2, cLinha, Len(cLinha)) <> Len(cLinha)
						Alert('Erro ao escrever no Arq2: ' + CRLF + cLinha)
					EndIf
				EndIf
			Else
				If SIX->ORDEM == MSIX->ORDEM
					cLinha := MSIX->INDICE + '-' + MSIX->ORDEM + '-' + MSIX->CHAVE + '  --> Verificar nova ordem!' + CRLF
					If fWrite(nArq3, cLinha, Len(cLinha)) <> Len(cLinha)
						Alert('Erro ao escrever no Arq3: ' + CRLF + cLinha)
					EndIf
				EndIf
			EndIf
		EndIf
		SIX->(dbSkip())
	EndDo
	
	MSIX->(dbSkip())
EndDo
MSIX->(dbCloseArea())

fClose(nArq1)
fClose(nArq2)
fClose(nArq3)

Return

Static FUNCTION Aviso(cCaption,cMensagem,aBotoes,nSize,cCaption2)

Local aBtn      := {}
Local ny       	:= 0
Local nx       	:= 0
Local aSize		:= { 	{134,304,35,155,35,113,51},; 	// Tamanho 1
{134,450,35,155,35,185,51},;	// Tamanho 2
{200,450,35,210,50,185,82} }	// Tamanho 3
Private oDlgAviso
Private nOpcAviso	:= 0

cCaption2 := Iif(cCaption2 == Nil, cCaption, cCaption2)

If nSize == Nil
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o numero de botoes Max. 5 e o tamanho da Msg.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	Len(aBotoes) > 3
		If Len(cMensagem) > 286
			nSize := 3
		Else
			nSize := 2
		EndIf
	Else
		Do Case
			Case Len(cMensagem) > 170 .And. Len(cMensagem) < 250
				nSize := 2
			Case Len(cMensagem) >= 250
				nSize := 3
			OtherWise
				nSize := 1
		EndCase
	EndIf
EndIf
DEFINE MSDIALOG oDlgAviso FROM 0,0 TO aSize[nSize][1],aSize[nSize][2] TITLE cCaption Of oDlgAviso PIXEL
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
@ 0, 0 BITMAP oBmp RESNAME "LOGIN" oF oDlgAviso SIZE aSize[nSize][3],aSize[nSize][4] NOBORDER WHEN .F. PIXEL
@ 11 ,35  TO 13 ,400 LABEL '' OF oDlgAviso PIXEL
@ 3  ,37  SAY cCaption2 Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold
@ 16 ,38  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nSize][6],aSize[nSize][5]
TButton():New(1000,1000," ",oDlgAviso,{||Nil},32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
ny := (aSize[nSize][2]/2)-36
For nx:=1 to Len(aBotoes)
	cAction:="{||nOpcAviso:="+Str(Len(aBotoes)-nx+1)+",oDlgAviso:End()}"
	bAction:=&(cAction)
	aAdd(aBtn, TButton():New(aSize[nSize][7],ny,OemToAnsi(AllTrim(aBotoes[Len(aBotoes)-nx+1])), oDlgAviso,bAction,32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.))
	aBtn[Len(aBtn)]:SetCss("QPushButton{color:#000};")
	ny -= 35
Next nx

ACTIVATE MSDIALOG oDlgAviso CENTERED

Return (nOpcAviso)
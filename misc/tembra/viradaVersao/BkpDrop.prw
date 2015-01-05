#include 'protheus.ch'
User Function BkpDrop()

Local aTab := {;
'CCX010','CCZ010','CD9010','DTC010','FIM010',;
'RA8010','RDP010','SB9010','SFV010','SFW010',;
'SI3010','SN5010','SN9010','SRV010','TP9070',;
'TQ0070','TS8070','CCZ020','CD6020','CD9020',;
'FIM020','SB9020','SC3020','SC7020','SC8020',;
'SF5020','SFK020','SFV020','SFW020','SN9020',;
'SY1020','CCZ030','CD9030','SB9030','SC7030',;
'SFV030','SFW030','CCZ040','CD9040','SC1040',;
'SC7040','SFV040','SFW040','SN9040','SY1040',;
'CCZ050','CD9050','SB9050','SC1050','SC3050',;
'SC7050','SC8050','SFV050','SFW050','SY1050',;
'CCZ060','CD9060','CDA060','FIM060','SB9060',;
'SBZ060','SC1060','SC3060','SC7060','SFV060',;
'SFW060','SN9060','SY1060','CC4080','CC6080',;
'CC9080','CCA080','CCB080','CCC080','CCD080',
'CCH080','CCZ080','CTK080','CV3080','CVA080',;
'SFV080','SFW080','CCZ090','SFV090','SFW090',;
'AFU910','CCZ910','RDP910','SFT910','SFV910',;
'SFW910','AFU920','CCZ920','SFT920','SFV920',;
'SFW920','AFU960','CCZ960','SFT960','SFV960',;
'SFW960','AA1990','ACJ990','AFN990','AKS990',;
'CTO990','CV1990','DA1990','DT6990','SA2990',;
'SA3990','SB2990','SB6990','SB8990','SB9990',;
'SBE990','SBM990','SBU990','SC2990','SC4990',;
'SD5990','SDB990','SE4990','SEF990','SF5990',;
'SFC990','SRM990','SU7990,';
'CDM010','FIH010','FII010','FRD010','JA1010',;
'RFF010','RFG010','SE2010','SE5010','STA070',;
'CDM020','RFF020','RFG020','SE2020','SE5020',;
'STA020','CDM030','SE2030','SE5030','STA030',;
'CDM040','SE2040','SE5040','STA040','CDM050',;
'SE2050','SE5050','STA050','CDM060','RFF060',;
'RFG060','SE2060','SE5060','STA060','SE2080',;
'SE5080','FIH090','FII090','FRD090','SE2090',;
'SE5090','AFR910','AFT910','FI2910','FIA910',;
'FIE910','FIH910','FII910','FR3910','FRD910',;
'SE1910','SE2910','SE3910','SE5910','SE6910',;
'SEF910','SEV910','STA910','AFR920','AFT920',;
'FI2920','FIA920','FIE920','FIH920','FII920',;
'FR3920','FRD920','SE1920','SE2920','SE3920',;
'SE5920','SE6920','SEV920','STA920','AFR960',;
'AFT960','FI2960','FIA960','FIE960','FIH960',;
'FII960','FR3960','FRD960','SE1960','SE2960',;
'SE3960','SE5960','SE6960','SEV960','STA960',;
'FIH990','FII990','FRD990','SE2990','SE5990',;
'TP5070','TPH070','TPF070','TQ1070';
}
Local nMax, nI, nQtd
Local nTipo := 1
Local cFile

/*For nI := 1 to Len(aTab2)
	If aScan(aTab, aTab2[nI]) == 0
		aAdd(aTab, aTab2[nI])
	EndIf
Next nI*/

nTipo := Aviso('BkpDrop - Op豫o','Escolha a rotina que deseja executar:',{'Backup','Drop','Append','Sair'})

If nTipo == 4
	Return Nil
EndIf

RpcClearEnv()
RpcSetType(3)
RpcSetEnv('01','01',,,'COM',GetEnvServer())
SetModulo('SIGACOM', 'COM')
SetHideInd(.T.)
Sleep(1000)
__cInternet := Nil
__cLogSiga := 'NNNNNNN'

nMax := Len(aTab)
For nI := 1 to nMax
	cAlias := 'M'+Left(aTab[nI],3)
	ConOut(' Tabela ' + aTab[nI] + ' '+Dtoc(Date())+' - '+Time())
	dbUseArea(.T.,'TOPCONN',aTab[nI],cAlias)
	If Select(cAlias) <> 0
		dbSelectArea(cAlias)
		If nTipo == 1
			Set Filter To
			(cAlias)->(dbGoTop())
			nQtd := (cAlias)->(RecCount())
			If nQtd > 0
				ConOut('   > Copiando ' + cValToChar(nQtd) + ' registros...')
				Copy To '\system\BKP-PRE-VIRADA\' + Upper(aTab[nI]) + '.dbf' VIA 'DBFCDX'
			Else
				ConOut('   > Arquivo vazio!')
			EndIf
			(cAlias)->(dbCloseArea())
		ElseIf nTipo == 2
			(cAlias)->(dbCloseArea())
			cQry := 'DROP TABLE ' + aTab[nI]
			If TCSqlExec(cQry) < 0
				ConOut('   > Erro ao executar DROP: '+ TCSQLError())
			Else
				ConOut('   > DROP executado com sucesso!')
			EndIf
		ElseIf nTipo == 3
			cFile := '\system\BKP-PRE-VIRADA\' + Upper(aTab[nI]) + '.dbf'
			If !File(cFile)
				ConOut('   > Arquivo de backup inexistente!')
			Else
				ConOut('   > Restaurando ' + cFile + '...')
				Append From &(cFile)
			EndIf
			(cAlias)->(dbCloseArea())
		EndIf
	Else
		ConOut('   > Tabela inexistente!')
	EndIf
Next nI

dbCloseAll()

Return Nil

User Function CriaArr()

Local aLinha := U_MyLeArq('c:\erro_tab.txt')
Local aOut := {}
Local nI, nMax, nPos1, nPos2, nOut
Local cLinha

nMax := Len(aLinha)
For nI := 1 to nMax
	cLinha := aLinha[nI]
	//037
	nPos1 := At(' no arquivo ', cLinha)
	If nPos1 > 0
		cLinha := AllTrim(SubStr(cLinha, nPos1+12))
		aLinha[nI] := cLinha
	EndIf
	//035 e 036
	nPos1 := At(' arquivo ', cLinha)
	If nPos1 > 0
		cLinha := SubStr(cLinha, nPos1+9)
		nPos2 := At(' e d', cLinha)
		If nPos2 > 0
			cLinha := SubStr(cLinha, 1, nPos2-1)
			aLinha[nI] := cLinha
		EndIf
	EndIf
	//058
	nPos1 := At(' de usuario ', cLinha)
	If nPos1 > 0
		cLinha := SubStr(cLinha, nPos1+12)
		nPos2 := At(' existe na ', cLinha)
		If nPos2 > 0
			cLinha := SubStr(cLinha, 1, nPos2-1)
			aLinha[nI] := cLinha
		EndIf
	EndIf
	//068
	nPos1 := At(' na tabela ', cLinha)
	If nPos1 > 0
		cLinha := SubStr(cLinha, nPos1+11)
		nPos2 := At(', existem ', cLinha)
		If nPos2 > 0
			cLinha := SubStr(cLinha, 1, nPos2-1)
			aLinha[nI] := cLinha
		EndIf
	EndIf
	If aScan(aOut, aLinha[nI]) == 0
		aAdd(aOut, aLinha[nI])
	EndIf
Next nI

nOut := fCreate('c:\arr.txt')
nMax := Len(aOut)
For nI := 1 to nMax
	cLinha := "'" + aOut[nI] + "'" + Iif(nI<>nMax,',','')
	If (nI%5) == 0 .or. nI == nMax
		cLinha += ';' + CRLF
	EndIf
	fWrite(nOut, cLinha, Len(cLinha))
Next nI
fClose(nOut)

Return Nil

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
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Verifica o numero de botoes Max. 5 e o tamanho da Msg.       �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
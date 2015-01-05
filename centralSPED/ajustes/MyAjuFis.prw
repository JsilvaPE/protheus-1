#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function myAjuFis()
Local cPerg := "#MyAjuFis"  
Local oButton1
Local oButton2
Local oButton3
Local oGroup1
Local oSay1
Local oSay2
Private oDlg2

AjuSX1(cPerg)

Pergunte(cPerg,.F.)

DEFINE MSDIALOG oDlg2 TITLE "Ajusta CST x CFOP" FROM 000, 000  TO 135, 500 COLORS 0, 16777215 PIXEL
	@ 005, 010 GROUP oGroup1 TO 043, 239 OF oDlg2 COLOR 0, 16777215 PIXEL

	@ 014, 014 SAY oSay1 PROMPT "Este programa tem o objetivo de ajustar os CSTs das tabelas: " 	SIZE 185, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
	@ 023, 014 SAY oSay2 PROMPT "SD1, SD2, e SFT, de acordo com os parametros informados."	SIZE 223, 007 OF oDlg2 COLORS 0, 16777215 PIXEL

	@ 046, 117 BUTTON oButton1 PROMPT "&Parâm."	SIZE 037, 012 OF oDlg2 ACTION Pergunte(cPerg,.T.) 															PIXEL
	@ 046, 159 BUTTON oButton2 PROMPT "&Ok" 		SIZE 037, 012 OF oDlg2 ACTION Processa({|| PROCCST()},"AJUFIS","Processando, aguarde...")	PIXEL
	@ 046, 201 BUTTON oButton3 PROMPT "&Sair" 	SIZE 037, 012 OF oDlg2 ACTION oDlg2:End() 																		PIXEL
ACTIVATE MSDIALOG oDlg2 CENTERED
Return()

Static Function PROCCST()
Local cQry       

/*
'MV_PAR01' => 'Data inicial'
'MV_PAR02' => 'Data final'
'MV_PAR03' => 'CFOP?'
'MV_PAR04' => 'CST Antigo?'
'MV_PAR05'=> 'CST Novo?'
*/

/////////////////
// Atualiza SD1//
/////////////////  
Begin Transaction
 
If MV_PAR03 < '5000'
	cQry := ""
	cQry += "UPDATE " 
	cQry += "   " + RETSQLNAME("SD1") + " "
	cQry += "SET "
	cQry += "   D1_CLASFIS = SB1.B1_ORIGEM + '" + Alltrim(MV_PAR05) + "' "
	cQry += "	FROM " + RETSQLNAME("SD1") + " SD1 "
	cQry += "	," + RETSQLNAME("SB1") + " SB1 "
	cQry += "WHERE "             
	cQry += "   SD1.D_E_L_E_T_<>'*' "
	cQry += "   AND SB1.D_E_L_E_T_<>'*' "
	cQry += "   AND SD1.D1_FILIAL = '" + XFILIAL("SD1") + "' "
	cQry += "   AND SB1.B1_FILIAL = '" + XFILIAL("SB1") + "' "
	cQry += "   AND SD1.D1_COD = SB1.B1_COD "
	cQry += "   AND SD1.D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
	cQry += "   AND SD1.D1_DOC BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' "
	cQry += "   AND SD1.D1_SERIE BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "' "
	cQry += "   AND SD1.D1_FORNECE BETWEEN '" + MV_PAR10 + "' AND '" + MV_PAR11 + "' "
	cQry += "   AND SD1.D1_LOJA BETWEEN '" + MV_PAR12 + "' AND '" + MV_PAR13 + "' "
	cQry += "   AND SD1.D1_CF = '" + MV_PAR03 + "' "
	cQry += "   AND SD1.D1_CLASFIS = SB1.B1_ORIGEM + '" + Alltrim(MV_PAR04) + "' "
	If AllTrim(MV_PAR05) $ '00/10/20/70'
		cQry += "   AND SD1.D1_BASEICM > 0"
	EndIf
	If AllTrim(MV_PAR05) $ '00/10/20'
		cQry += "   AND SD1.D1_VALICM > 0"
	EndIf
	If AllTrim(MV_PAR05) $ '30'
		cQry += "   AND SD1.D1_BASEICM = 0"
		cQry += "   AND SD1.D1_VALICM = 0"
	EndIf
	If AllTrim(MV_PAR05) $ '10/30/60/70'
		cQry += "   AND SD1.D1_BASERET > 0"
		cQry += "   AND SD1.D1_ICMSRET > 0"
	EndIf
	If AllTrim(MV_PAR05) $ '40/41/50/51/90'
		cQry += "   AND SD1.D1_BASEICM = 0"
		cQry += "   AND SD1.D1_VALICM = 0"
		cQry += "   AND SD1.D1_BASERET = 0"
		cQry += "   AND SD1.D1_ICMSRET = 0"
	EndIf
//	AVISO("AVISO",CQRY,{"oK"})
	TCSQLEXEC(cQry)
ENDIF

/////////////////
// Atualiza SD2//
/////////////////   
If MV_PAR03 >= '5000'
	cQry := ""
	cQry += "UPDATE " 
	cQry += "   " + RETSQLNAME("SD2") + " "
	cQry += "SET "
	cQry += "   D2_CLASFIS = SB1.B1_ORIGEM + '" + Alltrim(MV_PAR05) + "' "
	cQry += "	FROM " + RETSQLNAME("SD2") + " SD2 "
	cQry += "	," + RETSQLNAME("SB1") + " SB1 "
	cQry += "WHERE "             
	cQry += "   SD2.D_E_L_E_T_<>'*' "
	cQry += "   AND SB1.D_E_L_E_T_<>'*' "
	cQry += "   AND SD2.D2_FILIAL = '" + XFILIAL("SD2") + "' "
	cQry += "   AND SB1.B1_FILIAL = '" + XFILIAL("SB1") + "' "
	cQry += "   AND SD2.D2_COD = SB1.B1_COD "
	cQry += "   AND SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
	cQry += "   AND SD2.D2_DOC BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' "
	cQry += "   AND SD2.D2_SERIE BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "' "
	cQry += "   AND SD2.D2_CLIENTE BETWEEN '" + MV_PAR10 + "' AND '" + MV_PAR11 + "' "
	cQry += "   AND SD2.D2_LOJA BETWEEN '" + MV_PAR12 + "' AND '" + MV_PAR13 + "' "
	cQry += "   AND SD2.D2_CF = '" + MV_PAR03 + "' "
	cQry += "   AND SD2.D2_CLASFIS = SB1.B1_ORIGEM + '" + Alltrim(MV_PAR04) + "' "
	If AllTrim(MV_PAR05) $ '00/10/20/70'
		cQry += "   AND SD2.D2_BASEICM > 0"
	EndIf
	If AllTrim(MV_PAR05) $ '00/10/20'
		cQry += "   AND SD2.D2_VALICM > 0"
	EndIf
	If AllTrim(MV_PAR05) $ '30'
		cQry += "   AND SD2.D2_BASEICM = 0"
		cQry += "   AND SD2.D2_VALICM = 0"
	EndIf
	If AllTrim(MV_PAR05) $ '10/30/60/70'
		cQry += "   AND SD2.D2_BASERET > 0"
		cQry += "   AND SD2.D2_ICMSRET > 0"
	EndIf
	If AllTrim(MV_PAR05) $ '40/41/50/51/90'
		cQry += "   AND SD2.D2_BASEICM = 0"
		cQry += "   AND SD2.D2_VALICM = 0"
		cQry += "   AND SD2.D2_BASERET = 0"
		cQry += "   AND SD2.D2_ICMSRET = 0"
	EndIf
//	AVISO("AVISO",CQRY,{"oK"})
	TCSQLEXEC(cQry)     
Endif

/////////////////
// Atualiza SFT//
/////////////////   
	cQry := ""
	cQry += "UPDATE " 
	cQry += "   " + RETSQLNAME("SFT") + " "
	cQry += "SET "
	cQry += "   FT_CLASFIS = SB1.B1_ORIGEM + '" + Alltrim(MV_PAR05) + "' "
	cQry += "	FROM " + RETSQLNAME("SFT") + " SFT "
	cQry += "	," + RETSQLNAME("SB1") + " SB1 "
	cQry += "WHERE "             
	cQry += "   SFT.D_E_L_E_T_<>'*' "
	cQry += "   AND SB1.D_E_L_E_T_<>'*' "
	cQry += "   AND SFT.FT_FILIAL = '" + XFILIAL("SFT") + "' "
	cQry += "   AND SB1.B1_FILIAL = '" + XFILIAL("SB1") + "' "
	cQry += "   AND SFT.FT_PRODUTO = SB1.B1_COD "
	cQry += "   AND SFT.FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
	cQry += "   AND SFT.FT_NFISCAL BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' "
	cQry += "   AND SFT.FT_SERIE BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "' "
	cQry += "   AND SFT.FT_CLIEFOR BETWEEN '" + MV_PAR10 + "' AND '" + MV_PAR11 + "' "
	cQry += "   AND SFT.FT_LOJA BETWEEN '" + MV_PAR12 + "' AND '" + MV_PAR13 + "' "
	cQry += "   AND SFT.FT_CFOP = '" + MV_PAR03 + "' "
	cQry += "   AND SFT.FT_CLASFIS = SB1.B1_ORIGEM + '" + Alltrim(MV_PAR04) + "' "
	If AllTrim(MV_PAR05) $ '00/10/20/70'
		cQry += "   AND SFT.FT_BASEICM > 0"
	EndIf
	If AllTrim(MV_PAR05) $ '00/10/20'
		cQry += "   AND SFT.FT_VALICM > 0"
	EndIf
	If AllTrim(MV_PAR05) $ '30'
		cQry += "   AND SFT.FT_BASEICM = 0"
		cQry += "   AND SFT.FT_VALICM = 0"
	EndIf
	If AllTrim(MV_PAR05) $ '10/30/60/70'
		cQry += "   AND SFT.FT_BASERET > 0"
		cQry += "   AND SFT.FT_ICMSRET > 0"
	EndIf
	If AllTrim(MV_PAR05) $ '40/41/50/51/90'
		cQry += "   AND SFT.FT_BASEICM = 0"
		cQry += "   AND SFT.FT_VALICM = 0"
		cQry += "   AND SFT.FT_BASERET = 0"
		cQry += "   AND SFT.FT_ICMSRET = 0"
	EndIf
//	AVISO("AVISO",CQRY,{"oK"})
TCSQLEXEC(cQry)

End Transaction
                          
Alert("Atualização finalizada!")
Return()


Static Function AjuSX1(cPerg)

Local nTamGrp := Len(SX1->X1_GRUPO)
Local aHelpPor := {}, aHelpEng := {}, aHelpSpa := {}
Local cNome

aHelpPor := {}
aAdd(aHelpPor, 'Informe a data inicial/final para    ')
aAdd(aHelpPor, 'o ajuste das notas.                  ')
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
aAdd(aHelpPor, 'Informe o CFOP para filtragem    ')
cNome := 'CFOP?'
PutSx1(PadR(cPerg,nTamGrp), '03', cNome, cNome, cNome,;
'MV_CH3', 'C', 5, 0, 0, 'G', '', '13', '', '', 'MV_PAR03',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe o CST para filtragem       ')
cNome := 'CST Antigo?'
PutSx1(PadR(cPerg,nTamGrp), '04', cNome, cNome, cNome,;
'MV_CH4', 'C', 2, 0, 0, 'G', '', 'S2', '', '', 'MV_PAR04',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe o CST para alteração       ')
cNome := 'CST Novo?'
PutSx1(PadR(cPerg,nTamGrp), '05', cNome, cNome, cNome,;
'MV_CH5', 'C', 2, 0, 0, 'G', '', 'S2', '', '', 'MV_PAR05',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe o documento inicial        ')
cNome := 'Documento de'
PutSx1(PadR(cPerg,nTamGrp), '06', cNome, cNome, cNome,;
'MV_CH6', 'C', 9, 0, 0, 'G', '', '', '', '', 'MV_PAR06',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe o documento final          ')
cNome := 'Documento ate'
PutSx1(PadR(cPerg,nTamGrp), '07', cNome, cNome, cNome,;
'MV_CH7', 'C', 9, 0, 0, 'G', '', '', '', '', 'MV_PAR07',;
'', '', '', 'zzzzzzzzz',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe a série inicial            ')
cNome := 'Série de'
PutSx1(PadR(cPerg,nTamGrp), '08', cNome, cNome, cNome,;
'MV_CH8', 'C', 3, 0, 0, 'G', '', '', '', '', 'MV_PAR08',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe a série final              ')
cNome := 'Série ate'
PutSx1(PadR(cPerg,nTamGrp), '09', cNome, cNome, cNome,;
'MV_CH9', 'C', 3, 0, 0, 'G', '', '', '', '', 'MV_PAR09',;
'', '', '', 'zzz',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe o cliente/fornecedor inicial')
cNome := 'Cliente / Fornecedor de'
PutSx1(PadR(cPerg,nTamGrp), '10', cNome, cNome, cNome,;
'MV_CHA', 'C', 6, 0, 0, 'G', '', '', '', '', 'MV_PAR10',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe o cliente/fornecedor final ')
cNome := 'Cliente / Fornecedor ate'
PutSx1(PadR(cPerg,nTamGrp), '11', cNome, cNome, cNome,;
'MV_CHB', 'C', 6, 0, 0, 'G', '', '', '', '', 'MV_PAR11',;
'', '', '', 'zzzzzz',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe a loja inicial             ')
cNome := 'Loja de'
PutSx1(PadR(cPerg,nTamGrp), '12', cNome, cNome, cNome,;
'MV_CHC', 'C', 2, 0, 0, 'G', '', '', '', '', 'MV_PAR12',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe a loja final               ')
cNome := 'Loja ate'
PutSx1(PadR(cPerg,nTamGrp), '13', cNome, cNome, cNome,;
'MV_CHD', 'C', 2, 0, 0, 'G', '', '', '', '', 'MV_PAR13',;
'', '', '', 'zz',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return()
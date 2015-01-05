#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DATA : 10/07/2014
// USER : WALBER FREIRE 
// ACAO : AJUSTES DE NCM DO PRODUTO
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
USER FUNCTION MyNCMB1()
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

_cJanTit := "Ajusta NCM - Cadastro de Produto"

PUBLIC cTipo := 'N'
PRIVATE aCmpAlt := {} 
PRIVATE INCLUI := .F.
PRIVATE ALTERA := .T.

//Caso exista alguma restrição a algum campo listado, basta retira-lo do aCmpAlt.
aCmpAlt := {'B1_COD', 'B1_GRPCTB', 'B1_EX_NCM', 'B1_EX_NBM', 'B1_POSIPI'}


PRIVATE nItens := 0
PRIVATE nUsado := 0
PRIVATE aHeader1 := {}
PRIVATE aCols1 := {}
PRIVATE aCols2 := {}
PRIVATE nCtrl  := 0
PRIVATE aCamp  := separa('B1_COD    ,B1_GRPCTB ,B1_POSIPI ,B1_EX_NCM ,B1_EX_NBM ,B1_DESC   ', ',')

//MONTANDO aHeader1 PARA O MsNewGetDados
DBSELECTAREA("SX3")
DBSETORDER(2)
FOR nI := 1 TO len(aCamp)
	IF DBSEEK(aCamp[nI])
		nUsado++
		aAdd(aHeader1, {;
			TRIM(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			"",;//Iif(AllTrim(aCamp[nI])=='B1_POSIPI',"U_MyVldNCM()",""),;
			"",;
			SX3->X3_TIPO,;
			"",;
			"";
		})
	Else
		Alert("Campo: " + aCamp[nI] + "não encontrado.")
	ENDIF
	DBGOTOP()
NEXT nI

aAdd(aCols1,Array(nUsado+1))
FOR nI := 1 TO nUsado
	cCol := Space(aHeader1[nI][4])
	aCols1[1][nI] := cCol
NEXT
//aCols1[1][2] := 'walber'
aCols1[1][nUsado+1] := .F.

Private cProd      := Space(15)
Private cDesc      := Space(60)
Private nExNCM     := Space(3)
Private cGRPCTB    := Space(4)
Private nPosIPI    := Space(10)

Private aBotoes    := {}

Private nPosCampo
nPosCampo := aScan(aHeader1,{|x| AllTrim(x[2]) == 'B1_COD'})

Private nPosGRPCTB
nPosGRPCTB := aScan(aHeader1,{|x| AllTrim(x[2]) == 'B1_GRPCTB'})

Private nPosPOSIPI
nPosPOSIPI := aScan(aHeader1,{|x| AllTrim(x[2]) == 'B1_POSIPI'})

Private nPosEX_NCM
nPosEX_NCM := aScan(aHeader1,{|x| AllTrim(x[2]) == 'B1_EX_NCM'})

Private nPosEX_NBM
nPosEX_NBM := aScan(aHeader1,{|x| AllTrim(x[2]) == 'B1_EX_NBM'})

SetPrvt("oDlg1")

oDlg1 := MSDialog():New( 000,000,430,679,OemToAnsi(_cJanTit),,,.F.,,,,,,.T.,,,.T. )

aCols2 := aClone(aCols1)

oGetD := MsNewGetDados():New(0,0,203,341,GD_INSERT + GD_UPDATE + GD_DELETE,,,,aCmpAlt,,21,'U_NCMB1VLD',,,oDlg1,aHeader1,aCols1)
oGetD:oBrowse:bAdd := {||oGetD:ADDLINE(),NEWLINE()}
oGetD:Refresh()

oDlg1:bInit := {||EnchoiceBar(oDlg1,{||NCMB1_OK()},{||oDlg1:End()},.F.,aBotoes)}
oDlg1:Activate(,,,.T.)

RETURN NIL

User Function NCMB1VLD()
	If oGetD:oBrowse:ColPos == nPosCampo
		oGetD:oBrowse:bEditCol := {||DADOS()}
	ElseIf oGetD:oBrowse:ColPos == nPosPOSIPI
		oGetD:oBrowse:bEditCol := {||VLDNCM()}
	endIf
Return .T.

Static Function NEWLINE()
	FOR nI := 1 TO nUsado
		cCol := Space(aHeader1[nI][4])
		oGetD:aCols[oGetD:nAt][nI] := cCol
	NEXT
return Nil

Static Function DADOS()
	Local cResult
	SB1->(DBSETORDER(1))
	If !SB1->(DBSEEK(XFILIAL('SB1')+oGetD:aCols[ oGetD:nAt, nPosCampo ]))
		Alert('Código de produto (' + AllTrim(oGetD:aCols[ oGetD:nAt, nPosCampo ]) + ') inválido ou não encontrado.')
		oGetD:aCols[ oGetD:nAt, nPosCampo ] := Space(aHeader1[nPosCampo][4])
		return .F.
	EndIf
	aCols1 := oGetD:aCols
	FOR nI := 1 TO nUsado
		If nI <> nPosCampo
			cCol := "SB1->"+aHeader1[nI][2]
			cResult := &(cCol)
			oGetD:aCols[ oGetD:nAt, nI] := cResult
		EndIf
	NEXT
Return .T.

Static Function VLDNCM()
	Local lRet := U_MyVldNCM(oGetD:aCols[ oGetD:nAt, nPosPOSIPI ])
	If !lRet
		oGetD:aCols[ oGetD:nAt, nPosPOSIPI ] := Space(aHeader1[nPosPOSIPI][4])
	EndIf
Return lRet

STATIC FUNCTION NCMB1_OK()
	MSAGUARDE({||NCMB1OK()},_cJanTit,'Aguarde...' + chr(13) + 'Atualizando registros...')
RETURN NIL

STATIC FUNCTION NCMB1OK()
	Local lOk := .T.
	SB1->(DBSETORDER(1))
	For nI := 1 To len(oGetD:aCols)
		If !SB1->(DBSEEK(XFILIAL('SB1')+oGetD:aCols[ nI, nPosCampo ]))
			Alert('Código de produto inválido ou não encontrado na linha: ' + nI)
			lOk := .F.
		EndIf
		exit
	Next nI
	If lOk
		SB1->(DBSETORDER(1))
		For nI := 1 To len(oGetD:aCols)
			If oGetD:aCols[ nI, (nUsado+1) ]	== .F.
				If SB1->(dbSeek(XFILIAL('SB1')+oGetD:aCols[ nI, nPosCampo ]))
					RecLock('SB1',.F.)
					
					SB1->B1_GRPCTB := oGetD:aCols[ nI, nPosGRPCTB ]
					SB1->B1_POSIPI := oGetD:aCols[ nI, nPosPOSIPI ]
					SB1->B1_EX_NCM := oGetD:aCols[ nI, nPosEX_NCM ]
					SB1->B1_EX_NBM := oGetD:aCols[ nI, nPosEX_NBM ]
					
					SB1->(MsUnlock())
				EndIf
				SB1->(dbGoTop())
			EndIf
		Next nI
      Alert('Registros alterados com sucesso.')
		//Limpando o oGetD:aCols
		oGetD:aCols := aClone(aCols2)
		oGetD:Refresh()
	EndIf
RETURN NIL
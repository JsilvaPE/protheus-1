#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DATA : 10/07/2014
// USER : WALBER FREIRE 
// ACAO : AJUSTES DE CHAVE E SÉRIE DA NF DE ENTRADA
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
USER FUNCTION MyCHVOK()
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Private _cMyES := 'E'

If Aviso('Escolha','Verifica documentos de ENTRADA ou SAÍDA?',{'ENTRADA','SAÍDA'}) == 1
	_cJanTit := "Ajusta Chave NF Entrada"
	_cMyES := 'E'
Else
	_cJanTit := "Ajusta Chave NF Saída"
	_cMyES := 'S'
EndIf

PUBLIC cTipo := 'N'
PRIVATE aCmpAlt := {} 
PRIVATE INCLUI := .F.
PRIVATE ALTERA := .T.

//Caso exista alguma restrição a algum campo listado, basta retira-lo do aCmpAlt.
If _cMyES == 'E'
	//aCmpAlt := {'FT_CHVNFE','FT_SERIE','FT_EMISSAO'}
	aCmpAlt := {'FT_CHVNFE','FT_EMISSAO'}
Else
	aCmpAlt := {'FT_CHVNFE'}
Endif


PRIVATE nItens := 0
PRIVATE nUsado := 0
PRIVATE aHeader1 := {}
PRIVATE aCols1 := {}
PRIVATE aCols2 := {}
PRIVATE nCtrl  := 0
If _cMyES == 'E'
	PRIVATE aCamp  := separa('FT_ENTRADA,FT_NFISCAL,FT_SERIE  ,FT_ESPECIE,FT_FORMUL ,FT_CLIEFOR,FT_LOJA   ,A2_CGC    ,A2_NOME   ,FT_ESTADO ,FT_EMISSAO,FT_CHVNFE ', ',')
	PRIVATE aCampf3 := separa(',,,,,SA2,,,,,,', ',', .T.)
Else
	PRIVATE aCamp  := separa('FT_ENTRADA,FT_NFISCAL,FT_SERIE  ,FT_ESPECIE,FT_FORMUL ,FT_CLIEFOR,FT_LOJA   ,A1_CGC    ,A1_NOME   ,FT_ESTADO ,FT_EMISSAO,FT_CHVNFE ', ',')
	PRIVATE aCampf3 := separa(',,,,,SA1,,,,,,', ',', .T.)
EndIf

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
			"",;
			aCampF3[nI],;
			SX3->X3_TIPO,;
			"",;
			"";
		})
	Else
		Alert("Campo: " + aCamp[nI] + "não encontrado.")
	ENDIF
	DBGOTOP()
NEXT nI

If _cMyES == 'S'
	//Acrescentando campo de retorno sefa
	nUsado++
	aAdd(aHeader1, {;
		'Ret.SEFA',;
		'MyRetSEFA',;
		'',;
		30,;
		0,;
		"",;
		"",;
		'C',;
		"",;
		"";
	})
	//Acrescentando campo DT6_CHVCTE
	nUsado++
	aAdd(aHeader1, {;
		'Chave TMS',;
		'MyChvTMS',;
		'',;
		44,;
		0,;
		"",;
		"",;
		'C',;
		"",;
		"";
	})
EndIf

//Acrescentando campo de mensagem de erro
nUsado++
aAdd(aHeader1, {;
	'Erro Chave NF',;
	'MyInfoErro',;
	'',;
	80,;
	0,;
	"",;
	"",;
	'C',;
	"",;
	"";
})



aCols1 := {}

Private cProd      := Space(15)
Private cDesc      := Space(60)
Private nExNCM     := Space(3)
Private cGRPCTB    := Space(4)
Private nPosIPI    := Space(10)
Private dData1     := ctod('')
Private dData2     := ctod('')
Private dBusca1    := ctod('')
Private dBusca2    := ctod('')

Private aBotoes    := {;
	{"PMSEXCEL",{|| Excel() },"Exportar para o Excel"},;
	{"SDUDELETE",{|| Inutil() },"Limpar chaves inutilizadas"},;
	{"COPYUSER",{|| Copiar() },"Copiar chave TMS para livro"};
}

Private nPosDOC
nPosDOC := aScan(aHeader1,{|x| AllTrim(x[2]) == 'FT_NFISCAL'})
Private nPosSERIE
nPosSERIE := aScan(aHeader1,{|x| AllTrim(x[2]) == 'FT_SERIE'})
Private nPosFORNE
nPosFORNE := aScan(aHeader1,{|x| AllTrim(x[2]) == 'FT_CLIEFOR'})
Private nPosLOJA
nPosLOJA := aScan(aHeader1,{|x| AllTrim(x[2]) == 'FT_LOJA'})
Private nPosDTENT
nPosDTENT := aScan(aHeader1,{|x| AllTrim(x[2]) == 'FT_ENTRADA'})
Private nPosDTEMI
nPosDTEMI := aScan(aHeader1,{|x| AllTrim(x[2]) == 'FT_EMISSAO'})
Private nPosCHAVE
nPosCHAVE := aScan(aHeader1,{|x| AllTrim(x[2]) == 'FT_CHVNFE'})
Private nPosRETSEFA
nPosRETSEFA := aScan(aHeader1,{|x| AllTrim(x[2]) == 'MyRetSEFA'})
Private nPosCHVTMS
nPosCHVTMS := aScan(aHeader1,{|x| AllTrim(x[2]) == 'MyChvTMS'})
Private nPosINFERR
nPosINFERR := aScan(aHeader1,{|x| AllTrim(x[2]) == 'MyInfoErro'})

SetPrvt("oDlg1","oSay1","oSay2","oGet1","oGet2")

oDlg1 := MSDialog():New( 000,000,430,679,OemToAnsi(_cJanTit),,,.F.,,,,,,.T.,,,.T. )
oSay1 := TSay():New( 010,004,{||"Data De"},oDlg1,,,.F.,.F.,.F.,.T.,,,042,008)
oSay2 := TSay():New( 010,052,{||"Data Até"},oDlg1,,,.F.,.F.,.F.,.T.,,,042,008)
oGet1 := TGet():New( 017,004,{|u| If(PCount()>0, ( dData1:=u , dBusca1:=ctod('') ) ,dData1) },oDlg1,042,008,,,,,,,,.T.,"",,,.F.,.T.,,.F.,.F.,"","dData1",,)
oGet2 := TGet():New( 017,052,{|u| If(PCount()>0, ( dData2:=u , dBusca2:=ctod('') ) ,dData2) },oDlg1,042,008,,,,,,,,.T.,"",,,.F.,.T.,,.F.,.F.,"","dData2",,)
oBtn1 := TButton():New( 016,098,"Pesquisar",,{||PESQNFE()},027,012,,,,.T.,,"",,,,.F. )

aCols2 := aClone(aCols1)

oGetD := MsNewGetDados():New(30,0,203,341,GD_UPDATE,,,,aCmpAlt,,21,,,,oDlg1,aHeader1,aCols1)
oGetD:aCols := {}
oGetD:Refresh()

oDlg1:bInit := {||EnchoiceBar(oDlg1,{||CHVOK_OK()},{||oDlg1:End()},.F.,aBotoes)}
oDlg1:Activate(,,,.T.)

RETURN NIL

STATIC FUNCTION PESQNFE()
	dBusca1 := dData1
	dBusca2 := dData2
	MSAGUARDE({||_PESQNFE()},_cJanTit,'Aguarde...' + chr(13) + 'Buscando registros...')
RETURN NIL

Static Function _PESQNFE()
	Local lRet := .T.
	Local lInu := .F.
	Local cRet := ''
	LOCAL cQry := ''
	Local cChave := ''
	Local nDigV, nDigC
	Local	cUF, cAAMM, cCNPJ, cMod, cSer, cNum
	Local cMyUF := ''
	Local cMyCNPJ := ''
	Local dDEmissao, cEsp, cSerie, cNFiscal
	If !(dData1 <> ctod(''))
		Alert('É necessário o preenchimento do campo data de.')
	ElseIf !(dData2 <> ctod(''))
		Alert('É necessário o preenchimento do campo data ate.')
	ElseIf dData1 > dData2
		Alert("O campo 'data de' não pode ser superior ao campo 'data ate'.")
	Else
		//Limpando aCols
		aCols1 := {}
		oGetD:aCols := {}
		oGetD:Refresh()
		
		If _cMyES == 'E'
			//Pesquisando notas de entrada
			cQry := " SELECT FT_NFISCAL, "
			cQry += "        FT_SERIE, "
			cQry += "        FT_CLIEFOR, "
			cQry += "        FT_LOJA, "
			cQry += "        FT_ESTADO, "
			cQry += "        FT_ENTRADA, "
			cQry += "        FT_EMISSAO, "
			cQry += "        FT_CHVNFE, "
			cQry += "        FT_ESPECIE, "
			cQry += "        FT_FORMUL, "
			cQry += "        A2_CGC AS CGC, "	
			cQry += "        A2_NOME AS NOME,"	
			cQry += "        '' AS RETSEFA"	
			cQry += " FROM "+RETSQLNAME('SFT')+" AS SFT "
			cQry += " LEFT JOIN " + RETSQLNAME('SA2')+" AS SA2 "
			cQry += " ON  A2_FILIAL   = '"+XFILIAL('SA2')+"'"
			cQry += " AND FT_CLIEFOR  = A2_COD"
			cQry += " AND FT_LOJA  = A2_LOJA"
			cQry += " AND SA2.D_E_L_E_T_  = ' '"
			cQry += " WHERE FT_FILIAL = '"+XFILIAL('SFT')+"'"
			cQry += " AND FT_TIPOMOV  = 'E'"
			cQry += " AND FT_ESPECIE  IN ('CTE', 'SPED')"
			cQry += " AND FT_ENTRADA  >= '"+dTos(dData1)+"'"
			cQry += " AND FT_ENTRADA  <= '"+dTos(dData2)+"'"
			cQry += " AND SFT.D_E_L_E_T_  = ' '"
			cQry += " GROUP BY FT_NFISCAL, "
			cQry += "          FT_SERIE, "
			cQry += "          FT_CLIEFOR, "
			cQry += "          FT_LOJA, "
			cQry += "          FT_ESTADO, "
			cQry += "          FT_ENTRADA, "
			cQry += "          FT_EMISSAO, "
			cQry += "          FT_CHVNFE, "
			cQry += "          FT_ESPECIE, "
			cQry += "          FT_FORMUL, "
			cQry += "          A2_CGC, "
			cQry += "          A2_NOME "
			cQry += " ORDER BY FT_ENTRADA, "
			cQry += "          FT_NFISCAL, "
			cQry += "          FT_SERIE, "
			cQry += "          FT_CLIEFOR, "
			cQry += "          FT_LOJA, "
			cQry += "          FT_ESTADO "		
		Else
			//Pesquisando notas de entrada
			cQry := " SELECT DISTINCT "
			cQry += "        FT_NFISCAL, "
			cQry += "        FT_SERIE, "
			cQry += "        FT_CLIEFOR, "
			cQry += "        FT_LOJA, "
			cQry += "        FT_ESTADO, "
			cQry += "        FT_ENTRADA, "
			cQry += "        FT_EMISSAO, "
			cQry += "        FT_CHVNFE, "
			cQry += "        FT_ESPECIE, "
			cQry += "        FT_FORMUL, "
			cQry += "        A1_CGC AS CGC, "	
			cQry += "        A1_NOME AS NOME,"	
			cQry += "        F3_CODRSEF AS RETSEFA,"
			cQry += "        F3_CHVNFE,"
			cQry += "        DT6_CHVCTE"
			cQry += " FROM "+RETSQLNAME('SFT')+" AS SFT "
			cQry += " LEFT JOIN " + RETSQLNAME('SA1')+" AS SA1 "
			cQry += " ON  A1_FILIAL   = '"+XFILIAL('SA1')+"'"
			cQry += " AND FT_CLIEFOR  = A1_COD"
			cQry += " AND FT_LOJA  = A1_LOJA"
			cQry += " AND SA1.D_E_L_E_T_  = ' '"
			cQry += " LEFT JOIN " + RETSQLNAME('SF3')+" AS SF3 "
			cQry += " ON  F3_FILIAL   = '"+XFILIAL('SF3')+"'"
			cQry += " AND FT_NFISCAL  = F3_NFISCAL"
			cQry += " AND FT_SERIE    = F3_SERIE"
			cQry += " AND FT_CLIEFOR  = F3_CLIEFOR"
			cQry += " AND FT_LOJA  = F3_LOJA"
			cQry += " AND SF3.D_E_L_E_T_  = ' '"
			cQry += " LEFT JOIN " + RETSQLNAME('DT6')+" AS DT6 "
			cQry += " ON  DT6_FILIAL  = '"+XFILIAL('DT6')+"'"
			cQry += " AND DT6_FILDOC  = FT_FILIAL"
			cQry += " AND FT_NFISCAL  = DT6_DOC"
			cQry += " AND FT_SERIE    = DT6_SERIE"
			cQry += " AND FT_CLIEFOR  = DT6_CLIDEV"
			cQry += " AND FT_LOJA     = DT6_LOJDEV"
			cQry += " WHERE FT_FILIAL = '"+XFILIAL('SFT')+"'"
			cQry += " AND FT_TIPOMOV  = 'S'"
			cQry += " AND FT_ESPECIE  IN ('CTE', 'SPED')"
			cQry += " AND FT_ENTRADA  >= '"+dTos(dData1)+"'"
			cQry += " AND FT_ENTRADA  <= '"+dTos(dData2)+"'"
			cQry += " AND SFT.D_E_L_E_T_  = ' '"
			cQry += " GROUP BY FT_NFISCAL, "
			cQry += "          FT_SERIE, "
			cQry += "          FT_CLIEFOR, "
			cQry += "          FT_LOJA, "
			cQry += "          FT_ESTADO, "
			cQry += "          FT_ENTRADA, "
			cQry += "          FT_EMISSAO, "
			cQry += "          FT_CHVNFE, "
			cQry += "          FT_ESPECIE, "
			cQry += "          FT_FORMUL, "
			cQry += "          A1_CGC, "
			cQry += "          A1_NOME, "
			cQry += "          F3_CODRSEF, "
			cQry += "          F3_CHVNFE, "
			cQry += "          DT6_CHVCTE "
			cQry += " ORDER BY FT_ENTRADA, "
			cQry += "          FT_NFISCAL, "
			cQry += "          FT_SERIE, "
			cQry += "          FT_CLIEFOR, "
			cQry += "          FT_LOJA, "
			cQry += "          FT_ESTADO "
		EndIf
		DBUSEAREA(.T.,"TOPCONN",TCGENQRY(,,cQry),"TEMP1",.T.)
		WHILE !TEMP1->(EOF())
			lRet    := .T.
			lInu    := .F.
			cRet    := ''
			cChave  := SoNum(AllTrim(TEMP1->FT_CHVNFE))
			
			If AllTrim(TEMP1->RETSEFA) == '102' .and. AllTrim(TEMP1->FT_CHVNFE) <> ''
				//inutilizado E com chave = ERRADO
				cRet += 'Número inutilizado. Não deve possuir chave (SFT). '
				lRet := .F.
				lInu := .T.
			EndIf
			
			If AllTrim(TEMP1->RETSEFA) == '102' .and. AllTrim(TEMP1->F3_CHVNFE) <> ''
				//inutilizado E com chave = ERRADO
				cRet += 'Número inutilizado. Não deve possuir chave (SF3). '
				lRet := .F.
				lInu := .T.
			EndIf
			
			If !lInu
				//verificando tamanho da chave
				If Len(cChave) <> 44
					cRet += 'Tamanho da chave inválido. '
					lRet := .F.
				EndIf
				
				cMyUF   := AllTrim(TEMP1->FT_ESTADO)
				If _cMyES == 'S'
					cMyUF := AllTrim(SM0->M0_ESTCOB)
				EndIf
				cMyCNPJ := AllTrim(TEMP1->CGC)
				If AllTrim(TEMP1->FT_FORMUL) == 'S' .or. _cMyES == 'S'
					cMyCNPJ := AllTrim(SM0->M0_CGC)
				EndIf
				dDEmissao := sTod(TEMP1->FT_EMISSAO)
				nDigV   := Right(cChave,1)
				nDigC   := Modulo11(Left(cChave,43),2,9)
				cEsp := AllTrim(TEMP1->FT_ESPECIE)
				cSerie := TEMP1->FT_SERIE
				cNFiscal := TEMP1->FT_NFISCAL
				
				//comparando dígito verificador digitado com o calculado
				If nDigC <> nDigV
					cRet += 'Dígito verificador inválido. '
					lRet := .F.
				EndIf
	
				//valida dados da chave com os digitados no sistema
				cUF   := SubStr(cChave, 01, 02)
				cAAMM := SubStr(cChave, 03, 04)
				cCNPJ := SubStr(cChave, 07, 14)
				cMod  := Substr(cChave, 21, 02)
				cSer  := Substr(cChave, 23, 03)
				cNum  := Substr(cChave, 26, 09)
					
				If RetUF(cMyUF) <> cUF
					cRet += 'UF inválida. '
					lRet := .F.		
				EndIf
				If (Right(cValToChar(Year(dDEmissao)),2) + StrZero(Month(dDEmissao),2)) <> cAAMM
					cRet += 'Ano/Mês emissão inválido. '
					lRet := .F.
				EndIf
				If cMyCNPJ <> cCNPJ
					cRet += 'CNPJ inválido. '
					lRet := .F.
				EndIf
				If (cEsp == 'SPED' .and. cMod <> '55') .or. (cEsp == 'CTE' .and. cMod <> '57')
					cRet += 'Espécie e/ou modelo inválido. '
					lRet := .F.
				EndIf
				If StrZero(Val(AllTrim(cSerie)),3) <> cSer
					cRet += 'Série inválida. '
					lRet := .F.
				EndIf
				If StrZero(Val(AllTrim(cNFiscal)),9) <> cNum
					cRet += 'Número inválido. '
					lRet := .F.
				EndIf
			EndIf
			
			If AllTrim(TEMP1->RETSEFA) == '102' .and. AllTrim(TEMP1->FT_CHVNFE) == '' .and. AllTrim(TEMP1->F3_CHVNFE) == ''
				//inutilizado E sem chave = CORRETO
				lRet := .T.
			EndIf
			
			If !(lRet)
				If _cMyES == 'E'
					aAdd(aCols1,{;
						sTod(TEMP1->FT_ENTRADA),;
						TEMP1->FT_NFISCAL,;
						TEMP1->FT_SERIE,;
						TEMP1->FT_ESPECIE,;
						TEMP1->FT_FORMUL,;
						TEMP1->FT_CLIEFOR,;
						TEMP1->FT_LOJA,;
						TEMP1->CGC,;
						TEMP1->NOME,;
						TEMP1->FT_ESTADO,;
						sTod(TEMP1->FT_EMISSAO),;
						TEMP1->FT_CHVNFE,;
						cRet,;
						.F.;
					})
				Else
					aAdd(aCols1,{;
						sTod(TEMP1->FT_ENTRADA),;
						TEMP1->FT_NFISCAL,;
						TEMP1->FT_SERIE,;
						TEMP1->FT_ESPECIE,;
						TEMP1->FT_FORMUL,;
						TEMP1->FT_CLIEFOR,;
						TEMP1->FT_LOJA,;
						TEMP1->CGC,;
						TEMP1->NOME,;
						TEMP1->FT_ESTADO,;
						sTod(TEMP1->FT_EMISSAO),;
						TEMP1->FT_CHVNFE,;
						RetSEFA(TEMP1->RETSEFA),;
						TEMP1->DT6_CHVCTE,;
						cRet,;
						.F.;
					})
				EndIf
			EndIf
			TEMP1->(DBSKIP())
		ENDDO
		TEMP1->(DBCLOSEAREA())
		oGetD:aCols := aClone(aCols1)
		oGetD:Refresh()
	EndIf
return Nil

STATIC FUNCTION CHVOK_OK()
	MSAGUARDE({||CHVOKOK()},_cJanTit,'Aguarde...' + chr(13) + 'Atualizando registros...')
RETURN NIL

STATIC FUNCTION CHVOKOK()
	//UPDATE dos registros   
	begin transaction
	For nI := 1 To len(oGetD:aCols)
		If oGetD:aCols[ nI, (nUsado+1) ]	== .F.
			If _cMyES == 'E'
				cQry := " UPDATE "+RETSQLNAME('SFT')
//				cQry += " SET FT_SERIE = '"+oGetD:aCols[ nI, nPosSERIE ]+"', "
//				cQry += "     FT_CHVNFE = '"+oGetD:aCols[ nI, nPosCHAVE ]+"', "
				cQry += " SET FT_CHVNFE = '"+oGetD:aCols[ nI, nPosCHAVE ]+"', "
				cQry += "     FT_EMISSAO = '"+DTOS(oGetD:aCols[ nI, nPosDTEMI ])+"' "
				cQry += " WHERE FT_FILIAL = '"+XFILIAL('SFT')+"'"
				cQry += " AND FT_NFISCAL  = '"+oGetD:aCols[ nI, nPosDOC ]+"'"
				cQry += " AND FT_SERIE    = '"+oGetD:aCols[ nI, nPosSERIE ]+"'"
				cQry += " AND FT_ENTRADA  = '"+dTos(oGetD:aCols[ nI, nPosDTENT ])+"'"
				cQry += " AND FT_TIPOMOV  = 'E'"
				cQry += " AND FT_ESPECIE  IN ('CTE', 'SPED')"
				cQry += " AND FT_CLIEFOR  = '"+oGetD:aCols[ nI, nPosFORNE ]+"'"
				cQry += " AND FT_LOJA  = '"+oGetD:aCols[ nI, nPosLOJA ]+"'"
				cQry += " AND D_E_L_E_T_  = ' '"
				If TCSqlExec(cQry) < 0
					DisarmTransaction()
					Alert('Erro ao gravar alterações SFT.')
				EndIf
				cQry := " UPDATE "+RETSQLNAME('SF3')
//				cQry += " SET F3_SERIE = '"+oGetD:aCols[ nI, nPosSERIE ]+"', "
//				cQry += "     F3_CHVNFE = '"+oGetD:aCols[ nI, nPosCHAVE ]+"', "
				cQry += " SET F3_CHVNFE = '"+oGetD:aCols[ nI, nPosCHAVE ]+"', "
				cQry += "     F3_EMISSAO = '"+DTOS(oGetD:aCols[ nI, nPosDTEMI ])+"' "
				cQry += " WHERE F3_FILIAL = '"+XFILIAL('SF3')+"'"
				cQry += " AND F3_NFISCAL  = '"+oGetD:aCols[ nI, nPosDOC ]+"'"
				cQry += " AND F3_SERIE    = '"+oGetD:aCols[ nI, nPosSERIE ]+"'"
				cQry += " AND F3_ENTRADA  = '"+dTos(oGetD:aCols[ nI, nPosDTENT ])+"'"
				cQry += " AND F3_CFO  < '5000'"
				cQry += " AND F3_ESPECIE  IN ('CTE', 'SPED')"
				cQry += " AND F3_CLIEFOR  = '"+oGetD:aCols[ nI, nPosFORNE ]+"'"
				cQry += " AND F3_LOJA  = '"+oGetD:aCols[ nI, nPosLOJA ]+"'"
				cQry += " AND D_E_L_E_T_  = ' '"
				If TCSqlExec(cQry) < 0
					DisarmTransaction()
					Alert('Erro ao gravar alterações SF3.')
				EndIf
				cQry := " UPDATE "+RETSQLNAME('SF1')
//				cQry += " SET F1_SERIE = '"+oGetD:aCols[ nI, nPosSERIE ]+"', "
//				cQry += "     F1_CHVNFE = '"+oGetD:aCols[ nI, nPosCHAVE ]+"', "
				cQry += " SET F1_CHVNFE = '"+oGetD:aCols[ nI, nPosCHAVE ]+"', "
				cQry += "     F1_EMISSAO = '"+DTOS(oGetD:aCols[ nI, nPosDTEMI ])+"' "
				cQry += " WHERE F1_FILIAL = '"+XFILIAL('SF1')+"'"
				cQry += " AND F1_DOC  = '"+oGetD:aCols[ nI, nPosDOC ]+"'"
				cQry += " AND F1_SERIE    = '"+oGetD:aCols[ nI, nPosSERIE ]+"'"
				cQry += " AND F1_DTDIGIT  = '"+dTos(oGetD:aCols[ nI, nPosDTENT ])+"'"
				cQry += " AND F1_ESPECIE  IN ('CTE', 'SPED')"
				cQry += " AND F1_FORNECE  = '"+oGetD:aCols[ nI, nPosFORNE ]+"'"
				cQry += " AND F1_LOJA  = '"+oGetD:aCols[ nI, nPosLOJA ]+"'"
				cQry += " AND D_E_L_E_T_  = ' '"
				If TCSqlExec(cQry) < 0
					DisarmTransaction()
					Alert('Erro ao gravar alterações SF1.')
				EndIf
				cQry := " UPDATE "+RETSQLNAME('SD1')
//				cQry += " SET D1_SERIE = '"+oGetD:aCols[ nI, nPosSERIE ]+"', "
//				cQry += "     D1_EMISSAO = '"+DTOS(oGetD:aCols[ nI, nPosDTEMI ])+"' "
				cQry += " SET D1_EMISSAO = '"+DTOS(oGetD:aCols[ nI, nPosDTEMI ])+"' "
				cQry += " WHERE D1_FILIAL = '"+XFILIAL('SD1')+"'"
				cQry += " AND D1_DOC  = '"+oGetD:aCols[ nI, nPosDOC ]+"'"
				cQry += " AND D1_SERIE    = '"+oGetD:aCols[ nI, nPosSERIE ]+"'"
				cQry += " AND D1_DTDIGIT  = '"+dTos(oGetD:aCols[ nI, nPosDTENT ])+"'"
				cQry += " AND D1_FORNECE  = '"+oGetD:aCols[ nI, nPosFORNE ]+"'"
				cQry += " AND D1_LOJA  = '"+oGetD:aCols[ nI, nPosLOJA ]+"'"
				cQry += " AND D_E_L_E_T_  = ' '"
				If TCSqlExec(cQry) < 0
					DisarmTransaction()
					Alert('Erro ao gravar alterações SD1.')
				EndIf
			Else
				cQry := " UPDATE "+RETSQLNAME('SFT')
				cQry += " SET FT_CHVNFE = '"+oGetD:aCols[ nI, nPosCHAVE ]+"' "
				cQry += " WHERE FT_FILIAL = '"+XFILIAL('SFT')+"'"
				cQry += " AND FT_NFISCAL  = '"+oGetD:aCols[ nI, nPosDOC ]+"'"
				cQry += " AND FT_SERIE  = '"+oGetD:aCols[ nI, nPosSERIE ]+"'"
				cQry += " AND FT_TIPOMOV  = 'S'"
				cQry += " AND FT_ESPECIE  IN ('CTE', 'SPED')"
				cQry += " AND FT_CLIEFOR  = '"+oGetD:aCols[ nI, nPosFORNE ]+"'"
				cQry += " AND FT_LOJA  = '"+oGetD:aCols[ nI, nPosLOJA ]+"'"
				cQry += " AND D_E_L_E_T_  = ' '"
				If TCSqlExec(cQry) < 0
					DisarmTransaction()
					Alert('Erro ao gravar alterações SFT.')
				EndIf
				cQry := " UPDATE "+RETSQLNAME('SF3')
				cQry += " SET F3_CHVNFE = '"+oGetD:aCols[ nI, nPosCHAVE ]+"'"
				cQry += " WHERE F3_FILIAL = '"+XFILIAL('SF3')+"'"
				cQry += " AND F3_NFISCAL  = '"+oGetD:aCols[ nI, nPosDOC ]+"'"
				cQry += " AND F3_SERIE  = '"+oGetD:aCols[ nI, nPosSERIE ]+"'"
				cQry += " AND F3_CFO  > '5000'"
				cQry += " AND F3_ESPECIE  IN ('CTE', 'SPED')"
				cQry += " AND F3_CLIEFOR  = '"+oGetD:aCols[ nI, nPosFORNE ]+"'"
				cQry += " AND F3_LOJA  = '"+oGetD:aCols[ nI, nPosLOJA ]+"'"
				cQry += " AND D_E_L_E_T_  = ' '"
				If TCSqlExec(cQry) < 0
					DisarmTransaction()
					Alert('Erro ao gravar alterações SF3.')
				EndIf
				cQry := " UPDATE "+RETSQLNAME('SF2')
				cQry += " SET F2_CHVNFE = '"+oGetD:aCols[ nI, nPosCHAVE ]+"'"
				cQry += " WHERE F2_FILIAL = '"+XFILIAL('SF2')+"'"
				cQry += " AND F2_DOC  = '"+oGetD:aCols[ nI, nPosDOC ]+"'"
				cQry += " AND F2_SERIE  = '"+oGetD:aCols[ nI, nPosSERIE ]+"'"
				cQry += " AND F2_ESPECIE  IN ('CTE', 'SPED')"
				cQry += " AND F2_CLIENTE  = '"+oGetD:aCols[ nI, nPosFORNE ]+"'"
				cQry += " AND F2_LOJA  = '"+oGetD:aCols[ nI, nPosLOJA ]+"'"
				cQry += " AND D_E_L_E_T_  = ' '"
				If TCSqlExec(cQry) < 0
					DisarmTransaction()
					Alert('Erro ao gravar alterações SF2.')
				EndIf
			EndIf
		EndIf
	Next nI
	end transaction
	//Limpando o oGetD:aCols
	oGetD:aCols := {}
	oGetD:Refresh()
RETURN NIL

Static Function RetUF(cUF)

Local nPos
Local cRet := '99'
Local aUF := {;
	{'RO','11'},;
	{'AC','12'},;
	{'AM','13'},;
	{'RR','14'},;
	{'PA','15'},;
	{'AP','16'},;
	{'TO','17'},;
	{'MA','21'},;
	{'PI','22'},;
	{'CE','23'},;
	{'RN','24'},;
	{'PB','25'},;
	{'PE','26'},;
	{'AL','27'},;
	{'SE','28'},;
	{'BA','29'},;
	{'MG','31'},;
	{'ES','32'},;
	{'RJ','33'},;
	{'SP','35'},;
	{'PR','41'},;
	{'SC','42'},;
	{'RS','43'},;
	{'MS','50'},;
	{'MT','51'},;
	{'GO','52'},;
	{'DF','53'},;
	{'EX','99'},;
}

nPos := aScan(aUF, {|x| x[1] == cUF})
If nPos > 0
	cRet := aUF[nPos][2]
EndIf

Return cRet

/* ------------------- */

Static Function Excel()

Local cCabec := 'NF-e/CT-e com Chave Inválida'
Local aExcel := {}
Local aHeader := aClone(aHeader1)
Local aCols := aClone(oGetD:aCols)
Local nI, nMaxI, nJ, nMaxJ

If dBusca1 == CTOD('') .or. dBusca2 == CTOD('')
	MsgAlert('Primeiramente realize a pesquisa para depois exportar o resultado.')
	Return Nil
EndIf

cCabec += CRLF + 'Relatório emitido em '+DTOC(Date())+' às '+Time()+' por '+AllTrim(cUsername)
cCabec += CRLF + 'Período: '+DTOC(dBusca1)+' até '+DTOC(dBusca2)
cCabec += CRLF + ''
cCabec += CRLF + 'Empresa: '+cEmpAnt+'/'+cFilAnt+'-'+AllTrim(SM0->M0_NOME)+' / '+AllTrim(SM0->M0_FILIAL) + ' - CNPJ: '+Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')

nMaxI := Len(aCols)
If nMaxI > 0
	For nI := 1 to nMaxI
		nMaxJ := Len(aCols[nI])
		For nJ := 1 to nMaxJ
			If ValType(aCols[nI][nJ]) == 'C'
				aCols[nI][nJ] := chr(160) + aCols[nI][nJ]
			EndIf
		Next nJ
	Next nI
Else
	aHeader := {{'','cMyVar','@!',200,0,'','','C','',''}}
	aCols := {{'NÃO EXISTEM REGISTROS PARA O PERÍODO SELECIONADO!',.F.}}
Endif

aAdd(aExcel, {'GETDADOS', cCabec, aClone(aHeader), aClone(aCols)})

MsgRun('Aguarde...', 'Exportando os registros para o Excel', {|| DlgToExcel(aExcel) })

Return Nil

/* ------------------- */

Static Function SoNum(cTxt)

Local nI, nMax
Local cRet := ''
Local cChar

nMax := Len(cTxt)
For nI := 1 to nMax
	cChar := SubStr(cTxt, nI, 1)
	If cChar $ '0123456789'
		cRet += cChar
	EndIf
Next nI

Return cRet

/* ------------------- */

Static Function RetSEFA(cCod)

Local aRet
Local cRet := ''
Local nPos

aRet := {;
'100|Autorizado o uso da NF-e',;
'101|Cancelamento de NF-e homologado',;
'102|Inutilização de número homologado';
}

cCod := AllTrim(cCod)
nPos := aScan(aRet, {|x| Left(x,3) == cCod })
If nPos > 0
	cRet := cCod + ' - ' + SubStr(aRet[nPos], 5)
Else
	cRet := cCod
EndIf

Return cRet

/* ------------------- */

Static Function Inutil()

Local nI
Local nMax := Len(oGetD:aCols)

If !MsgYesNo('Você deseja limpar a chave de todos os documentos com status inutilizado?')
	Return Nil
EndIf

For nI := 1 to nMax
	If Left(oGetD:aCols[nI][nPosRETSEFA],3) == '102'
		oGetD:aCols[nI][nPosCHAVE] := Space(44)
	EndIf
Next nI

oGetD:Refresh()

MsgAlert('As chaves das notas inutilizadas foram removidas. Você precisa ainda confirmar a alteração.')

Return Nil

/* ------------------- */

Static Function Copiar()

Local nI
Local nMax := Len(oGetD:aCols)

If !MsgYesNo('Você deseja copiar a chave TMS para o livro fiscal?')
	Return Nil
EndIf

For nI := 1 to nMax
	If Left(oGetD:aCols[nI][nPosRETSEFA],3) <> '102'
		oGetD:aCols[nI][nPosCHAVE] := oGetD:aCols[nI][nPosCHVTMS]
	EndIf
Next nI

oGetD:Refresh()

MsgAlert('As chaves do TMS foram copiadas para o livro fiscal. Você precisa ainda confirmar a alteração.')

Return Nil
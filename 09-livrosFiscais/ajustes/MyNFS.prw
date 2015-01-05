#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyNFS()
///////////////////////////////////////////////////////////////////////////////
// Data : 08/02/2014
// User : Thieres Tembra
// Desc : Modifica os dados abaixo para as notas de saída com série NFS:
//        - D2_TES
//        - D2_CF
//        - D2_CLASFIS
//        - D2_SITTRIB
//        - D2_BASEICM
//        - D2_PICM
//        - D2_VALICM
///////////////////////////////////////////////////////////////////////////////
Local cPerg := '#MyNFS    '

If Aviso('Atenção','Esta rotina irá modificar a TES, CFOP, Classificação ' +;
'Fiscal, Situação Tributária, Base ICMS e Valor ICMS, das notas fiscais ' +;
'de saída que possuam série NFS. Deseja prosseguir?',{'Sim','Não'}) == 2
	Return Nil
EndIf

CriaSX1(cPerg)

If Pergunte(cPerg, .T.)
	Processa({|| Executa() }, 'Modificando dados NFS...')
EndIf

Return Nil

/* ---------------- */

Static Function Executa()

Local cQry
Local nPos   := 0
Local nCount := 0
Local cTES  := '713'
Local cCST  := ''
Local cCFOP := ''
Local cOrig := ''

SF4->(dbGoTop())
If !SF4->(dbSeek( xFilial('SF4') + cTES ))
	Alert('Não foi possível encontrar a TES ' + cTES + '.' +;
	'Por favor crie a TES mencionada com as configurações corretas, ' +;
	'ou solicite ao administrador do sistema para modificar a TES na rotina.')
	Return Nil
EndIf

cCST  := SF4->F4_SITTRIB
cCFOP := SF4->F4_CF

cQry := " SELECT R_E_C_N_O_ AS RECNUM"
cQry += " FROM " + RetSqlName('SD2')
cQry += " WHERE D2_FILIAL = '" + xFilial('SD2') + "'"
cQry += "   AND LEFT(D2_EMISSAO,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += "   AND D_E_L_E_T_ <> '*'"
cQry += "   AND D2_SERIE = 'NFS'"

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSD2',.T.)
SSD2->(dbEval({|| nCount++ }))
SSD2->(dbGoTop())

ProcRegua(nCount)

While !SSD2->(Eof())
	nPos++
	SD2->(dbGoTo( SSD2->RECNUM ))
	
	IncProc(cValToChar(nPos) + '/' + cValToChar(nCount) + ' - ' + SD2->D2_DOC + '/' + SD2->D2_SERIE + ' - ' + SD2->D2_CLIENTE + '-' + SD2->D2_LOJA)
	
	cOrig := ''
	cOrig := Posicione('SB1', 1, xFilial('SB1') + SD2->D2_COD, 'B1_ORIGEM')
	If cOrig == ''
		cOrig := '0'
	EndIf
	
	RecLock('SD2',.F.)
	SD2->D2_TES     := cTES
	SD2->D2_CF      := cCFOP
	SD2->D2_CLASFIS := cOrig + cCST
	SD2->D2_SITTRIB := ''
	SD2->D2_BASEICM := 0
	SD2->D2_PICM    := 0
	SD2->D2_VALICM  := 0
	SD2->(MsUnlock())
	
	SSD2->(dbSkip())
EndDo
SSD2->(dbCloseArea())

IncProc()

Return Nil

/* ---------------- */

Static Function CriaSX1(cPerg)

Local nTamGrp := Len(SX1->X1_GRUPO)
Local aHelpPor := {}, aHelpEng := {}, aHelpSpa := {}
Local cNome

aHelpPor := {}
aAdd(aHelpPor, 'Informe o ano/mes inicial para       ')
aAdd(aHelpPor, 'processamento das notas. Ex: 201201  ')
cNome := 'Do Ano Mes (Ex: 201201)'
PutSx1(PadR(cPerg,nTamGrp), '01', cNome, cNome, cNome,;
'MV_CH1', 'C', 6, 0, 0, 'G', '', '', '', '', 'MV_PAR01',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe o ano/mes final para         ')
aAdd(aHelpPor, 'processamento das notas. Ex: 201203  ')
cNome := 'Ate Ano Mes (Ex: 201203)'
PutSx1(PadR(cPerg,nTamGrp), '02', cNome, cNome, cNome,;
'MV_CH2', 'C', 6, 0, 0, 'G', '', '', '', '', 'MV_PAR02',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
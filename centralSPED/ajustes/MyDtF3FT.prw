#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyDtF3FT()
///////////////////////////////////////////////////////////////////////////////
// Data : 15/10/2014
// User : Thieres Tembra
// Desc : Rotina que verifica os documentos fiscais que possuem as datas de
//        entrada, emissão e cancelamento diferentes no SF3 e SFT eatualiza o
//        SFT de acordo com SF3.
///////////////////////////////////////////////////////////////////////////////
Local cTitulo := 'Ajuste de Datas SF3 > SFT'
Local cPerg := '#MYDTF3FT'

CriaSX1(cPerg)

If !Pergunte(cPerg, .T., cTitulo)
	Return Nil
End If

If MV_PAR01 == Nil .or. MV_PAR01 == CTOD('') .or. MV_PAR02 == Nil .or. MV_PAR02 == CTOD('')
	Alert('Informe as datas para geração do relatório.')
	Return Nil
ElseIf MV_PAR01 > MV_PAR02
	Alert('A data final deve ser maior que a data inicial.')
	Return Nil
EndIf

Processa({|| Executa(cTitulo) },cTitulo,'Aguarde...')

Return Nil

/* ------------------- */

Static Function Executa(cTitulo)

Local cQry

ProcRegua(0)

cQry := CRLF + " UPDATE " + RetSqlName('SFT')
cQry += CRLF + " SET FT_ENTRADA = F3_ENTRADA"
cQry += CRLF + "    ,FT_EMISSAO = F3_EMISSAO"
cQry += CRLF + "    ,FT_DTCANC = F3_DTCANC"
cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
cQry += CRLF + " LEFT JOIN " + RetSqlName('SF3') + " SF3"
cQry += CRLF + " ON  SF3.D_E_L_E_T_ <> '*'"
cQry += CRLF + " AND F3_FILIAL = '" + xFilial('SF3') + "'"
cQry += CRLF + " AND F3_NFISCAL = FT_NFISCAL"
cQry += CRLF + " AND F3_SERIE = FT_SERIE"
cQry += CRLF + " AND F3_CLIEFOR = FT_CLIEFOR"
cQry += CRLF + " AND F3_LOJA = FT_LOJA"
cQry += CRLF + " AND F3_CFO = FT_CFOP"
cQry += CRLF + " AND ("
cQry += CRLF + "     F3_ENTRADA <> FT_ENTRADA"
cQry += CRLF + "  OR F3_EMISSAO <> FT_EMISSAO"
cQry += CRLF + "  OR F3_DTCANC <> FT_DTCANC"
cQry += CRLF + " )"
cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
cQry += CRLF + "   AND F3_ENTRADA IS NOT NULL"

If TCSQLExec(cQry) < 0
	Alert('Erro ao executar ajuste: ' + TCSQLError())
Else
	MsgAlert('Ajuste realizado com sucesso.')
EndIf

Return Nil

/* ------------------- */

Static Function CriaSX1(cPerg,cCFPad)

Local nTamGrp := Len(SX1->X1_GRUPO)
Local aHelpPor := {}, aHelpEng := {}, aHelpSpa := {}
Local cNome

aHelpPor := {}
aAdd(aHelpPor, 'Informe a data inicial/final para    ')
aAdd(aHelpPor, 'geração do relatório.                ')
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

Return Nil
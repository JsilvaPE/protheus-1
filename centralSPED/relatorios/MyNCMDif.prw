#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyNCMDif()
///////////////////////////////////////////////////////////////////////////////
// Data : 09/05/2014
// User : Thieres Tembra
// Desc : Relação de Produtos que possuem NCM diferente na SFT e na SB1
///////////////////////////////////////////////////////////////////////////////

Local cTitulo := 'Relação de Produtos que possuem NCM diferente na SFT e na SB1'
Local cPerg := '#MyNCMDif'

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

Processa({|| Executa(cTitulo) },cTitulo,'Realizando consulta...')

Return Nil

/* -------------- */

Static Function Executa(cTitulo)

Local cQry
Local cAux, cRet
Local cArq := 'MyNCMDif'
Local aExcel := {}
Local nCnt

ProcRegua(0)

cQry := CRLF + " SELECT DISTINCT"
cQry += CRLF + "        B1_COD"
cQry += CRLF + "       ,B1_DESC"
cQry += CRLF + "       ,B1_POSIPI"
cQry += CRLF + "       ,FT_POSIPI"
cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
cQry += CRLF + "     ," + RetSqlName('SB1') + " SB1"
cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND SB1.D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
cQry += CRLF + "   AND B1_FILIAL = '" + xFilial('SB1') + "'"
cQry += CRLF + "   AND FT_PRODUTO = B1_COD"
cQry += CRLF + "   AND FT_POSIPI <> B1_POSIPI"
cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
cQry += CRLF + " ORDER BY B1_COD"
cQry += CRLF + "         ,B1_POSIPI"
cQry += CRLF + "         ,FT_POSIPI"

cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY',.T.)

nCnt := 0
MQRY->(dbEval({||nCnt++}))
MQRY->(dbGoTop())

ProcRegua(nCnt)

aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' às '+Time()+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Período: '+DTOC(MV_PAR01)+' até '+DTOC(MV_PAR02)})
aAdd(aExcel, {''})
aAdd(aExcel, {'Empresa: '+cEmpAnt+'/'+cFilAnt+'-'+AllTrim(SM0->M0_NOME)+' / '+AllTrim(SM0->M0_FILIAL) + ' - CNPJ: '+Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')})
aAdd(aExcel, {'Código','Descrição','NCM na SB1','NCM na SFT'})
		
While !MQRY->(Eof())
	aAdd(aExcel, {MQRY->B1_COD, MQRY->B1_DESC, MQRY->B1_POSIPI, MQRY->FT_POSIPI})
	MQRY->(dbSkip())
EndDo

MQRY->(dbCloseArea())

cAux := AllTrim(cGetFile('CSV (*.csv)|*.csv', 'Selecione o diretório onde será salvo o relatório', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NETWORKDRIVE, GETF_RETDIRECTORY ), .F., .T.))
If cAux <> ''
	cAux := SubStr(cAux, 1, RAt('\', cAux)) + cArq
	cAux := cAux + '-' + DTOS(Date()) + '-' + StrTran(Time(), ':', '') + '.csv'
	
	cRet := U_MyArrCsv(aExcel, cAux, Nil, cTitulo)
	If cRet <> ''
		Alert(cRet)
	EndIf
Else
	Alert('A geração do relatório foi cancelada!')
EndIf

Return Nil

/* -------------- */

Static Function CriaSX1(cPerg)

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
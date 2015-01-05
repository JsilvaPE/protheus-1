#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyRDIEF1()
///////////////////////////////////////////////////////////////////////////////
// Data : 22/09/2014
// User : Thieres Tembra
// Desc : Relatório referente ao Anexo I - Prestação de Serviço de Transporte
//        da DIEF - PA.
///////////////////////////////////////////////////////////////////////////////
Local cTitulo := 'Relatório Anexo I - DIEF'
Local cPerg := '#MYRDIEF1'

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

Local aExcel := {}
Local cArq := 'MYRDIEF1'
Local cAux, cRet, cQry
Local nTotal
Local cCFOPs := ''
Local cUF := ''

cCFOPs := AllTrim(U_MyGeraIn(GetMV('MV_CFODIEF',.F.,'')))
If cCFOPs == ''
	Alert('Preencha o parâmetro MV_CFODIEF com os CFOPs a serem informados no Anexo I da DIEF.')
	Return Nil
EndIf

cUF := AllTrim(GetMV('MV_ESTADO',.F.,'PA'))

aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' às '+Time()+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Período: '+DTOC(MV_PAR01)+' até '+DTOC(MV_PAR02)})
aAdd(aExcel, {'Considera TMS: '+Iif(MV_PAR03==1,'Sim','Não')})
aAdd(aExcel, {''})
aAdd(aExcel, {'Empresa: '+cEmpAnt+'/'+cFilAnt+'-'+AllTrim(SM0->M0_NOME)+' / '+AllTrim(SM0->M0_FILIAL)})
aAdd(aExcel, {''})

If MV_PAR03 == 2
	//não considera TMS
	//utiliza SD2 e SA1
	cQry := CRLF + " SELECT"
	cQry += CRLF + "    B5_DIEF AS PRODIEF"
	cQry += CRLF + "   ,ZZFB5.ZZF_DESC AS PRODUTO"
	cQry += CRLF + "   ,A1_DIEF AS MUNDIEF"
	cQry += CRLF + "   ,ZZFA1.ZZF_DESC AS MUNICIPIO"
	cQry += CRLF + "   ,SUM(D2_QUANT) AS QTD"
	cQry += CRLF + "   ,CASE F4_AGREG"
	cQry += CRLF + "      WHEN 'I' THEN SUM(D2_TOTAL+D2_VALICM)"
	cQry += CRLF + "      ELSE SUM(D2_TOTAL)"
	cQry += CRLF + "    END AS VALOR"
	cQry += CRLF + " FROM " + RetSqlName('SF3') + " SF3"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SD2') + " SD2"
	cQry += CRLF + " ON  SD2.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND D2_FILIAL = '" + xFilial('SD2') + "'"
	cQry += CRLF + " AND D2_DOC = F3_NFISCAL"
	cQry += CRLF + " AND D2_SERIE = F3_SERIE"
	cQry += CRLF + " AND D2_CLIENTE = F3_CLIEFOR"
	cQry += CRLF + " AND D2_LOJA = F3_LOJA"
	cQry += CRLF + " AND D2_CF = F3_CFO"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SA1') + " SA1"
	cQry += CRLF + " ON  SA1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND A1_FILIAL = '" + xFilial('SA1') + "'"
	cQry += CRLF + " AND A1_COD = F3_CLIEFOR"
	cQry += CRLF + " AND A1_LOJA = F3_LOJA"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('ZZF') + " ZZFA1"
	cQry += CRLF + " ON  ZZFA1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND ZZFA1.ZZF_FILIAL = '" + xFilial('ZZF') + "'"
	cQry += CRLF + " AND ZZFA1.ZZF_UF = A1_EST"
	cQry += CRLF + " AND ZZFA1.ZZF_TIPO = '1'"
	cQry += CRLF + " AND ZZFA1.ZZF_CODIGO = A1_DIEF"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SB5') + " SB5"
	cQry += CRLF + " ON  SB5.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND B5_FILIAL = '" + xFilial('SB5') + "'"
	cQry += CRLF + " AND B5_COD = D2_COD"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('ZZF') + " ZZFB5"
	cQry += CRLF + " ON  ZZFB5.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND ZZFB5.ZZF_FILIAL = '" + xFilial('ZZF') + "'"
	cQry += CRLF + " AND ZZFB5.ZZF_UF = '" + cUF + "'"
	cQry += CRLF + " AND ZZFB5.ZZF_TIPO = '2'"
	cQry += CRLF + " AND ZZFB5.ZZF_CODIGO = B5_DIEF"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SF4') + " SF4"
	cQry += CRLF + " ON  SF4.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND F4_FILIAL = '" + xFilial('SF4') + "'"
	cQry += CRLF + " AND F4_CODIGO = D2_TES"
	cQry += CRLF + " WHERE SF3.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND F3_FILIAL = '" + xFilial('SF3') + "'"
	cQry += CRLF + "   AND F3_CFO IN " + cCFOPs
	cQry += CRLF + "   AND F3_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQry += CRLF + "   AND F4_VLAGREG = 'S'"
	cQry += CRLF + " GROUP BY"
	cQry += CRLF + "    B5_DIEF"
	cQry += CRLF + "   ,ZZFB5.ZZF_DESC"
	cQry += CRLF + "   ,A1_DIEF"
	cQry += CRLF + "   ,ZZFA1.ZZF_DESC"
	cQry += CRLF + "   ,F4_AGREG"
	cQry += CRLF + " ORDER BY"
	cQry += CRLF + "    B5_DIEF"
	cQry += CRLF + "   ,ZZFB5.ZZF_DESC"
	cQry += CRLF + "   ,A1_DIEF"
	cQry += CRLF + "   ,ZZFA1.ZZF_DESC"
ElseIf MV_PAR03 == 1
	//considera o TMS
	//utiliza SD2, DT6 e DUY
	cQry := CRLF + " SELECT"
	cQry += CRLF + "    B5_DIEF AS PRODIEF"
	cQry += CRLF + "   ,ZZFB5.ZZF_DESC AS PRODUTO"
	cQry += CRLF + "   ,DUY_DIEF AS MUNDIEF"
	cQry += CRLF + "   ,ZZFDUY.ZZF_DESC AS MUNICIPIO"
	cQry += CRLF + "   ,SUM(D2_QUANT) AS QTD"
	cQry += CRLF + "   ,CASE F4_AGREG"
	cQry += CRLF + "      WHEN 'I' THEN SUM(D2_TOTAL+D2_VALICM)"
	cQry += CRLF + "      ELSE SUM(D2_TOTAL)"
	cQry += CRLF + "    END AS VALOR"
	cQry += CRLF + " FROM " + RetSqlName('SF3') + " SF3"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SD2') + " SD2"
	cQry += CRLF + " ON  SD2.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND D2_FILIAL = '" + xFilial('SD2') + "'"
	cQry += CRLF + " AND D2_DOC = F3_NFISCAL"
	cQry += CRLF + " AND D2_SERIE = F3_SERIE"
	cQry += CRLF + " AND D2_CLIENTE = F3_CLIEFOR"
	cQry += CRLF + " AND D2_LOJA = F3_LOJA"
	cQry += CRLF + " AND D2_CF = F3_CFO"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('DT6') + " DT6"
	cQry += CRLF + " ON  DT6.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND DT6_FILIAL = '" + xFilial('DT6') + "'"
	cQry += CRLF + " AND DT6_FILDOC = F3_FILIAL"
	cQry += CRLF + " AND DT6_DOC = F3_NFISCAL"
	cQry += CRLF + " AND DT6_SERIE = F3_SERIE"
	cQry += CRLF + " AND DT6_CLIDEV = F3_CLIEFOR"
	cQry += CRLF + " AND DT6_LOJDEV = F3_LOJA"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('DUY') + " DUY"
	cQry += CRLF + " ON  DUY.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND DUY_FILIAL = '" + xFilial('DUY') + "'"
	cQry += CRLF + " AND DUY_GRPVEN = DT6_CDRORI"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('ZZF') + " ZZFDUY"
	cQry += CRLF + " ON  ZZFDUY.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND ZZFDUY.ZZF_FILIAL = '" + xFilial('ZZF') + "'"
	cQry += CRLF + " AND ZZFDUY.ZZF_UF = DUY_EST"
	cQry += CRLF + " AND ZZFDUY.ZZF_TIPO = '1'"
	cQry += CRLF + " AND ZZFDUY.ZZF_CODIGO = DUY_DIEF"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SB5') + " SB5"
	cQry += CRLF + " ON  SB5.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND B5_FILIAL = '" + xFilial('SB5') + "'"
	cQry += CRLF + " AND B5_COD = D2_COD"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('ZZF') + " ZZFB5"
	cQry += CRLF + " ON  ZZFB5.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND ZZFB5.ZZF_FILIAL = '" + xFilial('ZZF') + "'"
	cQry += CRLF + " AND ZZFB5.ZZF_UF = '" + cUF + "'"
	cQry += CRLF + " AND ZZFB5.ZZF_TIPO = '2'"
	cQry += CRLF + " AND ZZFB5.ZZF_CODIGO = B5_DIEF"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SF4') + " SF4"
	cQry += CRLF + " ON  SF4.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND F4_FILIAL = '" + xFilial('SF4') + "'"
	cQry += CRLF + " AND F4_CODIGO = D2_TES"
	cQry += CRLF + " WHERE SF3.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND F3_FILIAL = '" + xFilial('SF3') + "'"
	cQry += CRLF + "   AND F3_CFO IN " + cCFOPs
	cQry += CRLF + "   AND F3_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQry += CRLF + "   AND F4_VLAGREG = 'S'"
	cQry += CRLF + " GROUP BY"
	cQry += CRLF + "    B5_DIEF"
	cQry += CRLF + "   ,ZZFB5.ZZF_DESC"
	cQry += CRLF + "   ,DUY_DIEF"
	cQry += CRLF + "   ,ZZFDUY.ZZF_DESC"
	cQry += CRLF + "   ,F4_AGREG"
	cQry += CRLF + " ORDER BY"
	cQry += CRLF + "    B5_DIEF"
	cQry += CRLF + "   ,ZZFB5.ZZF_DESC"
	cQry += CRLF + "   ,DUY_DIEF"
	cQry += CRLF + "   ,ZZFDUY.ZZF_DESC"
EndIf

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY',.T.)
nTotal := 0
MQRY->(dbEval({|| nTotal++ }))
MQRY->(dbGoTop())

ProcRegua(nTotal)

aAdd(aExcel, {'Produto', 'Código DIEF', 'Município', 'Código DIEF', 'Quantidade', 'Valor'})
While !MQRY->(Eof())
	IncProc()
	
	aAdd(aExcel, {MQRY->PRODUTO, MQRY->PRODIEF, MQRY->MUNICIPIO, MQRY->MUNDIEF, MQRY->QTD, MQRY->VALOR})
	
	MQRY->(dbSkip())
EndDo

MQRY->(dbCloseArea())

IncProc()

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

aHelpPor := {}
aAdd(aHelpPor, 'Selecione se deseja considerar os    ')
aAdd(aHelpPor, 'valores do módulo TMS.               ')
cNome := 'Considera TMS'
PutSx1(PadR(cPerg,nTamGrp), '03', cNome, cNome, cNome,;
'MV_CH3', 'N', 1, 0, 1, 'C', '', '', '', '', 'MV_PAR03',;
'Sim', 'Sim', 'Sim', '',;
'Não', 'Não', 'Não',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
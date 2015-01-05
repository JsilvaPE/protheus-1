#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyRe1400()
///////////////////////////////////////////////////////////////////////////////
// Data : 22/09/2014
// User : Thieres Tembra
// Desc : Relatório do registro 1400 do SPED Fiscal que contém informações
//        referente aos Valores Agregados por Município
///////////////////////////////////////////////////////////////////////////////
Local cTitulo := 'Relatório Valores Agregados 1400 - SPED Fiscal'
Local cPerg := '#MYRE1400'

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
Local cArq := 'MYRE1400'
Local cAux, cRet, cQry
Local nTotal

aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' às '+Time()+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Período: '+DTOC(MV_PAR01)+' até '+DTOC(MV_PAR02)})
aAdd(aExcel, {'Considera TMS: '+Iif(MV_PAR03==1,'Sim','Não')})
aAdd(aExcel, {''})
aAdd(aExcel, {'Empresa: '+cEmpAnt+'/'+cFilAnt+'-'+AllTrim(SM0->M0_NOME)+' / '+AllTrim(SM0->M0_FILIAL)})
aAdd(aExcel, {''})

If MV_PAR03 == 2
	//não considera TMS
	//utiliza SFT e SA1
	cQry := CRLF + " SELECT"
	cQry += CRLF + "    CC2_EST AS ESTADO"
	cQry += CRLF + "   ,CC2_CODMUN AS IBGE"
	cQry += CRLF + "   ,CC2_MUN AS MUNICIPIO"
	cQry += CRLF + "   ,FT_PRODUTO AS PRODUTO"
	cQry += CRLF + "   ,B1_DESC AS DESCRICAO"
	cQry += CRLF + "   ,SUM(FT_VALCONT) AS VALOR"
	cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SD2') + " SD2"
	cQry += CRLF + " ON  SD2.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND D2_FILIAL = '" + xFilial('SD2') + "'"
	cQry += CRLF + " AND D2_DOC = FT_NFISCAL"
	cQry += CRLF + " AND D2_SERIE = FT_SERIE"
	cQry += CRLF + " AND D2_CLIENTE = FT_CLIEFOR"
	cQry += CRLF + " AND D2_LOJA = FT_LOJA"
	cQry += CRLF + " AND D2_COD = FT_PRODUTO"
	cQry += CRLF + " AND D2_ITEM = FT_ITEM"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SF4') + " SF4"
	cQry += CRLF + " ON  SF4.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND F4_FILIAL = '" + xFilial('SF4') + "'"
	cQry += CRLF + " AND F4_CODIGO = D2_TES"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SA1') + " SA1"
	cQry += CRLF + " ON  SA1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND A1_FILIAL = '" + xFilial('SA1') + "'"
	cQry += CRLF + " AND A1_COD = FT_CLIEFOR"
	cQry += CRLF + " AND A1_LOJA = FT_LOJA"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('CC2') + " CC2"
	cQry += CRLF + " ON  CC2.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND CC2_FILIAL = '" + xFilial('CC2') + "'"
	cQry += CRLF + " AND CC2_EST = A1_EST"
	cQry += CRLF + " AND CC2_CODMUN = A1_COD_MUN"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SB1') + " SB1"
	cQry += CRLF + " ON  SB1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND B1_FILIAL = '" + xFilial('SB1') + "'"
	cQry += CRLF + " AND B1_COD = FT_PRODUTO"
	cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
	cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQry += CRLF + "   AND F4_VLAGREG = 'S'"
	cQry += CRLF + " GROUP BY"
	cQry += CRLF + "    CC2_EST"
	cQry += CRLF + "   ,CC2_CODMUN"
	cQry += CRLF + "   ,CC2_MUN"
	cQry += CRLF + "   ,FT_PRODUTO"
	cQry += CRLF + "   ,B1_DESC"
	cQry += CRLF + " ORDER BY"
	cQry += CRLF + "    CC2_EST"
	cQry += CRLF + "   ,CC2_MUN"
	cQry += CRLF + "   ,FT_PRODUTO"
	cQry += CRLF + "   ,B1_DESC"
ElseIf MV_PAR03 == 1
	//considera o TMS
	//utiliza SFT, DT6 e DUY
	cQry := CRLF + " SELECT"
	cQry += CRLF + "    CC2_EST AS ESTADO"
	cQry += CRLF + "   ,CC2_CODMUN AS IBGE"
	cQry += CRLF + "   ,CC2_MUN AS MUNICIPIO"
	cQry += CRLF + "   ,FT_PRODUTO AS PRODUTO"
	cQry += CRLF + "   ,B1_DESC AS DESCRICAO"
	cQry += CRLF + "   ,SUM(FT_VALCONT) AS VALOR"
	cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SD2') + " SD2"
	cQry += CRLF + " ON  SD2.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND D2_FILIAL = '" + xFilial('SD2') + "'"
	cQry += CRLF + " AND D2_DOC = FT_NFISCAL"
	cQry += CRLF + " AND D2_SERIE = FT_SERIE"
	cQry += CRLF + " AND D2_CLIENTE = FT_CLIEFOR"
	cQry += CRLF + " AND D2_LOJA = FT_LOJA"
	cQry += CRLF + " AND D2_COD = FT_PRODUTO"
	cQry += CRLF + " AND D2_ITEM = FT_ITEM"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SF4') + " SF4"
	cQry += CRLF + " ON  SF4.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND F4_FILIAL = '" + xFilial('SF4') + "'"
	cQry += CRLF + " AND F4_CODIGO = D2_TES"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('DT6') + " DT6"
	cQry += CRLF + " ON  DT6.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND DT6_FILIAL = '" + xFilial('DT6') + "'"
	cQry += CRLF + " AND DT6_FILDOC = FT_FILIAL"
	cQry += CRLF + " AND DT6_DOC = FT_NFISCAL"
	cQry += CRLF + " AND DT6_SERIE = FT_SERIE"
	cQry += CRLF + " AND DT6_CLIDEV = FT_CLIEFOR"
	cQry += CRLF + " AND DT6_LOJDEV = FT_LOJA"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('DUY') + " DUY"
	cQry += CRLF + " ON  DUY.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND DUY_FILIAL = '" + xFilial('DUY') + "'"
	cQry += CRLF + " AND DUY_GRPVEN = DT6_CDRORI"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('CC2') + " CC2"
	cQry += CRLF + " ON  CC2.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND CC2_FILIAL = '" + xFilial('CC2') + "'"
	cQry += CRLF + " AND CC2_EST = DUY_EST"
	cQry += CRLF + " AND CC2_CODMUN = DUY_CODMUN"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SB1') + " SB1"
	cQry += CRLF + " ON  SB1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND B1_FILIAL = '" + xFilial('SB1') + "'"
	cQry += CRLF + " AND B1_COD = FT_PRODUTO"
	cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
	cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQry += CRLF + "   AND F4_VLAGREG = 'S'"
	cQry += CRLF + " GROUP BY"
	cQry += CRLF + "    CC2_EST"
	cQry += CRLF + "   ,CC2_CODMUN"
	cQry += CRLF + "   ,CC2_MUN"
	cQry += CRLF + "   ,FT_PRODUTO"
	cQry += CRLF + "   ,B1_DESC"
	cQry += CRLF + " ORDER BY"
	cQry += CRLF + "    CC2_EST"
	cQry += CRLF + "   ,CC2_MUN"
	cQry += CRLF + "   ,FT_PRODUTO"
	cQry += CRLF + "   ,B1_DESC"
EndIf

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY',.T.)
nTotal := 0
MQRY->(dbEval({|| nTotal++ }))
MQRY->(dbGoTop())

ProcRegua(nTotal)

aAdd(aExcel, {'Código IBGE', 'Município', 'Produto', 'Descrição', 'Valor'})
While !MQRY->(Eof())
	IncProc()
	
	aAdd(aExcel, {RetUF(MQRY->ESTADO) + MQRY->IBGE, AllTrim(MQRY->MUNICIPIO) + ' - ' + MQRY->ESTADO, MQRY->PRODUTO, MQRY->DESCRICAO, MQRY->VALOR})
	
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

Static Function RetUF(cUF)

Local nPos := 0
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
	{'EX','99'} ;
}

nPos := aScan(aUF, {|x| x[1] == cUF})
If nPos > 0
	cRet := aUF[nPos][2]
EndIf

Return cRet

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
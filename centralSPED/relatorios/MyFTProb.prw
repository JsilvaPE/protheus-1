#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyFTProb()
///////////////////////////////////////////////////////////////////////////////
// Data : 16/07/2014
// User : Thieres Tembra
// Desc : Relação de Produtos que possuem NCM diferente na SFT e na SB1
///////////////////////////////////////////////////////////////////////////////

Local cTitulo := 'Relação de problemas encontrados no Livro Fiscal'
Local cPerg := '#MyFTProb'

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

Local cAux, cRet
Local cArq := 'MyFTProb'
Local aExcel := {}
Local nI
			
ProcRegua(0)

aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' às '+Time()+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Período: '+DTOC(MV_PAR01)+' até '+DTOC(MV_PAR02)})
aAdd(aExcel, {'Todos os problemas: '+Iif(MV_PAR04==1,'Não','Sim')})
aAdd(aExcel, {'Empresa: '+cEmpAnt+'/'+cFilAnt+'-'+AllTrim(SM0->M0_NOME)+' / '+AllTrim(SM0->M0_FILIAL) + ' - CNPJ: '+Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')})
aAdd(aExcel, {''})

If MV_PAR04 == 2
	For nI := 1 to 5
		Problema(nI, @aExcel)
	Next nI
Else
	If !Problema(MV_PAR03, @aExcel)
		Return Nil
	EndIf
EndIf

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

Static Function Problema(nTipo, aExcel)

Local cQry
Local nCnt
Local aProb := {;
	'Produto em branco',;
	'Produto não está na SB1',;
	'Cliente/Fornecedor em branco',;
	'Cliente não está na SA1',;
	'Fornecedor não está na SA2';
}
Local aProbCab := {;
	{'Movimentação','Entrada','Série','Documento','Espécie','Cli/Forn','Loja','Emissão','CFOP','Valor Contábil','Item','Quantidade'},;
	{'Movimentação','Entrada','Série','Documento','Espécie','Cli/Forn','Loja','Emissão','CFOP','Valor Contábil','Item','Quantidade','Produto'},;
	{'Movimentação','Entrada','Série','Documento','Espécie','Emissão','Valor Contábil'},;
	{'Movimentação','Tipo','Entrada','Série','Documento','Espécie','Cliente','Loja','Emissão','Valor Contábil'},;
	{'Movimentação','Tipo','Entrada','Série','Documento','Espécie','Fornecedor','Loja','Emissão','Valor Contábil'};
}

ProcRegua(0)
IncProc('Problema ' + cValToChar(nTipo) + ' = ' + aProb[nTipo])

cQry := ""
If nTipo == 1
	//produto em branco
	cQry += CRLF + " SELECT "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
	cQry += CRLF + "   ,FT_EMISSAO"
	cQry += CRLF + "   ,FT_CFOP"
	cQry += CRLF + "   ,FT_VALCONT"
	cQry += CRLF + "   ,FT_ESPECIE"
	cQry += CRLF + "   ,FT_ITEM"
	cQry += CRLF + "   ,FT_QUANT"
	cQry += CRLF + " FROM " + RetSqlName('SFT')
	cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
	cQry += CRLF + "   AND FT_PRODUTO = ''"
	cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQry += CRLF + " ORDER BY "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
ElseIf nTipo == 2
	//produto não está na SB1
	cQry += CRLF + " SELECT "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
	cQry += CRLF + "   ,FT_EMISSAO"
	cQry += CRLF + "   ,FT_CFOP"
	cQry += CRLF + "   ,FT_VALCONT"
	cQry += CRLF + "   ,FT_ESPECIE"
	cQry += CRLF + "   ,FT_ITEM"
	cQry += CRLF + "   ,FT_QUANT"
	cQry += CRLF + "   ,FT_PRODUTO"
	cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SB1') + " SB1"
	cQry += CRLF + " ON  SB1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND B1_FILIAL = '" + xFilial('SB1') + "'"
	cQry += CRLF + " AND B1_COD = FT_PRODUTO"
	cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
	cQry += CRLF + "   AND B1_COD IS NULL"
	cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQry += CRLF + " ORDER BY "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
ElseIf nTipo == 3
	//cliente/fornecedor em branco
	cQry += CRLF + " SELECT "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
	cQry += CRLF + "   ,FT_EMISSAO"
	cQry += CRLF + "   ,FT_ESPECIE"
	cQry += CRLF + "   ,SUM(FT_VALCONT) AS VALCONT"
	cQry += CRLF + " FROM " + RetSqlName('SFT')
	cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
	cQry += CRLF + "   AND ("
	cQry += CRLF + "        RTRIM(LTRIM(FT_CLIEFOR)) = ''"
	cQry += CRLF + "     OR RTRIM(LTRIM(FT_LOJA)) = ''"
	cQry += CRLF + "   )"
	cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQry += CRLF + " GROUP BY "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
	cQry += CRLF + "   ,FT_EMISSAO"
	cQry += CRLF + "   ,FT_ESPECIE"
	cQry += CRLF + " ORDER BY "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
ElseIf nTipo == 4
	//cliente não está na SA1
	cQry += CRLF + " SELECT "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
	cQry += CRLF + "   ,FT_EMISSAO"
	cQry += CRLF + "   ,FT_ESPECIE"
	cQry += CRLF + "   ,FT_TIPO"
	cQry += CRLF + "   ,SUM(FT_VALCONT) AS VALCONT"
	cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SA1') + " SA1"
	cQry += CRLF + " ON  SA1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND A1_FILIAL = '" + xFilial('SA1') + "'"
	cQry += CRLF + " AND A1_COD = FT_CLIEFOR"
	cQry += CRLF + " AND A1_LOJA = FT_LOJA"
	cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
	cQry += CRLF + "   AND ("
	cQry += CRLF + "        A1_COD IS NULL"
	cQry += CRLF + "     OR A1_LOJA IS NULL"
	cQry += CRLF + "   )"
	cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
	cQry += CRLF + "   AND FT_TIPO NOT IN ('D','B')"
	cQry += CRLF + " GROUP BY "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
	cQry += CRLF + "   ,FT_EMISSAO"
	cQry += CRLF + "   ,FT_ESPECIE"
	cQry += CRLF + "   ,FT_TIPO"
	
	cQry += CRLF + " UNION ALL"

	cQry += CRLF + " SELECT "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
	cQry += CRLF + "   ,FT_EMISSAO"
	cQry += CRLF + "   ,FT_ESPECIE"
	cQry += CRLF + "   ,FT_TIPO"
	cQry += CRLF + "   ,SUM(FT_VALCONT) AS VALCONT"
	cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SA1') + " SA1"
	cQry += CRLF + " ON  SA1.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND A1_FILIAL = '" + xFilial('SA1') + "'"
	cQry += CRLF + " AND A1_COD = FT_CLIEFOR"
	cQry += CRLF + " AND A1_LOJA = FT_LOJA"
	cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
	cQry += CRLF + "   AND ("
	cQry += CRLF + "        A1_COD IS NULL"
	cQry += CRLF + "     OR A1_LOJA IS NULL"
	cQry += CRLF + "   )"
	cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
	cQry += CRLF + "   AND FT_TIPO IN ('D','B')"
	cQry += CRLF + " GROUP BY "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
	cQry += CRLF + "   ,FT_EMISSAO"
	cQry += CRLF + "   ,FT_ESPECIE"
	cQry += CRLF + "   ,FT_TIPO"
	
	cQry += CRLF + " ORDER BY "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
ElseIf nTipo == 5
	//fornecedor não está na SA2
	cQry += CRLF + " SELECT "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
	cQry += CRLF + "   ,FT_EMISSAO"
	cQry += CRLF + "   ,FT_ESPECIE"
	cQry += CRLF + "   ,FT_TIPO"
	cQry += CRLF + "   ,SUM(FT_VALCONT) AS VALCONT"
	cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SA2') + " SA2"
	cQry += CRLF + " ON  SA2.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND A2_FILIAL = '" + xFilial('SA2') + "'"
	cQry += CRLF + " AND A2_COD = FT_CLIEFOR"
	cQry += CRLF + " AND A2_LOJA = FT_LOJA"
	cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
	cQry += CRLF + "   AND ("
	cQry += CRLF + "        A2_COD IS NULL"
	cQry += CRLF + "     OR A2_LOJA IS NULL"
	cQry += CRLF + "   )"
	cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
	cQry += CRLF + "   AND FT_TIPO NOT IN ('D','B')"
	cQry += CRLF + " GROUP BY "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
	cQry += CRLF + "   ,FT_EMISSAO"
	cQry += CRLF + "   ,FT_ESPECIE"
	cQry += CRLF + "   ,FT_TIPO"
	
	cQry += CRLF + " UNION ALL"

	cQry += CRLF + " SELECT "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
	cQry += CRLF + "   ,FT_EMISSAO"
	cQry += CRLF + "   ,FT_ESPECIE"
	cQry += CRLF + "   ,FT_TIPO"
	cQry += CRLF + "   ,SUM(FT_VALCONT) AS VALCONT"
	cQry += CRLF + " FROM " + RetSqlName('SFT') + " SFT"
	cQry += CRLF + " LEFT JOIN " + RetSqlName('SA2') + " SA2"
	cQry += CRLF + " ON  SA2.D_E_L_E_T_ <> '*'"
	cQry += CRLF + " AND A2_FILIAL = '" + xFilial('SA2') + "'"
	cQry += CRLF + " AND A2_COD = FT_CLIEFOR"
	cQry += CRLF + " AND A2_LOJA = FT_LOJA"
	cQry += CRLF + " WHERE SFT.D_E_L_E_T_ <> '*'"
	cQry += CRLF + "   AND FT_FILIAL = '" + xFilial('SFT') + "'"
	cQry += CRLF + "   AND ("
	cQry += CRLF + "        A2_COD IS NULL"
	cQry += CRLF + "     OR A2_LOJA IS NULL"
	cQry += CRLF + "   )"
	cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
	cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
	cQry += CRLF + "   AND FT_TIPO IN ('D','B')"
	cQry += CRLF + " GROUP BY "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
	cQry += CRLF + "   ,FT_EMISSAO"
	cQry += CRLF + "   ,FT_ESPECIE"
	cQry += CRLF + "   ,FT_TIPO"
	
	cQry += CRLF + " ORDER BY "
	cQry += CRLF + "    FT_TIPOMOV"
	cQry += CRLF + "   ,FT_ENTRADA"
	cQry += CRLF + "   ,FT_SERIE"
	cQry += CRLF + "   ,FT_NFISCAL"
	cQry += CRLF + "   ,FT_CLIEFOR"
	cQry += CRLF + "   ,FT_LOJA"
EndIf

cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY',.T.)

nCnt := 0
MQRY->(dbEval({||nCnt++}))
MQRY->(dbGoTop())

If nCnt == 0
	If MV_PAR04 == 1
		MsgAlert('Não existem dados a serem apresentados.')
	Else
		aAdd(aExcel, {''})
		aAdd(aExcel, {'Problema: '+cValToChar(nTipo)+' = '+aProb[nTipo]})
		aAdd(aExcel, {'Não existem dados a serem apresentados.'})
		aAdd(aExcel, {''})
	EndIf
	MQRY->(dbCloseArea())
	Return .F.
EndIf

ProcRegua(nCnt)

aAdd(aExcel, {''})
aAdd(aExcel, {'Problema: '+cValToChar(nTipo)+' = '+aProb[nTipo]})
aAdd(aExcel, aClone(aProbCab[nTipo]))
		
While !MQRY->(Eof())
	If nTipo == 1
		//produto em branco
		aAdd(aExcel, {;
			TipoMov(MQRY->FT_TIPOMOV),;
			STOD(MQRY->FT_ENTRADA),;
			MQRY->FT_SERIE,;
			MQRY->FT_NFISCAL,;
			MQRY->FT_ESPECIE,;
			MQRY->FT_CLIEFOR,;
			MQRY->FT_LOJA,;
			STOD(MQRY->FT_EMISSAO),;
			MQRY->FT_CFOP,;
			MQRY->FT_VALCONT,;
			MQRY->FT_ITEM,;
			MQRY->FT_QUANT;
		})
	ElseIf nTipo == 2
		//produto não está na SB1
		aAdd(aExcel, {;
			TipoMov(MQRY->FT_TIPOMOV),;
			STOD(MQRY->FT_ENTRADA),;
			MQRY->FT_SERIE,;
			MQRY->FT_NFISCAL,;
			MQRY->FT_ESPECIE,;
			MQRY->FT_CLIEFOR,;
			MQRY->FT_LOJA,;
			STOD(MQRY->FT_EMISSAO),;
			MQRY->FT_CFOP,;
			MQRY->FT_VALCONT,;
			MQRY->FT_ITEM,;
			MQRY->FT_QUANT,;
			MQRY->FT_PRODUTO;
		})
	ElseIf nTipo == 3
		//cliente/fornecedor em branco
		aAdd(aExcel, {;
			TipoMov(MQRY->FT_TIPOMOV),;
			STOD(MQRY->FT_ENTRADA),;
			MQRY->FT_SERIE,;
			MQRY->FT_NFISCAL,;
			MQRY->FT_ESPECIE,;
			STOD(MQRY->FT_EMISSAO),;
			MQRY->VALCONT;
		})
	ElseIf nTipo == 4
		//cliente não está na SA1
		aAdd(aExcel, {;
			TipoMov(MQRY->FT_TIPOMOV),;
			TipoNF(MQRY->FT_TIPO),;
			STOD(MQRY->FT_ENTRADA),;
			MQRY->FT_SERIE,;
			MQRY->FT_NFISCAL,;
			MQRY->FT_ESPECIE,;
			MQRY->FT_CLIEFOR,;
			MQRY->FT_LOJA,;
			STOD(MQRY->FT_EMISSAO),;
			MQRY->VALCONT;
		})
	ElseIf nTipo == 5
		//fornecedor não está na SA2
		aAdd(aExcel, {;
			TipoMov(MQRY->FT_TIPOMOV),;
			TipoNF(MQRY->FT_TIPO),;
			STOD(MQRY->FT_ENTRADA),;
			MQRY->FT_SERIE,;
			MQRY->FT_NFISCAL,;
			MQRY->FT_ESPECIE,;
			MQRY->FT_CLIEFOR,;
			MQRY->FT_LOJA,;
			STOD(MQRY->FT_EMISSAO),;
			MQRY->VALCONT;
		})
	EndIf
	MQRY->(dbSkip())
EndDo

MQRY->(dbCloseArea())

aAdd(aExcel, {''})

Return .T.

/* -------------- */

Static Function TipoMov(cTipo)

Local cRet  := ''
Local aTipo := {;
	{'E','Entrada'},;
	{'S','Saída'};
}
Local nPos

nPos := aScan(aTipo, {|x| x[1] == AllTrim(cTipo)})
If nPos > 0
	cRet := aTipo[nPos][2]
EndIf

Return cRet

/* -------------- */

Static Function TipoNF(cTipo)

Local cRet  := ''
Local aTipo := {;
	{'' ,'Normal'},;
	{'N','Normal'},;
	{'D','Devolução'},;
	{'I','Compl. ICMS'},;
	{'P','Compl. IPI'},;
	{'C','Compl. Preço/Frete'},;
	{'B','Beneficiamento'};
}
Local nPos

nPos := aScan(aTipo, {|x| x[1] == AllTrim(cTipo)})
If nPos > 0
	cRet := aTipo[nPos][2]
EndIf

Return cRet

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

aHelpPor := {}
aAdd(aHelpPor, 'Selecione o tipo de problema que você')
aAdd(aHelpPor, 'deseja visualizar a relação:         ')
aAdd(aHelpPor, '1 = Produto em branco                ')
aAdd(aHelpPor, '2 = Produto não está na SB1          ')
aAdd(aHelpPor, '3 = Cliente/Fornecedor em branco     ')
aAdd(aHelpPor, '4 = Cliente não está na SA1          ')
aAdd(aHelpPor, '5 = Fornecedor não está na SA2       ')
cNome := 'Tipo'
PutSx1(PadR(cPerg,nTamGrp), '03', cNome, cNome, cNome,;
'MV_CH3', 'N', 1, 0, 1, 'C', '', '', '', '', 'MV_PAR03',;
'Problema 1', 'Problema 1', 'Problema 1', '',;
'Problema 2', 'Problema 2', 'Problema 2',;
'Problema 3', 'Problema 3', 'Problema 3',;
'Problema 4', 'Problema 4', 'Problema 4',;
'Problema 5', 'Problema 5', 'Problema 5',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Selecione se deseja listar todos os  ')
aAdd(aHelpPor, 'problemas de uma única vez.          ')
cNome := 'Todos os problemas'
PutSx1(PadR(cPerg,nTamGrp), '04', cNome, cNome, cNome,;
'MV_CH4', 'N', 1, 0, 1, 'C', '', '', '', '', 'MV_PAR04',;
'Não', 'Não', 'Não', '',;
'Sim', 'Sim', 'Sim',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
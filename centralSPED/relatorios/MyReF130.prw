#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyReF130()
///////////////////////////////////////////////////////////////////////////////
// Data : 11/08/2014
// User : Thieres Tembra
// Desc : Relatório dos registros gerados para o bloco F130 através
//        da função AtfRegF130 padrão Protheus
///////////////////////////////////////////////////////////////////////////////
Local cTitulo := 'Relatório do registro F130'
Local cPerg := '#MYREF130'

CriaSX1(cPerg)

If !Pergunte(cPerg, .T., cTitulo)
	Return Nil
End If

If AllTrim(MV_PAR01) == '' .or. AllTrim(MV_PAR02) == ''
	Alert('Informe as datas para geração do relatório.')
	Return Nil
ElseIf MV_PAR01 > MV_PAR02
	Alert('O ano mês final deve ser igual ou maior que o ano mês inicial.')
	Return Nil
EndIf

Processa({|| Executa(cTitulo) },cTitulo,'Aguarde...')

Return Nil

/* ------------------- */

Static Function Executa(cTitulo)

Local aExcel   := {}
Local cArq     := 'MYREF130'
Local aResult
Local cAliasF130
Local cDescCta, cDescCC, cNomeFor
Local aCST := {}
Local nPos, nI, nMax, nMaxF, nTot
Local aMes := {}
Local cMes
Local nMes, nAno
Local cMesLim, cMesOpe
Local nParApr

aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' às '+Time()+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Período: '+MV_PAR01+' até '+MV_PAR02})
aAdd(aExcel, {''})
aAdd(aExcel, {'Empresa: '+cEmpAnt+'/'+cFilAnt+'-'+AllTrim(SM0->M0_NOME)+' / '+AllTrim(SM0->M0_FILIAL)})
aAdd(aExcel, {''})

cMes := MV_PAR01
While cMes <= MV_PAR02
	aAdd(aMes, cMes)
	If Right(cMes,2) == '12'
		cMes := StrZero(Val(Left(cMes,4))+1,4) + '01'
	Else
		cMes := Left(cMes,4) + StrZero(Val(Right(cMes,2))+1,2)
	EndIf
EndDo

nMaxF := 0
nMax := Len(aMes)

ProcRegua(nMax)

aAdd(aExcel, {;
				'Mês Referência'							,;
				'CodBCC'										,;
				'Identificação'							,;
				'Origem'										,;
				'Utilização'								,;
				'Mês/Ano Aquisição'						,;
				'Mês/Ano Limite'						,;
				'Valor de Aquisição'						,;
				'Parcela a Excluir do Valor de Aquisição'		,;
				'Valor BCC'									,;
				'Nr. Parcelas a serem apropriadas'	,;
				'Parcela Apropriada'	,;
				'CST PIS'									,;
				'Base Cálculo PIS'						,;
				'Alíq. PIS'									,;
				'Valor PIS'									,;
				'CST COFINS'								,;
				'Base Cálculo COFINS'					,;
				'Alíq. COFINS'								,;
				'Valor COFINS'								,;
				'Conta Analítica'							,;
				'Nome da Conta'							,;
				'Centro de Custo'							,;
				'Descrição CC'								,;
				'Descrição Complementar'				,;
				'Bem'											,;
				'Item'										,;
				'Data Aquisição'							,;
				'Nota Fiscal'								,;
				'Série'										,;
				'Fornecedor'								,;
				'Loja'										,;
				'Nome'										 ;
})
		
For nI := 1 to nMax
	IncProc('Analisando mês ' + aMes[nI] + '..')
	
	nMes := Val(Right(aMes[nI],2))
	nAno := Val(Left(aMes[nI],4))
	
	cAliasF130 := GetNextAlias()
	aResult := _AtfRegF130(xFilial('SN1'),U_MyDia(1,nMes,nAno),U_MyDia(2,nMes,nAno),"          ","ZZZZZZZZZZ",cAliasF130)
	
	If Len(aResult) > 0
		cAliasF130 := aResult[1,2]
				
		nTot := 0
		(cAliasF130)->(dbEval({ || nTot++ }))
		(cAliasF130)->(dbGoTop())
		nMaxF += nTot
		
		While !(cAliasF130)->(Eof())
			
			cDescCta := Posicione('CT1',1,xFilial('CT1') + (cAliasF130)->COD_CTA,'CT1_DESC01')
			cDescCC  := Posicione('CTT',1,xFilial('CTT') + (cAliasF130)->COD_CCUS,'CTT_DESC01')
			cNomeFor := Posicione('SA2',1,xFilial('SA2') + (cAliasF130)->FORNECEDOR + (cAliasF130)->LOJA,'A2_NOME')
			
			cMesOpe := StrZero((cAliasF130)->MES_OPER_A,6)
			
			If (cAliasF130)->IND_NR_PAR == 3
				cMesLim := cMesOpe
				If Left(cMesLim,2) == '01'
					cMesLim := '12' + StrZero(Val(Right(cMesLim,4))+1,4)
				Else
					cMesLim := StrZero(Val(Left(cMesLim,2))-1,2) + StrZero(Val(Right(cMesLim,4))+2,4)
				EndIf
				nParApr := U_MyDMes(CTOD('01/' + Left(cMesOpe,2) + '/' + Right(cMesOpe,4)),CTOD('01/' + Right(aMes[nI],2) + '/' + Left(aMes[nI],4)))
				If nParApr == 0
					nParApr := 1
				EndIf
			Else
				cMesLim := StrZero((cAliasF130)->MES_OPER_A,6)
				nParApr := 0
			EndIf
			aAdd(aExcel, {;
							aMes[nI]				,;
							(cAliasF130)->NAT_BC_CRE				,;
							IndIde((cAliasF130)->IDENT_BEM) 		,;
							IndOri((cAliasF130)->IND_ORIG_C)		,;
							IndUti((cAliasF130)->IND_UTIL_B)		,;
							cMesOpe	,;
							cMesLim	,;
							(cAliasF130)->VL_OPER_AQ				,;
							(cAliasF130)->PARC_OPER					,;
							(cAliasF130)->VL_BC_CRED				,;
							IndPar((cAliasF130)->IND_NR_PAR)		,;
							Iif(nParApr==0,'0',cValToChar(nParApr)+'a.')		,;
							(cAliasF130)->CST_PIS					,;
							(cAliasF130)->VL_BC_PIS					,;
							(cAliasF130)->ALIQ_PIS					,;
							(cAliasF130)->VL_PIS						,;
							(cAliasF130)->CST_COFINS				,;
							(cAliasF130)->VL_BC_COFIN				,;
							(cAliasF130)->ALIQ_COFIN				,;
							(cAliasF130)->VL_COFINS					,;
							(cAliasF130)->COD_CTA					,;
							cDescCta										,;
							(cAliasF130)->COD_CCUS					,;
							cDescCC										,;
							(cAliasF130)->DESC_BEM_I				,;
							(cAliasF130)->BEM							,;
							(cAliasF130)->ITEM						,;
							(cAliasF130)->DTAQS						,;
							(cAliasF130)->NOTAFISCAL				,;
							(cAliasF130)->SERIE						,;
							(cAliasF130)->FORNECEDOR				,;
							(cAliasF130)->LOJA			 			,;
							cNomeFor							 			 ;
			})
			
			nPos := aScan(aCST, {|x| x[1] == (cAliasF130)->CST_PIS })
			If nPos <> 0
				aCST[nPos][2] += (cAliasF130)->VL_BC_PIS
				aCST[nPos][3] += (cAliasF130)->VL_BC_COFIN
				aCST[nPos][4] += (cAliasF130)->VL_PIS
				aCST[nPos][5] += (cAliasF130)->VL_COFINS
			Else
				aAdd(aCST, {(cAliasF130)->CST_PIS, (cAliasF130)->VL_BC_PIS, (cAliasF130)->VL_BC_COFIN, (cAliasF130)->VL_PIS, (cAliasF130)->VL_COFINS})
			EndIf
			
			(cAliasF130)->(dbSkip())
		EndDo
		(cAliasF130)->(dbCloseArea())
	EndIf
Next nI

If nMaxF > 0
	aAdd(aExcel, {''})
	aAdd(aExcel, {'Totais por CST'})
	aAdd(aExcel, {'CST','Base PIS','Base COFINS','Valor PIS','Valor COFINS'})
	aSort(aCST,,,{|x,y| x[1] < y[1] })
	nMax := Len(aCST)
	For nI := 1 to nMax
		aAdd(aExcel, {aCST[nI][1], aCST[nI][2], aCST[nI][3], aCST[nI][4], aCST[nI][5]})
	Next nI
Else
	aAdd(aExcel, {'Não existem registros a serem apresentados.'})
EndIf

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

Static Function IndIde(nInd)

Local cRet := ''
Local aInd := {;
	{'01', '01 - Edificações e Benfeitorias'},;
	{'03', '03 - Instalações'},;
	{'04', '04 - Máquinas'},;
	{'05', '05 - Equipamentos'},;
	{'06', '06 - Veículos'},;
	{'99', '99 - Outros Bens Incorporados ao Ativo Imobilizado'};
}
Local nPos

nPos := aScan(aInd, {|x| x[1] == StrZero(nInd,2) })
If nPos > 0
	cRet := aInd[nPos][2]
EndIf

Return cRet

/* ------------------- */

Static Function IndOri(cInd)

Local cRet := ''
Local aInd := {;
	{'0', '0 - Aquisição no Mercado Interno'},;
	{'1', '1 - Aquisição no Mercado Externo (Importação)'};
}
Local nPos

nPos := aScan(aInd, {|x| x[1] == cInd })
If nPos > 0
	cRet := aInd[nPos][2]
EndIf

Return cRet

/* ------------------- */

Static Function IndUti(nInd)

Local cRet := ''
Local aInd := {;
	{'1', '1 - Produção de Bens Destinados a Venda'},;
	{'2', '2 - Prestação de Serviços'},;
	{'3', '3 - Locação a Terceiros'},;
	{'9', '9 - Outros'};
}
Local nPos

nPos := aScan(aInd, {|x| x[1] == StrZero(nInd,1) })
If nPos > 0
	cRet := aInd[nPos][2]
EndIf

Return cRet

/* ------------------- */

Static Function IndPar(nInd)

Local cRet := ''
Local aInd := {;
	{'1', '1 - Integral (Mês de Aquisição)'},;
	{'2', '2 - 12 Meses'},;
	{'3', '3 - 24 Meses'},;
	{'4', '4 - 48 Meses'},;
	{'5', '6 - 6 Meses (Embalagens de bebidas frias)'},;
	{'9', '9 - Outra periodicidade definida em Lei'};
}
Local nPos

nPos := aScan(aInd, {|x| x[1] == StrZero(nInd,1) })
If nPos > 0
	cRet := aInd[nPos][2]
EndIf

Return cRet

/* ------------------- */

Static Function CriaSX1(cPerg,cCFPad)

Local nTamGrp := Len(SX1->X1_GRUPO)
Local aHelpPor := {}, aHelpEng := {}, aHelpSpa := {}
Local cNome

aHelpPor := {}
aAdd(aHelpPor, 'Informe o ano/mês inicial para       ')
aAdd(aHelpPor, 'geração do relatório. Deve ser       ')
aAdd(aHelpPor, 'informado a data de aquisição.       ')
aAdd(aHelpPor, 'Ex: 201201                           ')
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
aAdd(aHelpPor, 'Informe o ano/mês final para         ')
aAdd(aHelpPor, 'geração do relatório. Deve ser       ')
aAdd(aHelpPor, 'informado a data de aquisição.       ')
aAdd(aHelpPor, 'Ex: 201203                           ')
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
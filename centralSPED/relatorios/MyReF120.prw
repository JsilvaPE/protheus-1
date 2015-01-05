#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyReF120()
///////////////////////////////////////////////////////////////////////////////
// Data : 16/10/2014
// User : Thieres Tembra
// Desc : Relatório dos registros gerados para o bloco F120 através
//        da função DeprecAtivo padrão Protheus
///////////////////////////////////////////////////////////////////////////////
Local cTitulo := 'Relatório do registro F120'
Local cPerg := '#MYREF120'

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
Local cArq     := 'MYREF120'
Local aResult
Local cAliasF120
Local cDescCta, cDescCC, cNomeFor
Local aCST := {}
Local nPos, nI, nMax, nMaxF, nTot
Local aMes := {}
Local aProcItem := {}
Local cMes
Local nMes, nAno
Local cCSTCRED	:= '50/51/52/53/54/55/56/60/61/62/63/64/65/66/67'

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
				'Valor de Depreciação/Amortização'						,;
				'Parcela a Excluir do Valor de Depreciação/Amortização'		,;
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
				'Processo Referenciado'				,;
				'Indicador de Origem do Processo'				,;
				'Bem'											,;
				'Item'										,;
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
	
	cAliasF120 := GetNextAlias()
	aProcItem := {'          ','ZZZZZZZZZZ',CTOD(''),U_MyDia(2,nMes,nAno),cAliasF120}
	aResult := _DeprecAtivo(U_MyDia(1,nMes,nAno),aProcItem[4],.T.,.F.,aProcItem,,.F.,'09/11',SM0->M0_CODFIL,.F.)
	
	(cAliasF120)->(dbSetOrder(1))
	(cAliasF120)->(dbGoTop())
	
	If !(cAliasF120)->(Eof()) .and. (cAliasF120)->(FieldPos('NATBCCRED')) > 0 .and. Len(aResult) > 0
		cAliasF120 := aResult[1,2]
				
		nTot := 0
		(cAliasF120)->(dbEval({ || nTot++ }))
		(cAliasF120)->(dbGoTop())
		nMaxF += nTot
		
		While !(cAliasF120)->(Eof())
			
			If (cAliasF120)->CSTPIS $ cCSTCRED .or. (cAliasF120)->CSTCOFINS $ cCSTCRED			
				cDescCta := Posicione('CT1',1,xFilial('CT1') + (cAliasF120)->CODCONTA,'CT1_DESC01')
				cDescCC  := Posicione('CTT',1,xFilial('CTT') + (cAliasF120)->CODCCUSTO,'CTT_DESC01')
				cNomeFor := Posicione('SA2',1,xFilial('SA2') + (cAliasF120)->FORNECEDOR + (cAliasF120)->LOJA,'A2_NOME')
				
				aAdd(aExcel, {;
								aMes[nI]                         ,;
								(cAliasF120)->NATBCCRED          ,;
								IndIde((cAliasF120)->INDBEMIMOB) ,;
								IndOri((cAliasF120)->INDORIGCRD) ,;
								IndUti((cAliasF120)->INDUTILBEM) ,;
								(cAliasF120)->VRET               ,;
								0                                ,;
								(cAliasF120)->CSTPIS             ,;
								(cAliasF120)->VLRBCPIS           ,;
								(cAliasF120)->ALIQPIS            ,;
								(cAliasF120)->VLRPIS             ,;
								(cAliasF120)->CSTCOFINS          ,;
								(cAliasF120)->VLRBCCOFIN         ,;
								(cAliasF120)->ALIQCOFINS         ,;
								(cAliasF120)->VLRCOFINS          ,;
								(cAliasF120)->CODCONTA           ,;
								cDescCta                         ,;
								(cAliasF120)->CODCCUSTO          ,;
								cDescCC                          ,;
								(cAliasF120)->DESCBEMIMO         ,;
								(cAliasF120)->NUMPRO             ,;
								IndPro((cAliasF120)->INDPRO)     ,;
								(cAliasF120)->BEM                ,;
								(cAliasF120)->ITEM               ,;
								(cAliasF120)->NOTAFISCAL         ,;
								(cAliasF120)->SERIE              ,;
								(cAliasF120)->FORNECEDOR         ,;
								(cAliasF120)->LOJA               ,;
								cNomeFor                          ;
				})
				
				nPos := aScan(aCST, {|x| x[1] == (cAliasF120)->CSTPIS })
				If nPos <> 0
					aCST[nPos][2] += (cAliasF120)->VLRBCPIS
					aCST[nPos][3] += (cAliasF120)->VLRBCCOFIN
					aCST[nPos][4] += (cAliasF120)->VLRPIS
					aCST[nPos][5] += (cAliasF120)->VLRCOFINS
				Else
					aAdd(aCST, {(cAliasF120)->CSTPIS, (cAliasF120)->VLRBCPIS, (cAliasF120)->VLRBCCOFIN, (cAliasF120)->VLRPIS, (cAliasF120)->VLRCOFINS})
				EndIf
			EndIf
			
			(cAliasF120)->(dbSkip())
		EndDo
		(cAliasF120)->(dbCloseArea())
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

Static Function IndIde(cInd)

Local cRet := ''
Local aInd := {;
	{'01', '01 - Edificações e Benfeitorias em Imóveis Próprios'},;
	{'02', '02 - Edificações e Benfeitorias em Imóveis de Terceiros'},;
	{'03', '03 - Instalações'},;
	{'04', '04 - Máquinas'},;
	{'05', '05 - Equipamentos'},;
	{'06', '06 - Veículos'},;
	{'99', '99 - Outros'};
}
Local nPos

nPos := aScan(aInd, {|x| x[1] == cInd })
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

Static Function IndUti(cInd)

Local cRet := ''
Local aInd := {;
	{'1', '1 - Produção de Bens Destinados a Venda'},;
	{'2', '2 - Prestação de Serviços'},;
	{'3', '3 - Locação a Terceiros'},;
	{'9', '9 - Outros'};
}
Local nPos

nPos := aScan(aInd, {|x| x[1] == cInd })
If nPos > 0
	cRet := aInd[nPos][2]
EndIf

Return cRet

/* ------------------- */

Static Function IndPro(cInd)

Local cRet := ''
Local aInd := {;
	{'0', '0 - SEFAZ'},;
	{'1', '1 - Justiça Federal'},;
	{'2', '2 - Justiça Estadual'},;
	{'3', '3 - Secretaria da Receita Federal do Brasil'},;
	{'9', '9 - Outros'};
}
Local nPos

nPos := aScan(aInd, {|x| x[1] == cInd })
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
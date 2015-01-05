#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyReF100()
///////////////////////////////////////////////////////////////////////////////
// Data : 24/05/2014
// User : Thieres Tembra
// Desc : Relatório dos registros gerados para o bloco F100 através
//        da função MyF100 customizada
///////////////////////////////////////////////////////////////////////////////
Local cTitulo := 'Relatório do registro F100 customizado'
Local cPerg := '#MYREF100'

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

Local cFilDe   := MV_PAR03
Local cFilAte  := MV_PAR04
Local dDataDe  := MV_PAR01
Local dDataAte := MV_PAR02
Local aExcel   := {}
Local aRegs    := {}
Local aPart    := {}
Local aArea    := GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local aAreaSA2 := SA2->(GetArea())
Local aAreaSED := SED->(GetArea())
Local aAreaCT1 := CT1->(GetArea())
Local aAreaCVD := CVD->(GetArea())
Local aAreaCTT := CTT->(GetArea())
Local cArq     := 'MYREF100'
Local nI, nMax
Local cTab, cNat, cCST, cBCC, nVlr, nRec
Local cIndOper, cCodPart, cCodLoja, cCodCta, cCodCCus
Local nAliqPIS, nVlrPIS, nAliqCOF, nVlrCOF, nValCom5
Local cCtaNat, cCtaInd, cCtaNiv, cCtaCod, cCtaNom, cCtaRef
Local cCCCod, cCCDesc
Local dDatOper, dCtaDta, dCCDta
Local cAux, cRet
Local cSFX := ''
Local cSFT := ''
Local cQry
Local aTFil := {}
Local aTGeral := {}
Local nPos

Local aOper := {;
	'0-Aquisição, Custos, Despesa ou Encargos, ou Receitas, Sujeita à Incidência de Crédito de PIS/Pasep ou Cofins (CST 50 a 66).'	,;
	'1-Receita Auferida Sujeita ao Pagamento da Contribuição para o PIS/Pasep e da Cofins (CST 01, 02, 03 ou 05).'					,;
	'2-Receita Auferida Não Sujeita ao Pagamento da Contribuição para o PIS/Pasep e da Cofins (CST 04, 06, 07, 08, 09, 49 ou 99)'	 ;
}

SA1->(dbSetOrder(1))
SA2->(dbSetOrder(1))
SED->(dbSetOrder(1))
CT1->(dbSetOrder(1))
CVD->(dbSetOrder(1))
CTT->(dbSetOrder(1))

aRegs := U_MyF100(cFilDe,dDataDe,dDataAte,cFilAte)

aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' às '+Time()+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Período: '+DTOC(MV_PAR01)+' até '+DTOC(MV_PAR02)+' - Filial: '+MV_PAR03+' até '+MV_PAR04})
aAdd(aExcel, {''})
aAdd(aExcel, {	'Filial'				 			,;
				'Indicador do Tipo da Operação',;
				'Cliente/Fornecedor'	 			,;
				'Loja'					 			,;
				'Nome Cliente/Fornecedor' 		,;
				'Data da Operação'		 		,;
				'Valor da Operação'		 		,;
				'CST PIS'			  				,;
				'Base Cálculo PIS'	  			,;
				'Alíq. PIS'			  				,;
				'Valor PIS'							,;
				'CST COFINS'		  				,;
				'Base Cálculo COFINS'  			,;
				'Alíq. COFINS'		  				,;
				'Valor COFINS'						,;
				'CodBCC'			 					,;
				'Origem do Crédito'	  			,;
				'Conta Analítica Custo'			,;
				'Nome da Conta'					,;
				'Centro de Custo'		 			,;
				'Descrição CC'						,;
				'Tabela Origem'			  		,;
				'Prefixo'							,;
				'Título'						  		,;
				'Parcela'							,;
				'Tipo'								,;
				'Natureza'							,;
				'Emissão'							,;
				'Vencimento'						,;
				'Vencimento Real'					,;
				'Data da Baixa'					,;
				'Valor'		 						,;
				'Valor Comissão 5'				,;
				'Origem'								,;
				'Existe na SF1/SF2'				,;
				'Existe na SFT'					,;
				'RecNo'								 ;
})

nMax := Len(aRegs)
ProcRegua(nMax)
For nI := 1 to nMax
	IncProc('Analisando registro ' + cValToChar(nI) + '/' + cValToChar(nMax) + '..')
	
	cTab := aRegs[nI][01] //01 - Tabela
	cNat := aRegs[nI][02] //02 - Natureza
	cCC  := aRegs[nI][03] //03 - Centro de Custo
	cCST := aRegs[nI][04] //04 - CST
	cBCC := aRegs[nI][05] //05 - BCC
	nVlr := aRegs[nI][06] //06 - Valor
	nRec := aRegs[nI][07] //07 - RecNo
	
	//limpa campos auxiliares que serão usados na criação do registro
	cIndOper := cCodPart := cCodLoja := cCodCta := cCodCCus := ''
	nAliqPIS := nVlrPIS  := nAliqCOF := nVlrCOF := nValCom5 := 0
	cCtaNat  := cCtaInd  := cCtaNiv  := cCtaCod := cCtaNom  := cCtaRef := ''
	cCCCod   := cCCDesc  := ''
	dDatOper := dCCDta   := dCtaDta  := CTOD('')
	
	//posiciona título
	(cTab)->(dbGoTo(nRec))
	
	//posiciona cliente/fornecedor
	If cTab == 'SE1'
		If !SA1->(dbSeek( xFilial('SA1') + (cTab)->E1_CLIENTE + (cTab)->E1_LOJA ))
			Alert('O cliente ' + (cTab)->E1_CLIENTE + '-' + (cTab)->E1_LOJA +;
			' não foi encontrado no sistema! O título do ' + cTab + ' com recno ' + cValToChar(nRec) +;
			' não será gerado no relatório.')
			Loop
		EndIf
		cCodPart := SA1->A1_COD
		cCodLoja := SA1->A1_LOJA
		aPart    := InfPartDoc('SA1')
	ElseIf cTab == 'SE2'
		If !SA2->(dbSeek( xFilial('SA2') + (cTab)->E2_FORNECE + (cTab)->E2_LOJA ))
			Alert('O fornecedor ' + (cTab)->E2_FORNECE + '-' + (cTab)->E2_LOJA +;
			' não foi encontrado no sistema! O título do ' + cTab + ' com recno ' + cValToChar(nRec) +;
			' não será gerado no relatório.')
			Loop
		EndIf
		cCodPart := SA2->A2_COD
		cCodLoja := SA2->A2_LOJA
		aPart    := InfPartDoc('SA2')
	EndIf
	
	//posiciona natureza (SED)
	If cNat <> ''
		If !SED->(dbSeek( xFilial('SED') + cNat ))
			Alert('A natureza ' + cNat + ' não foi encontrada no sistema!' +;
			' O título do ' + cTab + ' com recno ' + cValToChar(nRec) +;
			' não será gerado no relatório.')
			Loop
		EndIf
		
		//posiciona conta contábil custo (CT1)
		If AllTrim(SED->ED_CONTAC) <> ''
			If !CT1->(dbSeek( xFilial('CT1') + SED->ED_CONTAC ))
				Alert('A conta contábil ' + SED->ED_CONTAC + ' não foi encontrada no sistema!' +;
				' O título do ' + cTab + ' com recno ' + cValToChar(nRec) +;
				' não será gerado no relatório.')
				Loop
			EndIf
			
			cCodCta := AllTrim(CT1->CT1_CONTA + xFilial('CT1'))
			dCtaDta := CT1->CT1_DTEXIS
			cCtaNat := CT1->CT1_NTSPED
			cCtaInd := Iif(CT1->CT1_CLASSE=='1','S','A')
			cCtaNiv := Str(CtbNivCta(CT1->CT1_CONTA))
			cCtaCod := AllTrim(CT1->CT1_CONTA + xFilial('CT1'))
			cCtaNom := CT1->CT1_DESC01
			//verifica conta referencial (CVD)
			If CVD->(dbSeek( xFilial('CVD') + CT1->CT1_CONTA ))
				cCtaRef := CVD->CVD_CTAREF
			EndIf
		EndIf
	EndIf
	
	//posiciona centro de custo (CTT)
	If cCC <> ''
		If !CTT->(dbSeek( xFilial('CTT') + cCC ))
			Alert('O centro de custo ' + cCC + ' não foi encontrada no sistema!' +;
			' O título do ' + cTab + ' com recno ' + cValToChar(nRec) +;
			' não será gerado no relatório.')
			Loop
		EndIf
		cCodCCus := AllTrim(CTT->CTT_CUSTO + xFilial('CTT'))
		dCCDta   := CTT->CTT_DTEXIS
		cCCCod   := AllTrim(CTT->CTT_CUSTO + xFilial('CTT'))
		cCCDesc  := CTT->CTT_DESC01
	EndIf
	
	cIndOper := Iif(cTab=='SE2','0',Iif(cCST$'01;02;03;05','1','2'))
	//dDatOper := Iif(cTab=='SE1',SE1->E1_EMISSAO,SE2->E2_EMISSAO)
	dDatOper := Iif(cTab=='SE1',SE1->E1_EMIS1,SE2->E2_EMIS1)
	nAliqPIS := GetMV('MV_TXPIS')
	nVlrPIS  := Round(nVlr*nAliqPIS/100, 2)
	nAliqCOF := GetMV('MV_TXCOFIN')
	nVlrCOF  := Round(nVlr*nAliqCOF/100, 2)
	nValCom5 := Iif(cTab=='SE1',SE1->E1_VALCOM5,0)
	
	//valida se existe na SF1/SF2 e SFT
	If cTab == 'SE1' .or. (cTab == 'SE2' .and. 'FAT' $ SE2->E2_ORIGEM)
		cQry := " SELECT TOP 1"
		cQry += "    R_E_C_N_O_"
		cQry += " FROM " + RetSqlName('SF2')
		cQry += " WHERE D_E_L_E_T_ <> '*'"
		cQry += "   AND F2_FILIAL  = '" + &(cTab + '->' + Right(cTab,2) + '_FILIAL') + "'"
		cQry += "   AND F2_PREFIXO = '" + &(cTab + '->' + Right(cTab,2) + '_PREFIXO') + "'"
		cQry += "   AND F2_DUPL    = '" + &(cTab + '->' + Right(cTab,2) + '_NUM') + "'"
		cQry += "   AND F2_CLIENTE = '" + cCodPart + "'"
		cQry += "   AND F2_LOJA    = '" + cCodLoja + "'"
		dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSF2',.T.)
		cSFX := 'Não'
		While !SSF2->(Eof())
			cSFX := 'Sim'
			SSF2->(dbSkip())
		EndDo
		SSF2->(dbCloseArea())
	ElseIf cTab == 'SE2' .or. (cTab == 'SE1' .and. 'MAT' $ SE1->E1_ORIGEM)
		cQry := " SELECT TOP 1"
		cQry += "    R_E_C_N_O_"
		cQry += " FROM " + RetSqlName('SF1')
		cQry += " WHERE D_E_L_E_T_ <> '*'"
		cQry += "   AND F1_FILIAL  = '" + &(cTab + '->' + Right(cTab,2) + '_FILIAL') + "'"
		cQry += "   AND F1_PREFIXO = '" + &(cTab + '->' + Right(cTab,2) + '_PREFIXO') + "'"
		cQry += "   AND F1_DUPL    = '" + &(cTab + '->' + Right(cTab,2) + '_NUM') + "'"
		cQry += "   AND F1_FORNECE = '" + cCodPart + "'"
		cQry += "   AND F1_LOJA    = '" + cCodLoja + "'"
		dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSF1',.T.)
		cSFX := 'Não'
		While !SSF1->(Eof())
			cSFX := 'Sim'
			SSF1->(dbSkip())
		EndDo
		SSF1->(dbCloseArea())
	EndIf
	
	cQry := " SELECT TOP 1"
	cQry += "    R_E_C_N_O_"
	cQry += " FROM " + RetSqlName('SFT')
	cQry += " WHERE D_E_L_E_T_ <> '*'"
	cQry += "   AND FT_FILIAL  = '" + &(cTab + '->' + Right(cTab,2) + '_FILIAL') + "'"
	cQry += "   AND FT_SERIE   = '" + &(cTab + '->' + Right(cTab,2) + '_PREFIXO') + "'"
	cQry += "   AND FT_NFISCAL = '" + &(cTab + '->' + Right(cTab,2) + '_NUM') + "'"
	cQry += "   AND FT_CLIEFOR = '" + cCodPart + "'"
	cQry += "   AND FT_LOJA    = '" + cCodLoja + "'"
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSFT',.T.)
	cSFT := 'Não'
	While !SSFT->(Eof())
		cSFT := 'Sim'
		SSFT->(dbSkip())
	EndDo
	SSFT->(dbCloseArea())
	//fim validação
	
	aAdd(aExcel, {	&(cTab + '->' + Right(cTab,2) + '_FILIAL')	,;
					aOper[Val(cIndOper)+1]						,;
					cCodPart									,;
					cCodLoja									,;
					aPart[2]									,;
					dDatOper									,;
					nVlr										,;
					cCST										,;
					nVlr										,;
					nAliqPIS									,;
					nVlrPIS										,;
					cCST										,;
					nVlr										,;
					nAliqCOF									,;
					nVlrCOF										,;
					cBCC										,;
					'0-Operação no Mercado Interno'				,;
					cCtaCod										,;
					cCtaNom										,;
					cCCCod										,;
					cCCDesc										,;
					cTab										,;
					&(cTab + '->' + Right(cTab,2) + '_PREFIXO')	,;
					&(cTab + '->' + Right(cTab,2) + '_NUM')		,;
					&(cTab + '->' + Right(cTab,2) + '_PARCELA')	,;
					&(cTab + '->' + Right(cTab,2) + '_TIPO')	,;
					cNat													,;
					&(cTab + '->' + Right(cTab,2) + '_EMISSAO')	,;
					&(cTab + '->' + Right(cTab,2) + '_VENCTO')	,;
					&(cTab + '->' + Right(cTab,2) + '_VENCREA')	,;
					&(cTab + '->' + Right(cTab,2) + '_BAIXA')	,;
					&(cTab + '->' + Right(cTab,2) + '_VALOR')	,;
					nValCom5									,;
					&(cTab + '->' + Right(cTab,2) + '_ORIGEM')	,;
					cSFX	,;
					cSFT	,;
					&(cTab + '->(RecNo())')						 ;
	})
	
	//totalizadores por filial e CST
	nPos := aScan(aTFil, {|x| x[1] == &(cTab + '->' + Right(cTab,2) + '_FILIAL') .and. x[2] == cCST})
	If nPos <> 0
		aTFil[nPos][3] += nVlr
		aTFil[nPos][4] += nVlr
		aTFil[nPos][5] += nVlr
		aTFil[nPos][6] += nVlrPIS
		aTFil[nPos][7] += nVlrCOF
	Else
		aAdd(aTFil, {&(cTab + '->' + Right(cTab,2) + '_FILIAL'), cCST, nVlr, nVlr, nVlr, nVlrPIS, nVlrCOF})
	EndIf
	
	//totalizadores gerais por CST
	nPos := aScan(aTGeral, {|x| x[1] == cCST})
	If nPos <> 0
		aTGeral[nPos][2] += nVlr
		aTGeral[nPos][3] += nVlr
		aTGeral[nPos][4] += nVlr
		aTGeral[nPos][5] += nVlrPIS
		aTGeral[nPos][6] += nVlrCOF
	Else
		aAdd(aTGeral, {cCST, nVlr, nVlr, nVlr, nVlrPIS, nVlrCOF})
	EndIf
Next nI

//exibindo totais por filial e CST
aAdd(aExcel, {''})
aAdd(aExcel, {'Totais por Filial e CST'})
aAdd(aExcel, {'Filial','CST','Valor Operação','Base PIS','Base COFINS','Valor PIS','Valor COFINS'})
aSort(aTFil,,,{|x,y| x[1]+x[2] < y[1]+y[2] })
nMax := Len(aTFil)
For nI := 1 to nMax
	aAdd(aExcel, {aTFil[nI][1], aTFil[nI][2], aTFil[nI][3], aTFil[nI][4], aTFil[nI][5], aTFil[nI][6], aTFil[nI][7]})
Next nI

//exibindo total geral por CST (empresa)
aAdd(aExcel, {''})
aAdd(aExcel, {'Total Geral por CST'})
aAdd(aExcel, {'CST','Valor Operação','Base PIS','Base COFINS','Valor PIS','Valor COFINS'})
aSort(aTGeral,,,{|x,y| x[1] < y[1] })
nMax := Len(aTGeral)
For nI := 1 to nMax
	aAdd(aExcel, {aTGeral[nI][1], aTGeral[nI][2], aTGeral[nI][3], aTGeral[nI][4], aTGeral[nI][5], aTGeral[nI][6]})
Next nI

IncProc()

CTT->(RestArea(aAreaCTT))
CVD->(RestArea(aAreaCVD))
CT1->(RestArea(aAreaCT1))
SED->(RestArea(aAreaSED))
SA2->(RestArea(aAreaSA2))
SA1->(RestArea(aAreaSA1))
RestArea(aArea)

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
aAdd(aHelpPor, 'Informe as filiais que devem ser     ')
aAdd(aHelpPor, 'consideradas.                        ')
cNome := 'Da Filial'
PutSx1(PadR(cPerg,nTamGrp), '03', cNome, cNome, cNome,;
'MV_CH3', 'C', 2, 0, 0, 'G', '', 'SM0', '', '', 'MV_PAR03',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

cNome := 'Ate Filial'
PutSx1(PadR(cPerg,nTamGrp), '04', cNome, cNome, cNome,;
'MV_CH4', 'C', 2, 0, 0, 'G', '', 'SM0', '', '', 'MV_PAR04',;
'', '', '', 'ZZ',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
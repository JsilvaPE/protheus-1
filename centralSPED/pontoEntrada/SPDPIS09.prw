#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function SPDPIS09()
///////////////////////////////////////////////////////////////////////////////
// Data : 26/03/2014
// User : Thieres Tembra
// Desc : Permite adicionar linhas nos registros F100, 0150, 0500 e 0600 do 
//        SPED PIS/COFINS
///////////////////////////////////////////////////////////////////////////////
Local cFil     := Paramixb[1]
Local dDataDe  := Paramixb[2]
Local dDataAte := Paramixb[3]
Local aRegF100 := {}
Local aRegs    := {}
Local aPart    := {}
Local aArea    := GetArea()
Local aAreaSA1 := SA1->(GetArea())
Local aAreaSA2 := SA2->(GetArea())
Local aAreaSED := SED->(GetArea())
Local aAreaCT1 := CT1->(GetArea())
Local aAreaCVD := CVD->(GetArea())
Local aAreaCTT := CTT->(GetArea())
Local nI, nMax
Local cTab, cNat, cCST, cBCC, nVlr, nRec
Local cIndOper, cCodPart, cCodLoja, cDatOper, cCodCta, cCodCCus, cDescDoc
Local nAliqPIS, nVlrPIS, nAliqCOF, nVlrCOF
Local cCtaDta, cCtaNat, cCtaInd, cCtaNiv, cCtaCod, cCtaNom, cCtaRef
Local cCCDta, cCCCod, cCCDesc

SA1->(dbSetOrder(1))
SA2->(dbSetOrder(1))
SED->(dbSetOrder(1))
CT1->(dbSetOrder(1))
CVD->(dbSetOrder(1))
CTT->(dbSetOrder(1))

aRegs := U_MyF100(cFil,dDataDe,dDataAte)

nMax := Len(aRegs)
For nI := 1 to nMax
	cTab := aRegs[nI][01] //01 - Tabela
	cNat := aRegs[nI][02] //02 - Natureza
	cCC  := aRegs[nI][03] //03 - Centro de Custo
	cCST := aRegs[nI][04] //04 - CST
	cBCC := aRegs[nI][05] //05 - BCC
	nVlr := aRegs[nI][06] //06 - Valor
	nRec := aRegs[nI][07] //07 - RecNo
	
	//limpa campos auxiliares que serão usados na criação do registro
	cIndOper := cCodPart := cCodLoja := cDatOper := cCodCta := cCodCCus := cDescDoc := ''
	nAliqPIS := nVlrPIS  := nAliqCOF := nVlrCOF  := 0
	cCtaDta  := cCtaNat  := cCtaInd  := cCtaNiv  := cCtaCod := cCtaNom  := cCtaRef  := ''
	cCCDta   := cCCCod   := cCCDesc  := ''
	
	//posiciona título
	(cTab)->(dbGoTo(nRec))
	
	//posiciona cliente/fornecedor
	If cTab == 'SE1'
		If !SA1->(dbSeek( xFilial('SA1') + (cTab)->E1_CLIENTE + (cTab)->E1_LOJA ))
			Alert('O cliente ' + (cTab)->E1_CLIENTE + '-' + (cTab)->E1_LOJA +;
			' não foi encontrado no sistema! O título do ' + cTab + ' com recno ' + cValToChar(nRec) +;
			' não será gerado para o EFD Contribuições.')
			Loop
		EndIf
		cCodPart := SA1->A1_COD
		cCodLoja := SA1->A1_LOJA
		aPart    := InfPartDoc('SA1')
		//salva PREFIXO + NUM para utilização no campo Descrição do Documento ou Operação
		cDescDoc := (cTab)->E1_PREFIXO + (cTab)->E1_NUM
	ElseIf cTab == 'SE2'
		If !SA2->(dbSeek( xFilial('SA2') + (cTab)->E2_FORNECE + (cTab)->E2_LOJA ))
			Alert('O fornecedor ' + (cTab)->E2_FORNECE + '-' + (cTab)->E2_LOJA +;
			' não foi encontrado no sistema! O título do ' + cTab + ' com recno ' + cValToChar(nRec) +;
			' não será gerado para o EFD Contribuições.')
			Loop
		EndIf
		cCodPart := SA2->A2_COD
		cCodLoja := SA2->A2_LOJA
		aPart    := InfPartDoc('SA2')
		//salva PREFIXO + NUM para utilização no campo Descrição do Documento ou Operação
		cDescDoc := (cTab)->E2_PREFIXO + (cTab)->E2_NUM
	EndIf
	
	//posiciona natureza (SED)
	If cNat <> ''
		If !SED->(dbSeek( xFilial('SED') + cNat ))
			Alert('A natureza ' + cNat + ' não foi encontrada no sistema!' +;
			' O título do ' + cTab + ' com recno ' + cValToChar(nRec) +;
			' não será gerado para o EFD Contribuições.')
			Loop
		EndIf
		
		//posiciona conta contábil custo (CT1)
		If AllTrim(SED->ED_CONTAC) <> ''
			If !CT1->(dbSeek( xFilial('CT1') + SED->ED_CONTAC ))
				Alert('A conta contábil ' + SED->ED_CONTAC + ' não foi encontrada no sistema!' +;
				' O título do ' + cTab + ' com recno ' + cValToChar(nRec) +;
				' não será gerado para o EFD Contribuições.')
				Loop
			EndIf
			
			cCodCta := AllTrim(CT1->CT1_CONTA + xFilial('CT1'))
			cCtaDta := DTOSInv(CT1->CT1_DTEXIS)
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
			' não será gerado para o EFD Contribuições.')
			Loop
		EndIf
		cCodCCus := AllTrim(CTT->CTT_CUSTO + xFilial('CTT'))
		cCCDta   := DTOSInv(CTT->CTT_DTEXIS)
		cCCCod   := AllTrim(CTT->CTT_CUSTO + xFilial('CTT'))
		cCCDesc  := CTT->CTT_DESC01
	EndIf
	
	cIndOper := Iif(cTab=='SE2','0',Iif(cCST$'01;02;03;05','1','2'))
	cDatOper := DTOSInv(Iif(cTab=='SE1',SE1->E1_EMIS1,SE2->E2_EMIS1))
	nAliqPIS := GetMV('MV_TXPIS')
	nVlrPIS  := Round(nVlr*nAliqPIS/100, 2)
	nAliqCOF := GetMV('MV_TXCOFIN')
	nVlrCOF  := Round(nVlr*nAliqCOF/100, 2)
	
	aAdd( aRegF100, {	'F100'				,;		// F100 - 01 - REG
						cIndOper			,;		// F100 - 02 - IND_OPER  ( 0 - Entrada, >0 - Saida )
						cCodPart			,;		// F100 - 03 - COD_PART (Entrada = SA2->A2_COD, Saida = SA1->A1_COD)
						''					,;		// F100 - 04 - COD_ITEM
						cDatOper			,;		// F100 - 05 - DT_OPER
						nVlr				,;		// F100 - 06 - VL_OPER
						cCST				,;		// F100 - 07 - CST_PIS
						nVlr				,;		// F100 - 08 - VL_BC_PIS
						nAliqPIS			,;		// F100 - 09 - ALIQ_PIS
						nVlrPIS				,;		// F100 - 10 - VL_PIS
						cCST				,;		// F100 - 11 - CST_COFINS
						nVlr				,;		// F100 - 12 - VL_BC_COFINS
						nAliqCOF			,;		// F100 - 13 - ALIQ_COFINS
						nVlrCOF				,;		// F100 - 14 - VL_COFINS
						cBCC				,;		// F100 - 15 - NAT_BC_CRED
						'0'					,;		// F100 - 16 - IND_ORIG_CRED
						cCodCta				,;		// F100 - 17 - COD_CTA
						cCodCCus			,;		// F100 - 18 - COD_CCUS
						cDescDoc			,;		// F100 - 19 - DESC_DOC_OPER
						cCodLoja			,;		// F100 - 20 - LOJA (Entrada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
						'1'					,;		// F100 - 21 - INDICE DE CUMULATIVIDADE (0 - Cumulativo, 1 - Nao cumulativo)
						aPart[1]			,;		// 0150 - 02 - COD_PART
						aPart[2]			,;		// 0150 - 03 - NOME
						aPart[3]			,;		// 0150 - 04 - COD_PAIS
						aPart[4]			,;		// 0150 - 05 - CNPJ
						aPart[5]			,;		// 0150 - 06 - CPF
						aPart[6]			,;		// 0150 - 07 - IE
						aPart[7]			,;		// 0150 - 08 - COD_MUN
						aPart[8]			,;		// 0150 - 09 - SUFRAMA
						aPart[9]			,;		// 0150 - 10 - END
						aPart[10]			,;		// 0150 - 11 - NUM
						aPart[11]			,;		// 0150 - 12 - COMPL
						aPart[12]			,;		// 0150 - 13 - BAIRRO
						cCtaDta				,;		// 0500 - 02 - DT_ALT
						cCtaNat				,;		// 0500 - 03 - COD_NAT_CC
						cCtaInd				,;		// 0500 - 04 - IND_CTA
						cCtaNiv				,;		// 0500 - 05 - NIVEL
						cCtaCod				,;		// 0500 - 06 - COD_CTA
						cCtaNom				,;		// 0500 - 07 - NOME_CTA
						cCtaRef				,;		// 0500 - 08 - COD_CTA_REF
						''					,;		// 0500 - 09 - CNPJ_EST
						''					,;		// Codigo da tabela da Natureza da Receita.
						''					,;		// Codigo da Natureza da Receita
						''					,;		// Grupo da Natureza da Receita
						''					,;		// Dt.Fim Natureza da Receita
						cCCDta				,;		// 0600 - 02 - DT_ALT
						cCCCod 				,;		// 0600 - 03 - COD_CCUS
						cCCDesc				;		// 0600 - 04 - CCUS
	})
Next nI

CTT->(RestArea(aAreaCTT))
CVD->(RestArea(aAreaCVD))
CT1->(RestArea(aAreaCT1))
SED->(RestArea(aAreaSED))
SA2->(RestArea(aAreaSA2))
SA1->(RestArea(aAreaSA1))
RestArea(aArea)

Return aClone(aRegF100)

/* ------------------- */

Static Function DTOSInv(dData)

Local cRet := DTOS(dData)

cRet := SubStr(cRet, 7) + SubStr(cRet, 5, 2) + SubStr(cRet, 1, 4)

Return cRet
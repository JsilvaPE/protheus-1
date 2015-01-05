#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyRDvCom()
///////////////////////////////////////////////////////////////////////////////
// Data : 25/04/2014
// User : Thieres Tembra
// Desc : Emite o relatório de devolução de compras para uso do PIS/COFINS
// Ação : A rotina emite o relatório de notas fiscais de saída emitidas para
//        devolução de compras, considerando ambos os casos previstos na lei:
//        dentro do período e fora do período. O relatório realiza o filtro
//        por CFOP e por CST, e obtém os dados a partir da tabela SFT.
//        No final o resultado é exportado para o excel.
//
// OBS  : Utiliza a função U_MyRDvCom para gerar a query.
///////////////////////////////////////////////////////////////////////////////

Local cTitulo := 'Relatório de Devolução de Compras'
Local cPerg := '#MYRDVCOM'
Local aArea := GetArea()
Local aAreaSM0 := SM0->(GetArea())
Local cCFPad  := AllTrim(GetMV('MY_CFDEVPC'))

CriaSX1(cPerg,cCFPad)

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

Processa({|| Executa(cTitulo,cCFPad) },cTitulo,'Realizando consulta...')

SM0->(RestArea(aAreaSM0))
RestArea(aArea)

Return Nil

/* -------------- */

Static Function Executa(cTitulo,cCFPad)

Local cQry
Local cRet, cAux, cFAnt, cNFAnt, cPeriodo
Local cArq := 'MYRDVCOM'
Local aExcel := {}
Local nCnt, nPos, nCnt2
Local nSoma, nSomaF, nSomaE
Local aAux
Local nPerPis, nPerCof, nBasePis, nBaseCof, nValPis, nValCof

ProcRegua(0)

cQry := U_MyQDvCom(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,cCFPad,MV_PAR07)

cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSFT',.T.)

nCnt := 0
SSFT->(dbEval({||nCnt++}))
SSFT->(dbGoTop())

ProcRegua(nCnt)
aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' às '+Time()+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Período: '+DTOC(MV_PAR01)+' até '+DTOC(MV_PAR02)+' - Filial: '+MV_PAR03+' até '+MV_PAR04})
If AllTrim(MV_PAR05) <> ''
	aAdd(aExcel, {'Somente CFOPs: '+AllTrim(MV_PAR05)})
Else
	aAdd(aExcel, {'CFOPs Padrão: '+AllTrim(cCFPad)})
EndIf
If AllTrim(MV_PAR07) <> ''
	aAdd(aExcel, {'Somente CSTs Entrada: '+AllTrim(MV_PAR07)})
EndIf

cFAnt  := ''
cNFAnt := ''
nSoma  := 0
nSomaF := 0
nSomaE := 0

While !SSFT->(Eof())
	If cFAnt <> SSFT->SFTS_FILIAL 
		//se mudou a filial e não está no início, imprime apuração e soma por CST
		If cFAnt <> '' .and. nSomaF <> 0
			Soma(@aExcel, 'Filial', nSomaF)
			nSomaE += nSomaF
			nSomaF := 0
		EndIf
		
		//inicia nova empresa
		aAdd(aExcel, {''})
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cEmpAnt+SSFT->SFTS_FILIAL))
		
		cAux := 'Empresa: '+cEmpAnt+'/'+SSFT->SFTS_FILIAL+'-'+AllTrim(SM0->M0_NOME)+' / '+AllTrim(SM0->M0_FILIAL)
		IncProc(cAux)
		
		cAux += ' - CNPJ: '+Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')
		aAdd(aExcel, {cAux})
		
		aAdd(aExcel, {;
			'Dados da NF de Devolução (SFT)','','','','','','','','','','','','','Dados da NF Original (SFT)','','',;
			'Dados da NF de Entrada (SFT)';
		})
		aAdd(aExcel, {;
			'Número','Série','Entrada','Período','Produto','NCM'        ,'Tab.Nat.Rec','Cód.Nat.Rec','Qtd'           ,'CFOP'          ,'CST'         ,'Valor Contábil','Valor do Item','Número','Série','Item',;
			'Número','Série','Item'   ,'Entrada','Produto','Qtd'        ,'CFOP'       ,'CST'        ,'Valor Contábil','Base PIS Devolvido','Base COFINS Devolvido','Valor PIS Devolvido','Valor COFINS Devolvido',;
			'Monof/AliqZero';
		})
	Else
		IncProc()
	EndIf
	
	If cNFAnt <> SSFT->SFTS_SERIE + '-' + SSFT->SFTS_DOC
		If cNFAnt <> ''
			If nSoma == 0
				nPos := Len(aExcel)
				While nPos > 0
					If Len(aExcel[nPos]) == 1
						If aExcel[nPos][1] == ''
							aDel(aExcel, nPos)
							Exit
						EndIf
					EndIf
					nPos--
				EndDo
			Else
				Soma(@aExcel, 'NF', nSoma)
				aAdd(aExcel, {''})
				nSoma := 0
			EndIf
		EndIf
		aAdd(aExcel, {''})
	EndIf
	
	
	cAux := 'Não'
	If AllTrim(SSFT->ZPI_NCM) <> ''
		cAux := 'Sim'
	EndIf
	
	cPeriodo := ''
	If Left(SSFT->SFTS_ENTRADA, 6) == Left(SSFT->SFTE_ENTRADA, 6)
		cPeriodo := 'DENTRO'
	Else
		cPeriodo := 'FORA'
	EndIf
	
	If ((MV_PAR06 == 1 .or. MV_PAR06 == 3) .and. cPeriodo == 'DENTRO') .or.;
	((MV_PAR06 == 2 .or. MV_PAR06 == 3) .and. cPeriodo == 'FORA')
		nPerPis := 0
		nPerCof := 0
		
		If SSFT->SFTS_BPIS > 0 .and. SSFT->SFTS_BPIS <= SSFT->SFTE_BPIS
			nPerPis := SSFT->SFTS_BPIS / SSFT->SFTE_BPIS
		Else
			nPerPis := ((SSFT->SFTS_QTD * 100) / SSFT->SFTE_QTD ) / 100
		EndIf
		
		If SSFT->SFTS_BCOF > 0 .and. SSFT->SFTS_BCOF <= SSFT->SFTE_BCOF
			nPerCof := SSFT->SFTS_BCOF / SSFT->SFTE_BCOF
		Else
			nPerCof := ((SSFT->SFTS_QTD * 100) / SSFT->SFTE_QTD ) / 100
		EndIf
		
		If SSFT->SFTS_QTD == SSFT->SFTE_QTD
			nBasePis := SSFT->SFTE_BPIS
			nBaseCof := SSFT->SFTE_BCOF
			nValPis := SSFT->SFTE_VPIS
			nValCof := SSFT->SFTE_VCOF
		Else
			nBasePis := Round(SSFT->SFTE_BPIS * nPerPis,2)
			nBaseCof := Round(SSFT->SFTE_BCOF * nPerCof,2)
			nValPis := Round(SSFT->SFTE_VPIS * nPerPis,2)
			nValCof := Round(SSFT->SFTE_VCOF * nPerCof,2)
		EndIf
		
		aAdd(aExcel, {;
			SSFT->SFTS_DOC, SSFT->SFTS_SERIE, CTOD(U_MyDataBR(SSFT->SFTS_ENTRADA)), cPeriodo                            , SSFT->SFTS_PRODUTO, SSFT->SFTS_POSIPI , SSFT->SFTS_TNATREC, SSFT->SFTS_CNATREC, SSFT->SFTS_QTD    , SSFT->SFTS_CFOP, SSFT->SFTS_CSTPIS, SSFT->SFTS_VALCONT, SSFT->SFTS_TOTAL, SSFT->SFTS_NFORI, SSFT->SFTS_SERORI, SSFT->SFTS_ITEMORI,;
			SSFT->SFTE_DOC, SSFT->SFTE_SERIE, SSFT->SFTE_ITEM                     , CTOD(U_MyDataBR(SSFT->SFTE_ENTRADA)), SSFT->SFTE_PRODUTO, SSFT->SFTE_QTD    , SSFT->SFTE_CFOP   , SSFT->SFTE_CSTPIS , SSFT->SFTE_VALCONT, nBasePis       , nBaseCof         , nValPis           , nValCof         ,;
			cAux;
		})
		
		//somente soma se não for monofásico ou alíquota zero
		If cAux == 'Não'
			nSoma  += SSFT->SFTS_VALCONT
			nSomaF += SSFT->SFTS_VALCONT
		EndIf
	EndIf
	
	cNFAnt := SSFT->SFTS_SERIE + '-' + SSFT->SFTS_DOC
	cFAnt  := SSFT->SFTS_FILIAL
	SSFT->(dbSkip())
EndDo

SSFT->(dbCloseArea())

If nCnt > 0
	//nota final
	If nSoma <> 0
		Soma(@aExcel, 'NF', nSoma)
		nSoma := 0
	EndIf
	aAdd(aExcel, {''})
	//filial final
	If nSomaF <> 0
		Soma(@aExcel, 'Filial', nSomaF)
		nSomaE += nSomaF
		nSomaF := 0
	EndIf
EndIf

aAdd(aExcel, {''})
Soma(@aExcel, 'Empresa', nSomaE)

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

Static Function Soma(aExcel, cTipo, nSoma)

aAdd(aExcel, {'','','','','','','Soma ' + cTipo + ' Monof/AliqZero = Não','','','','',nSoma})

Return Nil

/* -------------- */

Static Function CriaSX1(cPerg,cCFPad)

Local nTamGrp := Len(SX1->X1_GRUPO)
Local aHelpPor := {}, aHelpEng := {}, aHelpSpa := {}
Local cNome

aHelpPor := {}
aAdd(aHelpPor, 'Informe a data inicial/final para    ')
aAdd(aHelpPor, 'geração do relatório. Nesta data deve')
aAdd(aHelpPor, 'ser informado a data de emissão da   ')
aAdd(aHelpPor, 'nota de devolução.                   ')
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

aHelpPor := {}
aAdd(aHelpPor, 'Informe os CFOPs separados por ponto ')
aAdd(aHelpPor, 'e vígula (;) a serem listados no     ')
aAdd(aHelpPor, 'relatório. Caso você deixe em branco ')
aAdd(aHelpPor, 'serão considerados os seguintes:     ')
aAdd(aHelpPor, PadR(cCFPad,37))
cNome := 'CFOPs'
PutSx1(PadR(cPerg,nTamGrp), '05', cNome, cNome, cNome,;
'MV_CH5', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR05',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe os tipos de devoluções a     ')
aAdd(aHelpPor, 'serem listados:                      ')
aAdd(aHelpPor, '1-Dentro do período                  ')
aAdd(aHelpPor, '2-Fora do período                    ')
aAdd(aHelpPor, '3-Ambos                              ')
cNome := 'Período'
PutSx1(PadR(cPerg,nTamGrp), '06', cNome, cNome, cNome,;
'MV_CH6', 'N', 1, 0, 3, 'C', '', '', '', '', 'MV_PAR06',;
'Dentro', 'Dentro', 'Dentro', '',;
'Fora', 'Fora', 'Fora',;
'Ambos', 'Ambos', 'Ambos',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe os CSTs separados por ponto ')
aAdd(aHelpPor, 'e vígula (;) para listar somente    ')
aAdd(aHelpPor, 'devoluções onde a nota de entrada   ')
aAdd(aHelpPor, 'possua estes CSTs.                  ')
cNome := 'CSTs Entrada'
PutSx1(PadR(cPerg,nTamGrp), '07', cNome, cNome, cNome,;
'MV_CH7', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR07',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
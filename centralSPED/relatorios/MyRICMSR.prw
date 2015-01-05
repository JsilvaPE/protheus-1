#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyRICMSR()
///////////////////////////////////////////////////////////////////////////////
// Data : 26/12/2014
// User : Thieres Tembra
// Desc : Emite o relatório de notas que possuem ICMS Retido
// Ação : A rotina emite o relatório de notas fiscais de entrada ou saída que
//        possuem ICMS Retido e por isso tem este valor descontado da base de
//        cálculo do PIS/COFINS diminuindo assim o crédito/contribuição.
///////////////////////////////////////////////////////////////////////////////

Local cTitulo := 'Relatório de NF com ICMS Retido'
Local cPerg := '#MYRICMSR'
Local aArea := GetArea()
Local aAreaSM0 := SM0->(GetArea())

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

SM0->(RestArea(aAreaSM0))
RestArea(aArea)

Return Nil

/* -------------- */

Static Function Executa(cTitulo)

Local cQry
Local cRet, cAux, cFAnt, cNFAnt
Local cArq := 'MYRICMSR'
Local aExcel := {}
Local nCnt
Local nSoma, nSomaF
Local nValCont, nBasePis, nBaseCof, nValPis, nValCof, nICMSRet
Local cCFOPs, cCSTs
Local aLivro := {'Entrada','Saída','Ambos'}
Local aAux

ProcRegua(0)

cQry := ""
cQry += CRLF + " SELECT"
cQry += CRLF + "    FT_FILIAL"
cQry += CRLF + "   ,FT_ENTRADA"
cQry += CRLF + "   ,FT_EMISSAO"
cQry += CRLF + "   ,FT_ESPECIE"
cQry += CRLF + "   ,FT_TIPO"
cQry += CRLF + "   ,FT_NFISCAL"
cQry += CRLF + "   ,FT_SERIE"
cQry += CRLF + "   ,FT_CLIEFOR"
cQry += CRLF + "   ,FT_LOJA"
cQry += CRLF + "   ,FT_TIPOMOV"
cQry += CRLF + "   ,FT_VALCONT"
cQry += CRLF + "   ,FT_BASEPIS"
cQry += CRLF + "   ,FT_BASECOF"
cQry += CRLF + "   ,FT_VALPIS"
cQry += CRLF + "   ,FT_VALCOF"
cQry += CRLF + "   ,FT_ICMSRET"
cQry += CRLF + "   ,FT_CFOP"
cQry += CRLF + "   ,FT_CSTPIS"
cQry += CRLF + " FROM " + RetSqlName('SFT')
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "   AND FT_FILIAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
cQry += CRLF + "   AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
cQry += CRLF + "   AND FT_ICMSRET > 0"
cQry += CRLF + "   AND LEN(FT_DTCANC) = 0 "
cQry += CRLF + "   AND FT_OBSERV NOT LIKE '%INUTIL%'"
cQry += CRLF + "   AND FT_OBSERV NOT LIKE '%CANCEL%'"
If AllTrim(MV_PAR06) <> ''
	cQry += CRLF + "   AND FT_CFOP IN " + U_MyGeraIn(AllTrim(MV_PAR06))
EndIf
If AllTrim(MV_PAR07) <> ''
	cQry += CRLF + "   AND FT_CSTPIS IN " + U_MyGeraIn(AllTrim(MV_PAR07))
EndIf
If MV_PAR05 == 1
	cQry += CRLF + "   AND FT_TIPOMOV = 'E'"
EndIf
If MV_PAR05 == 2
	cQry += CRLF + "   AND FT_TIPOMOV = 'S'"
EndIf
cQry += CRLF + " ORDER BY"
cQry += CRLF + "    FT_FILIAL"
cQry += CRLF + "   ,FT_TIPOMOV"
cQry += CRLF + "   ,FT_ENTRADA"
cQry += CRLF + "   ,FT_EMISSAO"
cQry += CRLF + "   ,FT_NFISCAL"
cQry += CRLF + "   ,FT_SERIE"
cQry += CRLF + "   ,FT_CLIEFOR"
cQry += CRLF + "   ,FT_LOJA"
cQry += CRLF + "   ,FT_CFOP"
cQry += CRLF + "   ,FT_CSTPIS"

cQry := ChangeQuery(cQry)
dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY',.T.)

nCnt := 0
MQRY->(dbEval({||nCnt++}))
MQRY->(dbGoTop())

ProcRegua(nCnt)
aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' às '+Time()+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Período: '+DTOC(MV_PAR01)+' até '+DTOC(MV_PAR02)+' - Filial: '+MV_PAR03+' até '+MV_PAR04})
aAdd(aExcel, {'Livro: '+aLivro[MV_PAR05]})
If AllTrim(MV_PAR06) <> ''
	aAdd(aExcel, {'Somente CFOPs: '+AllTrim(MV_PAR06)})
EndIf
If AllTrim(MV_PAR07) <> ''
	aAdd(aExcel, {'Somente CSTs: '+AllTrim(MV_PAR07)})
EndIf
aAdd(aExcel, {'Alíquota PIS: '+Transform(MV_PAR08, '@E 9.99')})
aAdd(aExcel, {'Alíquota COFINS: '+Transform(MV_PAR09, '@E 9.99')})

cFAnt    := ''
cNFAnt   := ''
aAux     := {}
nSoma    := 0
nSomaF   := 0
nValCont := 0
nBasePis := 0
nBaseCof := 0
nValPis  := 0
nValCof  := 0
nICMSRet := 0
cCFOPs   := ''
cCSTs    := ''

While !MQRY->(Eof())
	If cNFAnt <> MQRY->(FT_FILIAL + FT_TIPOMOV + FT_ENTRADA + FT_ESPECIE + FT_TIPO + FT_NFISCAL + FT_SERIE + FT_CLIEFOR + FT_LOJA) .and. cNFAnt <> ''
		//verifica se a nota mudou, se sim imprime
		Nota(@aExcel, @aAux, @nValCont, @nBasePis, @nBaseCof, @nValPis, @nValCof, @nICMSRet, @cCFOPs, @cCSTs, @nSomaF, @nSoma)
	EndIf
	
	If cFAnt <> MQRY->FT_FILIAL
		//se mudou a filial e não está no início, imprime apuração e soma por CST
		If cFAnt <> '' .and. nSomaF > 0
			SomaF(@aExcel, @nSomaF)
		EndIf
		
		//inicia nova empresa
		aAdd(aExcel, {''})
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cEmpAnt+MQRY->FT_FILIAL))
		
		cAux := 'Empresa: '+cEmpAnt+'/'+MQRY->FT_FILIAL+'-'+AllTrim(SM0->M0_NOME)+' / '+AllTrim(SM0->M0_FILIAL)
		IncProc(cAux)
		
		cAux += ' - CNPJ: '+Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')
		aAdd(aExcel, {cAux})

		aAdd(aExcel, {;
			'Livro','Entrada','Emissão','Espécie','Tipo','Número','Série','Cliente/Fornecedor','Loja',;
			'Valor Contábil','Base PIS','Base COFINS','Valor PIS','Valor COFINS','ICMS Retido','CFOPs','CSTs PIS/COFINS';
		})
	Else
		IncProc()
	EndIf
	
	If Len(aAux) == 0
		//salvando dados da nota no vetor auxiliar
		aAdd(aAux, Iif(MQRY->FT_TIPOMOV=='E','Entrada','Saída'))
		aAdd(aAux, DTOC(STOD(MQRY->FT_ENTRADA)))
		aAdd(aAux, DTOC(STOD(MQRY->FT_EMISSAO)))
		aAdd(aAux, MQRY->FT_ESPECIE)
		aAdd(aAux, MQRY->FT_TIPO)
		aAdd(aAux, MQRY->FT_NFISCAL)
		aAdd(aAux, MQRY->FT_SERIE)
		aAdd(aAux, MQRY->FT_CLIEFOR)
		aAdd(aAux, MQRY->FT_LOJA)
	EndIf
	
	//somando valores
	nValCont += MQRY->FT_VALCONT
	nBasePis += MQRY->FT_BASEPIS
	nBaseCof += MQRY->FT_BASECOF
	nValPis  += MQRY->FT_VALPIS
	nValCof  += MQRY->FT_VALCOF
	nICMSRet += MQRY->FT_ICMSRET
	If !(MQRY->FT_CFOP $ cCFOPs)
		cCFOPs += MQRY->FT_CFOP + ', '
	EndIf
	If !(MQRY->FT_CSTPIS $ cCSTs)
		cCSTs += MQRY->FT_CSTPIS + ', '
	EndIf
	
	//pegando dados da última nota processada
	cFAnt  := MQRY->FT_FILIAL
	cNFAnt := MQRY->(FT_FILIAL + FT_TIPOMOV + FT_ENTRADA + FT_ESPECIE + FT_TIPO + FT_NFISCAL + FT_SERIE + FT_CLIEFOR + FT_LOJA)
	MQRY->(dbSkip())
EndDo

MQRY->(dbCloseArea())

If Len(aAux) > 0
	Nota(@aExcel, @aAux, @nValCont, @nBasePis, @nBaseCof, @nValPis, @nValCof, @nICMSRet, @cCFOPs, @cCSTs, @nSomaF, @nSoma)
EndIf

If nSomaF > 0
	SomaF(@aExcel, @nSomaF)
EndIf

If nSoma > 0
	aAdd(aExcel, {''})
	aAdd(aExcel, {'Total da Empresa: ' + cEmpAnt + '-' + AllTrim(SM0->M0_NOME)})
	aAdd(aExcel, {'','Total ICMS Retido','','','',nSoma})
	aAdd(aExcel, {'','Valor PIS s/ ICMS Retido','','','',Round(nSoma * MV_PAR08 / 100,2)})
	aAdd(aExcel, {'','Valor COFINS s/ ICMS Retido','','','',Round(nSoma * MV_PAR09 / 100,2)})
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

/* -------------- */

Static Function SomaF(aExcel, nSomaF)

aAdd(aExcel, {'','','','','','','','','','','','Total ICMS Retido','','',nSomaF})
aAdd(aExcel, {'','','','','','','','','','','','Valor PIS s/ ICMS Retido','','',Round(nSomaF * MV_PAR08 / 100,2)})
aAdd(aExcel, {'','','','','','','','','','','','Valor COFINS s/ ICMS Retido','','',Round(nSomaF * MV_PAR09 / 100,2)})
nSomaF := 0
			
Return Nil

/* -------------- */

Static Function Nota(aExcel, aAux, nValCont, nBasePis, nBaseCof, nValPis, nValCof, nICMSRet, cCFOPs, cCSTs, nSomaF, nSoma)

aAdd(aAux, nValCont)
aAdd(aAux, nBasePis)
aAdd(aAux, nBaseCof)
aAdd(aAux, nValPis)
aAdd(aAux, nValCof)
aAdd(aAux, nICMSRet)
aAdd(aAux, Left(cCFOPs, Len(cCFOPs)-2))
aAdd(aAux, Left(cCSTs, Len(cCSTs)-2))

aAdd(aExcel, aClone(aAux))
aAux := {}

nSomaF += nICMSRet
nSoma  += nICMSRet

nValCont := 0
nBasePis := 0
nBaseCof := 0
nValPis  := 0
nValCof  := 0
nICMSRet := 0
cCFOPs   := ''
cCSTs    := ''

Return Nil

/* -------------- */

Static Function CriaSX1(cPerg)

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
aAdd(aHelpPor, 'Informe de qual livro as notas devem ')
aAdd(aHelpPor, 'ser listadas:                        ')
aAdd(aHelpPor, '1-Entrada                            ')
aAdd(aHelpPor, '2-Saída                              ')
aAdd(aHelpPor, '3-Ambos                              ')
cNome := 'Livro'
PutSx1(PadR(cPerg,nTamGrp), '05', cNome, cNome, cNome,;
'MV_CH5', 'N', 1, 0, 3, 'C', '', '', '', '', 'MV_PAR05',;
'Entrada', 'Entrada', 'Entrada', '',;
'Saída', 'Saída', 'Saída',;
'Ambos', 'Ambos', 'Ambos',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe os CFOPs separados por ponto')
aAdd(aHelpPor, 'e vígula (;) para listar somente    ')
aAdd(aHelpPor, 'as notas que possuam estes CFOPs.   ')
cNome := 'CFOPs'
PutSx1(PadR(cPerg,nTamGrp), '06', cNome, cNome, cNome,;
'MV_CH6', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR06',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe os CSTs separados por ponto ')
aAdd(aHelpPor, 'e vígula (;) para listar somente    ')
aAdd(aHelpPor, 'as notas que possuam estes CSTs.    ')
cNome := 'CSTs'
PutSx1(PadR(cPerg,nTamGrp), '07', cNome, cNome, cNome,;
'MV_CH7', 'C', 99, 0, 0, 'G', '', '', '', '', 'MV_PAR07',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe a alíquota do PIS para o     ')
aAdd(aHelpPor, 'cálculo do valor estimado.           ')
cNome := 'Aliq. PIS'
PutSx1(PadR(cPerg,nTamGrp), '08', cNome, cNome, cNome,;
'MV_CH8', 'N', 4, 2, 0, 'G', '', '', '', '', 'MV_PAR08',;
'', '', '', '1.65',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe a alíquota do COFINS para o  ')
aAdd(aHelpPor, 'cálculo do valor estimado.           ')
cNome := 'Aliq. COFINS'
PutSx1(PadR(cPerg,nTamGrp), '09', cNome, cNome, cNome,;
'MV_CH9', 'N', 4, 2, 0, 'G', '', '', '', '', 'MV_PAR09',;
'', '', '', '7.60',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
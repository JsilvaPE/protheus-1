#include 'protheus.ch'
#include 'rwmake.ch'
///////////////////////////////////////////////////////////////////////////////
User Function MyVerApu()
///////////////////////////////////////////////////////////////////////////////
// Data : 08/05/2014
// User : Thieres Tembra
// Desc : Rotina para verificar a existência 
///////////////////////////////////////////////////////////////////////////////
Local cTitulo := 'Verificando Apurações'
Local cPerg := '#MyVerApu'
Local nDoMes
Local nAteMes

CriaSX1(cPerg)

If !Pergunte(cPerg, .T., cTitulo)
	Return Nil
Endif

If MV_PAR01 == Nil .or. Len(AllTrim(MV_PAR01)) == 0 .or. MV_PAR02 == Nil .or. Len(AllTrim(MV_PAR02)) == 0
	Alert('Informe os períodos a serem verificados.')
	Return Nil
ElseIf MV_PAR01 > MV_PAR02
	Alert('O campo "Até Ano/Mês" deve ser maior que o campo "Do Ano/Mês".')
	Return Nil
Else
	nDoMes  := Val(Right(MV_PAR01,2))
	nAteMes := Val(Right(MV_PAR02,2))
	If !(nDoMes >= 1 .and. nDoMes <= 12)
		Alert('Informe um mês válido no campo "Do Ano/Mês".')
		Return Nil
	ElseIf !(nAteMes >= 1 .and. nAteMes <= 12)
		Alert('Informe um mês válido no campo "Até Ano/Mês".')
		Return Nil
	EndIf
EndIf

Processa({||Executa(cTitulo)}, cTitulo, 'Aguarde..')

Return Nil

/* ------------ */

Static Function Executa(cTitulo)

Local lUsaSped  := SuperGetMv('MV_USASPED',,.T.) .And. AliasIndic('CDH') .And. AliasIndic('CDA') .And. AliasIndic('CC6') .And. AliasIndic('CDO')
Local cAux
Local cArq := 'myverapu'
Local aMesAno := {}
Local aExcel := {}
Local nDoMes, nAteMes
Local nDoAno, nAteAno
Local lExiste
Local nQtd
Local aApur := {'Decendial','Quinzenal','Mensal','Semestral','Anual'}
Local aPeri := {'1o.', '2o.', '3o.', '1 e 2 periodo'}

aAdd(aExcel, {cTitulo})
aAdd(aExcel, {'Relatório emitido em '+DTOC(Date())+' às '+Time()+' por '+AllTrim(cUsername)})
aAdd(aExcel, {'Do Ano/Mês: ' + MV_PAR01 + ' - Até Ano/Mês: ' + MV_PAR02})
aAdd(aExcel, {'Número do Livro: ' + MV_PAR03})
aAdd(aExcel, {'Apuração: ' + aApur[MV_PAR04]})
aAdd(aExcel, {'Período: ' + aPeri[MV_PAR05]})

nDoMes  := Val(Right(MV_PAR01,2))
nAteMes := Val(Right(MV_PAR02,2))
nDoAno  := Val(Left(MV_PAR01,4))
nAteAno := Val(Left(MV_PAR02,4))

nQtd := ((nAteAno - nDoAno - 1) * 12) + (13 - nDoMes) + nAteMes

Alert(nQtd)

ProcRegua(nQtd)

//aumenta um mês no final para utilizar no loop abaixo
//e assim percorre todos os meses
If nAteMes == 12
	nAteMes := 1
	nAteAno++
Else
	nAteMes++
EndIf

aAdd(aExcel, {''})
aAdd(aExcel, {'Mês/Ano','Apuração de ICMS'})
While (StrZero(nDoAno, 4) + StrZero(nDoMes, 2)) <> (StrZero(nAteAno, 4) + StrZero(nAteMes, 2))
	cAux := StrZero(nDoMes,2) + '/' + StrZero(nDoAno,4)
	IncProc('Verificando ' + cAux + '..')
	
	lExiste := ExistApur(nDoMes,nDoAno,lUsaSped)
	
	aAdd(aExcel, {;
		cAux,;
		Iif(lExiste,'Existe!','Não Existe!');
	})
	
	nDoMes++
	If nDoMes == 13
		nDoAno++
		nDoMes := 1
	EndIf
EndDo

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

/* ------------ */

Static Function ExistApur(nMes,nAno,lUsaSped)

Local lRet      := .F.
Local cImp      := 'IC'
Local cNrLivro  := MV_PAR03
Local nApuracao := MV_PAR04
Local nPeriodo  := MV_PAR05
Local aDatas
Local dDtIni
Local cChave
Local cArqApur

If lUsaSped
	aDatas := DetDatas(nMes,nAno,nApuracao,nPeriodo)
	dDtIni := aDatas[1]
	cChave := Str(nApuracao,1) + Str(nPeriodo,1) + DTOS(dDtIni) + cNrLivro
	CDH->(dbSetOrder(1))
	If CDH->(dbSeek(xFilial('CDH') + cImp + cChave))
		lRet := .T.
	EndIf
Else
	cArqApur := NmArqApur(cImp,nAno,nMes,nApuracao,nPeriodo,cNrLivro)
	If File(cArqApur)
		lRet := .T.
	EndIf
EndIf

Return lRet

/* ------------ */

Static Function CriaSX1(cPerg)

Local nTamGrp := Len(SX1->X1_GRUPO)
Local aHelpPor := {}, aHelpEng := {}, aHelpSpa := {}
Local cNome

aHelpPor := {}
aAdd(aHelpPor, 'Informe o mês/ano inicial para       ')
aAdd(aHelpPor, 'verificação da apuração.             ')
aAdd(aHelpPor, 'Formato: AAAAMM                      ')
aAdd(aHelpPor, 'Exemplo: 201201                      ')
cNome := 'Do Ano/Mês (Ex: 201205)'
PutSx1(PadR(cPerg,nTamGrp), '01', cNome, cNome, cNome,;
'MV_CH1', 'C', 6, 0, 0, 'G', '', '', '', '', 'MV_PAR01',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe o mês/ano final para         ')
aAdd(aHelpPor, 'verificação da apuração.             ')
aAdd(aHelpPor, 'Formato: AAAAMM                      ')
aAdd(aHelpPor, 'Exemplo: 201301                      ')
cNome := 'Até Ano/Mês (Ex: 201301)'
PutSx1(PadR(cPerg,nTamGrp), '02', cNome, cNome, cNome,;
'MV_CH2', 'C', 6, 0, 0, 'G', '', '', '', '', 'MV_PAR02',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe o número do livro a ser      ')
aAdd(aHelpPor, 'verificado a apuração.               ')
cNome := 'Livro Selecionado'
PutSx1(PadR(cPerg,nTamGrp), '03', cNome, cNome, cNome,;
'MV_CH3', 'C', 1, 0, 0, 'G', '', '', '', '', 'MV_PAR03',;
'', '', '', '*',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Escolha o tipo do período da apuração')
aAdd(aHelpPor, 'a ser verificada.                    ')
cNome := 'Apuração'
PutSx1(PadR(cPerg,nTamGrp), '04', cNome, cNome, cNome,;
'MV_CH4', 'N', 1, 0, 3, 'C', '', '', '', '', 'MV_PAR04',;
'Decendial', 'Decendial', 'Decendial', '',;
'Quinzenal', 'Quinzenal', 'Quinzenal',;
'Mensal', 'Mensal', 'Mensal',;
'Semestral', 'Semestral', 'Semestral',;
'Anual', 'Anual', 'Anual',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Escolha o período da apuração a ser  ')
aAdd(aHelpPor, 'verificada.                          ')
cNome := 'Período'
PutSx1(PadR(cPerg,nTamGrp), '05', cNome, cNome, cNome,;
'MV_CH5', 'N', 1, 0, 1, 'C', '', '', '', '', 'MV_PAR05',;
'1o.', '1o.', '1o.', '',;
'2o.', '2o.', '2o.',;
'3o.', '3o.', '3o.',;
'1 e 2 periodo', '1 e 2 periodo', '1 e 2 periodo',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
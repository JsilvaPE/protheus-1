#include 'rwmake.ch'
#include 'protheus.ch'
#define CRLF chr(13) + chr(10)
#define MyVal(cTxt) Val(StrTran(cTxt, ',', '.'))
#define MyStrVal(nVal, nInt, nDec) StrTran(Transform(nVal, '@E '+Replicate('9',nInt)+'.'+Replicate('9',nDec)), ' ', '')
///////////////////////////////////////////////////////////////////////////////
User Function MyPCOk()
///////////////////////////////////////////////////////////////////////////////
// Data : 21/11/2013
// User : Thieres Tembra
// Desc : Função para tratar o arquivo gerado pela rotina SPEDPISCOF
// Ação : Corrige os seguintes registros:
//        C170, C191 e C195:
//            Se existir base de cálculo de PIS/COFINS, iguala o valor do item
//            a base de cálculo, pois o sistema está somando desconto,
//            diminuindo ICMS outras e diminuindo IPI
//            OBS: A mudança no registro C170 levou a modificar o registro C100.
//        C491 e C495:
//            O gerado pelo sistema é totalmente desprezado devido a não estar
//            levando todos os registros presentes no SFT. Dessa forma é feito
//            uma query no banco de dados para buscar os registros diretamente
//            da tabela e informá-los no arquivo.
//            OBS: A mudança nestes registros levou a adicionar linhas nos
//                 registros 0190 (unidades de medidas), 0200 (produtos) e a
//                 modificar vários totalizadores.
//            OBS: Chamado aberto na TOTVS sob o código TIAMMH
///////////////////////////////////////////////////////////////////////////////
// Alterações:
// 1) Thieres Tembra - 07/02/2014
//    Desabilitado correção nos registros C100, C170, C191 e C195, pois os
//    mesmos não são mais levados para o PVA.
///////////////////////////////////////////////////////////////////////////////

Local lOpen := .F.
_cDebug := ''
//verificar se o usuário quer gerar novo arquivo, ou deseja
//somente ajustar um arquivo gerado anteriormente
If MsgYesNo('Gerar arquivo SPED PIS/COFINS novo?')
	//programa padrão
	SPEDPISCOF()
Else
	lOpen := .T.
EndIf
//inicializa ajuste
Processa({||Executa(lOpen)},'SPED PIS/COFINS','Lendo arquivo..')

Return Nil

/* ------------------- */

Static Function Executa(lOpen)

Local aLinha
Local cLinha
Local nI, nTamI, nJ, nTamJ, nK, nTamK
Local nHdl
Local nQtd
Local cFile
Local cFileOk
Local aParam
Local cPan
Local lGrava
Local cReg
Local aNew := {}
Local aProd := {}
Local aUM := {}
Local aNewProd := {}
Local aNewUM := {}
Local cVar
Local uVar
Local cFilAtu
Private _nCX := 0
Private _n0X := 0
Private _nC491 := 0
Private _nC495 := 0
Private _n0190 := 0
Private _n0200 := 0
Private _cUltPIS := ''
Private _aECFPIS := {}
Private _cUltCOF := ''
Private _aECFCOF := {}
Private _cDataI
Private _cDataF

//flag de controle que verifica se usuário gerou arquivo novo
If !lOpen
	//lê arquivo de configuração do Wizard
	aParam := U_MyLeArq('\SYSTEM\SPEDPISCOF.CFP')
	
	//converte conteúdo para variáveis privadas no formato PXXXYYYZZZ onde:
	//  XXX - Representa o número do painel
	//  YYY - Representa a sequencia do campo do painel
	//  ZZZ - O tamanho do campo do painel
	//gerando um formato único para leitura.
	nTamI := Len(aParam)
	For nI := 1 to nTamI
		If SubStr(aParam[nI],2,6) == 'PAINEL'
			cPan := 'P' + SubStr(aParam[nI],8,3)
		Else
			cDef := cPan + SubStr(aParam[nI],5,3) + SubStr(aParam[nI],9,3)
			&(cDef) := SubStr(aParam[nI],13,1024)
		EndIf
	Next nI
	//pega nome do último arquivo gerado
	cFile := AllTrim(P001004050)+AllTrim(P001005020)
	//pega último período gerado
	_cDataI := AllTrim(P001001008)
	_cDataF := AllTrim(P001002008)
Else
	//se usuário estiver somente ajustando, exibe dialog para escolher arquivo
	cFile := AllTrim(cGetFile('TXT (*.txt)|*.txt', 'Escolha o arquivo SPED PIS/COFINS', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NETWORKDRIVE ), .F., .T.))
EndIf

//aponta o arquivo para o servidor
//cFile := '\!SPEDs\' + SubStr(cFile, 4)

//define nome do novo arquivo *_ok.txt
cFileOk := StrTran(cFile, '.txt', '') + '_ok.txt'

//carrega arquivo gerado para o vetor
aTxt := U_MyLeArq(cFile)
nTamI := Len(aTxt)
If nTamI == 0
	Alert('Impossível ler o arquivo origem.')
	Return Nil
EndIf

ProcRegua((nTamI*3)+3)

//cria novo arquivo
nHdl := fCreate(cFileOk)
If nHdl == -1
	Alert('Erro ao criar arquivo final: ' + cValToChar(fError()))
	Return Nil
EndIf

//inicia leitura do arquivo original
IncProc('Analisando arquivo..')
For nI := 1 to nTamI
	lGrava := .T.
	cLinha := aTxt[nI]
	//cria um vetor para cada linha, removendo a primeira e última posição devido ao layout do SPED
	aLinha := MySepara(cLinha)
	cReg := aLinha[01]
	
	If lOpen
		If cReg == '0000'
			//0000 - ABERTURA DO ARQUIVO DIGITAL E IDENTIFICAÇÃO DA PESSOA JURÍDICA
			//pega informações do arquivo escolhido na dialog
			_cDataI := SubStr(aLinha[06], 5)+SubStr(aLinha[06], 3, 2)+SubStr(aLinha[06], 1, 2)
			_cDataF := SubStr(aLinha[07], 5)+SubStr(aLinha[07], 3, 2)+SubStr(aLinha[07], 1, 2)
			//06 - Data inicial das informações contidas no arquivo.
			//07 - Data final das informações contidas no arquivo.
		EndIf
	EndIf
	
	If cReg == '0140'
		//0140 - TABELA DE CADASTRO DE ESTABELECIMENTO
		//verifica a filial que está sendo processada
		cFilAtu := aLinha[02]
		//02 - Código de identificação do estabelecimento
	ElseIf cReg == '0190'
		//0190 - IDENTIFICAÇÃO DAS UNIDADES DE MEDIDA
		//adiciona as unidades de medidas já existentes para controle
		aAdd(aUM, {cFilAtu, aLinha[02]})
		//02 - Código da unidade de medida
	ElseIf cReg == '0200'
		//0200 - TABELA DE IDENTIFICAÇÃO DO ITEM (PRODUTOS E SERVIÇOS)
		//adiciona os produtos já existentes para controle
		aAdd(aProd, {cFilAtu, aLinha[02]})
		//02 - Código do item
	//Alt. (1)
	/*
	ElseIf cReg == 'C100'
		//C100 - DOCUMENTO - NOTA FISCAL (CÓDIGO 01), NOTA FISCAL AVULSA (CÓDIGO 1B), NOTA FISCAL DE PRODUTOR (CÓDIGO 04) e NF-e (CÓDIGO 55)
		If MyVal(aLinha[12]) <> MyVal(aLinha[16])
			//12 - Valor total do documento fiscal
			//16 - Valor total das mercadorias e serviços
			aLinha[12] := aLinha[16]
		EndIf
	ElseIf cReg == 'C170'
		//C170 - COMPLEMENTO DO DOCUMENTO - ITENS DO DOCUMENTO (CÓDIGOS 01, 1B, 04 e 55)
		If MyVal(aLinha[26]) <> 0 .and.;
		MyVal(aLinha[07]) <> MyVal(aLinha[26])
			//07 - Valor total do item (mercadorias ou serviços)
			//26 - Valor da base de cálculo do PIS
			aLinha[07] := aLinha[26]
		EndIf
	ElseIf cReg $ 'C191;C195'
		//C191 - DETALHAMENTO DA CONSOLIDAÇÃO ? OPERAÇÕES DE AQUISIÇÃO COM DIREITO A CRÉDITO, E OPERAÇÕES DE DEVOLUÇÃO DE COMPRAS E VENDAS ? PIS/PASEP
		//C195 - DETALHAMENTO DA CONSOLIDAÇÃO ? OPERAÇÕES DE AQUISIÇÃO COM DIREITO A CRÉDITO, E OPERAÇÕES DE DEVOLUÇÃO DE COMPRAS E VENDAS ? COFINS
		If MyVal(aLinha[07]) <> 0 .and.;
		MyVal(aLinha[05]) <> MyVal(aLinha[07])
			//05 - Valor Item
			//07 - Valor da base de cálculo do PIS/PASEP (C191) ou COFINS (C195)
			aLinha[05] := aLinha[07]
		EndIf
	*/
	//Fim Alt. (1)
	ElseIf cReg $ 'C491;C495'
		//REGISTRO C491: DETALHAMENTO DA CONSOLIDAÇÃO DE DOCUMENTOS EMITIDOS POR ECF (CÓDIGOS 02, 2D e 59) ? PIS/PASEP
		//REGISTRO C495: DETALHAMENTO DA CONSOLIDAÇÃO DE DOCUMENTOS EMITIDOS POR ECF (CÓDIGOS 02, 2D e 59) ? COFINS
		cVar := Iif(cReg=='C491','PIS','COF')
		
		If &('_cUlt'+cVar) <> Right(aLinha[02], 2)
			//executa caso ainda não tenha processado a filial
			&('_cUlt'+cVar) := Right(aLinha[02], 2)
			//busca no banco de dados as informações consolidades de ECF e salva em um vetor
			&('_aECF'+cVar) := aClone(QryECF(cVar, &('_cUlt'+cVar)))
			
			nTamJ := Len(&('_aECF'+cVar))
			For nJ := 1 to nTamJ
				uVar := aClone(&('_aECF'+cVar)[nJ])
				
				//soma contador para cada registro retornado da query
				_nCX++
				If cReg == 'C491'
					_nC491++
				Else
					_nC495++
				EndIf
				//verifica se o produto retornado pela query está no vetor salvo anteriormente
				//ou no novo vetor que controla os novos produtos adicionados
				If aScan(aProd, {|x| x[1] == &('_cUlt'+cVar) .and. x[2] == uVar[1] }) == 0 .and. aScan(aNewProd, {|x| x[1] == &('_cUlt'+cVar) .and. x[2][2] == uVar[1] }) == 0
					//se não estiver, adiciona o novo produto
					NewProd(uVar[1], @aNewProd, @aUM, @aNewUM)
				EndIf
				
				//monta novo C491/C495 de acordo com o retorno da query
				aAdd(aNew, {;
					cReg,; //01 - Texto fixo contendo "C491" ou "C495"
					uVar[1],; //02 - Código do item (campo 02 do Registro 0200)
					uVar[2],; //03 - Código da Situação Tributária referente ao PIS/PASEP (C491) ou COFINS (C495)
					uVar[3],; //04 - Código fiscal de operação e prestação
					Iif(uVar[5]==0,'0',MyStrVal(uVar[5],12,2)),; //05 - Valor total dos itens
					Iif(uVar[6]==0,'0',MyStrVal(uVar[6],12,2)),; //06 - Valor da base de cálculo do PIS/PASEP (C491) ou COFINS (C495)
					Iif(uVar[4]==0,'0',MyStrVal(uVar[4],12,4)),; //07 - Alíquota do PIS/PASEP (C491) ou COFINS (C495) (em percentual)
					'',; //08 - Quantidade ? Base de cálculo PIS/PASEP (C491) ou COFINS (C495)
					'',; //09 - Alíquota do PIS/PASEP (C491) ou COFINS (C495) (em reais)
					Iif(uVar[7]==0,'0',MyStrVal(uVar[7],12,2)),; //10 - Valor do PIS/PASEP (C491) ou COFINS (C495)
					''; //11 - Código da conta analítica contábil debitada/creditada
				})
			Next nJ
		EndIf
		
		//ignora C491/C495 original
		lGrava := .F.
		
		//diminui do contador o registro original ignorado para, no final, termos
		//somente a diferença que será a quantidade de itens novos adicionados
		_nCX--
		If cReg == 'C491'
			_nC491--
		Else
			_nC495--
		EndIf
	EndIf
	
	If lGrava
		//adiciona a linha em formato de vetor em um novo vetor que será o arquivo final
		aAdd(aNew, aClone(aLinha))
	EndIf
	
	IncProc()
Next nI
MemoWrite('c:\debug.txt', _cDebug)
//redimensiona o vetor final para acomodar os novos produtos ou unidades de medida
IncProc('Ajustando arquivo..')
nTamJ := Len(aNewUM)
nTamK := Len(aNewProd)
nTamI := Len(aNew)+nTamJ+nTamK
aSize(aNew, nTamI)
//percorre o vetor final completamente
For nI := 1 to nTamI
	cReg := aNew[nI][1]
	
	//verificando a filial que está sendo processada
	If cReg == '0140'
		cFilAtu := aNew[nI][2]
	EndIf
	
	//utilizado como flag de controle para saber se as
	//unidades de medida da filial que está sendo processada
	//já foram adicionadas
	nQtd := 0
	aEval(aNewUM, {|x| Iif(x[1] == cFilAtu,nQtd++,.F.) })
	If nQtd > 0
		//encontrou a primeira unidade de medida (0190)
		If cReg == '0190'
			//percore o vetor de unidades de medida novas
			For nJ := 1 to nTamJ
				//verifica se a unidade de medida é da filial que está sendo processada
				If aNewUM[nJ][1] == cFilAtu
					//insere uma posição no vetor final, na posição atual
					//(da primeira unidade de medida encontrada), afastando
					//todos os demais registros para trás. não irá truncar
					//pois o vetor foi redimensionado no início
					aIns(aNew, nI)
					//adiciona nova unidade de medida na posição
					aNew[nI] := aClone(aNewUM[nJ][2])
					//remove a filial para não adicionar novamente
					aNewUM[nJ][1] := ''
				EndIf
			Next nJ
		EndIf
	EndIf
	
	//utilizado como flag de controle para saber se os
	//produtos da filial que está sendo processada
	//já foram adicionados
	nQtd := 0
	aEval(aNewProd, {|x| Iif(x[1] == cFilAtu,nQtd++,.F.) })
	If nQtd > 0
		//encontrou o primeiro produto (0190)
		If cReg == '0200'
			//percore o vetor de produtos novos
			For nK := 1 to nTamK
				//verifica se o produto é da filial que está sendo processada
				If aNewProd[nK][1] == cFilAtu
					//insere uma posição no vetor final, na posição atual
					//(do primeiro produto encontrado), afastando
					//todos os demais registros para trás. não irá truncar
					//pois o vetor foi redimensionado no início
					aIns(aNew, nI)
					//adiciona novo produto na posição
					aNew[nI] := aClone(aNewProd[nK][2])
					//remove a filial para não adicionar novamente
					aNewProd[nK][1] := ''
				EndIf
			Next nK
		EndIf
	EndIf
	
	//ajusta os totalizadores
	If cReg == '0990'
		//0990 - ENCERRAMENTO DO BLOCO 0
		//soma o valor existente com a quantidade de novos registros 0XXX adicionados
		aNew[nI][02] := cValToChar(Val(aNew[nI][02]) + _n0X)
		//02 - Quantidade total de linhas do Bloco 0
	ElseIf cReg == 'C990'
		//C990 - ENCERRAMENTO DO BLOCO C
		//soma o valor existente com a quantidade de novos registros CXXX adicionados
		aNew[nI][02] := cValToChar(Val(aNew[nI][02]) + _nCX)
		//02 - Quantidade total de linhas do Bloco C
	ElseIf cReg == '9900'
		//9900 - REGISTROS DO ARQUIVO
		//verifica se existe uma variável declarada no formato _nXXXX
		//para o contador do registro presente na posição 2 desta linha
		If Type('_n'+aNew[nI][02]) <> 'U'
			//02 - Registro que será totalizado no próximo campo
			//soma o valor existente com a quantidade de novos registros adicionados
			aNew[nI][03] := cValToChar(Val(aNew[nI][03]) + &('_n'+aNew[nI][02]))
			//03 - Total de registros do tipo informado no campo anterior
		EndIf
	ElseIf cReg == '9999'
		//9999 - ENCERRAMENTO DO ARQUIVO DIGITAL
		//soma o valor existente com a quantidade total de novos registros adicionados
		aNew[nI][02] := cValToChar(Val(aNew[nI][02]) + _n0X + _nCX)
		//02 - Quantidade total de linhas do arquivo digital
	EndIf
	
	IncProc()
Next nI

//converte o vetor final pro formato SPED e escreve no TXT
IncProc('Gerando arquivo final..')
nTamI := Len(aNew)
For nI := 1 to nTamI
	cLinha := '|'
	nTamJ := Len(aNew[nI])
	For nJ := 1 to nTamJ
		cLinha += aNew[nI][nJ]+'|'
	Next nI
	cLinha += CRLF
	If fWrite(nHdl, cLinha, Len(cLinha)) <> Len(cLinha)
		Alert('Erro ' + cValToChar(fError()) + ' ao escrever a nova linha no arquivo: ' + CRLF + cLinha)
	EndIf
	IncProc()
Next nI

//fecha o arquivo
fClose(nHdl)

MsgAlert('O arquivo final <b>' + SubStr(cFileOk, RAt('\', cFileOk)+1) + '</b> foi gerado com sucesso.')

Return Nil

/* ------------------- */

Static Function QryECF(cTipo, cFil)

Local aRet := {}
Local cQry := ''

If cTipo <> 'PIS' .and. cTipo <> 'COF'
	Return aClone(aRet)
EndIf

cQry := CRLF + " SELECT (FT_PRODUTO+FT_FILIAL) PRODUTO,"
cQry += CRLF + "        FT_CST" + cTipo + " CST,"
cQry += CRLF + "        FT_CFOP CFOP,"
cQry += CRLF + "        SUM(FT_VALCONT) VALCONT,"
cQry += CRLF + "        SUM(FT_BASE" + cTipo + ") BASE,"
cQry += CRLF + "        FT_ALIQ" + cTipo + " ALIQ,"
cQry += CRLF + "        SUM(FT_VAL" + cTipo + ") VALOR"
cQry += CRLF + " FROM " + RetSqlName('SFT')
cQry += CRLF + " WHERE FT_FILIAL = '" + cFil + "'"
cQry += CRLF + "   AND FT_ENTRADA >= '" + _cDataI + "'"
cQry += CRLF + "   AND FT_ENTRADA <= '" + _cDataF + "'"
cQry += CRLF + "   AND LEFT(FT_CFOP,1) >= '5'"
cQry += CRLF + "   AND FT_ESPECIE = 'CF'"
cQry += CRLF + "   AND LEN(FT_DTCANC) = 0"
cQry += CRLF + "   AND D_E_L_E_T_ <> '*'"
cQry += CRLF + " GROUP BY (FT_PRODUTO+FT_FILIAL), FT_CST" + cTipo + ", FT_CFOP, FT_ALIQ" + cTipo
cQry += CRLF + " ORDER BY (FT_PRODUTO+FT_FILIAL), FT_CST" + cTipo + ", FT_CFOP, FT_ALIQ" + cTipo
_cDebug += cQry + CRLF
dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MYECF',.T.)
While !MYECF->(Eof())
	aAdd(aRet, {AllTrim(MYECF->PRODUTO), AllTrim(MYECF->CST), AllTrim(MYECF->CFOP), MYECF->ALIQ, MYECF->VALCONT, MYECF->BASE, MYECF->VALOR, ''})
	MYECF->(dbSkip())
EndDo
MYECF->(dbCloseArea())

Return aClone(aRet)

/* ------------------- */

Static Function NewProd(cProd, aNewProd, aUM, aNewUM)

Local aLinha := {}
Local cFil := Iif(AllTrim(xFilial('SB1'))<>'',Right(cProd, 2),'  ')
Local cCod := Left(cProd, Len(cProd)-2)
Local cUM
Local nTipo
Local nICMPAD := SuperGetMV('MV_ICMPAD',.F.,17)
Local aArea
Local aAreaSB1
Local aTipo := {{'ME','00'},; //00 ? Mercadoria para Revenda
                {'MP','01'},; //01 ? Matéria-Prima
                {'EM','02'},; //02 ? Embalagem
                {'PP','03'},; //03 ? Produto em Processo
                {'PA','04'},; //04 ? Produto Acabado
                {'SP','05'},; //05 ? Subproduto
                {'PI','06'},; //06 ? Produto Intermediário
                {'MC','07'},; //07 ? Material de Uso e Consumo
                {'AI','08'},; //08 ? Ativo Imobilizado
                {'MO','09'},; //09 ? Serviços
                {'OI','10'}}  //10 ? Outros insumos
Local cTipo := '99'           //99 - Outras
aArea := GetArea()
aAreaSB1 := SB1->(GetArea('SB1'))

SB1->(dbSetOrder(1))
If SB1->(dbSeek( cFil + cCod ))
	//verifica tipo de acordo com o vetor declarado acima
	nTipo := aScan(aTipo, {|x| x[1] == SB1->B1_TIPO })
	If nTipo > 0
		cTipo := aTipo[nTipo][2]
	EndIf
	
	//verifica se a unidade de medida deste produto já está no vetor salvo anteriormente
	//ou no novo vetor que controla as novas unidades de medida adicionados
	cUM := SB1->B1_UM
	If aScan(aUM, {|x| x[1] == cFil .and. x[2] == cUM }) == 0 .and. aScan(aNewUM, {|x| x[1] == cFil .and. x[2][2] == cUM }) == 0
		//se não estiver, adiciona a nova unidade de medida
		NewUM(cUM, cFil, @aNewUM)
	EndIf
	
	//criando novo registro 0200 baseado no SB1
	aAdd(aLinha, '0200') //01 - Texto fixo contendo "0200"
	aAdd(aLinha, cProd) //02 - Código do item
	aAdd(aLinha, AllTrim(SB1->B1_DESC)) //03 - Descrição do item
	aAdd(aLinha, AllTrim(SB1->B1_CODBAR)) //04 - Representação alfanumérico do código de barra do produto, se houver
	aAdd(aLinha, Iif(AllTrim(SB1->B1_CODANT) <> '',AllTrim(SB1->B1_CODANT)+cFil,'')) //05 - Código anterior do item com relação à última informação apresentada
	aAdd(aLinha, cUM) //06 - Unidade de medida utilizada na quantificac¸a~o de estoques
	aAdd(aLinha, cTipo) //07 - Tipo do item ? Atividades Industriais, Comerciais e Serviços (conforme tabela acima)
	aAdd(aLinha, AllTrim(SB1->B1_POSIPI)) //08 - Código da Nomenclatura Comum do Mercosul
	aAdd(aLinha, AllTrim(SB1->B1_EX_NCM)) //09 - Código EX, conforme a TIPI
	aAdd(aLinha, AllTrim(Left(SB1->B1_POSIPI,2))) //10 - Código do gênero do item, conforme a Tabela 4.2.1
	aAdd(aLinha, '') //11 - Código do serviço conforme lista do Anexo I da Lei Complementar Federal no 116/03
	aAdd(aLinha, MyStrVal(Iif(SB1->B1_PICM > 0,SB1->B1_PICM,nICMPAD),2,2)) //12 - Alíquota de ICMS aplicável ao item nas operações internas
	
	//adicionando ao vetor de novos produtos
	aAdd(aNewProd, {cFil, aClone(aLinha)})
	
	//aumentando totalizadores dos registros
	_n0X++
	_n0200++
EndIf

SB1->(RestArea(aAreaSB1))
RestArea(aArea)

Return Nil

/* ------------------- */

Static Function NewUM(cUM, cFil, aNewUM)

Local aLinha := {}
Local cFilSAH := Iif(AllTrim(xFilial('SAH'))<>'',cFil,'  ')
Local aArea
Local aAreaSAH

aArea := GetArea()
aAreaSAH := SAH->(GetArea('SAH'))

SAH->(dbSetOrder(1))
If SAH->(dbSeek( cFilSAH + cUM ))
	//criando novo registro 0190 baseado no SAH
	aAdd(aLinha, '0190') //01 - Texto fixo contendo "0190"
	aAdd(aLinha, cUM) //02 - Código da unidade de medida
	aAdd(aLinha, AllTrim(SAH->AH_DESCPO)) //03 - Descrição da unidade de medida
	
	//adicionando ao vetor de novas unidades de medida
	aAdd(aNewUM, {cFil, aClone(aLinha)})
	
	//aumentando totalizadores dos registros
	_n0X++
	_n0190++
EndIf

SAH->(RestArea(aAreaSAH))
RestArea(aArea)

Return Nil

/* ------------------- */

Static Function MySepara(cTxt)

Local aRet := Separa(cTxt, '|')
aDel(aRet, 1)
aSize(aRet, Len(aRet)-2)

Return aClone(aRet)
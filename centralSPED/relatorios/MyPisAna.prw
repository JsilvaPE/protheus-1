#define VALIDA_EMPRESA
#define SERVER_DIR '\analisa-piscofins\'
//#define TESTE_DIR 'Z:\SPED\'
#define MANTEM_ARQUIVO
#define LIMITE_CAMPOS 40

#define COL_LEG			1
#define COL_CST			2
#define COL_BLOCO		3
#define COL_REF			4
#define COL_CAMPO		5
#define COL_PVA			6
#define COL_PROTHEUS	7
#define COL_DIF			8

#define CPO_VL_ITEM			'1-Valor do Item'
#define CPO_VL_BC_PIS		'2-Base do PIS'
#define CPO_VL_PIS			'3-Valor do PIS'
#define CPO_VL_BC_COFINS	'4-Base do COFINS'
#define CPO_VL_COFINS		'5-Valor do COFINS'

#define REG_PIS		'C181;C191;C491;C501;D101;D201;D501'
#define REG_COFINS	'C185;C195;C495;C505;D105;D205;D505'

#define A170		'A170'
#define A170_REF	'NF Serviço'
#define C170		'C170'
#define C170_REF	'NF Normal, Avulsa, Produtor e NF-e'
#define C181		'C181'
#define C181_REF	'NF-e Consolidadas - Vendas (PIS)'
#define C185		'C185'
#define C185_REF	'NF-e Consolidadas - Vendas (COFINS)'
#define C191		'C191'
#define C191_REF	'NF-e Consolidadas - Aquisições/Devoluções (PIS)'
#define C195		'C195'
#define C195_REF	'NF-e Consolidadas - Aquisições/Devoluções (COFINS)'
#define C491		'C491'
#define C491_REF	'Cupons Fiscais Consolidados (PIS)'
#define C495		'C495'
#define C495_REF	'Cupons Fiscais Consolidados (COFINS)'
#define C501		'C501'
#define C501_REF	'NF Energia, Água e Gás - Aquisições (PIS)'
#define C505		'C505'
#define C505_REF	'NF Energia, Água e Gás - Aquisições (COFINS)'
#define D101		'D101'
#define D101_REF	'Documentos de Transporte - Aquisições (PIS)'
#define D105		'D105'
#define D105_REF	'Documentos de Transporte - Aquisições (COFINS)'
#define D201		'D201'
#define D201_REF	'Documentos de Transporte - Prestações (PIS)'
#define D205		'D205'
#define D205_REF	'Documentos de Transporte - Prestações (COFINS)'
#define D501		'D501'
#define D501_REF	'NF Comunicação e Telecomunicação - Aquisições (PIS)'
#define D505		'D505'
#define D505_REF	'NF Comunicação e Telecomunicação - Aquisições (COFINS)'
#define F100		'F100'
#define F100_REF	'Demais Documentos'
#define F120		'F120'
#define F120_REF	'Bens Incorporados ao Ativo - Depreciação/Amortização'
#define F130		'F130'
#define F130_REF	'Bens Incorporados ao Ativo - Aquisição'

#include 'rwmake.ch'
#include 'protheus.ch'
#include 'totvs.ch'
/*/{Protheus.doc} MyPisAna
Analisa um arquivo do SPED PIS/COFINS (EFD-Contribuições),
quebrando por registro e comparando o mesmo com o conteúdo
da tabela SFT.

@author Thieres Tembra
@since 24/05/2014
@version 1.0
@return nulo Nada é retornado 
/*/
User Function MyPisAna()

Private _cMyTitulo := 'Análise EFD-Contribuições'
Private _cMyTab    := 'PISCOF_' + cEmpAnt + '_'
Private _oDlgMain, _oLayer
Private _oWndEnt, _oWndSai, _oWndMen, _oWndDes
Private _oBrwEnt, _oBrwSai
Private _cTitEnt, _cTitSai
Private _oTreeMenu
Private _aNodeMenu
Private _aColEnt := {}
Private _aColSai := {}
Private _aFilEnt := {}
Private _aFilSai := {}
Private _aFilCST := {}
Private _aFilReg := {}
Private _aFilCpo := {}
Private _lConsolid

CriaJanela()

Return Nil

/* ------------------- */

/*/{Protheus.doc} LoadFile
Exibe janela para o usuário selecionar o arquivo a ser analisado.
Após seleção o arquivo é copiado para o servidor e carregado para
um vetor. Então são feitos vários testes para verificar a
consistência do mesmo quanto ao layout do EFD-Contribuições.

@author Thieres Tembra
@since 24/05/2014
@version 1.0
@param aArq, array, Variável do tipo array enviado por referência onde será carregado o arquivo.
@param dDtIni, data, Variável do tipo data enviada por referência onde será salvo a data inicial do período de apuração do arquivo carregado.
@param dDtFim, data, Variável do tipo data enviada por referência onde será salvo a data final do período de apuração do arquivo carregado.
@return numérico Se menor que 0 ocorreu erro. Se igual a -1 ocorreu um erro genérico e não foi exibida nenhuma mensagem de erro. Se menor que -1 ocorreu um erro específico e já foi exibida uma mensagem de erro.
@see MyLeArq, MySepara
/*/
Static Function LoadFile(aArq,dDtIni,dDtFim)

Local nRet := 0
Local cArq := ''
Local cExt := ''
Local cDrv := ''
Local cDir := ''
Local aLinha
Local nPos
Local l0140 := .F.

ProcRegua(0)

#ifdef TESTE_DIR
	#define START_DIR TESTE_DIR
#else
	#define START_DIR 'C:\'
#endif
cArq := AllTrim(cGetFile('TXT (*.txt)|*.txt', 'Selecione o arquivo a ser analisado', 1, START_DIR, .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NETWORKDRIVE ), .F., .T.))
If cArq == ''
	MsgAlert('A importação do arquivo foi cancelada!')
	nRet := -2
Else
	If !ExistDir(SERVER_DIR)
		If MakeDir(SERVER_DIR) <> 0
			MsgAlert('Não foi possível criar o diretório ' + SERVER_DIR + ' no RootPath do servidor. Informe o administrador do sistema. O arquivo será copiado para o RootPath.')
			#define SERVER_DIR '\'
		EndIf
	EndIf
	If !CpyT2S(cArq, SERVER_DIR)
		MsgAlert('Não foi possível copiar o arquivo para o servidor.')
		nRet := -3
	Else
		SplitPath(cArq, @cDrv, @cDir, @cArq, @cExt)
		cArq := SERVER_DIR + cArq + cExt
		aArq := U_MyLeArq(cArq)
		#ifndef MANTEM_ARQUIVO
		FErase(cArq)
		#endif
		If Len(aArq) == 0
			nRet := -1
		Else
			aLinha := MySepara(aArq[1])
			If Len(aLinha) <> 14
				//primeira linha (possível registro 0000) não contém 14 campos
				nRet := -1
			Else
				If aLinha[1] <> '0000'
					//primeira linha não é registro 0000
					nRet := -1
				Else
					If Len(aLinha[6]) <> 8 .or. Len(aLinha[7]) <> 8
						//campos 06 e 07 do registro 0000 não tem 8 caracteres da data
						nRet := -1
					Else
						dDtIni := CTOD(SubStr(aLinha[6],1,2) + '/' + SubStr(aLinha[6],3,2) + '/' + SubStr(aLinha[6],5,4))
						dDtFim := CTOD(SubStr(aLinha[7],1,2) + '/' + SubStr(aLinha[7],3,2) + '/' + SubStr(aLinha[7],5,4))
						If dDtIni == Nil .or. dDtFim == Nil
							//não conseguiu converter os campos 06 e 07 do registro 0000 para data
							nRet := -1
						ElseIf dDtIni == CTOD('') .or. dDtFim == CTOD('')
							//não conseguiu converter os campos 06 e 07 do registro 0000 para data
							nRet := -1
						ElseIf dDtFim <= dDtIni
							//data final menor igual a data inicial
							nRet := -1
						#ifdef VALIDA_EMPRESA
						ElseIf Left(aLinha[9], 8) <> Left(SM0->M0_CGC, 8)
							//arquivo de outra empresa conforme comparação da base do CNPJ
							MsgAlert('Este arquivo pertence a outro grupo de empresas com CNPJ ' + Transform(aLinha[9], '@R 99.999.999/9999-99'))
							nRet := -4
						Else
							nPos := aScan(aArq, {|x| SubStr(x, 2, 4) == '0140' })
							While nPos <> 0
								aLinha := MySepara(aArq[nPos])
								If aLinha[4] == SM0->M0_CGC
									l0140 := .T.
									Exit
								EndIf
								nPos := aScanX(aArq, {|x| SubStr(x, 2, 4) == '0140' }, nPos+1)
							EndDo
							If !l0140
						 		MsgAlert('Este arquivo não possui informações desta empresa/filial.')
								nRet := -5
							EndIf
						#endif
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If nRet <> 0
	aArq   := Nil
	dDtIni := Nil
	dDtFim := Nil
EndIf

Return nRet

/* ------------------- */

/*/{Protheus.doc} MySepara
Separa uma linha de texto no padrão do layout SPED que utiliza o caractere "|"
como separador, utilizando a função padrão "Separa", porém desprezando a primeira
e a última posição do array retornado por esta função. 

@author Thieres Tembra
@since 24/05/2014
@version 1.0
@param cTxt, caracter, Texto a ser convertido
@return array Array consistente com todas as posições preenchidas, onde cada campo referência exatamente o mesmo número de campo no layout do SPED.
/*/
Static Function MySepara(cTxt)

Local aRet := Separa(cTxt, '|')
aDel(aRet, 1)
aSize(aRet, Len(aRet)-2)

Return aClone(aRet)

/* ------------------- */

/*/{Protheus.doc} ImportFile
Importa o arquivo contido no array para uma tabela dentro do banco de dados em uso.

@author Thieres Tembra
@since 24/05/2014
@version 1.0
@param aArq, array, Array contendo o arquivo a ser importado.
@return lógico Verdadeiro se conseguiu importar o arquivo, Falso caso contrário.
@database MSSQL
@see TabExists, TabCreate, TabData
/*/
Static Function ImportFile(aArq)

Local lRet := .T.
Local lDrop := .F.

ProcRegua(0)

If TabExists()
	If !MsgYesNo('O arquivo selecionado é referente a um período ' +;
	'já importado anteriormente. A escrituração existente será ' +;
	'substituída. Deseja continuar mesmo assim?')
		lRet := .F.
		Return lRet
	EndIf
	lDrop := .T.
EndIf

If !TabCreate(lDrop)
	lRet := .F.
	Return lRet
EndIf

If !TabData(aArq)
	lRet := .F.
	Return lRet
EndIf

Return lRet

/* ------------------- */

/*/{Protheus.doc} TabExists
Verifica a existência da tabela com nome salvo na variável
privada _cMyTab no banco de dados em uso.
 

@author Thieres Tembra
@since 24/05/2014
@version 1.0
@return lógico Verdadeiro se a tabela existir, Falso caso contrário.
@database MSSQL
/*/
Static Function TabExists()

Local lRet := .F.
Local cAlias := GetNextAlias()

BeginSql Alias cAlias
	SELECT 1
	FROM information_schema.tables
	WHERE TABLE_TYPE = 'BASE TABLE'
	  AND TABLE_NAME = %exp:_cMyTab%
EndSql

If !(cAlias)->(Eof())
	lRet := .T.
EndIf

Return lRet

/* ------------------- */

/*/{Protheus.doc} TabCreate
Cria a tabela com nome salvo na variável privada _cMyTab
no banco de dados em uso.

@author Thieres Tembra
@since 24/05/2014
@version 1.0
@param lDrop, lógico, Se Verdadeiro irá dropar a tabela do banco de dados.
@return lógico Verdadeiro se a tabela foi criada com sucesso, Falso caso contrário.
/*/
Static Function TabCreate(lDrop)

Local lRet := .T.
Local aQry := {}
Local nRet
Local nI, nMax
Local cCreate

If lDrop
	aAdd(aQry, {;
		'Apagando os dados existentes..'	,;
		"DROP TABLE " + _cMyTab				 ;
	})
EndIf

cCreate := CRLF + "CREATE TABLE " + _cMyTab + " ("
For nI := 1 to LIMITE_CAMPOS
	cCreate += CRLF + "  C" + StrZero(nI, 2) + " varchar(255) not null default '',"
Next nI
cCreate += CRLF + "  D_E_L_E_T_ varchar(1) not null default '',"
cCreate += CRLF + "  R_E_C_N_O_ int identity(1,1) primary key"
cCreate += CRLF + ")"
	
aAdd(aQry, {;
	'Criando estrutura para importação..'	,;
	cCreate									 ;
})

nMax := Len(aQry)
For nI := 1 to nMax
	IncProc(aQry[nI][1])
	nRet := TCSqlExec(aQry[nI][2])
	If nRet < 0
		Aviso(_cMyTitulo, 'Erro TCSqlExec ' + cValToChar(nRet) +;
		CRLF + CRLF + TCSqlError() + CRLF + CRLF +;
		'Query original executada:' + aQry[nI][2], {'OK'})
		lRet := .F.
		Exit
	EndIf
Next nI

Return lRet

/* ------------------- */

/*/{Protheus.doc} TabData
Coloca a tabela com nome salvo na variável privada _cMyTab em uso
através do alias "PISCOF" e em seguida realiza a inserção dos registros
carregados no array referente ao arquivo selecionado pelo usuário.

@author Thieres Tembra
@since 24/05/2014
@version 1.0
@param aArq, array, Array contendo o arquivo com os registros a serem carregados para o banco de dados.
@return lógico Verdadeiro se os registros foram inseridos com sucesso, Falso caso contrário.
/*/
Static Function TabData(aArq)

Local lRet := .T.
Local nI, nMaxI, nJ, nMaxJ, nRet
Local aLinha
Local cInsert

IncProc('Iniciando importação..')

If Select('PISCOF') > 0
	PISCOF->(dbCloseArea())
EndIf
dbUseArea(.T.,'TOPCONN',_cMyTab,'PISCOF',.F.,.T.)
If Select('PISCOF') == 0
	MsgAlert('Não foi possível abrir a tabela para importação.')
	lRet := .F.
	Return lRet
EndIf

nMaxI := Len(aArq)
ProcRegua(nMaxI)
For nI := 1 to nMaxI
	IncProc('Importando registro ' + cValToChar(nI) + ' de ' + cValToChar(nMaxI) + '..')
	aLinha := MySepara(aArq[nI])
	nMaxJ := Len(aLinha)
	If nMaxJ > LIMITE_CAMPOS
		MsgAlert('A linha ' + cValToChar(nI) + ' do arquivo importado possui mais que ' + cValToChar(LIMITE_CAMPOS) + ' campos. Informe o administrador do sistema.')
		lRet := .F.
		Return lRet
	Else
		cInsert := CRLF + "INSERT INTO " + _cMyTab + " ("
		For nJ := 1 to nMaxJ
			cInsert += CRLF + "  C" + StrZero(nJ, 2) + ","
		Next nJ
		cInsert := Left(cInsert, Len(cInsert)-1) //remove última vírgula
		cInsert += CRLF + ") VALUES ("
		For nJ := 1 to nMaxJ
			cInsert += CRLF + "  '" + aLinha[nJ] + "',"
		Next nJ
		cInsert := Left(cInsert, Len(cInsert)-1) //remove última vírgula
		cInsert += CRLF + ")"
		nRet := TCSqlExec(cInsert)
		If nRet < 0
			Aviso(_cMyTitulo, 'Erro TCSqlExec ' + cValToChar(nRet) +;
			CRLF + CRLF + TCSqlError() + CRLF + CRLF +;
			'Query original executada:' + cInsert, {'OK'})
			lRet := .F.
			Return lRet
		EndIf
	EndIf
Next nI

IncProc()

Return lRet


/* ------------------- */

/*/{Protheus.doc} Bloco A
Analisa os registros dos blocos Axxx.

@author Thieres Tembra
@since 24/05/2014
@version 1.0
@param dDtIni, data, Data inicial do período a ser analisado
@param dDtFim, data, Data final do período a ser analisado
@return nulo Nada é retornado
/*/
Static Function BlocoA(dDtIni, dDtFim)

Local cAlias
Local cTab := '%' + _cMyTab + '%'
Local cRecNo, cCST
Local aValores
Local n010Atu := 0
Local n010Nxt := 0

ProcRegua(3)

//agrupamento somente pela CST do PIS pois conforme a validação do PVA:
//	O CST referente ao PIS/PASEP deve ser igual ao CST referente à COFINS,
//	assim como o Valor da base de cálculo do PIS/PASEP deve ser igual ao
//	Valor da base de cálculo da COFINS.

//verificando registros A010 - primeira análise: PVA
cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT
	      C02        as CNPJ
	     ,R_E_C_N_O_ as RECNUM
	FROM %exp:cTab%
	WHERE C01 = 'A010'
EndSql

While !(cAlias)->(Eof())
	If n010Atu <> 0
		n010Nxt := (cAlias)->RECNUM
		Exit
	EndIf
	If AllTrim((cAlias)->CNPJ) == AllTrim(SM0->M0_CGC)
		n010Atu := (cAlias)->RECNUM
	EndIf
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

IncProc()

If n010Atu <> 0 .and. n010Nxt <> 0
	cRecNo := '%  AND R_E_C_N_O_ BETWEEN ' + cValToChar(n010Atu) + ' AND ' + cValToChar(n010Nxt) + '%'
ElseIf n010Atu <> 0 .and. n010Nxt == 0
	cRecNo := '%  AND R_E_C_N_O_ > ' + cValToChar(n010Atu) + '%'
Else
	cRecNo := ''
EndIf

//verificando registros A170 - primeira análise: PVA
If cRecNo <> ''
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       C09                                                as CST_PIS		/* 09 - CST_PIS			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c05,',','.'))), 2) as VL_ITEM		/* 05 - VL_ITEM			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c10,',','.'))), 2) as VL_BC_PIS		/* 10 - VL_BC_PIS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c12,',','.'))), 2) as VL_PIS			/* 12 - VL_PIS			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c14,',','.'))), 2) as VL_BC_COFINS	/* 14 - VL_BC_COFINS	*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c16,',','.'))), 2) as VL_COFINS		/* 16 - VL_COFINS		*/
		FROM %exp:cTab%
		WHERE C01 = 'A170'
		%exp:cRecNo%
		GROUP BY C09 /* 09 - CST_PIS */
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->CST_PIS
		aValores := {;
			(cAlias)->VL_ITEM		,; // 05 - VL_ITEM
			(cAlias)->VL_BC_PIS		,; // 10 - VL_BC_PIS
			(cAlias)->VL_PIS		,; // 12 - VL_PIS
			(cAlias)->VL_BC_COFINS	,; // 14 - VL_BC_COFINS
			(cAlias)->VL_COFINS		 ; // 16 - VL_COFINS
		}
		NovoReg(cCST, A170, A170_REF, aValores, COL_PVA)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
EndIf

IncProc()

//referência registros A170 - segunda análise: Protheus
cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT
	       FT_CSTPIS                as FT_CSTPIS
	      ,ROUND(SUM(
	         CASE FT_AGREG
	         WHEN 'I' THEN
	           FT_TOTAL+FT_VALICM
	         ELSE
	           FT_TOTAL
	         END
	       ),2)                     as FT_TOTAL
	      ,ROUND(SUM(FT_BASEPIS),2) as FT_BASEPIS
	      ,ROUND(SUM(FT_VALPIS),2)  as FT_VALPIS
	      ,ROUND(SUM(FT_BASECOF),2) as FT_BASECOF
	      ,ROUND(SUM(FT_VALCOF),2)  as FT_VALCOF
	FROM %table:SFT%
	WHERE %notDel%
	  AND FT_FILIAL = %xFilial:SFT%
	  AND (
	    (
	          LEN(FT_DTCANC) = 0
	      AND FT_OBSERV NOT LIKE '%INUTIL%'
	      AND FT_OBSERV NOT LIKE '%CANCEL%'
	    ) OR (
	          LEN(FT_DTCANC) > 0
	      AND FT_OBSERV LIKE '%CANCEL%'
	      AND LEFT(FT_DTCANC,6) > %exp:Left(DTOS(dDtFim),6)%
	    )
	  )
	  AND FT_ESPECIE IN ('NFS','RPS','NFPS')
	  AND FT_BASEPIS > 0
	  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
	GROUP BY FT_CSTPIS
EndSql

While !(cAlias)->(Eof())
	cCST := (cAlias)->FT_CSTPIS
	aValores := {;
		(cAlias)->FT_TOTAL		,;
		(cAlias)->FT_BASEPIS	,;
		(cAlias)->FT_VALPIS		,;
		(cAlias)->FT_BASECOF	,;
		(cAlias)->FT_VALCOF		 ;
	}
	NovoReg(cCST, A170, A170_REF, aValores, COL_PROTHEUS)
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

IncProc()

Return Nil

/* ------------------- */

/*/{Protheus.doc} Bloco C
Analisa os registros dos blocos Cxxx

@author Thieres Tembra
@since 21/06/2014
@version 1.0
@param dDtIni, data, Data inicial do período a ser analisado
@param dDtFim, data, Data final do período a ser analisado
@return nulo Nada é retornado
/*/
Static Function BlocoC(dDtIni, dDtFim)

Local cAlias
Local cTab := '%' + _cMyTab + '%'
Local cRecNo, cCST
Local aValores
Local cEspecie
Local n010Atu := 0
Local n010Nxt := 0
Local nI

ProcRegua(19)

//agrupamento somente pela CST do PIS pois conforme a validação do PVA:
//	O CST referente ao PIS/PASEP deve ser igual ao CST referente à COFINS,
//	assim como o Valor da base de cálculo do PIS/PASEP deve ser igual ao
//	Valor da base de cálculo da COFINS.

//verificando registros C010 - primeira análise: PVA
_lConsolid := .F.
cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT
	      C02        as CNPJ
	     ,C03        as IND_ESCRI
	     ,R_E_C_N_O_ as RECNUM
	FROM %exp:cTab%
	WHERE C01 = 'C010'
EndSql

While !(cAlias)->(Eof())
	If n010Atu <> 0
		n010Nxt := (cAlias)->RECNUM
		Exit
	EndIf
	If AllTrim((cAlias)->CNPJ) == AllTrim(SM0->M0_CGC)
		n010Atu := (cAlias)->RECNUM
		If AllTrim((cAlias)->IND_ESCRI) == '1'
			_lConsolid := .T.
		EndIf
	EndIf
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

If !_lConsolid
	MsgAlert('O arquivo importado foi gerado com base no registro ' +;
	'individualizado de NF-e (C100 e C170) e de ECF (C400). A análise ' +;
	'dos registros de ECF individualizado não será efetuada pois não ' +;
	'está prevista na rotina.')
EndIf

IncProc()

If n010Atu <> 0 .and. n010Nxt <> 0
	cRecNo := '%  AND R_E_C_N_O_ BETWEEN ' + cValToChar(n010Atu) + ' AND ' + cValToChar(n010Nxt) + '%'
ElseIf n010Atu <> 0 .and. n010Nxt == 0
	cRecNo := '%  AND R_E_C_N_O_ > ' + cValToChar(n010Atu) + '%'
Else
	cRecNo := ''
EndIf

//verificando registros C170 - primeira análise: PVA
If cRecNo <> ''
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       C25                                                as CST_PIS		/* 25 - CST_PIS			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c07,',','.'))), 2) as VL_ITEM		/* 07 - VL_ITEM			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c26,',','.'))), 2) as VL_BC_PIS		/* 26 - VL_BC_PIS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c30,',','.'))), 2) as VL_PIS			/* 30 - VL_PIS			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c32,',','.'))), 2) as VL_BC_COFINS	/* 32 - VL_BC_COFINS	*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c36,',','.'))), 2) as VL_COFINS		/* 36 - VL_COFINS		*/
		FROM %exp:cTab%
		WHERE C01 = 'C170'
		%exp:cRecNo%
		GROUP BY C25 /* 25 - CST_PIS */
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->CST_PIS
		aValores := {;
			(cAlias)->VL_ITEM		,; // 07 - VL_ITEM
			(cAlias)->VL_BC_PIS		,; // 26 - VL_BC_PIS
			(cAlias)->VL_PIS		,; // 30 - VL_PIS
			(cAlias)->VL_BC_COFINS	,; // 32 - VL_BC_COFINS
			(cAlias)->VL_COFINS		 ; // 36 - VL_COFINS
		}
		NovoReg(cCST, C170, C170_REF, aValores, COL_PVA)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
EndIf

IncProc()

//referência registros C170 - segunda análise: Protheus
If _lConsolid
	cEspecie := "%('NF','NFA','NFP')%"
Else
	cEspecie := "%('NF','NFA','NFP','SPED')%"
EndIf
cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT
	       FT_CSTPIS                as FT_CSTPIS
	      ,ROUND(SUM(
	         CASE FT_AGREG
	         WHEN 'I' THEN
	           FT_TOTAL+FT_VALICM
	         ELSE
	           FT_TOTAL
	         END
	       ),2)                     as FT_TOTAL
	      ,ROUND(SUM(FT_BASEPIS),2) as FT_BASEPIS
	      ,ROUND(SUM(FT_VALPIS),2)  as FT_VALPIS
	      ,ROUND(SUM(FT_BASECOF),2) as FT_BASECOF
	      ,ROUND(SUM(FT_VALCOF),2)  as FT_VALCOF
	FROM %table:SFT% SFT
	LEFT JOIN %table:SF3% SF3
	ON  SF3.%notDel%
	AND F3_FILIAL  = %xFilial:SF3%
	AND F3_NFISCAL = FT_NFISCAL
	AND F3_SERIE   = FT_SERIE
	AND F3_CLIEFOR = FT_CLIEFOR
	AND F3_LOJA    = FT_LOJA
	AND F3_CFO     = FT_CFOP
	AND F3_TIPO    = FT_TIPO
	AND F3_IDENTFT = FT_IDENTF3
	WHERE SFT.%notDel%
	  AND FT_FILIAL = %xFilial:SFT%
	  AND (
	    (
	          LEN(FT_DTCANC) = 0
	      AND FT_OBSERV NOT LIKE '%INUTIL%'
	      AND FT_OBSERV NOT LIKE '%CANCEL%'
	    ) OR (
	          LEN(FT_DTCANC) > 0
	      AND FT_OBSERV LIKE '%CANCEL%'
	      AND LEFT(FT_DTCANC,6) > %exp:Left(DTOS(dDtFim),6)%
	      AND (
	        (
	              F3_CODRSEF = '101'
	          AND FT_ESPECIE = 'SPED'
	        ) OR (
	              F3_CODRSEF = ''
	          AND FT_ESPECIE <> 'SPED'
	        )
	      )
	    )
	  )
	  AND FT_ESPECIE IN %exp:cEspecie%
	  AND FT_BASEPIS > 0
	  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
	GROUP BY FT_CSTPIS
EndSql

While !(cAlias)->(Eof())
	cCST := (cAlias)->FT_CSTPIS
	aValores := {;
		(cAlias)->FT_TOTAL		,;
		(cAlias)->FT_BASEPIS	,;
		(cAlias)->FT_VALPIS		,;
		(cAlias)->FT_BASECOF	,;
		(cAlias)->FT_VALCOF		 ;
	}
	NovoReg(cCST, C170, C170_REF, aValores, COL_PROTHEUS)
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

IncProc()

If _lConsolid
	//verificando registros C181 - primeira análise: PVA
	If cRecNo <> ''
		cAlias := GetNextAlias()
		BeginSql Alias cAlias
			SELECT
			       C02                                                as CST_PIS		/* 02 - CST_PIS			*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c04,',','.'))), 2) as VL_ITEM		/* 04 - VL_ITEM			*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c06,',','.'))), 2) as VL_BC_PIS		/* 06 - VL_BC_PIS		*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c10,',','.'))), 2) as VL_PIS			/* 10 - VL_PIS			*/
			FROM %exp:cTab%
			WHERE C01 = 'C181'
			%exp:cRecNo%
			GROUP BY C02 /* 02 - CST_PIS */
		EndSql
		
		While !(cAlias)->(Eof())
			cCST := (cAlias)->CST_PIS
			aValores := {;
				(cAlias)->VL_ITEM		,; // 04 - VL_ITEM
				(cAlias)->VL_BC_PIS		,; // 06 - VL_BC_PIS
				(cAlias)->VL_PIS		 ; // 10 - VL_PIS
			}
			NovoReg(cCST, C181, C181_REF, aValores, COL_PVA)
			(cAlias)->(dbSkip())
		EndDo
		
		(cAlias)->(dbCloseArea())
	EndIf
	
	IncProc()
	
	//referência registros C181 - segunda análise: Protheus
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       FT_CSTPIS                as FT_CSTPIS
		      ,ROUND(SUM(
		         CASE FT_AGREG
		         WHEN 'I' THEN
		           FT_TOTAL+FT_VALICM
		         ELSE
		           FT_TOTAL
		         END
		       ),2)                     as FT_TOTAL
		      ,ROUND(SUM(FT_BASEPIS),2) as FT_BASEPIS
		      ,ROUND(SUM(FT_VALPIS),2)  as FT_VALPIS
		FROM %table:SFT% SFT
		LEFT JOIN %table:SF3% SF3
		ON  SF3.%notDel%
		AND F3_FILIAL  = %xFilial:SF3%
		AND F3_NFISCAL = FT_NFISCAL
		AND F3_SERIE   = FT_SERIE
		AND F3_CLIEFOR = FT_CLIEFOR
		AND F3_LOJA    = FT_LOJA
		AND F3_CFO     = FT_CFOP
		AND F3_TIPO    = FT_TIPO
		AND F3_IDENTFT = FT_IDENTF3
		WHERE SFT.%notDel%
		  AND FT_FILIAL = %xFilial:SFT%
		  AND (
		    (
		          LEN(FT_DTCANC) = 0
		      AND FT_OBSERV NOT LIKE '%INUTIL%'
		      AND FT_OBSERV NOT LIKE '%CANCEL%'
		    ) OR (
		          LEN(FT_DTCANC) > 0
		      AND FT_OBSERV LIKE '%CANCEL%'
		      AND LEFT(FT_DTCANC,6) > %exp:Left(DTOS(dDtFim),6)%
		      AND F3_CODRSEF = '101'
		    )
		  )
		  AND FT_ESPECIE IN ('SPED')
		  AND FT_BASEPIS > 0
		  AND FT_TIPOMOV = 'S'
		  AND FT_TIPO NOT IN ('D')
		  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
		GROUP BY FT_CSTPIS
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->FT_CSTPIS
		aValores := {;
			(cAlias)->FT_TOTAL		,;
			(cAlias)->FT_BASEPIS	,;
			(cAlias)->FT_VALPIS		 ;
		}
		NovoReg(cCST, C181, C181_REF, aValores, COL_PROTHEUS)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
	
	IncProc()
	
	//verificando registros C185 - primeira análise: PVA
	If cRecNo <> ''
		cAlias := GetNextAlias()
		BeginSql Alias cAlias
			SELECT
			       C02                                                as CST_COFINS		/* 02 - CST_COFINS		*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c04,',','.'))), 2) as VL_ITEM		/* 04 - VL_ITEM			*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c06,',','.'))), 2) as VL_BC_COFINS	/* 06 - VL_BC_COFINS	*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c10,',','.'))), 2) as VL_COFINS		/* 10 - VL_COFINS		*/
			FROM %exp:cTab%
			WHERE C01 = 'C185'
			%exp:cRecNo%
			GROUP BY C02 /* 02 - CST_COFINS */
		EndSql
		
		While !(cAlias)->(Eof())
			cCST := (cAlias)->CST_COFINS
			aValores := {;
				(cAlias)->VL_ITEM		,; // 04 - VL_ITEM
				(cAlias)->VL_BC_COFINS	,; // 06 - VL_BC_COFINS
				(cAlias)->VL_COFINS		 ; // 10 - VL_CONFIS
			}
			NovoReg(cCST, C185, C185_REF, aValores, COL_PVA)
			(cAlias)->(dbSkip())
		EndDo
		
		(cAlias)->(dbCloseArea())
	EndIf
	
	IncProc()
	
	//referência registros C185 - segunda análise: Protheus
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       FT_CSTCOF                as FT_CSTCOF
		      ,ROUND(SUM(
		         CASE FT_AGREG
		         WHEN 'I' THEN
		           FT_TOTAL+FT_VALICM
		         ELSE
		           FT_TOTAL
		         END
		       ),2)                     as FT_TOTAL
		      ,ROUND(SUM(FT_BASECOF),2) as FT_BASECOF
		      ,ROUND(SUM(FT_VALCOF),2)  as FT_VALCOF
		FROM %table:SFT% SFT
		LEFT JOIN %table:SF3% SF3
		ON  SF3.%notDel%
		AND F3_FILIAL  = %xFilial:SF3%
		AND F3_NFISCAL = FT_NFISCAL
		AND F3_SERIE   = FT_SERIE
		AND F3_CLIEFOR = FT_CLIEFOR
		AND F3_LOJA    = FT_LOJA
		AND F3_CFO     = FT_CFOP
		AND F3_TIPO    = FT_TIPO
		AND F3_IDENTFT = FT_IDENTF3
		WHERE SFT.%notDel%
		  AND FT_FILIAL = %xFilial:SFT%
		  AND (
		    (
		          LEN(FT_DTCANC) = 0
		      AND FT_OBSERV NOT LIKE '%INUTIL%'
		      AND FT_OBSERV NOT LIKE '%CANCEL%'
		    ) OR (
		          LEN(FT_DTCANC) > 0
		      AND FT_OBSERV LIKE '%CANCEL%'
		      AND LEFT(FT_DTCANC,6) > %exp:Left(DTOS(dDtFim),6)%
		      AND F3_CODRSEF = '101'
		    )
		  )
		  AND FT_ESPECIE IN ('SPED')
		  AND FT_BASECOF > 0
		  AND FT_TIPOMOV = 'S'
		  AND FT_TIPO NOT IN ('D')
		  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
		GROUP BY FT_CSTCOF
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->FT_CSTCOF
		aValores := {;
			(cAlias)->FT_TOTAL		,;
			(cAlias)->FT_BASECOF	,;
			(cAlias)->FT_VALCOF		 ;
		}
		NovoReg(cCST, C185, C185_REF, aValores, COL_PROTHEUS)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
	
	IncProc()
	
	//verificando registros C191 - primeira análise: PVA
	If cRecNo <> ''
		cAlias := GetNextAlias()
		BeginSql Alias cAlias
			SELECT
			       C03                                                as CST_PIS		/* 03 - CST_PIS			*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c05,',','.'))), 2) as VL_ITEM		/* 05 - VL_ITEM			*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c07,',','.'))), 2) as VL_BC_PIS		/* 07 - VL_BC_PIS		*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c11,',','.'))), 2) as VL_PIS			/* 11 - VL_PIS			*/
			FROM %exp:cTab%
			WHERE C01 = 'C191'
			%exp:cRecNo%
			GROUP BY C03 /* 03 - CST_PIS */
		EndSql
		
		While !(cAlias)->(Eof())
			cCST := (cAlias)->CST_PIS
			aValores := {;
				(cAlias)->VL_ITEM		,; // 05 - VL_ITEM
				(cAlias)->VL_BC_PIS		,; // 07 - VL_BC_PIS
				(cAlias)->VL_PIS		 ; // 11 - VL_PIS
			}
			NovoReg(cCST, C191, C191_REF, aValores, COL_PVA)
			(cAlias)->(dbSkip())
		EndDo
		
		(cAlias)->(dbCloseArea())
	EndIf
	
	IncProc()
	
	//referência registros C191 - segunda análise: Protheus
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       FT_CSTPIS                as FT_CSTPIS
		      ,ROUND(SUM(
		         CASE FT_AGREG
		         WHEN 'I' THEN
		           FT_TOTAL+FT_VALICM
		         ELSE
		           FT_TOTAL
		         END
		       ),2)                     as FT_TOTAL
		      ,ROUND(SUM(FT_BASEPIS),2) as FT_BASEPIS
		      ,ROUND(SUM(FT_VALPIS),2)  as FT_VALPIS
		FROM %table:SFT% SFT
		LEFT JOIN %table:SF3% SF3
		ON  SF3.%notDel%
		AND F3_FILIAL  = %xFilial:SF3%
		AND F3_NFISCAL = FT_NFISCAL
		AND F3_SERIE   = FT_SERIE
		AND F3_CLIEFOR = FT_CLIEFOR
		AND F3_LOJA    = FT_LOJA
		AND F3_CFO     = FT_CFOP
		AND F3_TIPO    = FT_TIPO
		AND F3_IDENTFT = FT_IDENTF3
		WHERE SFT.%notDel%
		  AND FT_FILIAL = %xFilial:SFT%
		  AND (
		    (
		          LEN(FT_DTCANC) = 0
		      AND FT_OBSERV NOT LIKE '%INUTIL%'
		      AND FT_OBSERV NOT LIKE '%CANCEL%'
		    ) OR (
		          LEN(FT_DTCANC) > 0
		      AND FT_OBSERV LIKE '%CANCEL%'
		      AND LEFT(FT_DTCANC,6) > %exp:Left(DTOS(dDtFim),6)%
		      AND F3_CODRSEF = '101'
		    )
		  )
		  AND FT_ESPECIE IN ('SPED')
		  AND FT_BASEPIS > 0
		  AND (
		    FT_TIPOMOV = 'E'
		    OR (
		      FT_TIPOMOV = 'S'
		      AND FT_TIPO = 'D'
		    )
		  )
		  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
		GROUP BY FT_CSTPIS
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->FT_CSTPIS
		aValores := {;
			(cAlias)->FT_TOTAL		,;
			(cAlias)->FT_BASEPIS	,;
			(cAlias)->FT_VALPIS		 ;
		}
		NovoReg(cCST, C191, C191_REF, aValores, COL_PROTHEUS)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
	
	IncProc()
	
	//verificando registros C195 - primeira análise: PVA
	If cRecNo <> ''
		cAlias := GetNextAlias()
		BeginSql Alias cAlias
			SELECT
			       C03                                                as CST_COFINS		/* 03 - CST_COFINS		*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c05,',','.'))), 2) as VL_ITEM		/* 05 - VL_ITEM			*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c07,',','.'))), 2) as VL_BC_COFINS	/* 07 - VL_BC_COFINS	*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c11,',','.'))), 2) as VL_COFINS		/* 11 - VL_COFINS		*/
			FROM %exp:cTab%
			WHERE C01 = 'C195'
			%exp:cRecNo%
			GROUP BY C03 /* 03 - CST_COFINS */
		EndSql
		
		While !(cAlias)->(Eof())
			cCST := (cAlias)->CST_COFINS
			aValores := {;
				(cAlias)->VL_ITEM		,; // 05 - VL_ITEM
				(cAlias)->VL_BC_COFINS	,; // 07 - VL_BC_COFINS
				(cAlias)->VL_COFINS		 ; // 11 - VL_CONFIS
			}
			NovoReg(cCST, C195, C195_REF, aValores, COL_PVA)
			(cAlias)->(dbSkip())
		EndDo
		
		(cAlias)->(dbCloseArea())
	EndIf
	
	IncProc()
	
	//referência registros C195 - segunda análise: Protheus
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       FT_CSTCOF                as FT_CSTCOF
		      ,ROUND(SUM(
		         CASE FT_AGREG
		         WHEN 'I' THEN
		           FT_TOTAL+FT_VALICM
		         ELSE
		           FT_TOTAL
		         END
		       ),2)                     as FT_TOTAL
		      ,ROUND(SUM(FT_BASECOF),2) as FT_BASECOF
		      ,ROUND(SUM(FT_VALCOF),2)  as FT_VALCOF
		FROM %table:SFT% SFT
		LEFT JOIN %table:SF3% SF3
		ON  SF3.%notDel%
		AND F3_FILIAL  = %xFilial:SF3%
		AND F3_NFISCAL = FT_NFISCAL
		AND F3_SERIE   = FT_SERIE
		AND F3_CLIEFOR = FT_CLIEFOR
		AND F3_LOJA    = FT_LOJA
		AND F3_CFO     = FT_CFOP
		AND F3_TIPO    = FT_TIPO
		AND F3_IDENTFT = FT_IDENTF3
		WHERE SFT.%notDel%
		  AND FT_FILIAL = %xFilial:SFT%
		  AND (
		    (
		          LEN(FT_DTCANC) = 0
		      AND FT_OBSERV NOT LIKE '%INUTIL%'
		      AND FT_OBSERV NOT LIKE '%CANCEL%'
		    ) OR (
		          LEN(FT_DTCANC) > 0
		      AND FT_OBSERV LIKE '%CANCEL%'
		      AND LEFT(FT_DTCANC,6) > %exp:Left(DTOS(dDtFim),6)%
		      AND F3_CODRSEF = '101'
		    )
		  )
		  AND FT_ESPECIE IN ('SPED')
		  AND FT_BASECOF > 0
		  AND (
		    FT_TIPOMOV = 'E'
		    OR (
		      FT_TIPOMOV = 'S'
		      AND FT_TIPO = 'D'
		    )
		  )
		  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
		GROUP BY FT_CSTCOF
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->FT_CSTCOF
		aValores := {;
			(cAlias)->FT_TOTAL		,;
			(cAlias)->FT_BASECOF	,;
			(cAlias)->FT_VALCOF		 ;
		}
		NovoReg(cCST, C195, C195_REF, aValores, COL_PROTHEUS)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
	
	IncProc()
	
	//verificando registros C491 - primeira análise: PVA
	If cRecNo <> ''
		cAlias := GetNextAlias()
		BeginSql Alias cAlias
			SELECT
			       C03                                                as CST_PIS		/* 03 - CST_PIS			*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c05,',','.'))), 2) as VL_ITEM		/* 05 - VL_ITEM			*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c06,',','.'))), 2) as VL_BC_PIS		/* 06 - VL_BC_PIS		*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c10,',','.'))), 2) as VL_PIS			/* 10 - VL_PIS			*/
			FROM %exp:cTab%
			WHERE C01 = 'C491'
			%exp:cRecNo%
			GROUP BY C03 /* 03 - CST_PIS */
		EndSql
		
		While !(cAlias)->(Eof())
			cCST := (cAlias)->CST_PIS
			aValores := {;
				(cAlias)->VL_ITEM		,; // 05 - VL_ITEM
				(cAlias)->VL_BC_PIS		,; // 06 - VL_BC_PIS
				(cAlias)->VL_PIS		 ; // 10 - VL_PIS
			}
			NovoReg(cCST, C491, C491_REF, aValores, COL_PVA)
			(cAlias)->(dbSkip())
		EndDo
		
		(cAlias)->(dbCloseArea())
	EndIf
	
	IncProc()
	
	//referência registros C491 - segunda análise: Protheus
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       FT_CSTPIS                as FT_CSTPIS
		      ,ROUND(SUM(
		         CASE FT_AGREG
		         WHEN 'I' THEN
		           FT_TOTAL+FT_VALICM
		         ELSE
		           FT_TOTAL
		         END
		       ),2)                     as FT_TOTAL
		      ,ROUND(SUM(FT_BASEPIS),2) as FT_BASEPIS
		      ,ROUND(SUM(FT_VALPIS),2)  as FT_VALPIS
		FROM %table:SFT%
		WHERE %notDel%
		  AND FT_FILIAL = %xFilial:SFT%
		  AND LEN(FT_DTCANC) = 0
		  AND FT_OBSERV NOT LIKE '%INUTIL%'
		  AND FT_OBSERV NOT LIKE '%CANCEL%'
		  AND FT_ESPECIE IN ('CF')
		  AND FT_BASEPIS > 0
		  AND FT_TIPOMOV = 'S'
		  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
		GROUP BY FT_CSTPIS
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->FT_CSTPIS
		aValores := {;
			(cAlias)->FT_TOTAL		,;
			(cAlias)->FT_BASEPIS	,;
			(cAlias)->FT_VALPIS		 ;
		}
		NovoReg(cCST, C491, C491_REF, aValores, COL_PROTHEUS)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
	
	IncProc()
	
	//verificando registros C495 - primeira análise: PVA
	If cRecNo <> ''
		cAlias := GetNextAlias()
		BeginSql Alias cAlias
			SELECT
			       C03                                                as CST_COFINS		/* 03 - CST_COFINS		*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c05,',','.'))), 2) as VL_ITEM		/* 05 - VL_ITEM			*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c06,',','.'))), 2) as VL_BC_COFINS	/* 06 - VL_BC_COFINS	*/
			      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c10,',','.'))), 2) as VL_COFINS		/* 10 - VL_COFINS		*/
			FROM %exp:cTab%
			WHERE C01 = 'C495'
			%exp:cRecNo%
			GROUP BY C03 /* 03 - CST_COFINS */
		EndSql
		
		While !(cAlias)->(Eof())
			cCST := (cAlias)->CST_COFINS
			aValores := {;
				(cAlias)->VL_ITEM		,; // 05 - VL_ITEM
				(cAlias)->VL_BC_COFINS	,; // 06 - VL_BC_COFINS
				(cAlias)->VL_COFINS		 ; // 10 - VL_CONFIS
			}
			NovoReg(cCST, C495, C495_REF, aValores, COL_PVA)
			(cAlias)->(dbSkip())
		EndDo
		
		(cAlias)->(dbCloseArea())
	EndIf
	
	IncProc()
	
	//referência registros C495 - segunda análise: Protheus
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       FT_CSTCOF                as FT_CSTCOF
		      ,ROUND(SUM(
		         CASE FT_AGREG
		         WHEN 'I' THEN
		           FT_TOTAL+FT_VALICM
		         ELSE
		           FT_TOTAL
		         END
		       ),2)                     as FT_TOTAL
		      ,ROUND(SUM(FT_BASECOF),2) as FT_BASECOF
		      ,ROUND(SUM(FT_VALCOF),2)  as FT_VALCOF
		FROM %table:SFT%
		WHERE %notDel%
		  AND FT_FILIAL = %xFilial:SFT%
		  AND LEN(FT_DTCANC) = 0
		  AND FT_OBSERV NOT LIKE '%INUTIL%'
		  AND FT_OBSERV NOT LIKE '%CANCEL%'
		  AND FT_ESPECIE IN ('CF')
		  AND FT_BASECOF > 0
		  AND FT_TIPOMOV = 'S'
		  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
		GROUP BY FT_CSTCOF
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->FT_CSTCOF
		aValores := {;
			(cAlias)->FT_TOTAL		,;
			(cAlias)->FT_BASECOF	,;
			(cAlias)->FT_VALCOF		 ;
		}
		NovoReg(cCST, C495, C495_REF, aValores, COL_PROTHEUS)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
	
	IncProc()
Else
	//individualizado
	//apenas aumentando barra de progresso
	For nI := 1 to 12
		IncProc()
	Next nI
EndIf

//verificando registros C501 - primeira análise: PVA
If cRecNo <> ''
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       C02                                                as CST_PIS		/* 02 - CST_PIS			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c03,',','.'))), 2) as VL_ITEM		/* 03 - VL_ITEM			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c05,',','.'))), 2) as VL_BC_PIS		/* 05 - VL_BC_PIS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c07,',','.'))), 2) as VL_PIS			/* 07 - VL_PIS			*/
		FROM %exp:cTab%
		WHERE C01 = 'C501'
		%exp:cRecNo%
		GROUP BY C02 /* 02 - CST_PIS */
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->CST_PIS
		aValores := {;
			(cAlias)->VL_ITEM		,; // 03 - VL_ITEM
			(cAlias)->VL_BC_PIS		,; // 05 - VL_BC_PIS
			(cAlias)->VL_PIS		 ; // 07 - VL_PIS
		}
		NovoReg(cCST, C501, C501_REF, aValores, COL_PVA)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
EndIf

IncProc()

//referência registros C501 - segunda análise: Protheus
cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT
	       FT_CSTPIS                as FT_CSTPIS
	      ,ROUND(SUM(
	         CASE FT_AGREG
	         WHEN 'I' THEN
	           FT_TOTAL+FT_VALICM
	         ELSE
	           FT_TOTAL
	         END
	       ),2)                     as FT_TOTAL
	      ,ROUND(SUM(FT_BASEPIS),2) as FT_BASEPIS
	      ,ROUND(SUM(FT_VALPIS),2)  as FT_VALPIS
	FROM %table:SFT%
	WHERE %notDel%
	  AND FT_FILIAL = %xFilial:SFT%
	  AND LEN(FT_DTCANC) = 0
	  AND FT_OBSERV NOT LIKE '%INUTIL%'
	  AND FT_OBSERV NOT LIKE '%CANCEL%'
	  AND FT_ESPECIE IN ('NFCEE','NFCFG','NFFA')
	  AND FT_BASEPIS > 0
	  AND FT_TIPOMOV = 'E'
	  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
	GROUP BY FT_CSTPIS
EndSql

While !(cAlias)->(Eof())
	cCST := (cAlias)->FT_CSTPIS
	aValores := {;
		(cAlias)->FT_TOTAL		,;
		(cAlias)->FT_BASEPIS	,;
		(cAlias)->FT_VALPIS		 ;
	}
	NovoReg(cCST, C501, C501_REF, aValores, COL_PROTHEUS)
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

IncProc()

//verificando registros C505 - primeira análise: PVA
If cRecNo <> ''
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       C02                                                as CST_COFINS		/* 02 - CST_COFINS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c03,',','.'))), 2) as VL_ITEM		/* 03 - VL_ITEM			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c05,',','.'))), 2) as VL_BC_COFINS	/* 05 - VL_BC_COFINS	*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c07,',','.'))), 2) as VL_COFINS		/* 07 - VL_COFINS		*/
		FROM %exp:cTab%
		WHERE C01 = 'C505'
		%exp:cRecNo%
		GROUP BY C02 /* 02 - CST_COFINS */
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->CST_COFINS
		aValores := {;
			(cAlias)->VL_ITEM		,; // 05 - VL_ITEM
			(cAlias)->VL_BC_COFINS	,; // 06 - VL_BC_COFINS
			(cAlias)->VL_COFINS		 ; // 10 - VL_CONFIS
		}
		NovoReg(cCST, C505, C505_REF, aValores, COL_PVA)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
EndIf

IncProc()

//referência registros C505 - segunda análise: Protheus
cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT
	       FT_CSTCOF                as FT_CSTCOF
	      ,ROUND(SUM(
	         CASE FT_AGREG
	         WHEN 'I' THEN
	           FT_TOTAL+FT_VALICM
	         ELSE
	           FT_TOTAL
	         END
	       ),2)                     as FT_TOTAL
	      ,ROUND(SUM(FT_BASECOF),2) as FT_BASECOF
	      ,ROUND(SUM(FT_VALCOF),2)  as FT_VALCOF
	FROM %table:SFT%
	WHERE %notDel%
	  AND FT_FILIAL = %xFilial:SFT%
	  AND LEN(FT_DTCANC) = 0
	  AND FT_OBSERV NOT LIKE '%INUTIL%'
	  AND FT_OBSERV NOT LIKE '%CANCEL%'
	  AND FT_ESPECIE IN ('NFCEE','NFCFG','NFFA')
	  AND FT_BASECOF > 0
	  AND FT_TIPOMOV = 'E'
	  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
	GROUP BY FT_CSTCOF
EndSql

While !(cAlias)->(Eof())
	cCST := (cAlias)->FT_CSTCOF
	aValores := {;
		(cAlias)->FT_TOTAL		,;
		(cAlias)->FT_BASECOF	,;
		(cAlias)->FT_VALCOF		 ;
	}
	NovoReg(cCST, C505, C505_REF, aValores, COL_PROTHEUS)
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

IncProc()

Return Nil

/* ------------------- */

/*/{Protheus.doc} Bloco D
Analisa os registros dos blocos Dxxx

@author Thieres Tembra
@since 21/06/2014
@version 1.0
@param dDtIni, data, Data inicial do período a ser analisado
@param dDtFim, data, Data final do período a ser analisado
@return nulo Nada é retornado
/*/
Static Function BlocoD(dDtIni, dDtFim)

Local cAlias
Local cTab := '%' + _cMyTab + '%'
Local cRecNo, cCST
Local aValores
Local cEspecie
Local n010Atu := 0
Local n010Nxt := 0

ProcRegua(13)

//agrupamento somente pela CST do PIS pois conforme a validação do PVA:
//	O CST referente ao PIS/PASEP deve ser igual ao CST referente à COFINS,
//	assim como o Valor da base de cálculo do PIS/PASEP deve ser igual ao
//	Valor da base de cálculo da COFINS.

//verificando registros D010 - primeira análise: PVA
cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT
	      C02        as CNPJ
	     ,R_E_C_N_O_ as RECNUM
	FROM %exp:cTab%
	WHERE C01 = 'D010'
EndSql

While !(cAlias)->(Eof())
	If n010Atu <> 0
		n010Nxt := (cAlias)->RECNUM
		Exit
	EndIf
	If AllTrim((cAlias)->CNPJ) == AllTrim(SM0->M0_CGC)
		n010Atu := (cAlias)->RECNUM
	EndIf
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

IncProc()

If n010Atu <> 0 .and. n010Nxt <> 0
	cRecNo := '%  AND R_E_C_N_O_ BETWEEN ' + cValToChar(n010Atu) + ' AND ' + cValToChar(n010Nxt) + '%'
ElseIf n010Atu <> 0 .and. n010Nxt == 0
	cRecNo := '%  AND R_E_C_N_O_ > ' + cValToChar(n010Atu) + '%'
Else
	cRecNo := ''
EndIf

//verificando registros D101 - primeira análise: PVA
If cRecNo <> ''
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       C04                                                as CST_PIS		/* 04 - CST_PIS			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c03,',','.'))), 2) as VL_ITEM		/* 03 - VL_ITEM			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c06,',','.'))), 2) as VL_BC_PIS		/* 06 - VL_BC_PIS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c08,',','.'))), 2) as VL_PIS			/* 08 - VL_PIS			*/
		FROM %exp:cTab%
		WHERE C01 = 'D101'
		%exp:cRecNo%
		GROUP BY C04 /* 04 - CST_PIS */
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->CST_PIS
		aValores := {;
			(cAlias)->VL_ITEM		,; // 03 - VL_ITEM
			(cAlias)->VL_BC_PIS		,; // 06 - VL_BC_PIS
			(cAlias)->VL_PIS		 ; // 08 - VL_PIS
		}
		NovoReg(cCST, D101, D101_REF, aValores, COL_PVA)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
EndIf

IncProc()

//referência registros D101 - segunda análise: Protheus
cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT
	       FT_CSTPIS                as FT_CSTPIS
	      ,ROUND(SUM(
	         CASE FT_AGREG
	         WHEN 'I' THEN
	           FT_TOTAL+FT_VALICM
	         ELSE
	           FT_TOTAL
	         END
	       ),2)                     as FT_TOTAL
	      ,ROUND(SUM(FT_BASEPIS),2) as FT_BASEPIS
	      ,ROUND(SUM(FT_VALPIS),2)  as FT_VALPIS
	FROM %table:SFT%
	WHERE %notDel%
	  AND FT_FILIAL = %xFilial:SFT%
	  AND LEN(FT_DTCANC) = 0
	  AND FT_OBSERV NOT LIKE '%INUTIL%'
	  AND FT_OBSERV NOT LIKE '%CANCEL%'
	  AND FT_ESPECIE IN ('NFST','CTR','CTA','CA','CTF','CTE')
	  AND FT_BASEPIS > 0
	  AND FT_TIPOMOV = 'E'
	  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
	GROUP BY FT_CSTPIS
EndSql

While !(cAlias)->(Eof())
	cCST := (cAlias)->FT_CSTPIS
	aValores := {;
		(cAlias)->FT_TOTAL		,;
		(cAlias)->FT_BASEPIS	,;
		(cAlias)->FT_VALPIS		 ;
	}
	NovoReg(cCST, D101, D101_REF, aValores, COL_PROTHEUS)
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

IncProc()

//verificando registros D105 - primeira análise: PVA
If cRecNo <> ''
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       C04                                                as CST_COFINS		/* 04 - CST_COFINS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c03,',','.'))), 2) as VL_ITEM		/* 03 - VL_ITEM			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c06,',','.'))), 2) as VL_BC_COFINS	/* 06 - VL_BC_COFINS	*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c08,',','.'))), 2) as VL_COFINS		/* 08 - VL_COFINS		*/
		FROM %exp:cTab%
		WHERE C01 = 'D105'
		%exp:cRecNo%
		GROUP BY C04 /* 04 - CST_COFINS */
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->CST_COFINS
		aValores := {;
			(cAlias)->VL_ITEM		,; // 03 - VL_ITEM
			(cAlias)->VL_BC_COFINS	,; // 06 - VL_BC_COFINS
			(cAlias)->VL_COFINS		 ; // 08 - VL_CONFIS
		}
		NovoReg(cCST, D105, D105_REF, aValores, COL_PVA)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
EndIf

IncProc()

//referência registros D105 - segunda análise: Protheus
cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT
	       FT_CSTCOF                as FT_CSTCOF
	      ,ROUND(SUM(
	         CASE FT_AGREG
	         WHEN 'I' THEN
	           FT_TOTAL+FT_VALICM
	         ELSE
	           FT_TOTAL
	         END
	       ),2)                     as FT_TOTAL
	      ,ROUND(SUM(FT_BASECOF),2) as FT_BASECOF
	      ,ROUND(SUM(FT_VALCOF),2)  as FT_VALCOF
	FROM %table:SFT%
	WHERE %notDel%
	  AND FT_FILIAL = %xFilial:SFT%
	  AND LEN(FT_DTCANC) = 0
	  AND FT_OBSERV NOT LIKE '%INUTIL%'
	  AND FT_OBSERV NOT LIKE '%CANCEL%'
	  AND FT_ESPECIE IN ('NFST','CTR','CTA','CA','CTF','CTE')
	  AND FT_BASECOF > 0
	  AND FT_TIPOMOV = 'E'
	  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
	GROUP BY FT_CSTCOF
EndSql

While !(cAlias)->(Eof())
	cCST := (cAlias)->FT_CSTCOF
	aValores := {;
		(cAlias)->FT_TOTAL		,;
		(cAlias)->FT_BASECOF	,;
		(cAlias)->FT_VALCOF		 ;
	}
	NovoReg(cCST, D105, D105_REF, aValores, COL_PROTHEUS)
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

IncProc()

//verificando registros D201 - primeira análise: PVA
If cRecNo <> ''
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       C02                                                as CST_PIS		/* 02 - CST_PIS			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c03,',','.'))), 2) as VL_ITEM		/* 03 - VL_ITEM			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c04,',','.'))), 2) as VL_BC_PIS		/* 04 - VL_BC_PIS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c06,',','.'))), 2) as VL_PIS			/* 06 - VL_PIS			*/
		FROM %exp:cTab%
		WHERE C01 = 'D201'
		%exp:cRecNo%
		GROUP BY C02 /* 02 - CST_PIS */
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->CST_PIS
		aValores := {;
			(cAlias)->VL_ITEM		,; // 03 - VL_ITEM
			(cAlias)->VL_BC_PIS		,; // 04 - VL_BC_PIS
			(cAlias)->VL_PIS		 ; // 06 - VL_PIS
		}
		NovoReg(cCST, D201, D201_REF, aValores, COL_PVA)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
EndIf

IncProc()

//referência registros D201 - segunda análise: Protheus
cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT
	       FT_CSTPIS                as FT_CSTPIS
	      ,ROUND(SUM(
	         CASE FT_AGREG
	         WHEN 'I' THEN
	           FT_TOTAL+FT_VALICM
	         ELSE
	           FT_TOTAL
	         END
	       ),2)                     as FT_TOTAL
	      ,ROUND(SUM(FT_BASEPIS),2) as FT_BASEPIS
	      ,ROUND(SUM(FT_VALPIS),2)  as FT_VALPIS
	FROM %table:SFT% SFT
	LEFT JOIN %table:SF3% SF3
	ON  SF3.%notDel%
	AND F3_FILIAL  = %xFilial:SF3%
	AND F3_NFISCAL = FT_NFISCAL
	AND F3_SERIE   = FT_SERIE
	AND F3_CLIEFOR = FT_CLIEFOR
	AND F3_LOJA    = FT_LOJA
	AND F3_CFO     = FT_CFOP
	AND F3_TIPO    = FT_TIPO
	AND F3_IDENTFT = FT_IDENTF3
	WHERE SFT.%notDel%
	  AND FT_FILIAL = %xFilial:SFT%
	  AND (
	    (
	          LEN(FT_DTCANC) = 0
	      AND FT_OBSERV NOT LIKE '%INUTIL%'
	      AND FT_OBSERV NOT LIKE '%CANCEL%'
	    ) OR (
	          LEN(FT_DTCANC) > 0
	      AND FT_OBSERV LIKE '%CANCEL%'
	      AND LEFT(FT_DTCANC,6) > %exp:Left(DTOS(dDtFim),6)%
	      AND F3_CODRSEF = '101'
	    )
	  )
	  AND FT_ESPECIE IN ('NFST','CTR','CTA','CA','CTF','CTE')
	  AND FT_BASEPIS > 0
	  AND FT_TIPOMOV = 'S'
	  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
	GROUP BY FT_CSTPIS
EndSql

While !(cAlias)->(Eof())
	cCST := (cAlias)->FT_CSTPIS
	aValores := {;
		(cAlias)->FT_TOTAL		,;
		(cAlias)->FT_BASEPIS	,;
		(cAlias)->FT_VALPIS		 ;
	}
	NovoReg(cCST, D201, D201_REF, aValores, COL_PROTHEUS)
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

IncProc()

//verificando registros D205 - primeira análise: PVA
If cRecNo <> ''
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       C02                                                as CST_COFINS		/* 02 - CST_COFINS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c03,',','.'))), 2) as VL_ITEM		/* 03 - VL_ITEM			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c04,',','.'))), 2) as VL_BC_COFINS	/* 04 - VL_BC_COFINS	*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c06,',','.'))), 2) as VL_COFINS		/* 06 - VL_COFINS		*/
		FROM %exp:cTab%
		WHERE C01 = 'D205'
		%exp:cRecNo%
		GROUP BY C02 /* 02 - CST_COFINS */
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->CST_COFINS
		aValores := {;
			(cAlias)->VL_ITEM		,; // 03 - VL_ITEM
			(cAlias)->VL_BC_COFINS	,; // 04 - VL_BC_COFINS
			(cAlias)->VL_COFINS		 ; // 06 - VL_CONFIS
		}
		NovoReg(cCST, D205, D205_REF, aValores, COL_PVA)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
EndIf

IncProc()

//referência registros D205 - segunda análise: Protheus
cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT
	       FT_CSTCOF                as FT_CSTCOF
	      ,ROUND(SUM(
	         CASE FT_AGREG
	         WHEN 'I' THEN
	           FT_TOTAL+FT_VALICM
	         ELSE
	           FT_TOTAL
	         END
	       ),2)                     as FT_TOTAL
	      ,ROUND(SUM(FT_BASECOF),2) as FT_BASECOF
	      ,ROUND(SUM(FT_VALCOF),2)  as FT_VALCOF
	FROM %table:SFT% SFT
	LEFT JOIN %table:SF3% SF3
	ON  SF3.%notDel%
	AND F3_FILIAL  = %xFilial:SF3%
	AND F3_NFISCAL = FT_NFISCAL
	AND F3_SERIE   = FT_SERIE
	AND F3_CLIEFOR = FT_CLIEFOR
	AND F3_LOJA    = FT_LOJA
	AND F3_CFO     = FT_CFOP
	AND F3_TIPO    = FT_TIPO
	AND F3_IDENTFT = FT_IDENTF3
	WHERE SFT.%notDel%
	  AND FT_FILIAL = %xFilial:SFT%
	  AND (
	    (
	          LEN(FT_DTCANC) = 0
	      AND FT_OBSERV NOT LIKE '%INUTIL%'
	      AND FT_OBSERV NOT LIKE '%CANCEL%'
	    ) OR (
	          LEN(FT_DTCANC) > 0
	      AND FT_OBSERV LIKE '%CANCEL%'
	      AND LEFT(FT_DTCANC,6) > %exp:Left(DTOS(dDtFim),6)%
	      AND F3_CODRSEF = '101'
	    )
	  )
	  AND FT_ESPECIE IN ('NFST','CTR','CTA','CA','CTF','CTE')
	  AND FT_BASECOF > 0
	  AND FT_TIPOMOV = 'S'
	  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
	GROUP BY FT_CSTCOF
EndSql

While !(cAlias)->(Eof())
	cCST := (cAlias)->FT_CSTCOF
	aValores := {;
		(cAlias)->FT_TOTAL		,;
		(cAlias)->FT_BASECOF	,;
		(cAlias)->FT_VALCOF		 ;
	}
	NovoReg(cCST, D205, D205_REF, aValores, COL_PROTHEUS)
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

IncProc()

//verificando registros D501 - primeira análise: PVA
If cRecNo <> ''
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       C02                                                as CST_PIS		/* 02 - CST_PIS			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c03,',','.'))), 2) as VL_ITEM		/* 03 - VL_ITEM			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c05,',','.'))), 2) as VL_BC_PIS		/* 05 - VL_BC_PIS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c07,',','.'))), 2) as VL_PIS			/* 07 - VL_PIS			*/
		FROM %exp:cTab%
		WHERE C01 = 'D501'
		%exp:cRecNo%
		GROUP BY C02 /* 02 - CST_PIS */
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->CST_PIS
		aValores := {;
			(cAlias)->VL_ITEM		,; // 03 - VL_ITEM
			(cAlias)->VL_BC_PIS		,; // 05 - VL_BC_PIS
			(cAlias)->VL_PIS		 ; // 07 - VL_PIS
		}
		NovoReg(cCST, D501, D501_REF, aValores, COL_PVA)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
EndIf

IncProc()

//referência registros D501 - segunda análise: Protheus
cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT
	       FT_CSTPIS                as FT_CSTPIS
	      ,ROUND(SUM(
	         CASE FT_AGREG
	         WHEN 'I' THEN
	           FT_TOTAL+FT_VALICM
	         ELSE
	           FT_TOTAL
	         END
	       ),2)                     as FT_TOTAL
	      ,ROUND(SUM(FT_BASEPIS),2) as FT_BASEPIS
	      ,ROUND(SUM(FT_VALPIS),2)  as FT_VALPIS
	FROM %table:SFT%
	WHERE %notDel%
	  AND FT_FILIAL = %xFilial:SFT%
	  AND LEN(FT_DTCANC) = 0
	  AND FT_OBSERV NOT LIKE '%INUTIL%'
	  AND FT_OBSERV NOT LIKE '%CANCEL%'
	  AND FT_ESPECIE IN ('NTSC','NTST')
	  AND FT_BASEPIS > 0
	  AND FT_TIPOMOV = 'E'
	  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
	GROUP BY FT_CSTPIS
EndSql

While !(cAlias)->(Eof())
	cCST := (cAlias)->FT_CSTPIS
	aValores := {;
		(cAlias)->FT_TOTAL		,;
		(cAlias)->FT_BASEPIS	,;
		(cAlias)->FT_VALPIS		 ;
	}
	NovoReg(cCST, D501, D501_REF, aValores, COL_PROTHEUS)
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

IncProc()

//verificando registros D505 - primeira análise: PVA
If cRecNo <> ''
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       C02                                                as CST_COFINS		/* 02 - CST_COFINS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c03,',','.'))), 2) as VL_ITEM		/* 03 - VL_ITEM			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c05,',','.'))), 2) as VL_BC_COFINS	/* 05 - VL_BC_COFINS	*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c07,',','.'))), 2) as VL_COFINS		/* 07 - VL_COFINS		*/
		FROM %exp:cTab%
		WHERE C01 = 'D505'
		%exp:cRecNo%
		GROUP BY C02 /* 02 - CST_COFINS */
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->CST_COFINS
		aValores := {;
			(cAlias)->VL_ITEM		,; // 03 - VL_ITEM
			(cAlias)->VL_BC_COFINS	,; // 05 - VL_BC_COFINS
			(cAlias)->VL_COFINS		 ; // 07 - VL_CONFIS
		}
		NovoReg(cCST, D505, D505_REF, aValores, COL_PVA)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
EndIf

IncProc()

//referência registros D505 - segunda análise: Protheus
cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT
	       FT_CSTCOF                as FT_CSTCOF
	      ,ROUND(SUM(
	         CASE FT_AGREG
	         WHEN 'I' THEN
	           FT_TOTAL+FT_VALICM
	         ELSE
	           FT_TOTAL
	         END
	       ),2)                     as FT_TOTAL
	      ,ROUND(SUM(FT_BASECOF),2) as FT_BASECOF
	      ,ROUND(SUM(FT_VALCOF),2)  as FT_VALCOF
	FROM %table:SFT%
	WHERE %notDel%
	  AND FT_FILIAL = %xFilial:SFT%
	  AND LEN(FT_DTCANC) = 0
	  AND FT_OBSERV NOT LIKE '%INUTIL%'
	  AND FT_OBSERV NOT LIKE '%CANCEL%'
	  AND FT_ESPECIE IN ('NTSC','NTST')
	  AND FT_BASECOF > 0
	  AND FT_TIPOMOV = 'E'
	  AND FT_ENTRADA BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
	GROUP BY FT_CSTCOF
EndSql

While !(cAlias)->(Eof())
	cCST := (cAlias)->FT_CSTCOF
	aValores := {;
		(cAlias)->FT_TOTAL		,;
		(cAlias)->FT_BASECOF	,;
		(cAlias)->FT_VALCOF		 ;
	}
	NovoReg(cCST, D505, D505_REF, aValores, COL_PROTHEUS)
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

IncProc()

Return Nil

/* ------------------- */

/*/{Protheus.doc} Bloco F
Analisa os registros dos blocos Fxxx

@author Thieres Tembra
@since 21/06/2014
@version 1.0
@param dDtIni, data, Data inicial do período a ser analisado
@param dDtFim, data, Data final do período a ser analisado
@return nulo Nada é retornado
/*/
Static Function BlocoF(dDtIni, dDtFim)

Local cAlias
Local cTab := '%' + _cMyTab + '%'
Local cRecNo, cCST
Local aValores
Local cEspecie
Local n010Atu := 0
Local n010Nxt := 0
Local nBasePis, nBaseCof, nValPis, nValCof
Local aRegs
Local aResult
Local aCST
Local aProcItem
Local cCST
Local nPos, nI, nMax, nVlr
Local aVlrCST := {}
Local cCSTCRED	:= '50/51/52/53/54/55/56/60/61/62/63/64/65/66/67'

ProcRegua(7)

//agrupamento somente pela CST do PIS pois conforme a validação do PVA:
//	O CST referente ao PIS/PASEP deve ser igual ao CST referente à COFINS,
//	assim como o Valor da base de cálculo do PIS/PASEP deve ser igual ao
//	Valor da base de cálculo da COFINS.

//verificando registros F010 - primeira análise: PVA
cAlias := GetNextAlias()
BeginSql Alias cAlias
	SELECT
	      C02        as CNPJ
	     ,R_E_C_N_O_ as RECNUM
	FROM %exp:cTab%
	WHERE C01 = 'F010'
EndSql

While !(cAlias)->(Eof())
	If n010Atu <> 0
		n010Nxt := (cAlias)->RECNUM
		Exit
	EndIf
	If AllTrim((cAlias)->CNPJ) == AllTrim(SM0->M0_CGC)
		n010Atu := (cAlias)->RECNUM
	EndIf
	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())

IncProc()

If n010Atu <> 0 .and. n010Nxt <> 0
	cRecNo := '%  AND R_E_C_N_O_ BETWEEN ' + cValToChar(n010Atu) + ' AND ' + cValToChar(n010Nxt) + '%'
ElseIf n010Atu <> 0 .and. n010Nxt == 0
	cRecNo := '%  AND R_E_C_N_O_ > ' + cValToChar(n010Atu) + '%'
Else
	cRecNo := ''
EndIf

//verificando registros F100 - primeira análise: PVA
If cRecNo <> ''
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       C07                                                as CST_PIS		/* 07 - CST_PIS			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c06,',','.'))), 2) as VL_ITEM		/* 06 - VL_ITEM			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c08,',','.'))), 2) as VL_BC_PIS		/* 08 - VL_BC_PIS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c10,',','.'))), 2) as VL_PIS			/* 10 - VL_PIS			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c12,',','.'))), 2) as VL_BC_COFINS	/* 12 - VL_BC_COFINS	*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(c14,',','.'))), 2) as VL_COFINS		/* 14 - VL_COFINS		*/
		FROM %exp:cTab%
		WHERE C01 = 'F100'
		%exp:cRecNo%
		GROUP BY C07 /* 04 - CST_PIS */
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->CST_PIS
		aValores := {;
			(cAlias)->VL_ITEM		,; // 06 - VL_ITEM
			(cAlias)->VL_BC_PIS		,; // 08 - VL_BC_PIS
			(cAlias)->VL_PIS		,; // 10 - VL_PIS
			(cAlias)->VL_BC_COFINS	,; // 12 - VL_BC_COFINS
			(cAlias)->VL_COFINS		 ; // 14 - VL_COFINS
		}
		NovoReg(cCST, F100, F100_REF, aValores, COL_PVA)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
EndIf

IncProc()

//referência registros F100 - segunda análise: Protheus
If ExistBlock('MyF100')
	//COM MyF100
	//         MyF100(cFil   , dData1, dData2, cFilAte, cFilCST)
	aRegs := U_MyF100(cFilAnt, dDtIni, dDtFim)
	
	nMax := Len(aRegs)
	For nI := 1 to nMax
		cCST := aRegs[nI][04] // 04 - CST
		nVlr := aRegs[nI][06] // 06 - CST
		
		nPos := aScan(aVlrCST, {|x| x[1] == cCST })
		If nPos == 0
			aAdd(aVlrCST, {cCST, nVlr})
		Else
			aVlrCST[nPos][2] += nVlr
		EndIf
	Next nI
	
	nMax := Len(aVlrCST)
	For nI := 1 to nMax
		nBasePis := aVlrCST[nI][2]
		nBaseCof := aVlrCST[nI][2]
		
		nValPis := Round(nBasePis * 1.65 / 100,2)
		nValCof := Round(nBaseCof * 7.60 / 100,2)
		
		cCST := aVlrCST[nI][1]
		aValores := {;
			aVlrCST[nI][2]		,;
			nBasePis			,;
			nValPis				,;
			nBaseCof			,;
			nValCof				 ;
		}
		NovoReg(cCST, F100, F100_REF, aValores, COL_PROTHEUS)
	Next nI
Else
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		      ED_CSTPIS              as ED_CSTPIS
		     ,ED_REDPIS              as ED_REDPIS
		     ,ED_REDCOF              as ED_REDCOF
		     ,ED_PCAPPIS             as ED_PCAPPIS
		     ,ED_PCAPCOF             as ED_PCAPCOF
		     ,ROUND(SUM(E1_VALOR),2) as VALOR
		FROM %table:SE1% SE1
		    ,%table:SED% SED
		WHERE SE1.%notDel%
		  AND SED.%notDel%
		  AND E1_FILIAL = %xFilial:SE1%
		  AND ED_FILIAL = %xFilial:SED%
		  AND ED_CSTPIS <> ''
		  AND E1_EMISSAO BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
		GROUP BY ED_CSTPIS
		        ,ED_REDPIS
		        ,ED_REDCOF
		        ,ED_PCAPPIS
		        ,ED_PCAPCOF
		UNION ALL
		SELECT
		      ED_CSTPIS              as ED_CSTPIS
		     ,ED_REDPIS              as ED_REDPIS
		     ,ED_REDCOF              as ED_REDCOF
		     ,ED_PCAPPIS             as ED_PCAPPIS
		     ,ED_PCAPCOF             as ED_PCAPCOF
		     ,ROUND(SUM(E2_VALOR),2) as VALOR
		FROM %table:SE2% SE2
		    ,%table:SED% SED
		WHERE SE2.%notDel%
		  AND SED.%notDel%
		  AND E2_FILIAL = %xFilial:SE2%
		  AND ED_FILIAL = %xFilial:SED%
		  AND ED_CSTPIS <> ''
		  AND E2_EMISSAO BETWEEN %exp:DTOS(dDtIni)% AND %exp:DTOS(dDtFim)%
		GROUP BY ED_CSTPIS
		        ,ED_REDPIS
		        ,ED_REDCOF
		        ,ED_PCAPPIS
		        ,ED_PCAPCOF
	EndSql
	
	While !(cAlias)->(Eof())
		nBasePis := Round((cAlias)->VALOR * (100-(cAlias)->ED_REDPIS) / 100,2)
		nBaseCof := Round((cAlias)->VALOR * (100-(cAlias)->ED_REDCOF) / 100,2)
		
		nValPis := Round(nBasePis * (cAlias)->ED_PCAPPIS / 100,2)
		nValCof := Round(nBaseCof * (cAlias)->ED_PCAPCOF / 100,2)
		
		cCST := (cAlias)->ED_CSTPIS
		aValores := {;
			(cAlias)->VALOR		,;
			nBasePis			,;
			nValPis				,;
			nBaseCof			,;
			nValCof				 ;
		}
		NovoReg(cCST, F100, F100_REF, aValores, COL_PROTHEUS)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
EndIf

IncProc()

//verificando registros F120 - primeira análise: PVA
If cRecNo <> ''
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       C08                                                as CST_PIS			/* 08 - CST_PIS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(C06,',','.'))), 2) as VL_OPER_DEP	/* 06 - VL_OPER_DEP	*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(C09,',','.'))), 2) as VL_BC_PIS		/* 09 - VL_BC_PIS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(C11,',','.'))), 2) as VL_PIS			/* 11 - VL_PIS			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(C13,',','.'))), 2) as VL_BC_COFINS	/* 13 - VL_BC_COFINS	*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(C15,',','.'))), 2) as VL_COFINS		/* 15 - VL_COFINS		*/
		FROM %exp:cTab%
		WHERE C01 = 'F120'
		%exp:cRecNo%
		GROUP BY C08 /* 08 - CST_PIS */
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->CST_PIS
		aValores := {;
			(cAlias)->VL_OPER_DEP		,; // 06 - VL_OPER_DEP
			(cAlias)->VL_BC_PIS		,; // 09 - VL_BC_PIS
			(cAlias)->VL_PIS		,; // 11 - VL_PIS
			(cAlias)->VL_BC_COFINS	,; // 13 - VL_BC_COFINS
			(cAlias)->VL_COFINS		 ; // 15 - VL_COFINS
		}
		NovoReg(cCST, F120, F120_REF, aValores, COL_PVA)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
EndIf

IncProc()

//referência registros F120 - segunda análise: Protheus
cAlias := GetNextAlias()
aProcItem := {'          ','ZZZZZZZZZZ',CTOD(''),dDtFim,cAlias}
aResult := DeprecAtivo(dDtIni,aProcItem[4],.T.,.F.,aProcItem,,.F.,'09/11',SM0->M0_CODFIL,.F.)

If !(cAlias)->(Eof()) .and. (cAlias)->(FieldPos('NATBCCRED')) > 0 .and. Len(aResult) > 0
	cAlias := aResult[1,2]
	aCST := {}
	
	While !(cAlias)->(Eof())
		If (cAlias)->CSTPIS $ cCSTCRED .or. (cAlias)->CSTCOFINS $ cCSTCRED
			nPos := aScan(aCST, {|x| x[1] == (cAlias)->CSTPIS })
			If nPos <> 0
				aCST[nPos][2] += (cAlias)->VRET
				aCST[nPos][3] += (cAlias)->VLRBCPIS
				aCST[nPos][4] += (cAlias)->VLRPIS
				aCST[nPos][5] += (cAlias)->VLRBCCOFIN
				aCST[nPos][6] += (cAlias)->VLRCOFINS
			Else
				aAdd(aCST, {(cAlias)->CSTPIS, (cAlias)->VRET, (cAlias)->VLRBCPIS, (cAlias)->VLRPIS, (cAlias)->VLRBCCOFIN, (cAlias)->VLRCOFINS})
			EndIf
		EndIf
		
		(cAlias)->(dbSkip())
	EndDo
	
	nMax := Len(aCST)
	For nI := 1 to nMax
		cCST := StrZero(aCST[nI][1],2)
		aValores := {;
			aCST[nI][2],;
			aCST[nI][3],;
			aCST[nI][4],;
			aCST[nI][5],;
			aCST[nI][6] ;
		}
		NovoReg(cCST, F120, F120_REF, aValores, COL_PROTHEUS)
	Next nI
EndIf

(cAlias)->(dbCloseArea())

IncProc()

//verificando registros F130 - primeira análise: PVA
If cRecNo <> ''
	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
		       C11                                                as CST_PIS			/* 11 - CST_PIS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(C09,',','.'))), 2) as VL_BC_CRED		/* 09 - VL_BC_CRED	*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(C12,',','.'))), 2) as VL_BC_PIS		/* 12 - VL_BC_PIS		*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(C14,',','.'))), 2) as VL_PIS			/* 14 - VL_PIS			*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(C16,',','.'))), 2) as VL_BC_COFINS	/* 16 - VL_BC_COFINS	*/
		      ,ROUND(SUM(CONVERT(FLOAT,REPLACE(C18,',','.'))), 2) as VL_COFINS		/* 18 - VL_COFINS		*/
		FROM %exp:cTab%
		WHERE C01 = 'F130'
		%exp:cRecNo%
		GROUP BY C11 /* 11 - CST_PIS */
	EndSql
	
	While !(cAlias)->(Eof())
		cCST := (cAlias)->CST_PIS
		aValores := {;
			(cAlias)->VL_BC_CRED		,; // 09 - VL_BC_CRED
			(cAlias)->VL_BC_PIS		,; // 12 - VL_BC_PIS
			(cAlias)->VL_PIS		,; // 14 - VL_PIS
			(cAlias)->VL_BC_COFINS	,; // 16 - VL_BC_COFINS
			(cAlias)->VL_COFINS		 ; // 18 - VL_COFINS
		}
		NovoReg(cCST, F130, F130_REF, aValores, COL_PVA)
		(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
EndIf

IncProc()

//referência registros F130 - segunda análise: Protheus
cAlias := GetNextAlias()
aResult := AtfRegF130(xFilial('SN1'),dDtIni,dDtFim,"          ","ZZZZZZZZZZ",cAlias)

If Len(aResult) > 0
	cAlias := aResult[1,2]
	aCST := {}
	
	While !(cAlias)->(Eof())
		nPos := aScan(aCST, {|x| x[1] == (cAlias)->CST_PIS })
		If nPos <> 0
			aCST[nPos][2] += (cAlias)->VL_BC_CRED
			aCST[nPos][3] += (cAlias)->VL_BC_PIS
			aCST[nPos][4] += (cAlias)->VL_PIS
			aCST[nPos][5] += (cAlias)->VL_BC_COFIN
			aCST[nPos][6] += (cAlias)->VL_COFINS
		Else
			aAdd(aCST, {(cAlias)->CST_PIS, (cAlias)->VL_BC_CRED, (cAlias)->VL_BC_PIS, (cAlias)->VL_PIS, (cAlias)->VL_BC_COFIN, (cAlias)->VL_COFINS})
		EndIf
		
		(cAlias)->(dbSkip())
	EndDo
	
	nMax := Len(aCST)
	For nI := 1 to nMax
		cCST := StrZero(aCST[nI][1],2)
		aValores := {;
			aCST[nI][2],;
			aCST[nI][3],;
			aCST[nI][4],;
			aCST[nI][5],;
			aCST[nI][6] ;
		}
		NovoReg(cCST, F130, F130_REF, aValores, COL_PROTHEUS)
	Next nI
EndIf

(cAlias)->(dbCloseArea())

IncProc()

Return Nil

/* ------------------- */

Static Function NovoReg(cCST, cReg, cRef, aValores, nTipo)

Local cCST := AllTrim(cCST)
Local aAux
Local nPos, nI, nMax, nVal1, nVal2
Local cChave
Local aCampos

If cReg $ REG_PIS
	aCampos := {;
		CPO_VL_ITEM			,;
		CPO_VL_BC_PIS		,;
		CPO_VL_PIS			 ;
	}
ElseIf cReg $ REG_COFINS
	aCampos := {;
		CPO_VL_ITEM			,;
		CPO_VL_BC_COFINS	,;
		CPO_VL_COFINS		 ;
	}
Else
	aCampos := {;
		CPO_VL_ITEM			,;
		CPO_VL_BC_PIS		,;
		CPO_VL_PIS			,;
		CPO_VL_BC_COFINS	,;
		CPO_VL_COFINS		 ;
	}
EndIf

If cCST >= '50'
	aAux := _aColEnt
Else
	aAux := _aColSai
EndIf

nMax := Len(aCampos)
For nI := 1 to nMax
	cChave := cCST + cReg + cRef + aCampos[nI]
	nPos := aScan(aAux, {|x| x[COL_CST] + x[COL_BLOCO] + x[COL_REF] + x[COL_CAMPO] == cChave })
	If nPos > 0
		aAux[nPos][nTipo] += aValores[nI]
	Else
		If nTipo == COL_PVA
			nVal1 := aValores[nI]
			nVal2 := 0
		Else
			nVal1 := 0
			nVal2 := aValores[nI]
		Endif
		aAdd(aAux, {.F., cCST, cReg, cRef, aCampos[nI], nVal1, nVal2, 0})
	EndIf
Next nI

Return Nil

/* ------------------- */

Static Function Analisar(dDtIni, dDtFim)

_aFilCST := {}
_aFilReg := {}
_aFilCpo := {}
Processa({|| BlocoA(dDtIni, dDtFim) }, _cMyTitulo, 'Analisando Bloco A')
Processa({|| BlocoC(dDtIni, dDtFim) }, _cMyTitulo, 'Analisando Bloco C')
Processa({|| BlocoD(dDtIni, dDtFim) }, _cMyTitulo, 'Analisando Bloco D')
Processa({|| BlocoF(dDtIni, dDtFim) }, _cMyTitulo, 'Analisando Bloco F')
Processa({|| Exibir(dDtIni, dDtFim) }, _cMyTitulo, 'Atualizando tela')

Return Nil

/* ------------------- */

Static Function Exibir(dDtIni, dDtFim)

Local cPeriodo := ' - Período: ' + DTOC(dDtIni) + ' até ' + DTOC(dDtFim)
Local cConsolid := ' - Apuração com base '

ProcRegua(0)

If _lConsolid
	cConsolid += 'nos registros de consolidação das operações por NF-e (C180 e C190) e por ECF (C490)'
Else
	cConsolid += 'no registro individualizado de NF-e (C100 e C170) e de ECF (C400)'
EndIf

_cTitEnt := 'Entrada' + cPeriodo + cConsolid
_cTitSai := 'Saída' + cPeriodo + cConsolid

CalcDif()
Filtrar()
_oLayer:setWinTitle('c02','l01_c02_w01', _cTitEnt, 'l01')
_oLayer:setWinTitle('c02','l01_c02_w02', _cTitSai, 'l01')

Return Nil

/* ------------------- */

Static Function CalcDif()

Local nI, nJ, nMaxI, nMaxJ
Local aAux
Local aCols := {'_aColEnt','_aColSai'}

nMaxI := Len(aCols)
For nI := 1 to nMaxI
	aAux := &(aCols[nI])
	
	aSort(aAux,,,{ |x,y| x[COL_CST] + x[COL_BLOCO] + x[COL_REF] + Left(x[COL_CAMPO],1) < y[COL_CST] + y[COL_BLOCO] + y[COL_REF] + Left(y[COL_CAMPO],1) })
	
	nMaxJ := Len(aAux)
	For nJ := 1 to nMaxJ
		If aAux[nJ][COL_PVA] > aAux[nJ][COL_PROTHEUS]
			aAux[nJ][COL_LEG] := .T.
			aAux[nJ][COL_DIF] := aAux[nJ][COL_PVA] - aAux[nJ][COL_PROTHEUS]
		ElseIf aAux[nJ][COL_PROTHEUS] > aAux[nJ][COL_PVA]
			aAux[nJ][COL_LEG] := .T.
			aAux[nJ][COL_DIF] := aAux[nJ][COL_PROTHEUS] - aAux[nJ][COL_PVA]
		EndIf
		aAux[nJ][COL_CAMPO] := SubStr(aAux[nJ][COL_CAMPO], 3) 
	Next nJ
Next nI

Return Nil

/* ------------------- */

Static Function Filtrar()

Local nI, nJ, nMaxI, nMaxJ
Local aAuxCol, aAuxFil
Local aCols := {'_aColEnt','_aColSai'}
Local aFils := {'_aFilEnt','_aFilSai'}
Local nPosCST, nPosReg, nPosCpo

nMaxI := Len(aCols)
For nI := 1 to nMaxI
	aAuxCol := &(aCols[nI])
	aAuxFil := {}
	
	nMaxJ := Len(aAuxCol)
	For nJ := 1 to nMaxJ
		nPosCST := aScan(_aFilCST, aAuxCol[nJ][COL_CST])
		nPosReg := aScan(_aFilReg, aAuxCol[nJ][COL_BLOCO])
		nPosCpo := aScan(_aFilCpo, aAuxCol[nJ][COL_CAMPO])
		If nPosCST == 0 .and. nPosReg == 0 .and. nPosCpo == 0
			aAdd(aAuxFil, aClone(aAuxCol[nJ]))
		EndIf
	Next nJ
	
	&(aFils[nI]) := aClone(aAuxFil)
Next nI

_oBrwEnt:setArray(_aFilEnt)
_oBrwSai:setArray(_aFilSai)
_oBrwEnt:nScrollType := 1
_oBrwSai:nScrollType := 1 
_oBrwEnt:refresh()
_oBrwSai:refresh()

Return Nil

/* ------------------- */

Static Function CriaJanela()

Local aCoors := {}
Local cPicN := '@E 999,999,999.99'
Local oBmpDes
Local cImgDes
Local nDesLeft := 0
Local nDesTop := 0

aCoors := FWGetDialogSize( oMainWnd )

//criando dialog
_oDlgMain := MSDialog():new(aCoors[1],aCoors[2],aCoors[3],aCoors[4],_cMyTitulo,,,.F.,nOr(WS_VISIBLE,WS_POPUP),,,,,.T.)
_oDlgMain:lMaximized := .T.

//criando layer
_oLayer := FWLayer():new()
_oLayer:init(_oDlgMain,.F.)
_oLayer:addLine('l01',100,.F.)
_oLayer:addCollumn('c01',020,.F.,'l01')
_oLayer:addCollumn('c02',080,.F.,'l01')
_oLayer:setColSplit('c01',CONTROL_ALIGN_RIGHT,'l01')

//criando windows
_oLayer:addWindow('c01','l01_c01_w01',_cMyTitulo            ,070,.F.,.F.,,'l01')
_oLayer:addWindow('c01','l01_c01_w02','Desenvolvido por'    ,030,.F.,.F.,,'l01')
_oLayer:addWindow('c02','l01_c02_w01','Entrada'             ,050,.T.,.F.,,'l01')
_oLayer:addWindow('c02','l01_c02_w02','Saída'               ,050,.T.,.F.,,'l01')

//salvando windows
_oWndMen := _oLayer:getWinPanel('c01','l01_c01_w01','l01')
_oWndDes := _oLayer:getWinPanel('c01','l01_c01_w02','l01')
_oWndEnt := _oLayer:getWinPanel('c02','l01_c02_w01','l01')
_oWndSai := _oLayer:getWinPanel('c02','l01_c02_w02','l01')

//menu
_oTreeMenu := DbTree():New(0,0,20,20,_oWndMen,,,.T.)
_oTreeMenu:align := CONTROL_ALIGN_ALLCLIENT
_oTreeMenu:setScroll(1, .T.)
_oTreeMenu:setScroll(2, .T.)
_oTreeMenu:bLDblClick := {|| MenuClick() }
_oTreeMenu:ptSendTree(MenuDef())

//desenvolvido por
If _oWndDes:nClientWidth > 270
	cImgDes := 'mytdt_360'
ElseIf _oWndDes:nClientWidth > 180
	cImgDes := 'mytdt_270'
Else
	cImgDes := 'mytdt_180'
EndIf
oBmpDes := TBitmap():new(0,0,20,20,cImgDes,,.F.,_oWndDes,{|| shellExecute('open', 'http://www.mytdt.com.br', '', '', 1) },,.F.,.F.,,,,,.T.,,,,)
oBmpDes:lAutoSize := .T.

//centralizando imagem
nDesLeft := (_oWndDes:nClientWidth - oBmpDes:nClientWidth) / 2
nDesTop := (_oWndDes:nClientHeight - oBmpDes:nClientHeight) / 2
oBmpDes:move(nDesTop,nDesLeft,oBmpDes:nClientWidth,oBmpDes:nClientHeight,,.T.)

//browse de entrada
_oBrwEnt := TCBrowse():New(0,0,20,20,,,,_oWndEnt,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
_oBrwEnt:addColumn(TCColumn():new(''          ,{|| BrwData(_aFilEnt, _oBrwEnt, COL_LEG)      },     ,,,'LEFT'  ,010,.T.,,,,,,))
_oBrwEnt:addColumn(TCColumn():new('CST'       ,{|| BrwData(_aFilEnt, _oBrwEnt, COL_CST)      },     ,,,'LEFT'  ,020,.F.,,,,,,))
_oBrwEnt:addColumn(TCColumn():new('Bloco'     ,{|| BrwData(_aFilEnt, _oBrwEnt, COL_BLOCO)    },     ,,,'LEFT'  ,020,.F.,,,,,,))
_oBrwEnt:addColumn(TCColumn():new('Referência',{|| BrwData(_aFilEnt, _oBrwEnt, COL_REF)      },     ,,,'LEFT'  ,150,.F.,,,,,,))
_oBrwEnt:addColumn(TCColumn():new('Campo'     ,{|| BrwData(_aFilEnt, _oBrwEnt, COL_CAMPO)    },     ,,,'CENTER',050,.F.,,,,,,))
_oBrwEnt:addColumn(TCColumn():new('PVA'       ,{|| BrwData(_aFilEnt, _oBrwEnt, COL_PVA)      },cPicN,,,'RIGHT' ,050,.F.,,,,,,))
_oBrwEnt:addColumn(TCColumn():new('Protheus'  ,{|| BrwData(_aFilEnt, _oBrwEnt, COL_PROTHEUS) },cPicN,,,'RIGHT' ,050,.F.,,,,,,))
_oBrwEnt:addColumn(TCColumn():new('Diferença' ,{|| BrwData(_aFilEnt, _oBrwEnt, COL_DIF)      },cPicN,,,'RIGHT' ,050,.F.,,,,,,))
_oBrwEnt:addColumn(TCColumn():new(''          ,{|| ''                                        },     ,,,'LEFT'  ,010,.F.,,,,,,))
_oBrwEnt:setArray(_aFilEnt)
_oBrwEnt:bLDblClick := {|| Detalhar(_oBrwEnt:nAt, _aFilEnt) }
_oBrwEnt:align := CONTROL_ALIGN_ALLCLIENT
_oBrwEnt:nScrollType := 1

//browse de saída
_oBrwSai := TCBrowse():New(0,0,20,20,,,,_oWndSai,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
_oBrwSai:addColumn(TCColumn():new(''          ,{|| BrwData(_aFilSai, _oBrwSai, COL_LEG)      },     ,,,'LEFT'  ,010,.T.,,,,,,))
_oBrwSai:addColumn(TCColumn():new('CST'       ,{|| BrwData(_aFilSai, _oBrwSai, COL_CST)      },     ,,,'LEFT'  ,020,.F.,,,,,,))
_oBrwSai:addColumn(TCColumn():new('Bloco'     ,{|| BrwData(_aFilSai, _oBrwSai, COL_BLOCO)    },     ,,,'LEFT'  ,020,.F.,,,,,,))
_oBrwSai:addColumn(TCColumn():new('Referência',{|| BrwData(_aFilSai, _oBrwSai, COL_REF)      },     ,,,'LEFT'  ,150,.F.,,,,,,))
_oBrwSai:addColumn(TCColumn():new('Campo'     ,{|| BrwData(_aFilSai, _oBrwSai, COL_CAMPO)    },     ,,,'CENTER',050,.F.,,,,,,))
_oBrwSai:addColumn(TCColumn():new('PVA'       ,{|| BrwData(_aFilSai, _oBrwSai, COL_PVA)      },cPicN,,,'RIGHT' ,050,.F.,,,,,,))
_oBrwSai:addColumn(TCColumn():new('Protheus'  ,{|| BrwData(_aFilSai, _oBrwSai, COL_PROTHEUS) },cPicN,,,'RIGHT' ,050,.F.,,,,,,))
_oBrwSai:addColumn(TCColumn():new('Diferença' ,{|| BrwData(_aFilSai, _oBrwSai, COL_DIF)      },cPicN,,,'RIGHT' ,050,.F.,,,,,,))
_oBrwSai:addColumn(TCColumn():new(''          ,{|| ''                                            },     ,,,'LEFT'  ,010,.F.,,,,,,))
_oBrwSai:setArray(_aFilSai)
_oBrwSai:bLDblClick := {|| Detalhar(_oBrwSai:nAt, _aFilSai) }
_oBrwSai:align := CONTROL_ALIGN_ALLCLIENT
_oBrwSai:nScrollType := 1

_oDlgMain:activate(,,,.F.)

Return Nil

/* ------------------- */

Static Function MenuDef()

Local nMenuId := 1

_aNodeMenu := {}
// 1 = Nível do item (Caracter)
// 2 = ID que identificará este item (Caracter)
// 3 = Compatibilidade. Configure sempre com aspas "" (Caracter)
// 4 = Descrição que será apresentada no item (Caracter)
// 5 = Imagem quando o item da árvore estiver fechado (Caracter)
// 6 = Imagem quando o item da árvore estiver aberto (Caracter)
// 7 = Customizado. Função que será executada quando clicar no item (Caracter)
//               1    2                  3   4                           5      6      7
aAdd(_aNodeMenu,{'00',StrZero(nMenuId,3),'','Realizar Análise'		,'SDUSEEK'		,'SDUSEEK'		,''			}) ; nMenuId++
aAdd(_aNodeMenu,{'01',StrZero(nMenuId,3),'','Novo arquivo'			,'BMPINCLUIR'	,'BMPINCLUIR'	,'NovoArq'	}) ; nMenuId++
aAdd(_aNodeMenu,{'01',StrZero(nMenuId,3),'','Arquivo existente'		,'FOLDER6'		,'FOLDER6'		,'AbreArq'	}) ; nMenuId++
aAdd(_aNodeMenu,{'00',StrZero(nMenuId,3),'','Filtrar'				,'FILTRO'		,'FILTRO'		,'Filtro'	}) ; nMenuId++
aAdd(_aNodeMenu,{'00',StrZero(nMenuId,3),'','Exportar para Excel'	,'PMSEXCEL'		,'PMSEXCEL'		,'Excel'	}) ; nMenuId++
aAdd(_aNodeMenu,{'00',StrZero(nMenuId,3),'','Sair'					,'FINAL'		,'FINAL'		,'Sair'		}) ; nMenuId++

Return _aNodeMenu

/* ------------------- */

Static Function MenuClick()

Local cNodeId  := _oTreeMenu:currentNodeId
Local cNodeTxt := _oTreeMenu:getPrompt()
Local nPos
Local cRet := ''

//pesquisa pelo ID
nPos := aScan(_aNodeMenu, { |x| x[2] == cNodeId })
If nPos > 0
	cRet := _aNodeMenu[nPos][7]
Else
	//não encontrou
	//pesquisa pelo texto
	nPos := aScan(_aNodeMenu, { |x| AllTrim(x[4]) == AllTrim(cNodeTxt) })
	If nPos > 0
		cRet := _aNodeMenu[nPos][7]
	EndIf
EndIf

If cRet <> ''
	//executa função
	&(cRet)()
EndIf
	
Return Nil

/* ------------------- */

Static Function BrwData(aFil, oBrw, nCol)

Local xRet
Local oOk := LoadBitmap(GetResources(),'BR_VERDE')   
Local oDif := LoadBitmap(GetResources(),'BR_VERMELHO')

If Len(aFil) > 0
	If nCol == COL_LEG
		If !aFil[oBrw:nAt][nCol]
			xRet := oOk
		Else
			xRet := oDif
		EndIf
	Else
		xRet := aFil[oBrw:nAt][nCol]
	EndIf
EndIf

Return xRet

/* ------------------- */

Static Function Detalhar(nPos, aCols)

/*
If Len(aCols) > 0
	MsgAlert(;
		'Detalhar'								+ CRLF +;
		'CST: '		+ aCols[nPos][COL_CST]		+ CRLF +;
		'Bloco: '	+ aCols[nPos][COL_BLOCO]	+ CRLF +;
		''										+ CRLF +;
		'Em desenvolvimento!';
	)
EndIf
*/

Return Nil

/* ------------------- */

Static Function NovoArq()

Local aArq
Local dDtIni, dDtFim
Local lRet, nRet

Processa({|| nRet := LoadFile(@aArq,@dDtIni,@dDtFim) }, _cMyTitulo, 'Carregando arquivo...')
If nRet < 0
	If nRet == -1
		Alert('Arquivo inválido. Selecione um arquivo do SPED PIS/COFINS.')
	EndIf
	Return Nil
EndIf

_cMyTab += DTOS(dDtIni) + '_' + DTOS(dDtFim)

Processa({|| lRet := ImportFile(aArq) }, _cMyTitulo, 'Aguarde...')
If !lRet
	Alert('A importação do arquivo foi abortada.')
	Return Nil
EndIf

Analisar(dDtIni, dDtFim)

Return Nil

/* ------------------- */

Static Function AbreArq()

Local lAnalisa := .F.
Local oDlg, oCombo, oSay, oBtn1, oBtn2
Local cCombo
Local dDtIni, dDtFim
Local aAux
Local nItem
Local aItems := {}
Local aPeriodos := {}
Local cAlias := GetNextAlias()
Local cTab

_cMyTab := 'PISCOF_' + cEmpAnt + '_'

//buscando períodos existentes para montar combo
BeginSql Alias cAlias
	SELECT TABLE_NAME
	FROM information_schema.tables
	WHERE TABLE_TYPE = 'BASE TABLE'
	  AND TABLE_NAME LIKE '%' + %exp:_cMyTab% + '%'
EndSql

While !(cAlias)->(Eof())
	cTab := StrTran((cAlias)->TABLE_NAME, _cMyTab, '')
	aAux := Separa(cTab, '_')
	dDtIni := STOD(aAux[1])
	dDtFim := STOD(aAux[2])
	aAdd(aPeriodos, {dDtIni, dDtFim})
	aAdd(aItems, DTOC(dDtIni) + ' até ' + DTOC(dDtFim)) 
	(cAlias)->(dbSkip())
EndDo

If Len(aItems) == 0
	MsgAlert('Não existem arquivos já importados para serem analisados!')
	Return Nil
EndIf

//criando dialog
oDlg := MSDialog():new(0,0,105,200,'Arquivo existente',,,.F.,,,,,,.T.)

//criando say
oSay := TSay():new(05,05,{||'Selecione o período:'},oDlg,,,,,,.T.,,,80,20)

//criando combo
cCombo := aItems[1]
oCombo := TComboBox():new(16,05,{|u|if(PCount()>0,cCombo:=u,cCombo)},aItems,92,20,oDlg,,{||},,,,.T.,,,,,,,,,'cCombo')

//criando botão analisar
oBtn1 := TButton():new(30,04,"        Confirmar",oDlg,{|| lAnalisa := .T. , nItem := oCombo:nAt , oDlg:End() },44,18,,,.F.,.T.,.F.,,.F.,,,.F.)
oBtn1:setCss("QPushButton{ background-image: url(rpo:ok.png); background-repeat: none; margin: 2px }")

//criando botão cancelar
oBtn2 := TButton():new(30,52,"        Cancelar",oDlg,{|| oDlg:End() },44,18,,,.F.,.T.,.F.,,.F.,,,.F.)
oBtn2:setCss("QPushButton{ background-image: url(rpo:cancel.png); background-repeat: none; margin: 2px }")

//ativando dialog  
oDlg:activate(,,,.T.)

If !lAnalisa
	//se não clicou em Analisar, finaliza função
	Return Nil
EndIf

dDtIni := aPeriodos[nItem][1]
dDtFim := aPeriodos[nItem][2]

_cMyTab += DTOS(dDtIni) + '_' + DTOS(dDtFim)

Analisar(dDtIni, dDtFim)

Return Nil

/* ------------------- */

Static Function Filtro()

Local cNodeId := _oTreeMenu:currentNodeId
Local lFiltra := .F.
Local nCST := 0
Local nReg := 0
Local nCpo := 0
Local cFil := ''
Local oDlg, oLayer, oWndCST, oWndReg, oWndCpo, oBtn1, oBtn2
Local aCST, aReg, aCpo
Local oLstCST, oLstReg, oLstCpo
Local nI, nJ, nMaxI, nMaxJ, nPos1, nPos2
Local aAux
Local aCols := {'_aColEnt','_aColSai'}
Local cChave

If Len(_aColEnt) == 0 .and. Len(_aColSai) == 0
	MsgAlert('Não existem dados a serem filtrados!')
	Return Nil
EndIf

aCST := {}
aReg := {}
aCpo := {}
nMaxI := Len(aCols)
For nI := 1 to nMaxI
	aAux := &(aCols[nI])
	
	nMaxJ := Len(aAux)
	For nJ := 1 to nMaxJ
		cChave := aAux[nJ][COL_CST]
		nPos1 := aScan(aCST, cChave)
		nPos2 := aScan(_aFilCST, cChave)
		If nPos1 == 0 .and. nPos2 == 0
			aAdd(aCST, cChave)
		EndIf
		
		cChave := aAux[nJ][COL_BLOCO]
		nPos1 := aScan(aReg, cChave)
		nPos2 := aScan(_aFilReg, cChave)
		If nPos1 == 0 .and. nPos2 == 0
			aAdd(aReg, cChave)
		EndIf
		
		cChave := aAux[nJ][COL_CAMPO]
		nPos1 := aScan(aCpo, cChave)
		nPos2 := aScan(_aFilCpo, cChave)
		If nPos1 == 0 .and. nPos2 == 0
			aAdd(aCpo, cChave)
		EndIf
	Next nJ
Next nI
aSort(aCst)
aSort(aReg)
aSort(aCpo)

//criando dialog
oDlg := MSDialog():new(0,0,235,830,'Filtrar',,,.F.,,,,,,.T.)

//criando layer
oLayer := FWLayer():new()
oLayer:init(oDlg,.F.)
oLayer:addLine('l01',083,.F.)
oLayer:addCollumn('c01',033,.F.,'l01')
oLayer:addCollumn('c02',034,.F.,'l01')
oLayer:addCollumn('c03',033,.F.,'l01')

//criando windows
oLayer:addWindow('c01','l01_c01_w01','CSTs'  ,100,.F.,.F.,,'l01')
oLayer:addWindow('c02','l01_c02_w01','Blocos',100,.F.,.F.,,'l01')
oLayer:addWindow('c03','l01_c03_w01','Campos',100,.F.,.F.,,'l01')

//salvando windows
oWndCST := oLayer:getWinPanel('c01','l01_c01_w01','l01')
oWndReg := oLayer:getWinPanel('c02','l01_c02_w01','l01')
oWndCpo := oLayer:getWinPanel('c03','l01_c03_w01','l01')

oLstCST := FilWnd(oWndCST, aCST, _aFilCST, .F.)
oLstReg := FilWnd(oWndReg, aReg, _aFilReg, .T.)
oLstCpo := FilWnd(oWndCpo, aCpo, _aFilCpo, .F.)

//criando botão filtrar
oBtn1 := TButton():new(98,161,"        Confirmar",oDlg,{||;
	lFiltra := .T.						,;
	_aFilCST := aClone(oLstCST:aItems)	,;
	_aFilReg := aClone(oLstReg:aItems)	,;
	_aFilCpo := aClone(oLstCpo:aItems)	,;
	oDlg:End()							 ;
},44,18,,,.F.,.T.,.F.,,.F.,,,.F.)
oBtn1:setCss("QPushButton{ background-image: url(rpo:ok.png); background-repeat: none; margin: 2px }")

//criando botão cancelar
oBtn2 := TButton():new(98,209,"        Cancelar",oDlg,{|| oDlg:End() },44,18,,,.F.,.T.,.F.,,.F.,,,.F.)
oBtn2:setCss("QPushButton{ background-image: url(rpo:cancel.png); background-repeat: none; margin: 2px }")

//ativando dialog  
oDlg:activate(,,,.T.)

If !lFiltra
	//se não clicou em Filtrar, finaliza função
	Return Nil
EndIf

nCST := Len(_aFilCST)
nReg := Len(_aFilReg)
nCpo := Len(_aFilCpo)

Filtrar()

If nCST > 0 .or. nReg > 0 .or. nCpo > 0
	cFil := ' (com filtro)'
EndIf
_oTreeMenu:ptChangePrompt('Filtrar' + cFil, cNodeId)

Return Nil

/* ------------------- */

Static Function FilWnd(oWnd, aItems1, aItems2, lMeio)

Local oSay, oLst1, oLst2, oBtn1, oBtn2, oBtn3, oBtn4
Local nLst1, nLst2
Local cLstCSS, cBtnCSS
Local nDesTop, nDesLeft, nBtnWidth, nBtnHeight

//criando CSS
cLstCSS := 'QWidget {'
cLstCSS += '  border: 2px solid #FFF;'
cLstCSS += '  border-top-color: #A7A6AA;'
cLstCSS += '  border-left-color: #A7A6AA;'
cLstCSS += '}'

cBtnCSS := 'QPushButton {'
cBtnCSS += '  background-image: url(rpo:%img%.png);'
cBtnCSS += '  border: none;'
cBtnCSS += '  background-color: #F7F7FF;'
cBtnCSS += '  background-repeat: none;'
cBtnCSS += '  background-position: center;'
cBtnCSS += '}'
cBtnCSS += 'QPushButton:pressed {'
cBtnCSS += '  background-position: bottom right;'
cBtnCSS += '}'

//criando say
oSay := TSay():new(0,0,{|| Space(Iif(lMeio,15,14)) + 'Exibir' + Space(Iif(lMeio,39,37)) + 'Ocultar' },oWnd,,,,,,.T.,,,08,08)
oSay:align := CONTROL_ALIGN_TOP

//criando listboxes
oLst1 := TListBox():new(15,0,{|u|if(PCount()>0,nLst1:=u,nLst1)},aItems1,055,050,,oWnd,,,,.T.,,{|| FilAdd(.F., oLst1, oLst2) })
oLst2 := TListBox():new(15,0,{|u|if(PCount()>0,nLst2:=u,nLst2)},aItems2,055,050,,oWnd,,,,.T.,,{|| FilAdd(.F., oLst2, oLst1) })

oLst1:align := CONTROL_ALIGN_LEFT
oLst2:align := CONTROL_ALIGN_RIGHT

oLst1:setCSS(cLstCSS)
oLst2:setCSS(cLstCSS)

//criando botões
oBtn1 := TButton():new(0,0,'',oWnd,{|| FilAdd(.T., oLst1, oLst2) },16,16,,,.F.,.T.,.F.,,.F.,,,.F.)
oBtn2 := TButton():new(0,0,'',oWnd,{|| FilAdd(.F., oLst1, oLst2) },16,16,,,.F.,.T.,.F.,,.F.,,,.F.)
oBtn3 := TButton():new(0,0,'',oWnd,{|| FilAdd(.F., oLst2, oLst1) },16,16,,,.F.,.T.,.F.,,.F.,,,.F.)
oBtn4 := TButton():new(0,0,'',oWnd,{|| FilAdd(.T., oLst2, oLst1) },16,16,,,.F.,.T.,.F.,,.F.,,,.F.)

oBtn1:setCss(StrTran(cBtnCSS, '%img%', 'pgnext'))
oBtn2:setCss(StrTran(cBtnCSS, '%img%', 'next'))
oBtn3:setCss(StrTran(cBtnCSS, '%img%', 'prev'))
oBtn4:setCss(StrTran(cBtnCSS, '%img%', 'pgprev'))

nDesTop := 15
nDesLeft := (oWnd:nClientWidth - oBtn1:nClientWidth) / 2
nBtnWidth := oBtn1:nClientWidth
nBtnHeight := oBtn1:nClientHeight

oBtn1:move(nDesTop,nDesLeft,nBtnWidth,nBtnHeight,,.T.) ; nDesTop += nBtnHeight
oBtn2:move(nDesTop,nDesLeft,nBtnWidth,nBtnHeight,,.T.) ; nDesTop += nBtnHeight
oBtn3:move(nDesTop,nDesLeft,nBtnWidth,nBtnHeight,,.T.) ; nDesTop += nBtnHeight
oBtn4:move(nDesTop,nDesLeft,nBtnWidth,nBtnHeight,,.T.) ; nDesTop += nBtnHeight

Return oLst2

/* ------------------- */

Static Function FilAdd(lTodos, oListDe, oListPara)

Local nPosDe, nPosPara
Local nI, nMax
Local aAux := {}

If !lTodos
	nPosDe := oListDe:getPos()
	aAux := aClone(oListPara:aItems)
	If nPosDe > 0
		aAdd(aAux, oListDe:getSelText())
		aSort(aAux)
		oListPara:setItems(aClone(aAux))
		oListDe:del(nPosDe)
	EndIf
Else
	aAux := aClone(oListPara:aItems)
	nMax := Len(oListDe:aItems)
	For nI := 1 to nMax
		aAdd(aAux, oListDe:aItems[nI])
	Next nI
	aSort(aAux)
	oListPara:setItems(aClone(aAux))
	aAux := {}
	oListDe:setItems(aClone(aAux))
EndIf

Return Nil

/* ------------------- */

Static Function Excel()

Local aHeaders, aCols
Local nI, nJ, nMaxI, nMaxJ
Local aAux
Local aExcel := {}
Local aTipos := {;
	{'_aFilEnt', _cTitEnt}	,;
	{'_aFilSai', _cTitSai}	 ;
}
Local cCabec
Local cFilCST, cFilReg, cFilCpo

//filtro de CST
cFilCST := ''
nMaxI := Len(_aFilCST)
For nI := 1 to nMaxI
	cFilCST += _aFilCST[nI] + ', '
Next nI
If cFilCST <> ''
	cFilCST := 'CSTs removidas pelo filtro: ' + Left(cFilCST, Len(cFilCST)-2)
EndIf

//filtro de blocos
cFilReg := ''
nMaxI := Len(_aFilReg)
For nI := 1 to nMaxI
	cFilReg += _aFilReg[nI] + ', '
Next nI
If cFilReg <> ''
	cFilReg := 'Blocos removidos pelo filtro: ' + Left(cFilReg, Len(cFilReg)-2)
EndIf

//filtro de campos
cFilCpo := ''
nMaxI := Len(_aFilCpo)
For nI := 1 to nMaxI
	cFilCpo += _aFilCpo[nI] + ', '
Next nI
If cFilCpo <> ''
	cFilCpo := 'Campos removidos pelo filtro: ' + Left(cFilCpo, Len(cFilCpo)-2)
EndIf

aHeaders := {}
aAdd(aHeaders, {'CST'		, 'C', 02, 00})
aAdd(aHeaders, {'Bloco'		, 'C', 04, 00})
aAdd(aHeaders, {'Referência', 'C', 99, 00})
aAdd(aHeaders, {'Campo'		, 'C', 20, 00})
aAdd(aHeaders, {'PVA'		, 'N', 14, 02})
aAdd(aHeaders, {'Protheus'	, 'N', 14, 02})
aAdd(aHeaders, {'Diferença'	, 'N', 14, 02})

nMaxI := Len(aTipos)
For nI := 1 to nMaxI
	aAux := &(aTipos[nI][1])
	
	aCols := {}
	nMaxJ := Len(aAux)
	If nMaxJ > 0
		For nJ := 1 to nMaxJ
			aAdd(aCols, {;
				aAux[nJ][COL_CST]		,;
				aAux[nJ][COL_BLOCO]		,;
				aAux[nJ][COL_REF]		,;
				aAux[nJ][COL_CAMPO]		,;
				aAux[nJ][COL_PVA]		,;
				aAux[nJ][COL_PROTHEUS]	,;
				aAux[nJ][COL_DIF]		,;
				.F.						 ;
			})
		Next nJ
		
		cCabec := _cMyTitulo + ' - Desenvolvido por MyTDT Corporation' + CRLF + aTipos[nI][2] + CRLF
		If cFilCST <> ''
			cCabec += CRLF + cFilCST
		EndIf
		If cFilReg <> ''
			cCabec += CRLF + cFilReg
		EndIf
		If cFilCpo <> ''
			cCabec += CRLF + cFilCpo
		EndIf
		
		aAdd(aExcel, {'GETDADOS', cCabec, aClone(aHeaders), aClone(aCols)})
	EndIf
Next nI

If Len(aExcel) > 0
	MsgRun('Aguarde...', 'Exportando os registros para o Excel', {|| DlgToExcel(aExcel) })
Else
	MsgAlert('Não existem dados a serem exportados!')
EndIf

Return Nil

/* ------------------- */

Static Function Sair()

_oDlgMain:End()

Return Nil
#include 'rwmake.ch'
#include 'protheus.ch'

#define FILIAL 01
#define NOTAS  02

#define NFS 01
#define CTR 02
#define CTA 03
#define NF  04

#define NUMERO 01
#define CNPJ   02

User Function MyNFFalt()

If !(AllTrim(Upper(cUsername)) $ 'THIERES;ADMINISTRADOR')
	Alert('Relatório não liberado para o usuário: ' + AllTrim(cUsername))
EndIf
Processa({||Executa()},'Gerando relatório','Aguarde...')

Return Nil

/* ------------------- */

Static Function Executa()

Local aEnt, aSai, aEntSai, cAlias
Local nI, nJ, nX, nA, nMaxI, nMaxJ, nCnt, nQtdTot
Local aNota
Local aDescFil := {'Matriz','Altamira','Manaus','','Santana'}
Local aDescTipo := {'NF Serviço','CTR','CTA','NF Normal'}
Local aExcel := {}
Local cAux, cRet, cCliForCGC, cCliForNom, cCliFor, cConta
Local cArq := 'relsped'
Local lFil, lRel

aEnt := {;
	{'01', {;
		{'500-07849470000769','3028-04906802000116','1144-14544433000112','108893-04833604000170'},;
		{'021934-10524538000582'},;
		{},;
		{};
	}},;
	{'02', {;
		{},;
		{},;
		{},;
		{};
	}},;
	{'03', {;
		{},;
		{},;
		{},;
		{};
	}},;
	{'05', {;
		{},;
		{},;
		{},;
		{'003316-03109057000111'};
	}};
}
aSai := {;
	{'01', {;
		{},;
		{},;
		{},;
		{};
	}},;
	{'02', {;
		{},;
		{},;
		{},;
		{};
	}},;
	{'03', {;
		{},;
		{},;
		{},;
		{};
	}},;
	{'05', {;
		{},;
		{},;
		{},;
		{};
	}};
}

nQtdTot := 0
For nA := 1 to 2
	aEntSai := aClone(Iif(nA==1,aEnt,aSai))
	nMaxI := Len(aEntSai)
	For nI := 1 to nMaxI
		For nX := NFS to NF
			nMaxJ := Len(aEntSai[nI][NOTAS][nX])
			nQtdTot += nMaxJ
		Next nX
	Next nI
Next nA

ProcRegua(nQtdTot)
			
//entrada e saída
For nA := 1 to 2
	If nA == 1
		aEntSai := aClone(aEnt)
		aAdd(aExcel, {'NOTAS DE ENTRADA'})
	Else
		aEntSai := aClone(aSai)
		aAdd(aExcel, {'NOTAS DE SAÍDA'})
	EndIf
	aAdd(aExcel, {''})
	
	//passando por filial
	nMaxI := Len(aEntSai)
	For nI := 1 to nMaxI
		lFil := .F.
				
		//lendo todos os tipos
		For nX := NFS to NF
			
			//lendo as notas por tipo
			lRel := .F.
			nCnt := 0
			nMaxJ := Len(aEntSai[nI][NOTAS][nX])
			For nJ := 1 to nMaxJ
				IncProc()
				aNota := Separa(aEntSai[nI][NOTAS][nX][nJ], '-')
				
				cAlias := QrySQL(aEntSai[nI][FILIAL],aNota[NUMERO],aNota[CNPJ],Iif(nA==1,'E','S'))
				While !(cAlias)->(Eof())
					If AllTrim((cAlias)->CLICNPJ) <> '' .or. AllTrim((cAlias)->FORCNPJ) <> ''
						If !lFil
							aAdd(aExcel, {'Filial: ' + aEntSai[nI][FILIAL] + ' - ' + aDescFil[Val(aEntSai[nI][FILIAL])]})
							lFil := .T.
						EndIf
						If !lRel
							aAdd(aExcel, {'','Relação de ' + aDescTipo[nX] + ' - Qtd: ' + cValToChar(nMaxJ)})
							aAdd(aExcel, {'','',;
								'Número',;
								'Série',;
								'Entrada',;
								'Emissão',;
								'Tipo Nota',;
								'Cliente/Fornecedor',;
								'Código',;
								'Loja',;
								'CNPJ',;
								'Nome',;
								'CFOPs',;
								'Valor Contábil',;
								'Conta ' + Iif(nA==1,'Débito','Crédito');
								})
							lRel := .T.
						EndIf
						
						If Val(Left(AllTrim((cAlias)->CFOPS),1)) < 5
							cConta := AllTrim((cAlias)->F1DEBITO)
							If AllTrim((cAlias)->TIPO) $ 'D;B'
								cCliFor    := 'Cliente'
								cCliForCGC := (cAlias)->CLICNPJ
								cCliForNom := (cAlias)->CLINOME
							Else                          
								cCliFor    := 'Fornecedor'
								cCliForCGC := (cAlias)->FORCNPJ
								cCliForNom := (cAlias)->FORNOME
							EndIf
						Else
							cConta := AllTrim((cAlias)->F2CREDIT)
							If AllTrim((cAlias)->TIPO) $ 'D;B'
								cCliFor    := 'Fornecedor'
								cCliForCGC := (cAlias)->FORCNPJ
								cCliForNom := (cAlias)->FORNOME
							Else
								cCliFor    := 'Cliente'
								cCliForCGC := (cAlias)->CLICNPJ
								cCliForNom := (cAlias)->CLINOME
							EndIf
						EndIf
						
						aAdd(aExcel, {'','',;
							(cAlias)->DOC,;
							(cAlias)->SERIE,;
							STOD((cAlias)->ENTRADA),;
							STOD((cAlias)->EMISSAO),;
							(cAlias)->TIPO,;
							cCliFor,;
							(cAlias)->CLIEFOR,;
							(cAlias)->LOJA,;
							cCliForCGC,;
							cCliForNom,;
							AllTrim((cAlias)->CFOPS),;
							(cAlias)->VALCONT,;
							cConta;
						})
						nCnt++
					EndIf
					
					(cAlias)->(dbSkip())
				EndDo
				(cAlias)->(dbCloseArea())
			Next nJ
			
			If nCnt > 0
				aAdd(aExcel, {'','','Total: ' + cValToChar(nCnt)})
			EndIf
			If lRel
				aAdd(aExcel, {''})
			EndIf
		Next nX
		
		If lFil
			aAdd(aExcel, {''})
		EndIf
	Next nI
Next nA

cAux := AllTrim(cGetFile('CSV (*.csv)|*.csv', 'Selecione o diretório onde será salvo o relatório', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NETWORKDRIVE, GETF_RETDIRECTORY ), .F., .T.))
If cAux <> ''
	cAux := SubStr(cAux, 1, RAt('\', cAux)) + cArq
	cAux := cAux + '-' + DTOS(Date()) + '-' + StrTran(Time(), ':', '') + '.csv'
	
	cRet := U_MyArrCsv(aExcel, cAux, Nil)
	If cRet <> ''
		Alert(cRet)
	EndIf
Else
	Alert('A geração do relatório foi cancelada!')
EndIf

Return Nil

Static Function QrySQL(cFil, cNota, cCNPJ, cEntSai)

Local cAlias := GetNextAlias()
Local cQry := ""

If cEntSai == 'E'
	cEntSai := "%LEFT(SF3.F3_CFO,1) < '5'%"
	cF3A1Tipo := "%SF3.F3_TIPO IN ('D','B')%"
	cF3A2Tipo := "%SF3.F3_TIPO NOT IN ('D','B')%"
Else
	cEntSai := "%LEFT(SF3.F3_CFO,1) >= '5'%"
	cF3A1Tipo := "%SF3.F3_TIPO NOT IN ('D','B')%"
	cF3A2Tipo := "%SF3.F3_TIPO IN ('D','B')%"
EndIf

BeginSql Alias cAlias
	%noParser%
	SELECT
	      SF3.F3_FILIAL                AS FILIAL
	     ,SF3.F3_NFISCAL               AS DOC
	     ,SF3.F3_SERIE                 AS SERIE
	     ,SF3.F3_ENTRADA               AS ENTRADA
	     ,SF3.F3_EMISSAO               AS EMISSAO
	     ,SF3.F3_CLIEFOR               AS CLIEFOR
	     ,SF3.F3_LOJA                  AS LOJA
	     ,SF3.F3_TIPO                  AS TIPO
	     ,SF1.R_E_C_N_O_               AS F1REC
	     ,SF2.R_E_C_N_O_               AS F2REC
	     ,A2_CGC                       AS FORCNPJ
	     ,A2_NOME                      AS FORNOME
	     ,A1_CGC                       AS CLICNPJ
	     ,A1_NOME                      AS CLINOME
	     ,ROUND(SUM(SF3.F3_VALCONT),2) AS VALCONT
	     ,STUFF(CAST((
	         SELECT ', ' + RTRIM(LTRIM(CFOP.F3_CFO))
	         FROM %table:SF3% CFOP
	         WHERE CFOP.%notDel%
	           AND CFOP.F3_FILIAL = SF3.F3_FILIAL
	           AND CFOP.F3_NFISCAL = SF3.F3_NFISCAL
	           AND CFOP.F3_SERIE = SF3.F3_SERIE
	           AND CFOP.F3_CLIEFOR = SF3.F3_CLIEFOR
	           AND CFOP.F3_LOJA = SF3.F3_LOJA
	           AND CFOP.F3_CFO <> ''
	         GROUP BY CFOP.F3_CFO
	         FOR XML PATH('')
	      ) AS VARCHAR(1000)), 1, 2, '') AS CFOPS
	     ,STUFF(CAST((
	         SELECT ', ' + RTRIM(LTRIM(CT2E.CT2_DEBITO))
	         FROM %table:CV3% CV3E
	             ,%table:CT2% CT2E
	         WHERE CV3E.%notDel%
	           AND CT2E.%notDel%
	           AND CV3E.CV3_FILIAL = SF3.F3_FILIAL
	           AND CONVERT(INT,CV3E.CV3_RECORI) = SF1.R_E_C_N_O_
	           AND CV3E.CV3_TABORI = 'SF1'
	           AND CV3E.CV3_DC IN ('1','3')
	           AND CT2E.CT2_FILIAL = CV3E.CV3_FILIAL
	           AND CT2E.R_E_C_N_O_ = CONVERT(INT,CV3E.CV3_RECDES)
	           AND CT2E.CT2_DEBITO <> ''
	         GROUP BY CT2E.CT2_DEBITO
	         FOR XML PATH('')
	      ) AS VARCHAR(1000)), 1, 2, '') AS F1DEBITO
	     ,STUFF(CAST((
	         SELECT ', ' + RTRIM(LTRIM(CT2S.CT2_CREDIT))
	         FROM %table:CV3% CV3S
	             ,%table:CT2% CT2S
	         WHERE CV3S.%notDel%
	           AND CT2S.%notDel%
	           AND CV3S.CV3_FILIAL = SF3.F3_FILIAL
	           AND CONVERT(INT,CV3S.CV3_RECORI) = SF2.R_E_C_N_O_
	           AND CV3S.CV3_TABORI = 'SF2'
	           AND CV3S.CV3_DC IN ('1','3')
	           AND CT2S.CT2_FILIAL = CV3S.CV3_FILIAL
	           AND CT2S.R_E_C_N_O_ = CONVERT(INT,CV3S.CV3_RECDES)
	           AND CT2S.CT2_CREDIT <> ''
	         GROUP BY CT2S.CT2_CREDIT
	         FOR XML PATH('')
	      ) AS VARCHAR(1000)), 1, 2, '') AS F2CREDIT
	FROM %table:SF3% SF3
	LEFT JOIN %table:SA2% SA2
	ON  SA2.%notDel%
	AND A2_FILIAL = %xFilial:SA2%
	AND A2_COD = SF3.F3_CLIEFOR
	AND A2_LOJA = SF3.F3_LOJA
	AND %exp:cF3A2Tipo%
	AND REPLACE(
	  REPLACE(
	    REPLACE(
	      REPLACE(A2_CGC,'.','')
	    ,'/','')
	  ,'-','')
	,' ','') = %exp:cCNPJ%
	LEFT JOIN %table:SA1% SA1
	ON  SA1.%notDel%
	AND A1_FILIAL = %xFilial:SA1%
	AND A1_COD = SF3.F3_CLIEFOR
	AND A1_LOJA = SF3.F3_LOJA
	AND %exp:cF3A1Tipo%
	AND REPLACE(
	  REPLACE(
	    REPLACE(
	      REPLACE(A1_CGC,'.','')
	    ,'/','')
	  ,'-','')
	,' ','') = %exp:cCNPJ%
	LEFT JOIN %table:SF1% SF1
	ON  SF1.%notDel%
	AND F1_FILIAL = SF3.F3_FILIAL
	AND F1_DOC = SF3.F3_NFISCAL
	AND F1_SERIE = SF3.F3_SERIE
	AND F1_FORNECE = SF3.F3_CLIEFOR
	AND F1_LOJA = SF3.F3_LOJA
	AND LEFT(SF3.F3_CFO,1) < '5'
	LEFT JOIN %table:SF2% SF2
   ON  SF2.%notDel%
	AND F2_FILIAL = SF3.F3_FILIAL
	AND F2_DOC = SF3.F3_NFISCAL
	AND F2_SERIE = SF3.F3_SERIE
	AND F2_CLIENTE = SF3.F3_CLIEFOR
	AND F2_LOJA = SF3.F3_LOJA
	AND LEFT(SF3.F3_CFO,1) >= '5'
	WHERE SF3.%notDel%
	  AND SF3.F3_FILIAL = %exp:cFil%
	  AND SF3.F3_NFISCAL LIKE '%' + %exp:cNota% + '%'
	  AND %exp:cEntSai%
	  AND SF3.F3_ENTRADA BETWEEN '20130101' AND '20131231'
	GROUP BY 
	        SF3.F3_FILIAL
	       ,SF3.F3_NFISCAL
	       ,SF3.F3_SERIE
	       ,SF3.F3_ENTRADA
	       ,SF3.F3_EMISSAO
	       ,SF3.F3_CLIEFOR
	       ,SF3.F3_LOJA
	       ,SF3.F3_TIPO
	       ,SF1.R_E_C_N_O_
	       ,SF2.R_E_C_N_O_
	       ,A2_CGC
	       ,A2_NOME
	       ,A1_CGC
	       ,A1_NOME
EndSql

Return cAlias
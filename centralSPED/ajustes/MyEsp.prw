#include 'rwmake.ch'
#include 'protheus.ch'
#include 'topconn.ch'

#define ENTRADA 1
#define SAIDA   2
///////////////////////////////////////////////////////////////////////////////
User Function MyEsp()
///////////////////////////////////////////////////////////////////////////////
// Data : 05/02/2014
// User : Thieres Tembra
// Desc : Modifica a espécie das notas fiscais de acordo com o CFOP e/ou Chave
///////////////////////////////////////////////////////////////////////////////
Local cPerg := '#MyEsp    '

If Aviso('Atenção','Esta rotina irá modificar todas as espécies das notas ' +;
'fiscais de entrada e saída de acordo com o CFOP e/ou Chave. Deseja ' +;
'prosseguir?',{'Sim','Não'}) == 2
	Return Nil
EndIf

CriaSX1(cPerg)

If Pergunte(cPerg, .T.)
	Processa({|| Executa() }, 'Modificando Espécie...')
EndIf

Return Nil

/* ---------------- */

Static Function Executa()

Local cQry
//   CFOP                   C/CHAVE S/CHAVE [preferencial para o primeiro]
//entrada
Local aCFxEspE := {;
	{'1351;1353;2351;2353', 'CTE' , 'CTR;CTA;CA'},;
	{'1253;2253;1254;2254', 'SPED', 'NFCEE'     },;
	{'1303;1304;2303;2304', 'SPED', 'NTST'      },;
	{'1933;2933'          , 'SPED', 'NFS'       },;
	{'*',                   'SPED', '-'         } ;
}
//saída
Local aCFxEspS := {;
	{'5353;6353', 'CTE',  'CTR;CTA;CA'},;
	{'5933;6933', 'CTE',  'NFS'       },;
	{'*',         'SPED', '-'         } ;
}
Local nI, nJ
Local nTamE := 0
Local nTamS := 0

If MV_PAR03 == 1 .or. MV_PAR03 == 3
	nTamE := Len(aCFxEspE)
EndIf
If MV_PAR03 == 2 .or. MV_PAR03 == 3
	nTamS := Len(aCFxEspS)
EndIf

ProcRegua(nTamE + nTamS)

//entrada
For nI := 1 to nTamE
	IncProc('Entrada - CFOPs: ' + aCFxEspE[nI][1] + ' - Espécie: ' + aCFxEspE[nI][2] + ' ou ' + aCFxEspE[nI][3])
	cQry := " SELECT D1_FILIAL,"
	cQry += "        D1_DOC,"
	cQry += "        D1_SERIE,"
	cQry += "        D1_FORNECE,"
	cQry += "        D1_LOJA"
	cQry += " FROM " + RetSqlName('SD1')
	cQry += " WHERE D1_FILIAL = '" + xFilial('SD1') + "'"
	If aCFxEspE[nI][1] <> '*'
		cQry += "   AND D1_CF IN " + U_MyGeraIn(aCFxEspE[nI][1])
	Else
		For nJ := 1 to nTamE
			If nI <> nJ .and. aCFxEspE[nJ][1] <> '*'
				cQry += "   AND D1_CF NOT IN " + U_MyGeraIn(aCFxEspE[nJ][1])
			EndIf
		Next nJ
	EndIf
	cQry += "   AND LEFT(D1_DTDIGIT,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	cQry += "   AND D_E_L_E_T_ <> '*'"
	cQry += " GROUP BY D1_FILIAL,"
	cQry += "          D1_DOC,"
	cQry += "          D1_SERIE,"
	cQry += "          D1_FORNECE,"
	cQry += "          D1_LOJA"
	
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSD1',.T.)
	While !SSD1->(Eof())
		Muda(ENTRADA, SSD1->D1_FILIAL, SSD1->D1_DOC, SSD1->D1_SERIE, SSD1->D1_FORNECE, SSD1->D1_LOJA, aCFxEspE[nI])
		SSD1->(dbSkip())
	EndDo
	SSD1->(dbCloseArea())
Next nI

//saída
For nI := 1 to nTamS
	IncProc('Saída - CFOPs: ' + aCFxEspS[nI][1] + ' - Espécies: ' + aCFxEspS[nI][2] + ' ou ' + aCFxEspS[nI][3])
	cQry := " SELECT D2_FILIAL,"
	cQry += "        D2_DOC,"
	cQry += "        D2_SERIE,"
	cQry += "        D2_CLIENTE,"
	cQry += "        D2_LOJA"
	cQry += " FROM " + RetSqlName('SD2')
	cQry += " WHERE D2_FILIAL = '" + xFilial('SD2') + "'"
	If aCFxEspS[nI][1] <> '*'
		cQry += "   AND D2_CF IN " + U_MyGeraIn(aCFxEspS[nI][1])
	Else
		For nJ := 1 to nTamS
			If nI <> nJ .and. aCFxEspS[nJ][1] <> '*'
				cQry += "   AND D2_CF NOT IN " + U_MyGeraIn(aCFxEspS[nJ][1])
			EndIf
		Next nJ
	EndIf
	cQry += "   AND LEFT(D2_EMISSAO,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	cQry += "   AND D_E_L_E_T_ <> '*'"
	cQry += "   AND D2_PDV = ''"
	cQry += " GROUP BY D2_FILIAL,"
	cQry += "          D2_DOC,"
	cQry += "          D2_SERIE,"
	cQry += "          D2_CLIENTE,"
	cQry += "          D2_LOJA"
	
	dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'SSD2',.T.)
	While !SSD2->(Eof())
		Muda(SAIDA, SSD2->D2_FILIAL, SSD2->D2_DOC, SSD2->D2_SERIE, SSD2->D2_CLIENTE, SSD2->D2_LOJA, aCFxEspS[nI])
		SSD2->(dbSkip())
	EndDo
	SSD2->(dbCloseArea())
Next nI

Return Nil

/* ---------------- */

Static Function Muda(nEntSai, cFil, cDoc, cSerie, cCliFor, cLoja, aChave)

Local cQry
Local aEspS := Separa(aChave[3], ';')
Local nEspS := Len(aEspS)
Local nI

//SF1 ou SF2
If nEntSai == ENTRADA
	cQry := " UPDATE " + RetSqlName('SF1')
	If aChave[2] <> '-' .and. aChave[3] <> '-'
		//tem ambos
		cQry += " SET F1_ESPECIE = CASE RTRIM(LTRIM(F1_CHVNFE)) WHEN '' THEN '" + aEspS[1] + "' ELSE '" + aChave[2] + "' END"
	ElseIf aChave[2] <> '-' .and. aChave[3] == '-'
		//tem somente eletrônico
		cQry += " SET F1_ESPECIE = '" + aChave[2] + "'"
	ElseIf aChave[3] <> '-' .and. aChave[2] == '-'
		//tem somente não eletrônico
		cQry += " SET F1_ESPECIE = '" + aEspS[1] + "'"
	EndIf
	cQry += " WHERE F1_FILIAL   = '" + cFil + "'"
	cQry += "   AND F1_DOC      = '" + cDoc + "'"
	cQry += "   AND F1_SERIE    = '" + cSerie + "'"
	cQry += "   AND F1_FORNECE  = '" + cCliFor + "'"
	cQry += "   AND F1_LOJA     = '" + cLoja + "'"
	cQry += "   AND LEFT(F1_DTDIGIT,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	cQry += "   AND D_E_L_E_T_ <> '*'"
	If aChave[2] <> '-' .and. aChave[3] <> '-'
		//tem ambos
		For nI := 1 to nEspS
			cQry += "   AND F1_ESPECIE <> CASE RTRIM(LTRIM(F1_CHVNFE)) WHEN '' THEN '" + aEspS[nI] + "' ELSE '" + aChave[2] + "' END"
		Next nI
	ElseIf aChave[2] <> '-' .and. aChave[3] == '-'
		//tem somente eletrônico
		cQry += "   AND F1_CHVNFE <> ''"
		cQry += "   AND F1_ESPECIE <> '" + aChave[2] + "'"
	ElseIf aChave[3] <> '-' .and. aChave[2] == '-'
		//tem somente não eletrônico
		cQry += "   AND F1_CHVNFE = ''"
		For nI := 1 to nEspS
			cQry += "   AND F1_ESPECIE <> '" + aEspS[nI] + "'"
		Next nI
	EndIf
ElseIf nEntSai == SAIDA
	cQry := " UPDATE " + RetSqlName('SF2')
	If aChave[2] <> '-' .and. aChave[3] <> '-'
		//tem ambos
		cQry += " SET F2_ESPECIE = CASE RTRIM(LTRIM(F2_CHVNFE)) WHEN '' THEN '" + aEspS[1] + "' ELSE '" + aChave[2] + "' END"
	ElseIf aChave[2] <> '-' .and. aChave[3] == '-'
		//tem somente eletrônico
		cQry += " SET F2_ESPECIE = '" + aChave[2] + "'"
	ElseIf aChave[3] <> '-' .and. aChave[2] == '-'
		//tem somente não eletrônico
		cQry += " SET F2_ESPECIE = '" + aEspS[1] + "'"
	EndIf
	cQry += " WHERE F2_FILIAL   = '" + cFil + "'"
	cQry += "   AND F2_DOC      = '" + cDoc + "'"
	cQry += "   AND F2_SERIE    = '" + cSerie + "'"
	cQry += "   AND F2_CLIENTE  = '" + cCliFor + "'"
	cQry += "   AND F2_LOJA     = '" + cLoja + "'"
	cQry += "   AND F2_PDV      = ''"
	cQry += "   AND LEFT(F2_EMISSAO,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	cQry += "   AND D_E_L_E_T_ <> '*'"
	If aChave[2] <> '-' .and. aChave[3] <> '-'
		//tem ambos
		For nI := 1 to nEspS
			cQry += "   AND F2_ESPECIE <> CASE RTRIM(LTRIM(F2_CHVNFE)) WHEN '' THEN '" + aEspS[nI] + "' ELSE '" + aChave[2] + "' END"
		Next nI
	ElseIf aChave[2] <> '-' .and. aChave[3] == '-'
		//tem somente eletrônico
		cQry += "   AND F2_CHVNFE <> ''"
		cQry += "   AND F2_ESPECIE <> '" + aChave[2] + "'"
	ElseIf aChave[3] <> '-' .and. aChave[2] == '-'
		//tem somente não eletrônico
		cQry += "   AND F2_CHVNFE = ''"
		For nI := 1 to nEspS
			cQry += "   AND F2_ESPECIE <> '" + aEspS[nI] + "'"
		Next nI
	EndIf
EndIf

If TCSqlExec(cQry) < 0
	Alert('Impossível atualizar a nota (SF2):' + CRLF +;
	cFil + '/' + cDoc + '/' + cSerie + ' - ' + cCliFor + '/' + cLoja)
EndIf

//SF3
cQry := " UPDATE " + RetSqlName('SF3')
If aChave[2] <> '-' .and. aChave[3] <> '-'
	//tem ambos
	cQry += " SET F3_ESPECIE = CASE RTRIM(LTRIM(F3_CHVNFE)) WHEN '' THEN '" + aEspS[1] + "' ELSE '" + aChave[2] + "' END"
ElseIf aChave[2] <> '-' .and. aChave[3] == '-'
	//tem somente eletrônico
	cQry += " SET F3_ESPECIE = '" + aChave[2] + "'"
ElseIf aChave[3] <> '-' .and. aChave[2] == '-'
	//tem somente não eletrônico
	cQry += " SET F3_ESPECIE = '" + aEspS[1] + "'"
EndIf
cQry += " WHERE F3_FILIAL   = '" + cFil + "'"
cQry += "   AND F3_NFISCAL  = '" + cDoc + "'"
cQry += "   AND F3_SERIE    = '" + cSerie + "'"
cQry += "   AND F3_CLIEFOR  = '" + cCliFor + "'"
cQry += "   AND F3_LOJA     = '" + cLoja + "'"
cQry += "   AND F3_PDV      = ''"
cQry += "   AND LEFT(F3_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += "   AND D_E_L_E_T_ <> '*'"
If aChave[2] <> '-' .and. aChave[3] <> '-'
	//tem ambos
	For nI := 1 to nEspS
		cQry += "   AND F3_ESPECIE <> CASE RTRIM(LTRIM(F3_CHVNFE)) WHEN '' THEN '" + aEspS[nI] + "' ELSE '" + aChave[2] + "' END"
	Next nI
ElseIf aChave[2] <> '-' .and. aChave[3] == '-'
	//tem somente eletrônico
	cQry += "   AND F3_CHVNFE <> ''"
	cQry += "   AND F3_ESPECIE <> '" + aChave[2] + "'"
ElseIf aChave[3] <> '-' .and. aChave[2] == '-'
	//tem somente não eletrônico
	cQry += "   AND F3_CHVNFE = ''"
	For nI := 1 to nEspS
		cQry += "   AND F3_ESPECIE <> '" + aEspS[nI] + "'"
	Next nI
EndIf

If TCSqlExec(cQry) < 0
	Alert('Impossível atualizar a nota (SF3):' + CRLF +;
	cFil + '/' + cDoc + '/' + cSerie + ' - ' + cCliFor + '/' + cLoja)
EndIf

//SFT
cQry := " UPDATE " + RetSqlName('SFT')
If aChave[2] <> '-' .and. aChave[3] <> '-'
	//tem ambos
	cQry += " SET FT_ESPECIE = CASE RTRIM(LTRIM(FT_CHVNFE)) WHEN '' THEN '" + aEspS[1] + "' ELSE '" + aChave[2] + "' END"
ElseIf aChave[2] <> '-' .and. aChave[3] == '-'
	//tem somente eletrônico
	cQry += " SET FT_ESPECIE = '" + aChave[2] + "'"
ElseIf aChave[3] <> '-' .and. aChave[2] == '-'
	//tem somente não eletrônico
	cQry += " SET FT_ESPECIE = '" + aEspS[1] + "'"
EndIf
cQry += " WHERE FT_FILIAL   = '" + cFil + "'"
cQry += "   AND FT_NFISCAL  = '" + cDoc + "'"
cQry += "   AND FT_SERIE    = '" + cSerie + "'"
cQry += "   AND FT_CLIEFOR  = '" + cCliFor + "'"
cQry += "   AND FT_LOJA     = '" + cLoja + "'"
cQry += "   AND FT_PDV      = ''"
cQry += "   AND LEFT(FT_ENTRADA,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQry += "   AND D_E_L_E_T_ <> '*'"
If aChave[2] <> '-' .and. aChave[3] <> '-'
	//tem ambos
	For nI := 1 to nEspS
		cQry += "   AND FT_ESPECIE <> CASE RTRIM(LTRIM(FT_CHVNFE)) WHEN '' THEN '" + aEspS[nI] + "' ELSE '" + aChave[2] + "' END"
	Next nI
ElseIf aChave[2] <> '-' .and. aChave[3] == '-'
	//tem somente eletrônico
	cQry += "   AND FT_CHVNFE <> ''"
	cQry += "   AND FT_ESPECIE <> '" + aChave[2] + "'"
ElseIf aChave[3] <> '-' .and. aChave[2] == '-'
	//tem somente não eletrônico
	cQry += "   AND FT_CHVNFE = ''"
	For nI := 1 to nEspS
		cQry += "   AND FT_ESPECIE <> '" + aEspS[nI] + "'"
	Next nI
EndIf

If TCSqlExec(cQry) < 0
	Alert('Impossível atualizar a nota (SFT):' + CRLF +;
	cFil + '/' + cDoc + '/' + cSerie + ' - ' + cCliFor + '/' + cLoja)
EndIf

Return Nil

/* ---------------- */

Static Function CriaSX1(cPerg)

Local nTamGrp := Len(SX1->X1_GRUPO)
Local aHelpPor := {}, aHelpEng := {}, aHelpSpa := {}
Local cNome

aHelpPor := {}
aAdd(aHelpPor, 'Informe o ano/mes inicial para       ')
aAdd(aHelpPor, 'processamento das notas. Ex: 201201  ')
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
aAdd(aHelpPor, 'Informe o ano/mes final para         ')
aAdd(aHelpPor, 'processamento das notas. Ex: 201203  ')
cNome := 'Ate Ano Mes (Ex: 201203)'
PutSx1(PadR(cPerg,nTamGrp), '02', cNome, cNome, cNome,;
'MV_CH2', 'C', 6, 0, 0, 'G', '', '', '', '', 'MV_PAR02',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Selecione de qual livro as notas     ')
aAdd(aHelpPor, ' deverão ser ajustadas.              ')
cNome := 'Livro'
PutSx1(PadR(cPerg,nTamGrp), '03', cNome, cNome, cNome,;
'MV_CH3', 'N', 1, 0, 3, 'C', '', '', '', '', 'MV_PAR03',;
'Entrada', 'Entrada', 'Entrada', '',;
'Saída', 'Saída', 'Saída',;
'Ambos', 'Ambos', 'Ambos',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
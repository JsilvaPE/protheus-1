User Function MyRNFCan()

Local cRelat := '#MyRNFCan'

CallIReport(cRelat,{'0',1,.F.,.T.})

Return Nil

/*
#include "rwmake.ch"
#include "topconn.ch"
User Function MyRNFCan()

Local cPerg := '#MYRNFCAN'

CriaSX1(cPerg)

If !Pergunte(cPerg, .T.)
	Return Nil
Endif

If MV_PAR01 == Nil .or. MV_PAR01 == CTOD('') .or. MV_PAR02 == Nil .or. MV_PAR02 == CTOD('')
	Alert('Informe as datas para geração do relatório.')
	Return Nil
ElseIf MV_PAR01 > MV_PAR02
	Alert('A data final deve ser maior que a data inicial.')
	Return Nil
EndIf

Processa({|| Executa() }, 'Notas Fiscais Canceladas/Inutilizadas', 'Aguarde..')

Return Nil

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function Executa()

Local dDataDe, dDataAte
Local cEmp, cQry, cArqTmp, cRelat, cPeriodo
Local aStruSF3
Local nI

dDataDe 	:= DTOS(MV_PAR01)
dDataAte	:= DTOS(MV_PAR02)
cPeriodo := DTOC(MV_PAR01) + Iif(MV_PAR01 <> MV_PAR02,' a ' + DTOC(MV_PAR02),'')

cQry := CRLF + " SELECT TOP 1"
cQry += CRLF + "    ID_ENT"
cQry += CRLF + " FROM SPED001"
cQry += CRLF + " WHERE D_E_L_E_T_ <> '*'"
cQry += CRLF + "  AND CNPJ = '" + AllTrim(SM0->M0_CGC) + "'"
cQry += CRLF + "  AND PASSCERT <> ''"

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY',.T.)
If !MQRY->(Eof())
	cEmp := MQRY->ID_ENT
Else
	Alert('Impossível localizar cadastro da empresa nas tabelas do TSS.')
	Return Nil
EndIf

MQRY->(dbCloseArea())

cQry := CRLF + " SELECT DISTINCT '"+SM0->M0_NOME+"' EMPRESA,'"+rtrim(SM0->M0_FILIAL)+"' FILIAL,'"+cPeriodo+"' PERIODO, "  + CHR(10)
cQry += CRLF + " (SELECT TOP 1 CSTAT_SEFR FROM SPED054 WHERE ID_ENT = '"+cEmp+"' AND NFE_ID = (SF3.F3_SERIE+SF3.F3_NFISCAL) COLLATE Latin1_General_BIN AND D_E_L_E_T_=' ' ORDER BY LOTE DESC) ID, "  + CHR(10)
cQry += CRLF + " (SELECT TOP 1 XMOT_SEFR FROM  SPED054 WHERE ID_ENT = '"+cEmp+"' AND NFE_ID = (SF3.F3_SERIE+SF3.F3_NFISCAL) COLLATE Latin1_General_BIN AND D_E_L_E_T_=' ' ORDER BY LOTE DESC) XMOT_SEFR, "  + CHR(10)
cQry += CRLF + " '' XMOT_SEFR,"  + CHR(10)
cQry += CRLF + " F3_FILIAL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_DTCANC,F3_EMISSAO,F3_OBSERV,F3_CHVNFE,F3_CODRSEF,F3_USERLGA,F3_USERLGI,'"+SPACE(40)+"' USRI,'"+SPACE(40)+"' USRA, " + CHR(10)
cQry += CRLF + " ( CASE " + CHR(10)
cQry += CRLF + "  WHEN LEFT(SF3.F3_CFO,1) >='5' AND SF3.F3_TIPO <> 'B' THEN (SELECT A1_NOME FROM "+RetSqlName("SA1")+" WHERE D_E_L_E_T_ =' ' AND A1_COD=SF3.F3_CLIEFOR AND A1_LOJA=SF3.F3_LOJA) " + CHR(10)
cQry += CRLF + "  WHEN LEFT(SF3.F3_CFO,1) >='5' AND SF3.F3_TIPO =  'B' THEN (SELECT A2_NOME FROM "+RetSqlName("SA2")+" WHERE D_E_L_E_T_ =' ' AND A2_COD=SF3.F3_CLIEFOR AND A2_LOJA=SF3.F3_LOJA) " + CHR(10)
cQry += CRLF + "  WHEN LEFT(SF3.F3_CFO,1) < '5' AND SF3.F3_TIPO =  'D' THEN (SELECT A1_NOME FROM "+RetSqlName("SA1")+" WHERE D_E_L_E_T_ =' ' AND A1_COD=SF3.F3_CLIEFOR AND A1_LOJA=SF3.F3_LOJA) " + CHR(10)
cQry += CRLF + "  WHEN LEFT(SF3.F3_CFO,1) < '5' AND SF3.F3_TIPO <> 'D' THEN (SELECT A2_NOME FROM "+RetSqlName("SA2")+" WHERE D_E_L_E_T_ =' ' AND A2_COD=SF3.F3_CLIEFOR AND A2_LOJA=SF3.F3_LOJA) " + CHR(10)
cQry += CRLF + "  END) Nome, " + CHR(10)
cQry += CRLF + " (CASE "  + CHR(10)
cQry += CRLF + "  WHEN LEFT(SF3.F3_CFO,1) >='5' THEN 'SAIDA' "  + CHR(10)
cQry += CRLF + "  WHEN LEFT(SF3.F3_CFO,1) < '5' THEN 'ENTRADA' "  + CHR(10)
cQry += CRLF + "  END ) TIPOMOV  "  + CHR(10)
cQry += CRLF + " FROM "+RetSqlName("SF3")+" AS SF3 WHERE "
cQry += CRLF + " SF3.F3_EMISSAO BETWEEN '"+dDataDe+"' AND '"+dDataAte+"' AND SF3.F3_DTCANC <> '' AND SF3.D_E_L_E_T_ <> '*' "  + CHR(10)
cQry += CRLF + " AND SF3.F3_ESPECIE <>'CF' AND SF3.F3_TIPO <>'S' "  + CHR(10)
cQry += CRLF + " AND SF3.F3_FILIAL = '"+cFilAnt+"' COLLATE database_default"

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),'MQRY',.T.)
If MQRY->(Eof())
	MsgAlert('Não existe nenhuma nota cancelada/inutilizada para listar.')
	Return Nil
EndIf

aStruSF3 := SF3->(dbStruct())
For nI := 1 To Len(aStruSF3)
	If aStruSF3[nI,2] <> 'C'
		TCSetField('MQRY',aStruSF3[nI,1],aStruSF3[nI,2],aStruSF3[nI,3],aStruSF3[nI,4])
	EndIf
Next nI

cArqTmp := 'MyRNFCan' + DTOS(Date()) + StrTran(Time(), ':', '') + '.dbf'

Copy To &cArqTmp

//TCCanOpen
//MsCreate(cArqTmp,'TOPCONN')
//MsErase(cArqTmp)
//TcDelFile()

MQRY->(dbCloseArea())
dbUseArea(.T.,'DBFCDX',cArqTMP,'MQRY',.T.)

While !MQRY->(Eof())
	RecLock('MQRY',.F.)
	MQRY->USRA := UsrRetName( SubStr( Embaralha( F3_USERLGA, 1 ), 3, 6 ) )
	MQRY->USRI := UsrRetName( SubStr( Embaralha( F3_USERLGI, 1 ), 3, 6 ) )
	MQRY->(MsUnlock())
	MQRY->(dbSkip())
EndDo

MQRY->(dbGoTop())
MQRY->(dbCloseArea())

cRelat := 'MyRNFCan'
CallIReport(cRelat,{'1',1,.T.,.F.})

Return Nil

Static Function CriaSX1(cPerg)

Local nTamGrp := Len(SX1->X1_GRUPO)
Local aHelpPor := {}, aHelpEng := {}, aHelpSpa := {}
Local cNome

aHelpPor := {}
aAdd(aHelpPor, 'Informe a data inicial/final para    ')
aAdd(aHelpPor, 'geração do relatório.                ')
cNome := 'Data de'
PutSx1(PadR(cPerg,nTamGrp), '01', cNome, cNome, cNome,;
'MV_CH1', 'D', 8, 0, 0, 'G', '', '', '', '', 'MV_PAR01',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

cNome := 'Data ate'
PutSx1(PadR(cPerg,nTamGrp), '02', cNome, cNome, cNome,;
'MV_CH2', 'D', 8, 0, 0, 'G', '', '', '', '', 'MV_PAR02',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
*/
#Include "RWMAKE.CH"
#Include "PROTHEUS.CH" 

/*/
+-----------+-----------+-------+-------------------------+------+----------+
| Funcao    | MySpedCTe | Autor | Ewerton Carreira        | Data | 03/06/14 |
+-----------+-----------+-------+-------------------------+------+----------+
| Descricao | Relatorio de comparação entre SFT/SF3 X SPED054               |
+-----------+---------------------------------------------------------------+
| Sintaxe   | MySpedCTe()                                                   |
+-----------+---------------------------------------------------------------+
| Uso       | Fiscal                                                        |
+-----------+---------------------------------------------------------------+
| ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO NICIAL                           |
+-----------+--------+------------------------------------------------------+
|Programador| Data   | Motivo da Alteracao                                  | 
+-----------+--------+------------------------------------------------------+
|           |        |                                                      |
+-----------+--------+------------------------------------------------------+
/*/

User Function MySpedCTe()                   
//+----------------------------------------------------------------+
//| Definicao de variaveis                                         |
//+----------------------------------------------------------------+
Local _cTitulo	:= 'Relatorio de SFT X Sped054'
Local _cArq 	:= 'MySpedCTe'
Local _cAux
Local _aExcel 	:= {}  
Local _cNomCliFor      
Local _cNfeID
Local _cNfeChv
Local _cStat
Local _cMot
Local _cProt                     
Local _lAtu := .F.

Private cPerg       	:= "MYSPEDCTE"
Private cString 		:= "TMPSFT"
Private _cQrySFT
Private _cQry054

//+----------------------------------------------------------------+
//| mv_par01			Tipo Movimento?             					    |
//| mv_par02			Da Entrada?             					       |
//| mv_par03			Ate Entrada?             					       |
//| mv_par04			Atualiza Chave?         		                |
//| mv_par04			Atualiza Chave?         		                |
//| mv_par05			Origem? (SFT ou SF3      		                |
//+----------------------------------------------------------------+
CriaSX1(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
EndIf

//+----------------------------------------------------------------+
//| Define a Query de extração de dados                            |
//+----------------------------------------------------------------+
If MV_PAR05 = 1	
	_cQrySFT := ""
	_cQrySFT += "SELECT "
	_cQrySFT += "	* "
	_cQrySFT += "FROM 
	_cQrySFT += "	" + RetSQLName("SFT") +  " "
	_cQrySFT += "WHERE "
	_cQrySFT += "	D_E_L_E_T_ <> '*' "
	_cQrySFT += "	AND FT_FILIAL = '" + xFilial("SFT") + "' "
	
	If MV_PAR01 == 1
		_cQrySFT += "	AND FT_TIPOMOV='E' "
	ElseIf MV_PAR01 == 2
		_cQrySFT += "	AND FT_TIPOMOV='S' "
	Endif
		                                     
	_cQrySFT += "	AND FT_ENTRADA BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "' "
	_cQrySFT += "	AND FT_ESPECIE IN ('SPED','CTE') "
	_cQrySFT += "	AND FT_CHVNFE='' "
	_cQrySFT += "ORDER BY "
	_cQrySFT += "	FT_TIPOMOV "
	_cQrySFT += "	,FT_NFISCAL "
	_cQrySFT += "	,FT_SERIE "
Else
	_cQrySFT := ""
	_cQrySFT += "SELECT "
	_cQrySFT += "	* "
	_cQrySFT += "FROM 
	_cQrySFT += "	" + RetSQLName("SF3") +  " "
	_cQrySFT += "WHERE "
	_cQrySFT += "	D_E_L_E_T_ <> '*' "
	_cQrySFT += "	AND F3_FILIAL = '" + xFilial("SF3") + "' "
	
	If MV_PAR01 == 1
		_cQrySFT += "	AND F3_CFO < '5000' "
	ElseIf MV_PAR01 == 2
		_cQrySFT += "	AND F3_CFO >= '5000' "
	Endif
		                                     
	_cQrySFT += "	AND F3_ENTRADA BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "' "
	_cQrySFT += "	AND F3_ESPECIE IN ('SPED','CTE') "
	_cQrySFT += "	AND F3_CHVNFE='' "
	_cQrySFT += "ORDER BY "
	_cQrySFT += "	F3_CFO "
	_cQrySFT += "	,F3_NFISCAL "
	_cQrySFT += "	,F3_SERIE "
Endif
	
//+----------------------------------------------------------------+
//| Cria a tabela temporaria                                       |
//+----------------------------------------------------------------+
_cQrySFT := ChangeQuery(_cQrySFT)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQrySFT),"TMPSFT",.F.,.T.)

//+----------------------------------------------------------------+
//| Cabecalho do relatorio                                         |
//+----------------------------------------------------------------+
aadd(_aExcel, {_cTitulo})
aadd(_aExcel, {'Relatório emitido em ' + DTOC(Date()) + ' às ' + Time() + ' por ' + Alltrim(cUsername)})
aadd(_aExcel, {'Período: ' + DTOC(mv_par02) + ' até ' + DTOC(mv_par03)})// + ' - Tipo: ' + mv_par01 + ' - Atualiza Chave: ' + mv_par04})
aadd(_aExcel, {''})
aadd(_aExcel, {'Empresa: '+cEmpAnt+'/'+cFilAnt+'-'+AllTrim(SM0->M0_NOME)+' / '+AllTrim(SM0->M0_FILIAL) + ' - CNPJ: '+Transform(SM0->M0_CGC,'@R 99.999.999/9999-99')})          
aadd(_aExcel, {''})

If MV_PAR05 = 1	
	aadd(_aExcel, {"INFORMAÇÕES SFT","","","","","","","","","","","","","","INFORMAÇÕES SPED054","","","",""})	
Else
	aadd(_aExcel, {"INFORMAÇÕES SF3","","","","","","","","","","","","","","INFORMAÇÕES SPED054","","","",""})	
Endif	

If MV_PAR05 = 1	
	aadd(_aExcel, {"Filial","Tipo Mov","Entrada","Emissão","Nota","Serie","Especie","Chave","Cli/For","Loja","Nome","PA","CFOP","Obs","CST","","ID NFE","CHV NFE","Status","Motivo","Protocolo"})	
Else
	aadd(_aExcel, {"Filial","CFOP","Entrada","Emissão","Nota","Serie","Especie","Chave","Cli/For","Loja","Nome","PA","Retorno","Obs","CST","","ID NFE","CHV NFE","Status","Motivo","Protocolo"})	
Endif

aadd(_aExcel, {''})

dbSelectArea("TMPSFT")
TMPSFT->(dbGotop())

//+----------------------------------------------------------------+
//| Corpo do relatorio                                             |
//+----------------------------------------------------------------+
While !TMPSFT->(EOF())

	If MV_PAR05 == 1
	   If TMPSFT->FT_tipomov == "E"
   		_cNomCliFor := Alltrim(Substr(Posicione("SA2",1,xFilial("SA2") + TMPSFT->FT_CLIEFOR + TMPSFT->FT_LOJA,"A2_NREDUZ"),1,20))
		Else
   		_cNomCliFor := Alltrim(Substr(Posicione("SA1",1,xFilial("SA1") + TMPSFT->FT_CLIEFOR + TMPSFT->FT_LOJA,"A1_NREDUZ"),1,20))
	 	Endif
	 Else
	   If TMPSFT->F3_CFO < "5000"
   		_cNomCliFor := Alltrim(Substr(Posicione("SA2",1,xFilial("SA2") + TMPSFT->F3_CLIEFOR + TMPSFT->F3_LOJA,"A2_NREDUZ"),1,20))
		Else
   		_cNomCliFor := Alltrim(Substr(Posicione("SA1",1,xFilial("SA1") + TMPSFT->F3_CLIEFOR + TMPSFT->F3_LOJA,"A1_NREDUZ"),1,20))
	 	Endif
	Endif	 

	_cQry054 := ""
	_cQry054 += "SELECT "
	_cQry054 += "	* "
	_cQry054 += "FROM "
	_cQry054 += "	SPED054 "
	_cQry054 += "	,SPED001 "
	_cQry054 += "WHERE "
	_cQry054 += "	SPED054.ID_ENT = SPED001.ID_ENT "
	_cQry054 += "	AND SPED054.D_E_L_E_T_<>'*' "
	_cQry054 += "	AND SPED001.D_E_L_E_T_<>'*' "
	_cQry054 += "	AND SPED001.CNPJ='" + SM0->M0_CGC + "' "   // 01259730000174
	_cQry054 += "	AND SPED054.CSTAT_SEFR IN ('100','101') "  
	If MV_PAR05 == 1
		_cQry054 += "	AND NFE_ID = '"+ strZero(Val(TMPSFT->FT_SERIE),3) + strZero(Val(FT_NFISCAL),9) + "' "
	Else
		_cQry054 += "	AND NFE_ID = '"+ strZero(Val(TMPSFT->F3_SERIE),3) + strZero(Val(F3_NFISCAL),9) + "' "
	Endif
	//+----------------------------------------------------------------+
	//| Cria a tabela temporaria                                       |
	//+----------------------------------------------------------------+
	_cQry054 := ChangeQuery(_cQry054)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry054),"TMP054",.F.,.T.) 

	_cNfeID  := ""
	_cNfeChv := ""
	_cStat	:= ""
	_cMot    := ""
	_cProt   := ""
	_lAtu    := .F.

	If !TMP054->(EOF())
		_cNfeID  := TMP054->NFE_ID
		_cNfeChv := TMP054->NFE_CHV
		_cStat	:= TMP054->CSTAT_SEFR
		_cMot    := TMP054->XMOT_SEFR
		_cProt   := TMP054->NFE_PROT
		_lAtu    := .T.

	Endif

	TMP054->(dbCloseArea())
	
	If MV_PAR05 = 1
		aadd(_aExcel, {TMPSFT->FT_FILIAL,TMPSFT->FT_TIPOMOV,STOD(TMPSFT->FT_ENTRADA),STOD(TMPSFT->FT_EMISSAO),TMPSFT->FT_NFISCAL,TMPSFT->FT_SERIE,TMPSFT->FT_ESPECIE,TMPSFT->FT_CHVNFE,TMPSFT->FT_CLIEFOR,TMPSFT->FT_LOJA,_cNomCliFor,TMPSFT->FT_ESTADO,TMPSFT->FT_CFOP,TMPSFT->FT_OBSERV,TMPSFT->FT_CLASFIS,"", _cNfeID, _cNfeChv, _cStat, _cMot, _cProt})	
   Else
		aadd(_aExcel, {TMPSFT->F3_FILIAL,TMPSFT->F3_CFO,STOD(TMPSFT->F3_ENTRADA),STOD(TMPSFT->F3_EMISSAO),TMPSFT->F3_NFISCAL,TMPSFT->F3_SERIE,TMPSFT->F3_ESPECIE,TMPSFT->F3_CHVNFE,TMPSFT->F3_CLIEFOR,TMPSFT->F3_LOJA,_cNomCliFor,TMPSFT->F3_ESTADO,TMPSFT->F3_CODRSEF,TMPSFT->F3_OBSERV,"","", _cNfeID, _cNfeChv, _cStat, _cMot, _cProt})	
   Endif

	//+----------------------------------------------------------------+
	//| Atualiza a Chave no SFT e SF3                                  |
	//+----------------------------------------------------------------+
	If MV_PAR05 == 1
		If MV_PAR04 == 2 .AND. _lAtu
			dbSelectArea("SFT")
			dbSetOrder(1)
			dbGotop()
					
			If dbSeek(xfilial("SFT") + TMPSFT->FT_TIPOMOV + TMPSFT->FT_SERIE + TMPSFT->FT_NFISCAL + TMPSFT->FT_CLIEFOR + TMPSFT->FT_LOJA)
				While !SFT->(eof()) .AND. SFT->FT_FILIAL == xFilial("SFT") .AND. SFT->FT_TIPOMOV == TMPSFT->FT_TIPOMOV .AND. SFT->FT_SERIE == TMPSFT->FT_SERIE .AND. SFT->FT_NFISCAL == TMPSFT->FT_NFISCAL .AND. SFT->FT_CLIEFOR == TMPSFT->FT_CLIEFOR .AND. SFT->FT_LOJA == TMPSFT->FT_LOJA
					If Reclock("SFT",.F.)
						SFT->FT_CHVNFE := _cNfeChv
						msUnlock()
						SFT->(dbSkip())
					Endif
				Enddo
			Endif
	
			dbSelectArea("SF3")
			dbSetOrder(1)
			dbGotop()
			
			If dbSeek(xfilial("SF3") + TMPSFT->FT_ENTRADA + TMPSFT->FT_NFISCAL + TMPSFT->FT_SERIE + TMPSFT->FT_CLIEFOR + TMPSFT->FT_LOJA + TMPSFT->FT_CLASFIS)
				While !SF3->(eof()) .AND. SF3->F3_FILIAL == xFilial("SF3") .AND. SF3->F3_ENTRADA == TMPSFT->FT_ENTRADA .AND. SF3->F3_NFISCAL == TMPSFT->FT_NFISCAL .AND. SF3->F3_SERIE == TMPSFT->FT_SERIE .AND. SFT->FT_CLIEFOR == TMPSFT->F3_CLIEFOR .AND. SF3->FT_LOJA == TMPSFT->F3_LOJA .AND. SF3->F3_CFO == TMPSFT->FT_CLASFIS
					If Reclock("SF3",.F.)
						SF3->F3_CHVNFE := _cNfeChv
						SF3->(dbSkip())
						msUnlock()
					Endif
				Enddo
			Endif
		
		Endif
	EndIf

   TMPSFT->(dbSkip())



Enddo
              
//+----------------------------------------------------------------+
//| Envio para o Excel                                             |
//+----------------------------------------------------------------+
_cAux := Alltrim(cGetfile('CSV (*.csv)|*.csv', 'Selecione o diretório onde será salvo o relatório', 1, 'C:\', .T., NOR(GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NETWORKDRIVE, GETF_RETDIRECTORY ), .F., .T.))

If _cAux <> ''
	_cAux := Substr(_cAux ,1 ,RAT('\' ,_cAux)) + _cArq
	_cAux := _cAux + '-' + DTOS(Date()) + '-' + Strtran(Time(), ':', '') + '.csv'
	_cRet := U_MYARRCSV(_aExcel ,_cAux ,NIL ,_cTitulo)

	If _cRet <> ''
		Alert(_cRet)
	Endif
Else
	Alert('A geração do relatório foi cancelada!')
Endif

//+----------------------------------------------------------------+
//| Destroi a tabela temporaria                                    |
//+----------------------------------------------------------------+
TMPSFT->(dbCloseArea())
Return(Nil)

/* -------------- */

Static Function CriaSX1(cPerg)

Local nTamGrp := Len(SX1->X1_GRUPO)
Local aHelpPor := {}, aHelpEng := {}, aHelpSpa := {}
Local cNome

aHelpPor := {}
aAdd(aHelpPor, 'Selecione o tipo de movimento.       ')
cNome := 'Tipo Movimento'
PutSx1(PadR(cPerg,nTamGrp), '01', cNome, cNome, cNome,;
'MV_CH1', 'N', 1, 0, 3, 'C', '', '', '', '', 'MV_PAR01',;
'Entrada', 'Entrada', 'Entrada', '',;
'Saída', 'Saída', 'Saída',;
'Ambos', 'Ambos', 'Ambos',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Informe a data inicial/final para    ')
aAdd(aHelpPor, 'geração do relatório.                ')
cNome := 'Da Entrada'
PutSx1(PadR(cPerg,nTamGrp), '02', cNome, cNome, cNome,;
'MV_CH2', 'D', 8, 0, 0, 'G', '', '', '', '', 'MV_PAR02',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

cNome := 'Ate Entrada'
PutSx1(PadR(cPerg,nTamGrp), '03', cNome, cNome, cNome,;
'MV_CH3', 'D', 8, 0, 0, 'G', '', '', '', '', 'MV_PAR03',;
'', '', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Selecione se deseja atualizar a chave')
aAdd(aHelpPor, 'nas tabelas SFT e SF3 conforme a     ')
aAdd(aHelpPor, 'SPED054 se existir.                  ')
cNome := 'Atualiza Chave'
PutSx1(PadR(cPerg,nTamGrp), '04', cNome, cNome, cNome,;
'MV_CH4', 'N', 1, 0, 1, 'C', '', '', '', '', 'MV_PAR04',;
'Não', 'Não', 'Não', '',;
'Sim', 'Sim', 'Sim',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

aHelpPor := {}
aAdd(aHelpPor, 'Selecione a tabela origem onde serão ')
aAdd(aHelpPor, 'buscadas as notas.                   ')
cNome := 'Origem'
PutSx1(PadR(cPerg,nTamGrp), '05', cNome, cNome, cNome,;
'MV_CH5', 'N', 1, 0, 1, 'C', '', '', '', '', 'MV_PAR05',;
'SFT', 'SFT', 'SFT', '',;
'SF3', 'SF3', 'SF3',;
'', '', '',;
'', '', '',;
'', '', '',;
aClone(aHelpPor), aClone(aHelpEng), aClone(aHelpSpa))

Return Nil
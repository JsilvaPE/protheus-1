#include 'rwmake.ch'
#include 'protheus.ch'
///////////////////////////////////////////////////////////////////////////////
User Function SPEDRTMS()
///////////////////////////////////////////////////////////////////////////////
// Data : 04/06/2014
// User : Thieres Tembra
// Desc : Este ponto de entrada tem como finalidade retornar um array com as
//        informações dos conhecimentos de transportes para os clientes que não
//        utilizam o módulo Gestão de Transportes.É utilizado na geração do
//        "Bloco documentos fiscais II serviço (ICMS)" para os Registros:
//        D100, D110, D120, D130, D140, D150, D160, D161, D162 e D190.
// Ação : Gera os registros D130/D140/D160 referente ao Conhecimento de Frete
//        O ponto de entrada já existia anteriormente, mas foi totalmente
//        reescrito durante o Projeto SPED, pois as informações enviadas não
//        estavam corretas.
///////////////////////////////////////////////////////////////////////////////
Local nPos    := Paramixb[1] //Posição do Array 										
Local cReg    := Paramixb[2] //Registro do Documento										
Local cAlias  := Paramixb[3] //contendo alias da tabela temporária de processamento do SPED.										
Local aDoc    := Paramixb[4] //contendo dados do documento fiscal
Local aRet    := {}
Local aLinha  := {}
Local cNum    := aDoc[1]
Local cSer    := aDoc[2]
Local cCli    := aDoc[3]
Local cLoj    := aDoc[4]
Local cCFOP   := aDoc[9]
Local aAreas  := {'SFT','SF2','SA1','SZY','XA1'}
Local aSvArea := {}
Local cCGCOri, cCGCDes, cIEOri, cIEDes
Local cConsig, cMunOri, cMunDes, cValLiqF, cValFrt
Local cRedesp, cIndFrt, cPlaca, cUFPlaca
Local cIrim, cViagem, cValAFRMM

cCGCOri := cCGCDes := cIEOri    := cIEDes   := ''
cConsig := cMunOri := cMunDes   := cValLiqF := cValFrt := ''
cRedesp := cIndFrt := cPlaca    := cUFPlaca := ''
cIrim   := cViagem := cValAFRMM := ''

//somente saída
If Left(cCFOP,1) >= '5'
	//salva áreas atuais
	aSvArea := U_MyArea(aAreas, .T.)
	
	//posicionando no livro fiscal
	SFT->(dbSetOrder(1))
	If !SFT->(dbSeek( xFilial('SFT') + 'S' + cSer + cNum + cCli + cLoj ))
		Alert('Documento ' + cNum + '/' + cSer + ' não encontrado no ' +;
		'livro fiscal de saída. O registro ' + cReg + ' não será ' +;
		'gerado corretamente para o SPED Fiscal.')
		U_MyArea(aSvArea, .F.)
		Return aRet
	EndIf
	
	If AllTrim(SFT->FT_ESPECIE) == 'CTE'
		//não executa para CT-e
		U_MyArea(aSvArea, .F.)
		Return aRet
	EndIf
	
	If SFT->FT_DTCANC <> CTOD('') .or. 'CANCELAD' $ AllTrim(SFT->FT_OBSERV)
		//nota cancelada, pula verificação
		U_MyArea(aSvArea, .F.)
		Return aRet
	EndIf
	
	//posicionando na nota fiscal de saída
	SF2->(dbSetOrder(1))
	If !SF2->(dbSeek( xFilial('SF2') + cNum + cSer + cCli + cLoj ))
		Alert('Documento ' + cNum + '/' + cSer + ' não encontrado entre ' +;
		'as notas fiscais de saída. O registro ' + cReg + ' não será ' +;
		'gerado corretamente para o SPED Fiscal.')
		U_MyArea(aSvArea, .F.)
		Return aRet
	EndIf
	
	//consignatário
	If (SF2->F2_REMETEN + SF2->F2_LOJAFIN) <> (SF2->F2_CONTRAT + SF2->F2_LOJACON) .and.;
	(SF2->F2_CLIENT + SF2->F2_LOJENT) <> (SF2->F2_CONTRAT + SF2->F2_LOJACON)
		cConsig := 'SA1' + xFilial('SF2') + SF2->F2_CONTRAT + SF2->F2_LOJACON
	EndIf
	
	//posicionando remetente
	SA1->(dbSetOrder(1))
	If !SA1->(dbSeek( xFilial('SA1') + SF2->F2_REMETEN + SF2->F2_LOJAFIN ))
		Alert('Documento ' + cNum + '/' + cSer + '. ' +;
		'Remetente ' + SF2->F2_REMETEN + '/' + SF2->F2_LOJAFIN + ' não ' +;
		'encontrado no cadastro de clientes. O registro ' + cReg + ' não será ' +;
		'gerado corretamente para o SPED Fiscal.')
		U_MyArea(aSvArea, .F.)
		Return aRet
	EndIf
	//cnpj remetente
	cCGCOri := AllTrim(SA1->A1_CGC)
	//inscrição estadual remetente
	cIEOri  := StrTran(StrTran(StrTran(SA1->A1_INSCR, '.', ''), '-', ''), ' ', '')
	If 'ISENT' $ cIEOri
		cIEOri := ''
	EndIf
	//município origem
	cMunOri := AllTrim(RetUF(SA1->A1_EST) + SA1->A1_COD_MUN)
	
	//posicionando destinatário
	SA1->(dbSetOrder(1))
	If !SA1->(dbSeek( xFilial('SA1') + SF2->F2_CLIENT + SF2->F2_LOJENT ))
		Alert('Documento ' + cNum + '/' + cSer + '. ' +;
		'Destinatário ' + SF2->F2_CLIENT + '/' + SF2->F2_LOJENT + ' não ' +;
		'encontrado no cadastro de clientes. O registro ' + cReg + ' não será ' +;
		'gerado corretamente para o SPED Fiscal.')
		U_MyArea(aSvArea, .F.)
		Return aRet
	EndIf
	//cnpj destinatário
	cCGCDes := AllTrim(SA1->A1_CGC)
	//inscrição estadual destinatário
	cIEDes  := StrTran(StrTran(StrTran(SA1->A1_INSCR, '.', ''), '-', ''), ' ', '')
	If 'ISENT' $ cIEDes
		cIEDes := ''
	EndIf
	//município destino
	cMunDes := AllTrim(RetUF(SA1->A1_EST) + SA1->A1_COD_MUN)
	
	//valor do frete líquido
	cValLiqF := AllTrim(Transform(SF2->F2_VALBRUT - SF2->F2_VALICM - SF2->F2_VALISS, '@E 999999999.99'))
	
	//valor do frete total (bruto)
	cValFrt := AllTrim(Transform(SF2->F2_VALBRUT, '@E 999999999.99'))
		
	//Complemento de Frete Rodoviário
	If cReg == 'D130'
		//redespachante
		cRedesp  := ''
		
		//indicador de frete
		If cConsig <> ''
			cIndFrt := '9'
		ElseIf SF2->F2_TPFRETE == 'C'
			cIndFrt := '1'
		ElseIf SF2->F2_TPFRETE == 'F'
			cIndFrt := '2'
		Else
			cIndFrt := '0'
		EndIf
		
		//verifica existência de veículo
		If AllTrim(SF2->F2_VEICUL1) <> ''
			//posicionando veículo
			XA1->(dbSetOrder(1))
			If !XA1->(dbSeek( xFilial('XA1') + SF2->F2_VEICUL1 ))
				Alert('Documento ' + cNum + '/' + cSer + '. ' +;
				'Veículo ' + SF2->F2_VEICUL1 + ' não encontrado. O registro ' +;
				cReg + ' não será gerado corretamente para o SPED Fiscal.')
				U_MyArea(aSvArea, .F.)
				Return aRet
			EndIf
			
			//placa do veículo
			cPlaca := StrTran(StrTran(XA1->XA1_CODIGO, '-', ''), ' ', '')
			
			//uf da placa
			cUFPlaca := AllTrim(XA1->XA1_UFPLAC)
		EndIf
		
		aLinha := {}
		aAdd(aLinha, 'D130'		) //01 - Código do registro
		aAdd(aLinha, cConsig		) //02 - Código do participante consignatário
		aAdd(aLinha, cRedesp		) //03 - Código do participante redespachante
		aAdd(aLinha, cIndFrt		) //04 - Indicador do tipo de frete de operação
		aAdd(aLinha, cMunOri		) //05 - Código do município de origem do serviço
		aAdd(aLinha, cMunDes		) //06 - Código do município de destino do serviço
		aAdd(aLinha, cPlaca		) //07 - Placa de identificação do veículo
		aAdd(aLinha, cValLiqF	) //08 - Valor líquido de frete
		aAdd(aLinha, '0'			) //09 - Soma de valores de Sec/Cat
		aAdd(aLinha, '0'			) //10 - Soma de valores de despacho
		aAdd(aLinha, '0'			) //11 - Soma dos valores de pedágio
		aAdd(aLinha, '0'			) //12 - Outros valores
		aAdd(aLinha, cValFrt		) //13 - Valor total do frete
		aAdd(aLinha, cUFPlaca	) //14 - Sigla da UF da placa do veículo
		aAdd(aRet, aClone(aLinha))

	//Complemento de Frete Aquaviário
	ElseIf cReg == 'D140'
		//verifica existência de viagem
		If AllTrim(SF2->F2_VIAGEM) <> ''
			//posicionando viagem
			SZY->(dbSetOrder(1))
			If !SZY->(dbSeek( xFilial('SZY') + SF2->F2_VIAGEM ))
				Alert('Documento ' + cNum + '/' + cSer + '. ' +;
				'Viagem ' + SF2->F2_VIAGEM + ' não encontrada. O registro ' +;
				cReg + ' não será gerado corretamente para o SPED Fiscal.')
				U_MyArea(aSvArea, .F.)
				Return aRet
			EndIf
			
			//posicionamento empurrador
			XA1->(dbSetOrder(1))
			If !XA1->(dbSeek( xFilial('XA1') + SZY->ZY_EMPURRA ))
				Alert('Documento ' + cNum + '/' + cSer + '. ' +;
				'Empurrador ' + SZY->ZY_EMPURRA + ' não encontrado. O registro ' +;
				cReg + ' não será gerado corretamente para o SPED Fiscal.')
				U_MyArea(aSvArea, .F.)
				Return aRet
			EndIf
			
			//irim do navio
			cIrim := AllTrim(XA1->XA1_CODIGO)
			
			//número da viagem
			cViagem := AllTrim(SF2->F2_VIAGEM)
		EndIf
		
		//valor do afrmm
		cValAFRMM := AllTrim(Transform(SF2->F2_AFRVAL + SF2->F2_AF2VAL, '@E 999999999.99'))
		
		aLinha := {}
		aAdd(aLinha, 'D140'		) //01 - Código do registro
		aAdd(aLinha, cConsig		) //02 - Código do participante consignatário
		aAdd(aLinha, cMunOri		) //03 - Código do município de origem do serviço
		aAdd(aLinha, cMunDes		) //04 - Código do município de destino do serviço
		aAdd(aLinha, '1'			) //05 - Indicador do tipo do veículo transportador (1=Empurrador/Rebocador)
		aAdd(aLinha, cIrim		) //06 - Identificação da embarcação
		aAdd(aLinha, '0'			) //07 - Indicador do tipo da navegação (0=Interior)
		aAdd(aLinha, cViagem		) //08 - Número da viagem
		aAdd(aLinha, cValLiqF	) //09 - Valor líquido do frete
		aAdd(aLinha, '0'			) //10 - Valor das despesas portuárias
		aAdd(aLinha, '0'			) //11 - Valor das despesas com carga e descarga
		aAdd(aLinha, '0'			) //12 - Outros valores
		aAdd(aLinha, cValFrt		) //13 - Valor bruto do frete
		aAdd(aLinha, cValAFRMM	) //14 - Valor adicional do frete para renovação da Marinha Mercante
		aAdd(aRet, aClone(aLinha))
		
	//Carga Transportada
	ElseIf cReg == 'D160'
	
		aLinha := {}
		aAdd(aLinha, 'D160'		) //01 - Código do registro
		aAdd(aLinha, ''			) //02 - Identificação do número do despacho
		aAdd(aLinha, cCGCOri		) //03 - CNPJ ou CPF do remetente das mercadorias que constam na nota fiscal
		aAdd(aLinha, cIEOri		) //04 - Inscrição Estadual do remetente das mercadorias que constam na nota fiscal
		aAdd(aLinha, cMunOri		) //05 - Código do Município de origem
		aAdd(aLinha, cCGCDes		) //06 - CNPJ ou CPF do destinatário das mercadorias que constam na nota fiscal
		aAdd(aLinha, cIEDes		) //07 - Inscrição Estadual do destinatário das mercadorias que constam na nota fiscal
		aAdd(aLinha, cMunDes		) //08 - Código do Município de destino
		aAdd(aRet, aClone(aLinha))
		
	EndIf
	
	//restaura áreas salvas
	U_MyArea(aSvArea, .F.)
EndIf

Return aRet

/* ------------------- */

Static Function RetUF(cUF)

Local nPos
Local cRet := '99'
Local aUF := {;
	{'RO','11'},;
	{'AC','12'},;
	{'AM','13'},;
	{'RR','14'},;
	{'PA','15'},;
	{'AP','16'},;
	{'TO','17'},;
	{'MA','21'},;
	{'PI','22'},;
	{'CE','23'},;
	{'RN','24'},;
	{'PB','25'},;
	{'PE','26'},;
	{'AL','27'},;
	{'SE','28'},;
	{'BA','29'},;
	{'MG','31'},;
	{'ES','32'},;
	{'RJ','33'},;
	{'SP','35'},;
	{'PR','41'},;
	{'SC','42'},;
	{'RS','43'},;
	{'MS','50'},;
	{'MT','51'},;
	{'GO','52'},;
	{'DF','53'},;
	{'EX','99'},;
}

nPos := aScan(aUF, {|x| x[1] == cUF})
If nPos > 0
	cRet := aUF[nPos][2]
EndIf

Return cRet
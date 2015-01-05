#Include "rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MapaUsu  � Autor �Carlos G. Berganton � Data �  16/02/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Mapeia Acessos dos Usuarios do Sistema                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MapaUsu()

//�������������������������Ŀ
//� Declaracao de Variaveis �
//���������������������������
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local imprime        := .T.
Local aOrd           := {"ID Usuario","Nome Usuario"}
Private titulo       := "Relatorio de Acessos dos Usuarios"
Private nLin         := 80
Private Cabec1       := ""
Private Cabec2       := ""
Private tamanho      := "M"
Private nomeprog     := "MapaUsu"
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private cPerg        := "MAPAUS"
Private m_pag        := 01
Private wnrel        := "MapaUsu"
Private cString      := ""

AjustSXB()

AjustSX1()

Pergunte(cPerg,.F.)

//�������������������������������������������Ŀ
//� Monta a interface padrao com o usuario... �
//���������������������������������������������
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  16/02/04   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem   := aReturn[8]
Local cAux     := ''
Local lAux     := .F.
Local aAux     := {}
Local aIdiomas := {"Portugues","Ingles","Espanhol"}
Local aTipoImp := {"Em Disco","Via Spool","Direto na Porta","E-Mail"}
Local aFormImp := {"Retrato","Paisagem"}
Local aAmbImp  := {"Servidor","Cliente"}
Local aColAcess:= {000,055,110}
Local aColMenus:= {000,044,088}
Local aAllUsers:= AllUsers()
Local aUser    := {}
Local i        := 0
Local k        := 0
Local j        := 0
Local aMenu

aModulos := fModulos()
aAcessos := fAcessos()

For i:=1 to len(aAllUsers)
	lFiltroGrp := .F.
	If	aAllUsers[i][01][01]>=mv_par01 .and. aAllUsers[i][01][01]<=mv_par02 .and.;
		aAllUsers[i][01][02]>=mv_par03 .and. aAllUsers[i][01][02]<=mv_par04
		
		//�����������������������������������������������������������Ŀ
		//� Se o usuario nao tiver um grupo, inclui um elemento vazio �
		//�������������������������������������������������������������
		If Len(aAllUsers[i][01][10])==0
			aAdd(aAllUsers[i][01][10],Space(06))
		Endif
		
		For k := 1 to Len(aAllUsers[i][01][10])
			If aAllUsers[i][01][10][k] >= mv_par05 .and.;
				aAllUsers[i][01][10][k] <= mv_par06
				aAdd(aUser,aAllUsers[i])
			Endif
		Next k
	Endif
Next i

//���������������
//� Indexa Aray �
//���������������
If nOrdem==1 //ID
	aSort(aUser,,,{ |aVar1,aVar2| aVar1[1][1] < aVar2[1][1]})
Else         //Usuario
	aSort(aUser,,,{ |aVar1,aVar2| aVar1[1][2] < aVar2[1][2]})
Endif

//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������
SetRegua(Len(aUser))

//�������������������Ŀ
//� Processa Usuarios �
//���������������������
For i:=1 to Len(aUser)
	IncRegua()
	
	//����������������������������������Ŀ
	//� Desconsidera Usu�rios Bloqueados �
	//������������������������������������
	If (aUser[i][01][17] .and. mv_par12==2) .or.;
	(aUser[i][01][23][2]==0 .and. aUser[i][01][23][3]==0 .and. aUser[i][01][23][1] .and. mv_par13==1) .or.;
	((aUser[i][01][23][2]<>0 .or. aUser[i][01][23][3]<>0) .and. aUser[i][01][23][1] .and. mv_par13==2) .or.;
	(!aUser[i][01][23][1] .and. mv_par13==2)
		Loop
	Endif
	
	//pega superiores
	aAux := Separa(aUser[i][1][11], '|')
	cAux := ''
	For k:=1 to Len(aAux)
		PswOrder(1)
		If PswSeek(aAux[k],.T.)
			aSuperior := PswRet(Nil)
			cAux += AllTrim(aSuperior[1][2]) + ', '
		EndIf
	Next k
	cAux := Left(cAux, Len(cAux)-2)
	//filtra superiores
	lAux := .F.
	If AllTrim(MV_PAR14) <> ''
		lAux := .T.
		aSuperior := Separa(AllTrim(MV_PAR14), ';')
		For k:=1 to Len(aSuperior)
			If AllTrim(aSuperior[k]) $ cAux
				//caso um superior digitado seja encontrado pro usu�rio, n�o pula
				lAux := .F.
				Exit
			EndIf
		Next k
	EndIf
	If lAux
		Loop
	EndIf
	
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 5
	
	@ nLin,000 pSay "I N F O R M A C O E S   D O   U S U A R I O"
	nLin+=1
	@ nLin,000 pSay "User ID.........................: "+aUser[i][01][01] //ID
	nLin+=1
	@ nLin,000 pSay "Usuario.........................: "+aUser[i][01][02] //Usuario
	nLin+=1
	@ nLin,000 pSay "Nome Completo...................: "+aUser[i][01][04] //Nome Completo
	nLin+=1
	@ nLin,000 pSay "Validade........................: "+DTOC(aUser[i][01][06]) //Validade
	nLin+=1
	@ nLin,000 pSay "Acessos para Expirar............: "+AllTrim(Str(aUser[i][01][07])) //Expira em n acessos
	nLin+=1
	@ nLin,000 pSay "Autorizado a Alterar Senha......: "+If(aUser[i][01][08],"Sim","Nao") //Autorizado a Alterar Senha
	nLin+=1
	@ nLin,000 pSay "Alterar Senha no Proximo LogOn..: "+If(aUser[i][01][09],"Sim","Nao") //Alterar Senha no Proximo LogOn
	nLin+=1
	@ nLin,000 pSay "Permite Alterar Data Base.......: "+If(aUser[i][01][23][1],If(aUser[i][01][23][2]==0 .and. aUser[i][01][23][3]==0,"Nao","Sim [Retroceder: "+cValToChar(aUser[i][01][23][2])+" dias |Avan�ar: "+cValToChar(aUser[i][01][23][3])+" dias]"),"Sim") //Alterar Data Base
	nLin+=1
	@ nLin,000 pSay "Superior........................: "+cAux //Superior
	nLin+=1
	@ nLin,000 pSay "Departamento....................: "+aUser[i][01][12] //Departamento
	nLin+=1
	@ nLin,000 pSay "Cargo...........................: "+aUser[i][01][13] //Cargo
	nLin+=1
	@ nLin,000 pSay "E-Mail..........................: "+aUser[i][01][14] //E-Mail
	nLin+=1
	@ nLin,000 pSay "Acessos Simultaneos.............: "+AllTrim(Str(aUser[i][01][15])) //Acessos Simultaneos
	nLin+=1
	@ nLin,000 pSay "Ultima Alteracao................: "+DTOC(aUser[i][01][16]) //Data da Ultima Alteracao
	nLin+=1
	@ nLin,000 pSay "Usuario Bloqueado...............: "+If(aUser[i][01][17],"Sim","Nao") //Usuario Bloqueado
	nLin+=1
	@ nLin,000 pSay "Digitos p/o Ano.................: "+AllTrim(STR(aUser[i][01][18])) //Numero de Digitos Para o Ano
	nLin+=1
	@ nLin,000 pSay "Idioma..........................: "+aIdiomas[aUser[i][02][02]] //Idioma
	nLin+=1
	@ nLin,000 pSay "Diretorio do Relatorio..........: "+aUser[i][02][03] //Diretorio de Relatorio
	nLin+=1
	@ nLin,000 pSay "Tipo de Impressao...............: "+aTipoImp[aUser[i][02][08]] // Tipo de Impressao
	nLin+=1
	@ nLin,000 pSay "Formato de Impressao............: "+aFormImp[aUser[i][02][09]] // Formato
	nLin+=1
	@ nLin,000 pSay "Ambiente de Impressao...........: "+aAmbImp[aUser[i][02][10]] // Ambiente
	nLin+=2
	
	//����������������Ŀ
	//� Imprime Grupos �
	//������������������
	@ nLin,000 pSay Replic("_",132)
	nLin+=1
	@nLin,000 pSay "G R U P O S"
	nLin+=2
	For k:=1 to Len(aUser[i][01][10])
		fCabec(@nLin,55)
		
		//�������������������������������������������������������������������������������������������������������Ŀ
		//� Verifica se Grupo eh vazio, pois em casos do usuario nao ter nenhum grupo sera adicionado um elemento �
		//� no Array com Space(06) para poder serconsiderado                                                      �
		//���������������������������������������������������������������������������������������������������������
		If !Empty(aUser[i][01][10][k])
			PswOrder(1)
			PswSeek(aUser[i][01][10][k],.f.)
			aGroup := PswRet(NIL)
			
			@ nLin,005 pSay aGroup[01][2] //Grupos
			nLin+=1
		Endif
	Next k
	nLin+=1
	
	//������������������Ŀ
	//� Imprime Horarios �
	//��������������������
	If mv_par07==1
		fCabec(@nLin,50)
		
		@ nLin,000 pSay Replic("_",132)
		nLin+=1
		@nLin,000 pSay "H O R A R I O S"
		nLin+=2
		For k:=1 to Len(aUser[i][02][01])
			fCabec(@nLin,55)
			
			@ nLin,005 pSay aUser[i][2][01][k] //Horarios
			nLin+=1
		Next k
		nLin+=1
	Endif
	
	//����������������������������Ŀ
	//� Imprime Empresas / Filiais �
	//������������������������������
	If mv_par08==1
		fCabec(@nLin,50)
		
		@ nLin,000 pSay Replic("_",132)
		nLin+=1
		@nLin,000 pSay "E M P R E S A S / F I L I A I S"
		nLin+=2
		For k:=1 to Len(aUser[i][02][06])
			fCabec(@nLin,55)
			
			dbSelectArea("SM0")
			dbSetOrder(1)
			dbSeek(aUser[i][02][06][k])
			@ nLin,005 pSay Substr(aUser[i][02][06][k],1,2)+"/"+Substr(aUser[i][02][06][k],3,2)+If(Found()," "+M0_NOME+" - "+M0_NOMECOM,If(Substr(aUser[i][02][06][k],1,2)=="@@"," - Todos","")) //Empresa / Filial
			nLin+=1
			
		Next k
		nLin+=1
	Endif
	
	//�������������������
	//� Imprime Modulos �
	//�������������������
	If mv_par09==1
		fCabec(@nLin,50)
		
		@ nLin,000 pSay Replic("_",132)
		nLin+=1
		@ nLin,000 pSay "M O D U L O S"
		nLin+=2
		//                        1         2         3         4         5         6         7         8
		//               123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
		@ nLin,000 pSay "MODULO                                               NIVEL ARQUIVO DO MENU"
		nLin+=1
		@ nLin,000 pSay "---------------------------------------------------- ----- --------------------------------------------"
		nLin+=1
		
		For k:=1 to Len(aUser[i][03])//Len(aModulos)
			If Substr(aUser[i][03][k],3,1) <> "X"
				If nLin > 58
					fCabec(@nLin,55)
					@ nLin,000 pSay "MODULO                                               NIVEL ARQUIVO DO MENU"
					nLin+=1
					@ nLin,000 pSay "---------------------------------------------------- ----- --------------------------------------------"
					nLin+=1
				Endif
				
				nPos := aScan(aModulos,{|x| x[1]==Left(aUser[i][03][k],2)})
				If !Empty(nPos)
					@ nLin,000 pSay aModulos[nPos][02]+" - "+aModulos[nPos][3]
					@ nLin,055 pSay Substr(aUser[i][03][k],3,1)
					@ nLin,059 pSay Substr(aUser[i][03][k],4)
					nLin+=1
				Else
					@ nLin,000 pSay 'DESCONHECIDO: ' + Left(aUser[i][03][k],2)
					@ nLin,055 pSay Substr(aUser[i][03][k],3,1)
					@ nLin,059 pSay aUser[i][03][k]
					nLin+=1
				Endif
			Endif
		Next k
		nLin+=1
	Endif
	
	//�������������������
	//� Imprime Acessos �
	//�������������������
	If mv_par10==1
		fCabec(@nLin,50)
		
		@ nLin,000 pSay Replic("_",132)
		nLin+=1
		@ nLin,000 pSay "A C E S S O S"
		nLin+=2
		
		nCol := 1
		For k:=1 to Len(aAcessos)
			cAux := ''
			If Substr(aUser[i][02][5],k,1) == "S"
				cAux := '[X] '
			Else
				cAux := '[ ] '
			EndIf
			fCabec(@nLin,55)
			@ nLin,aColAcess[nCol] pSay cAux + aAcessos[k]
			If nCol==3
				nCol:=1
				nLin+=1
			Else
				nCol+=1
			Endif
		Next k
	Endif
	
	//�����������������
	//� Imprime Menus �
	//�����������������
	
	If mv_par11==1
		fCabec(@nLin,50)
		
		@ nLin,000 pSay Replic("_",132)
		nLin+=1
		@ nLin,000 pSay "M E N U S"
		nLin+=2
		//                        1         2         3         4         5         6         7         8
		//               123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
		@ nLin,000 pSay "TITULO             PROGRAMA   ACESSOS       TITULO             PROGRAMA   ACESSOS       TITULO             PROGRAMA   ACESSOS"
		nLin+=1
		@ nLin,000 pSay "------------------ ---------- ----------    ------------------ ---------- ----------    ------------------ ---------- ----------"
		nLin+=1
		
		For k:=1 to Len(aUser[i][03])//Len(aModulos)
			If Substr(aUser[i][03][k],3,1) <> "X"
				aMenu := fGetMnu(Substr(aUser[i][03][k],4),aUser[i][01][02])
				
				nPos := aScan(aModulos,{|x| x[1]==Left(aUser[i][03][k],2)})
				If !Empty(nPos)
					nLin +=1
					@ nLin,000 pSay aModulos[nPos][02]+" - "+AllTrim(aModulos[nPos][3])+"  -->  "+Substr(aUser[i][03][k],4)
					nLin+=2
					
					nCol := 1
					For j:=1 to Len(aMenu)
						If nLin > 55
							fCabec(@nLin,55)
							@ nLin,000 pSay "TITULO             PROGRAMA   ACESSOS       TITULO             PROGRAMA   ACESSOS       TITULO             PROGRAMA   ACESSOS"
							nLin+=1
							@ nLin,000 pSay "------------------ ---------- ----------    ------------------ ---------- ----------    ------------------ ---------- ----------"
							nLin+=1
						Endif
						
						If !(aMenu[j][4] $ "T|F|E|D")
							Loop
						Endif
						
						@ nLin,aColMenus[nCol]+000 pSay If(Empty(aMenu[j][02])," ",aMenu[j][02])
						@ nLin,aColMenus[nCol]+019 pSay If(Empty(aMenu[j][03])," ",aMenu[j][03])
						@ nLin,aColMenus[nCol]+030 pSay If(Empty(aMenu[j][06])," ",aMenu[j][06])
						If nCol==3
							nCol:=1
							nLin+=1
						Else
							nCol+=1
						Endif
					Next
					nLin+=1
				Endif
			Endif
		Next k
		nLin+=1
	Endif
	
	Roda(,,"M")
	
Next i

//�������������������������������������Ŀ
//� Finaliza a execucao do relatorio... �
//���������������������������������������
SET DEVICE TO SCREEN

//������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao... �
//��������������������������������������������������������������
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fModulos �Autor  �Carlos G. Berganton � Data �  16/02/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna Array com Codigos e Nomes dos Modulos              ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fModulos()

Local aReturn

aReturn := {;
{"01","SIGAATF  ","Ativo Fixo                              "},;
{"02","SIGACOM  ","Compras                                 "},;
{"03","SIGACON  ","Contabilidade                           "},;
{"04","SIGAEST  ","Estoque/Custos                          "},;
{"05","SIGAFAT  ","Faturamento                             "},;
{"06","SIGAFIN  ","Financeiro                              "},;
{"07","SIGAGPE  ","Gestao de Pessoal                       "},;
{"08","SIGAFAS  ","Faturamento Servico                     "},;
{"09","SIGAFIS  ","Livros Fiscais                          "},;
{"10","SIGAPCP  ","Planej.Contr.Producao                   "},;
{"11","SIGAVEI  ","Veiculos                                "},;
{"12","SIGALOJA ","Controle de Lojas                       "},;
{"13","SIGATMK  ","Call Center                             "},;
{"14","SIGAOFI  ","Oficina                                 "},;
{"15","SIGARPM  ","Gerador de Relatorios Beta1             "},;
{"16","SIGAPON  ","Ponto Eletronico                        "},;
{"17","SIGAEIC  ","Easy Import Control                     "},;
{"18","SIGAGRH  ","Gestao de R.Humanos                     "},;
{"19","SIGAMNT  ","Manutencao de Ativos                    "},;
{"20","SIGARSP  ","Recrutamento e Selecao Pessoal          "},;
{"21","SIGAQIE  ","Inspecao de Entrada                     "},;
{"22","SIGAQMT  ","Metrologia                              "},;
{"23","SIGAFRT  ","Front Loja                              "},;
{"24","SIGAQDO  ","Controle de Documentos                  "},;
{"25","SIGAQIP  ","Inspecao de Projetos                    "},;
{"26","SIGATRM  ","Treinamento                             "},;
{"27","SIGAEIF  ","Importacao - Financeiro                 "},;
{"28","SIGATEC  ","Field Service                           "},;
{"29","SIGAEEC  ","Easy Export Control                     "},;
{"30","SIGAEFF  ","Easy Financing                          "},;
{"31","SIGAECO  ","Easy Accounting                         "},;
{"32","SIGAAFV  ","Administracao de Forca de Vendas        "},;
{"33","SIGAPLS  ","Plano de Saude                          "},;
{"34","SIGACTB  ","Contabilidade Gerencial                 "},;
{"35","SIGAMDT  ","Medicina e Seguranca no Trabalho        "},;
{"36","SIGAQNC  ","Controle de Nao-Conformidades           "},;
{"37","SIGAQAD  ","Controle de Auditoria                   "},;
{"38","SIGAQCP  ","Controle Estatistico de Processos       "},;
{"39","SIGAOMS  ","Gestao de Distribuicao                  "},;
{"40","SIGACSA  ","Cargos e Salarios                       "},;
{"41","SIGAPEC  ","Auto Pecas                              "},;
{"42","SIGAWMS  ","Gestao de Armazenagem                   "},;
{"43","SIGATMS  ","Gestao de Transporte                    "},;
{"44","SIGAPMS  ","Gestao de Projetos                      "},;
{"45","SIGACDA  ","Controle de Direitos Autorais           "},;
{"46","SIGAACD  ","Automacao Coleta de Dados               "},;
{"47","SIGAPPAP ","PPAP                                    "},;
{"48","SIGAREP  ","Replica                                 "},;
{"49","SIGAGAC  ","Gerenciamento Academico                 "},;
{"50","SIGAEDC  ","Easy DrawBack Control                   "},;
{"51","SIGAHSP  ","Gestao Hospitalar                       "},;
{"52","SIGADOC  ","Viewer                                  "},;
{"53","SIGAAPD  ","Avaliacao e Pesquisa de Desempenho      "},;
{"54","SIGAGSP  ","Gestao de Servi�os Publicos             "},;
{"55","SIGACRD  ","Sistema de Fidel.e Analise Credito      "},;
{"56","SIGASGA  ","Gestao Ambiental                        "},;
{"57","SIGAPCO  ","Planejamento e Controle Orcamentario    "},;
{"58","SIGAGPR  ","Gestao de Pesquisa e Resultados         "},;
{"59","SIGAGAC  ","Gestao de Acervos                       "},;
{"60","SIGAHEO  ","HRP Estrutura Organizacional            "},;
{"61","SIGAHGP  ","HRP Gestao de Pessoal                   "},;
{"62","SIGAHHG  ","HRP Ferramentas de Informacao           "},;
{"63","SIGAHPL  ","HRP Planejamento e Desenvolvimento      "},;
{"64","SIGAAPT  ","Acompanhamento de Processos Trabalhistas"},;
{"65","SIGAGAV  ","Gestao Advocaticia                      "},;
{"66","SIGAICE  ","Gestao de Riscos                        "},;
{"67","SIGAAGR  ","Gestao Agricolas - Graos                "},;
{"68","SIGAARM  ","Gestao de Armazens Gerais               "},;
{"69","SIGAGCT  ","Gestao de Contratos                     "},;
{"70","SIGAORG  ","Arquitetura Organizacional              "},;
{"71","SIGALVE  ","Locacao de Veiculos                     "},;
{"72","SIGAPHOTO","Controle de Lojas - Photo               "},;
{"73","SIGACRM  ","Costumer Relationship Management        "},;
{"74","SIGABPM  ","BPM - Business Process Management       "},;
{"75","SIGAAPON ","Apontamento/Ponto Eletronico            "},;
{"76","SIGAJURI ","Juridico                                "},;
{"77","SIGAPFS  ","Pre-Faturamento de Servicos             "},;
{"78","SIGAGFE  ","Gestao de Frete Embarcador              "},;
{"96","SIGAESP2 ","Especificos II                          "},;
{"97","SIGAESP  ","Especificos                             "},;
{"98","SIGAESP1 ","Especificos I                           "},;
{"99","SIGACFG  ","Configurador                            "}}

Return(aReturn)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fAcessos �Autor  �Carlos G. Berganton � Data �  16/02/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna os Acessos dos Sistema                             ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fAcessos()

Local aReturn

aReturn := {;
"Excluir Produtos                           ",;
"Alterar Produtos                           ",;
"Excluir Cadastros                          ",;
"Alterar Solicit. Compras                   ",;
"Excluir Solicit. Compras                   ",;
"Alterar Pedidos Compras                    ",;
"Excluir Pedidos Compras                    ",;
"Analisar Cotacoes                          ",;
"Relat Ficha Cadastral                      ",;
"Relat Bancos                               ",;
"Relacao Solicit. Compras                   ",;
"Relacao de Pedidos de Compras              ",;
"Alterar Estruturas                         ",;
"Excluir Estruturas                         ",;
"Alterar TES                                ",;
"Excluir TES                                ",;
"Inventario                                 ",;
"Fechamento Mensal                          ",;
"Proc Diferenca de Inventario               ",;
"Alterar Pedidos de Venda                   ",;
"Excluir Pedidos de Venda                   ",;
"Alterar Helps                              ",;
"Substituicao de Titulos                    ",;
"Inclusao de Dados Via F3                   ",;
"Rotina de Atendimento                      ",;
"Proc. Troco                                ",;
"Proc. Sangria                              ",;
"Bordero Cheques Pre-Datado                 ",;
"Rotina de Pagamento                        ",;
"Rotina de Recebimento                      ",;
"Troca de Mercadorias                       ",;
"Acesso Tabela de Precos                    ",;
"Abortar c/ Alt-C/Ctrl-Brk                  ",;
"Retorno Temporario p/ o DOS                ",;
"Acesso Condicao Negociada                  ",;
"Alterar DataBase do Sistema                ",;
"Alterar Empenhos de OP's                   ",;
"Pode Utilizar Debug                        ",;
"Form. Precos Todos os Niveis               ",;
"Configura Venda Rapida                     ",;
"Abrir/Fechar Caixa                         ",;
"Excluir Nota/Orc LOJA                      ",;
"Alterar Bem Ativo Fixo                     ",;
"Excluir Bem Ativo Fixo                     ",;
"Incluir Bem Via Copia                      ",;
"Tx Juros Condicao Negociada                ",;
"Liberacao Venda Forcad TEF                 ",;
"Cancelamento Venda TEF                     ",;
"Cadastra Moeda na Abertura                 ",;
"Altera Num. da NF                          ",;
"Emitir NF Retroativa                       ",;
"Excluir Baixa - Receber                    ",;
"Excluir Baixa - Pagar                      ",;
"Incluir Tabelas                            ",;
"Alterar Tabelas                            ",;
"Excluir Tabelas                            ",;
"Incluir Contratos                          ",;
"Alterar Contratos                          ",;
"Excluir Contratos                          ",;
"Uso Integracao SIGAEIC                     ",;
"Inclui Emprestimo                          ",;
"Alterar Emprestimo                         ",;
"Excluir Emprestimo                         ",;
"Incluir Leasing                            ",;
"Alterar Leasing                            ",;
"Excluir Leasing                            ",;
"Incluir Imp. Nao Financ.                   ",;
"Alterar Imp. Nao Financ.                   ",;
"Excluir Imp. Nao Financ.                   ",;
"Incluir Imp. Financ.                       ",;
"Alterar Imp. Financ.                       ",;
"Excluir Imp. Financ.                       ",;
"Incluir Imp. Fin.Export                    ",;
"Alterar Imp. Fin.Export                    ",;
"Excluir Imp. Fin.Export                    ",;
"Incluir Contrato                           ",;
"Alterar Contrato                           ",;
"Excluir Contrato                           ",;
"Lancar Taxa Libor                          ",;
"Consolidar Empresas                        ",;
"Incluir Cadastros                          ",;
"Alterar Cadastros                          ",;
"Incluir Cotacao Moedas                     ",;
"Alterar Cotacao Moedas                     ",;
"Excluir Cotacao Moedas                     ",;
"Incluir Corretoras                         ",;
"Alterar Corretoras                         ",;
"Excluir Corretoras                         ",;
"Incluir Imp./Exp./Cons                     ",;
"Alterar Imp./Exp./Cons                     ",;
"Excluir Imp./Exp./Cons                     ",;
"Baixar Solicitacoes                        ",;
"Visualiza Arquivo Limite                   ",;
"Imprime Doctos. Cancelados                 ",;
"Reativa Doctos. Cancelados                 ",;
"Consulta Doctos. Obsoletos                 ",;
"Imprime Doctos. Obsoletos                  ",;
"Consulta Doctos. Vencidos                  ",;
"Imprime Doctos. Vencidos                   ",;
"Def. Laudo Final Entrega                   ",;
"Imprime Param Relatorio                    ",;
"Transfere Pendencias                       ",;
"Usa Relatorio por E-Mail                   ",;
"Consulta posi��o cliente                   ",;
"Manuten. Aus. Temp. Todos                  ",;
"Manuten. Aus. Temp. Usu�rio                ",;
"Forma��o de Pre�o                          ",;
"Gravar Resposta Par�metros                 ",;
"Configurar Consulta F3                     ",;
"Permite alterar configura��o de impressora ",;
"Gerar Rel. em Disco Local                  ",;
"Gerar Rel. no Servidor                     ",;
"Incluir Solic. Compras                     ",;
"MBrowse - Visualiza outras filiais         ",;
"MBrowse - Edita registros de outras filiais",;
"MBrowse - Permite o uso de filtro          ",;
"F3 - Permite o uso de filtro               ",;
"MBrowse - Permite a configura��o de colunas",;
"Altera Or�amento Aprovado                  ",;
"Revisa Or�amento Aprovado                  ",;
"Usa impressora no Server                   ",;
"Usa impressora no Client                   ",;
"Agendar Processos/Relat�rios               ",;
"Processos id�nticos na MDI                 ",;
"Datas diferentes na MDI                    ",;
"Cad. Cli. no Cat�logo E-mail               ",;
"Cad. For. no Cat�logo E-mail               ",;
"Cad. Ven. no Cat�logo E-mail               ",;
"Impr. informa��es personalizadas           ",;
"Respeita par�metro MV_WFMESSE              ",;
"Aprovar/Rejeitar Pr�-estrutura             ",;
"Criar Estrutura com base em Pr�-estrutura  ",;
"Gerir Etapas                               ",;
"Gerir Despesas                             ",;
"Liberar Despesa para Faturamento           ",;
"Lib. Ped. Venda (credito)                  ",;
"Lib. Ped. Venda (estoque)                  ",;
"Habilitar op��o Executar (Ctrl+R)          ",;
"Permite incluir Ordem de Produ��o          ",;
"Acesso via ActiveX                         ";
}

Return(aReturn)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fCabec   �Autor  �Carlos G. Berganton � Data �  18/02/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Quebra de Pagina e Imprime Cabecalho                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fCabec(nLin,nLimite)

//������������������������������������������Ŀ
//� Impressao do cabecalho do relatorio. . . �
//��������������������������������������������
If nLin > nLimite
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 6
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fGetMnu   �Autor  �Carlos G. Berganton � Data �  15/03/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Obtem dados de um arquivo .mnu                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fGetMnu(cArq,cUsuario)

Local   aRet := {}
Local   aMenu:= {}
Private aTmp := {}

//���������������������������Ŀ
//� Verifica a Vers�o do Menu �
//�����������������������������
If Upper(Right(AllTrim(cArq),3))=="MNU"
	//������������������
	//� Abre o Arquivo �
	//������������������
	If File(cArq)
		ft_fuse(cArq)
	Else
		ApMsgAlert("Arquivo "+AllTrim(cArq)+" nao foi encontrado. Usuario "+AllTrim(cUsuario)+".")
		Return({})
	Endif
	
	While ! ft_feof()
		
		//���������������������Ŀ
		//� Le linha do Arquivo �
		//�����������������������
		cBuff := ft_freadln()
		aTmp := {}
		
		//��������������������������������Ŀ
		//� Monta Array com Dados da Linha �
		//����������������������������������
		aAdd(aTmp,Substr(cBuff,01,02))
		aAdd(aTmp,Substr(cBuff,03,18))
		aAdd(aTmp,Substr(cBuff,21,10))
		aAdd(aTmp,Substr(cBuff,31,01))
		aAdd(aTmp,{})
		For i:=32 to 89 Step 3
			If Substr(cBuff,i,3)<>"..."
				aAdd(aTmp[5],Substr(cBuff,i,3))
			Endif
		Next
		aAdd(aTmp,Substr(cBuff,122,10))
		
		//���������������������������Ŀ
		//� Abastece Array de Retorno �
		//�����������������������������
		aAdd(aRet,aTmp)
		
		ft_fskip()
	EndDo
	
	ft_fuse()
Elseif Upper(Right(AllTrim(cArq),3))=="XNU"
	aMenu := XNULOAD(cArq)
	//aMenu[i]						//-> Sub itens
	//aMenu[i][1][1]				//Nome -> Atualizacoes, etc
	//aMenu[i][3]					//-> Sub/Sub Itens
	//aMenu[i][3][k][1]			//Nome -> Cadastros
	//aMenu[i][3][k][3][j]		//Item do Menu
	//aMenu[i][3][k][3][j][2]	//Nome
	//aMenu[i][3][k][3][j][2]	//Status E=Enable
	//aMenu[i][3][k][3][j][3]	//Rotina
	//aMenu[i][3][k][3][j][4]	//Aliases (Array)
	//aMenu[i][3][k][3][j][5]	//Acessos xxxxxxxxxx
	//aMenu[i][3][k][3][j][6]	//Modulo
	//aMenu[i][3][k][3][j][7]	//Tipo
	
	
	For i:=1 to Len(aMenu) //Atualizacoes,Consultas,Relatorios,Miscelanea
		
		aAdd(aRet,fAddMnu(StrZero(i,2),aMenu[i][1][1],Space(10),aMenu[i][2],{},Space(10)))
		
		For k:=1 to Len(aMenu[i][3])//Cadastros,Solicitar/cotar,etc
			
			//������������������������������������Ŀ
			//� Verifica se � um Topico ou um Item �
			//��������������������������������������
			If Len(aMenu[i][3][k])==9
				aAdd(aRet,fAddMnu(StrZero(i,2),aMenu[i][3][k][1][1],aMenu[i][3][k][3],aMenu[i][3][k][2],aMenu[i][3][k][4],aMenu[i][3][k][5]))
			Else
				aAdd(aRet,fAddMnu(StrZero(i,2),aMenu[i][3][k][1][1],Space(10),aMenu[i][3][k][2],{},Space(10)))
				
				IF VALTYPE(aMenu[i][3][k][3]) == "A"
					_CONTADOR := Len(aMenu[i][3][k][3])
				ELSE
					_CONTADOR := 0
				ENDIF

				For _j:=1 to _CONTADOR
					//������������������������������������Ŀ
					//� Verifica se � um Topico ou um Item �
					//��������������������������������������
					If Len(aMenu[i][3][k][3][_j])==9
						aAdd(aRet,fAddMnu(StrZero(i,2),aMenu[i][3][k][3][_j][1][1],aMenu[i][3][k][3][_j][3],aMenu[i][3][k][3][_j][2],aMenu[i][3][k][3][_j][4],aMenu[i][3][k][3][_j][5]))
					Else
					
						aAdd(aRet,fAddMnu(StrZero(i,2),aMenu[i][3][k][3][_j][1][1],Space(10),aMenu[i][3][k][3][_j][2],{},Space(10)))
						For l:=1 to Len(aMenu[i][3][k][3][_j][3])
							///				aAdd(aRet,fAddMnu(StrZero(i,2),aMenu[i][3][k][3][j][3][l][1][1],aMenu[i][3][k][3][j][3][l][3],aMenu[i][3][k][3][j][3][l][2],aMenu[i][3][k][3][j][3][l][4],aMenu[i][3][k][3][j][3][l][5]))
							aAdd(aRet,fAddMnu(StrZero(i,2),aMenu[i][3][k][1][1],aMenu[i][3][k][3][_j][3],aMenu[i][3][k][2],{},Space(10)))
						Next l
					Endif
				Next _j
			Endif
		Next k
	Next i
Else
	Aviso("Inconsistencia...","Tipo de arquivo n�o suportado",{"Ok"})
Endif

Return(aRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fAddMnu  �Autor  � Gustavo Berganton  � Data �  15/03/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta Array de Item do Menu                                ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fAddMnu(cSubMenu,cNome,cFuncao,cStatus,aAlias,cAcessos)

Local aRet := {}
Local aTmp := {}

aAdd(aTmp,cSubMenu)
aAdd(aTmp,cNome)
aAdd(aTmp,cFuncao)
aAdd(aTmp,cStatus)
aAdd(aTmp,aAlias)
aAdd(aTmp,cAcessos)

//���������������������������Ŀ
//� Abastece Array de Retorno �
//�����������������������������
//aAdd(aRet,aTmp)

Return(aTMP)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AjustaSX1� Autor � Carlos G. Berganton   � Data � 15/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica as perguntas inclu�ndo-as caso n�o existam        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function AjustSX1()

Local aArea	    := GetArea()
Local cPerg		:= padr("MAPAUS",10)
Local aRegs		:= {}
Local i

AAdd(aRegs,{"01","Do ID?"                ,"mv_ch1","C",06,0,0,"G","mv_par01",""   ,""       ,""     ,"USR"})
AAdd(aRegs,{"02","Ate ID?"               ,"mv_ch2","C",06,0,0,"G","mv_par02",""   ,""       ,""     ,"USR"})
aadd(aRegs,{"03","Do Usu�rio?"           ,"mv_ch3","C",15,0,0,"G","mv_par03",""   ,""       ,""     ,"USN"})
aadd(aRegs,{"04","Ate Usu�rio?"          ,"mv_ch4","C",15,0,0,"G","mv_par04",""   ,""       ,""     ,"USN"})
aadd(aRegs,{"05","Do Grupo?"             ,"mv_ch5","C",06,0,0,"G","mv_par05",""   ,""       ,""     ,"GRP"})
aadd(aRegs,{"06","Ate Grupo?"            ,"mv_ch6","C",06,0,0,"G","mv_par06",""   ,""       ,""     ,"GRP"})
AAdd(aRegs,{"07","Imprimir Hor�rios?"    ,"mv_ch7","N",01,0,0,"C","mv_par07","Sim","Nao"    ,""     ,""})
AAdd(aRegs,{"08","Imprimir Emp/Filiais?" ,"mv_ch8","N",01,0,0,"C","mv_par08","Sim","Nao"    ,""     ,""})
AAdd(aRegs,{"09","Imprimir M�dulos?"     ,"mv_ch9","N",01,0,0,"C","mv_par09","Sim","Nao"    ,""     ,""})
AAdd(aRegs,{"10","Imprimir Acessos?"     ,"mv_cha","N",01,0,0,"C","mv_par10","Sim","Nao"    ,""     ,""})
AAdd(aRegs,{"11","Imprimir Menus?"       ,"mv_chb","N",01,0,0,"C","mv_par11","Sim","Nao"    ,""     ,""})
aAdd(aRegs,{"12","Imprimir Bloqueados?"  ,"mv_chc","N",01,0,0,"C","mv_par12","Sim","Nao"    ,""     ,""})
aAdd(aRegs,{"13","Pode Alterar Database?","mv_chd","N",01,0,0,"C","mv_par13","Sim","Nao"    ,"Ambos",""})
aAdd(aRegs,{"14","Superiores(Sup1;Sup2)?","mv_che","C",99,0,0,"G","mv_par14",""   ,""       ,""     ,""})

dbSelectArea("SX1")
dbSetOrder(1)
For i:=1 to Len(aRegs)
	dbSeek(cPerg+aRegs[i][1])
	If !Found() .or. aRegs[i][2]<>X1_PERGUNT .or. aRegs[i][01]<>X1_ORDEM
		RecLock("SX1",!Found())
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := aRegs[i][01]
		SX1->X1_PERGUNT := aRegs[i][02]
		SX1->X1_VARIAVL := aRegs[i][03]
		SX1->X1_TIPO    := aRegs[i][04]
		SX1->X1_TAMANHO := aRegs[i][05]
		SX1->X1_DECIMAL := aRegs[i][06]
		SX1->X1_PRESEL  := aRegs[i][07]
		SX1->X1_GSC     := aRegs[i][08]
		SX1->X1_VAR01   := aRegs[i][09]
		SX1->X1_DEF01   := aRegs[i][10]
		SX1->X1_DEF02   := aRegs[i][11]
		SX1->X1_DEF03   := aRegs[i][12]
		SX1->X1_F3      := aRegs[i][13]
		MsUnlock()
	Endif
Next

//������������������������������Ŀ
//� Deleta Parametros Excedentes �
//��������������������������������
While .t.
	dbSeek(cPerg+StrZero(Len(aRegs)+1,2),.t.)
	If X1_GRUPO==cPerg .and. Val(X1_ORDEM)>Val(aRegs[Len(aRegs)][1])
		RecLock("SX1",.f.)
		dbDelete()
		MsUnlock()
	Else
		Exit
	Endif
End

RestArea(aArea)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AjustaSXB� Autor � Marcos R. Coelho      � Data � 31/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica as consultas inclu�ndo-as caso n�o existam        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function AjustSXB()

local nXX
local aAreaSXB	:= SXB->( GetArea() )
Local aRegsSXB  := {}
Local cAliasSXB := "USN"

//				|ALIAS	|TIPO	|SEQ	|COLUNA	|DESCRI		|DESCSPA	|DESCENG	|CONTEM
aadd(aRegsSXB,	{	cAliasSXB, "1",	"01",	"US",	"Usu�rios",	"Usu�rios",	"Users",	""		})
aadd(aRegsSXB,	{	cAliasSXB, "5",	"01",	"",		"",			"",			"",			"NAME"	})

SXB->( dbsetorder(1) )
for nXX := 1 to len( aRegsSXB )
	if ! SXB->( dbseek( aRegsSXB[nXX,1] + aRegsSXB[nXX,2] + aRegsSXB[nXX,3] ) )
		RecLock("SXB",.T.)
		SXB->XB_ALIAS	:= aRegsSXB[nXX,1]
		SXB->XB_TIPO	:= aRegsSXB[nXX,2]
		SXB->XB_SEQ		:= aRegsSXB[nXX,3]
		SXB->XB_COLUNA	:= aRegsSXB[nXX,4]
		SXB->XB_DESCRI	:= aRegsSXB[nXX,5]
		SXB->XB_DESCSPA	:= aRegsSXB[nXX,6]
		SXB->XB_DESCENG	:= aRegsSXB[nXX,7]
		SXB->XB_CONTEM	:= aRegsSXB[nXX,8]
		SXB->( MsUnlock() )
	endif
next nXX

SXB->( RestArea( aAreaSXB ) )

return Nil


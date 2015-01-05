#Include 'rwmake.ch'
User Function MyInput(cTitulo, cMsg, cErro)
	Local cMotivo
	Local oDlg
	Public _cMyMoti
	
	If ValType(_cMyMoti) == 'U'
		_cMyMoti := ''
	EndIf
	
	cMotivo := Left(_cMyMoti+Space(255), 255)
	
	@ 000,000 To 085,420 Dialog oDlg Title OemToAnsi(cTitulo)
	@ 005,005 Say cMsg Size 200,10
	@ 015,005 Get cMotivo Size 200,10
	@ 030,178 BmpButton Type 01 Action (If(AllTrim(cMotivo)=='',Alert(cErro),Close(oDlg)))
	Activate Dialog oDlg Centered
	
Return AllTrim(cMotivo)
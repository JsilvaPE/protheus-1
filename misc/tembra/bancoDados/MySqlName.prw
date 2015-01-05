#include 'rwmake.ch'
#include 'protheus.ch'
User Function MySqlName(cTab, cEmp)

Local cRet   := ''
Local aArea  := GetArea()
Local cStart := AllTrim(GetSrvProfString('StartPath','\system\'))
Local cSX2

Default cEmp := cEmpAnt

If Left(cStart, 1) <> '\'
	cStart := '\' + cStart
EndIf

If Right(cStart, 1) <> '\'
	cStart += '\'
EndIf

cSX2 := cStart + 'SX2' + cEmp + '0.DBF'

dbUseArea(.T.,'DBFXCDX',cSX2,'MNAME',.F.,.F.)
MNAME->(dbGoTop())
While !MNAME->(Eof())
	If MNAME->X2_CHAVE == cTab
		cRet := MNAME->X2_ARQUIVO
		Exit
	EndIf
	MNAME->(dbSkip())
EndDo
MNAME->(dbCloseArea())

RestArea(aArea)

Return cRet
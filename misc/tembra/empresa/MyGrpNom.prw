#include 'rwmake.ch'
#include 'protheus.ch'
User Function MyGrpNom(nTipo)

Local cRet
Default nTipo := 1

cRet := Iif(nTipo==1,SM0->M0_NOME,SM0->M0_NOMECOM)

dbUseArea(.T.,'DBFCDX','\system\xx8.dbf','MXX8', .T., .F.)
MXX8->(dbSetOrder(2))
MXX8->(dbGoTop())
//                XX8_GRPEMP + XX8_CODIGO              + XX8_TIPO
If MXX8->(dbSeek( Space(12)  + PadR(SM0->M0_CODIGO,12) + '0' ))
	cRet := MXX8->XX8_DESCRI
EndIf
MXX8->(dbCloseArea())

cRet := AllTrim(cRet)

Return cRet
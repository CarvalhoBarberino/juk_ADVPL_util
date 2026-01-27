/*
	Funções uteis para tratamento de array no ADVPL.
*/

/*/{Protheus.doc} aGroupBy
	Funcao que agrupa
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function aGroupBy(aDados2D as array, nGroupeBy as Numeric)
	local aGroup2D			:= {} As Array
	local cGroupText		:= "" As Character
	local nFoundPos			:= 0 As Numeric
	local nDadosPos			:= 0 As Numeric
	local nCol
	local aQuant

	For nDadosPos := 1 To Len(aDados2D)
		cGroupText := iif(nGroupeBy != 0, aDados2D[nDadosPos][nGroupeBy], "")
		aQuant := {}

		for nCol := 1 to len(aDados2D[nDadosPos])
			aAdd(aQuant, aDados2D[nDadosPos][nCol])
		next

		nFoundPos := 0
		if Len(aGroup2D) > 0
			nFoundPos := aScan(aGroup2D, iif(nGroupeBy != 0, {|y| y[nGroupeBy] == cGroupText}, {|y| .T.}))
		endIf

		if nFoundPos == 0
			aAdd(aGroup2D, aQuant)
		Else
			for nCol := 1 to len(aDados2D[nDadosPos])
				if nCol != nGroupeBy .and. valType(aDados2D[nDadosPos][nCol]) == "N"
					aGroup2D[nFoundPos][nCol] += aQuant[nCol]
				else
					aGroup2D[nFoundPos][nCol] := aQuant[nCol]
				endIf
			next
		endIf
	Next
return aGroup2D

/*/{Protheus.doc} aSelByIndx
	Funcao que seleciona colunas
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function aSelByIndx(aOrig2D, aIndex)
	local aRet		:= {}
	local aItem		:= {}
	local nRow
	local nCol
	local nIndex

	for nRow := 1 to len(aOrig2D)
		aItem := {}
		for nIndex := 1 to len(aIndex)
			for nCol := 1 to len(aOrig2D[nRow])
				if aIndex[nIndex] == nCol
					aAdd(aItem, aOrig2D[nRow, nCol])
				endIf
			next
		next
		aAdd(aRet, aItem)
	next
return aRet

/*/{Protheus.doc} aToStr
	Funcao que transforma em string
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function aToStr(aDados2D, aMascara)
	local nRow
	local nCol
	local aRet := aClone(aDados2D)

	for nRow := 1 to len(aDados2D)
		for nCol := 1 to len(aDados2D[nRow])
			if valType(aDados2D[nRow, nCol]) == "N"
				aRet[nRow, nCol] := iif(!empty(aMascara[nCol]), Alltrim(Transform(aDados2D[nRow, nCol], aMascara[nCol])), Alltrim(cValToChar(aDados2D[nRow, nCol])))
			elseIf valType(aDados2D[nRow, nCol]) == "D"
				aRet[nRow, nCol] := allTrim(dToC(aDados2D[nRow, nCol]))
			elseIf valType(aDados2D[nRow, nCol]) == "C"
				aRet[nRow, nCol] := allTrim(aDados2D[nRow, nCol])
			endIf
		next
	next
return aRet

/*/{Protheus.doc} nSomaCol
	Funcao que soma coluna
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function nSomaCol(aDados2D, nCampo)
	local nRow		:= 0
	local nSoma		:= 0

	for nRow := 1 to len(aDados2D)
		if valType(aDados2D[nRow, nCampo]) == "N"
			nSoma += aDados2D[nRow, nCampo]
		endIf
	next
return nSoma

/*/{Protheus.doc} aEnumera
	Funcao que cria coluna enumerada
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function aEnumera(aOri, nShift)
	local aRet		:= {}
	local nRow		:= 0
	local nCol		:= 0

	for nRow := 1 to len(aOri)
		aAdd(aRet, {nRow + nShift})
		for nCol := 1 to len(aOri[nRow])
			aAdd(aRet[nRow], aOri[nRow, nCol])
		next
	next
return aRet

/*/{Protheus.doc} aPivot2D
	Funcao que pivoteia uma tabela
	@type static function
	@author Julio Carvalho Barberino
	@since 08/12/2025
	@version 0
/*/
static function aPivot2D(aEntrada, nOrdLin, nOrdCol, nColTarget)
	local aColunas	:= aGroupBy(aSelByIndx(aEntrada, {nOrdCol}), 1)
	local aLinhas	:= aGroupBy(aSelByIndx(aEntrada, {nOrdLin}), 1)
	local aPivotado	:= {}
	local nEnt		:= 1
	local nRow		:= 1
	local nCol		:= 1

	for nRow := 1 to len(aLinhas)
		aAdd(aPivotado, {})
		for nCol := 1 to len(aColunas)
			aAdd(aPivotado[nRow], 0)
			for nEnt := 1 to len(aEntrada)
				if aEntrada[nEnt, nOrdCol] == aColunas[nCol, 1] .and. aEntrada[nEnt, nOrdLin] == aLinhas[nRow, 1]
					aPivotado[nRow, nCol] := aEntrada[nEnt, nColTarget]
				endIf
			next
		next
	next
return aPivotado

/*/{Protheus.doc} aAppendCol
	Funcao que apenda matrizes uma a direita da outra (em coluna)
	@type static function
	@author Julio Carvalho Barberino
	@since 08/12/2025
	@version 0
/*/
static function aAppendCol(aTabOriE, aTabOriD)
	local aRet := aClone(aTabOriE)
	local nRow
	local nCol

	for nRow := 1 to len(aRet)
		for nCol := 1 to len(aTabOriD[nRow])
			aAdd(aRet[nRow], aTabOriD[nRow, nCol])
		next
	next
return aRet

/*/{Protheus.doc} aAppendLin
	Funcao que apenda matrizes uma abaixo da outra (em linha)
	@type static function
	@author Julio Carvalho Barberino
	@since 08/12/2025
	@version 0
/*/
static function aAppendLin(aTabOriUp, aTabOriDow)
	local aRet := aClone(aTabOriUp)
	local nRow

	for nRow := 1 to len(aTabOriDow)
		aAdd(aRet, aTabOriDow[nRow])
	next
return aRet

/*/{Protheus.doc} aTranspose
	Funcao que aplica tranposição matricial
	@type static function
	@author Julio Carvalho Barberino
	@since 08/12/2025
	@version 0
/*/
static function aTranspose(aRec)
	local aRet := {}
	local nCol
	local nRow

	for nCol := 1 to len(aRec[1])
		aAdd(aRet, {})
		for nRow := 1 to len(aRec)
			aAdd(aRet[nCol], aRec[nRow, nCol])
		next
	next
return aRet

/*
	Motivação inicial para criar essas funções se deu durante o desenvolvimento do relatório https://github.com/CarvalhoBarberino/RelatorioPvImpostosMF.
*/

/*
	Funções uteis para impressão com FWMsPrinter.
*/

/*/{Protheus.doc} grade
	Funcao que imprime grade
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function grade(nRowBase, nColBase, aHeights /*Array contendo a altura de cada linha*/, aWidths /*Array contendo a largura de cada coluna*/, oPrinterRec /*Objeto de impressão, do tipo FWMsPrinter, passado por referencia*/)
	local nHeiTot	:= 0
	local nWidTot	:= 0
	local nI
	local nHeiAux	:= 0
	local nWidAux	:= 0

	for nI := 1 to len(aHeights)
		nHeiTot += aHeights[nI]
	next
	for nI := 1 to len(aWidths)
		nWidTot += aWidths[nI]
	next

	oPrinterRec:Line(nRowBase, nColBase, nRowBase, nColBase + nWidTot, , "-2" )
	for nI := 1 to len(aHeights)
		nHeiAux += aHeights[nI]
		oPrinterRec:Line(nRowBase + nHeiAux, nColBase, nRowBase + nHeiAux, nColBase + nWidTot, , "-2" )
	next

	oPrinterRec:Line(nRowBase, nColBase, nRowBase + nHeiTot, nColBase, , "-2" )
	for nI := 1 to len(aWidths)
		nWidAux += aWidths[nI]
		oPrinterRec:Line(nRowBase, nColBase + nWidAux, nRowBase + nHeiTot, nColBase + nWidAux, , "-2" )
	next
return

/*/{Protheus.doc} printTab
	Funcao que imprime tabela
	@type static function
	@author Julio Carvalho Barberino
	@since 20/10/2025
	@version 0
/*/
static function printTab(nRowInicio, nColInicio, nRowHeight, aWidth /*Array com larguras das colunas*/, aAlign /*Array com alinhamentos das colunas*/, aFields /*Array com nomes dos campos*/, aData /*Array 2D com os dados*/, oPrinterRec /*Objeto de impressão, do tipo FWMsPrinter, passado por referencia*/)
	local nRowCount		:= 1
	local nColCount		:= 1
	local nRow_0		:= nRowInicio
	local nCol_0		:= nColInicio
	local nCol_1
	local nMargemCel	:= 3
	local oArial08		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 8 /*nHeight*/, .t./*compatibilidade .t.*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)
	local oArial08b		:= TFont():New("Arial" /*cName*/, /*uPar2*/, 8 /*nHeight*/, .t./*compatibilidade .t.*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, /*lItalic*/)

	if valType(aFields) != "U"
		for nColCount := 1 to len(aFields)
			nCol_1 := nCol_0 + aWidth[nColCount]
			oPrinterRec:Box(nRow_0, nCol_0, nRow_0 - nRowHeight, nCol_1, "-2")
			oPrinterRec:SayAlign(nRow_0 - nRowHeight, nCol_0 + nMargemCel, aFields[nColCount], oArial08b, aWidth[nColCount] - 2 * nMargemCel, nRowHeight, , 2, 0)
			nCol_0 := nCol_1
		next
	else
		nRow_0 -= nRowHeight
	endIf

	nCol_0 := nColInicio
	for nRowCount := 1 to len(aData)
		nRow_0 += nRowHeight
		for nColCount := 1 to len(aData[nRowCount])
			nCol_1 := nCol_0 + aWidth[nColCount]
			oPrinterRec:Box(nRow_0, nCol_0, nRow_0 - nRowHeight, nCol_1, "-2")
			oPrinterRec:SayAlign(nRow_0 - nRowHeight, nCol_0 + nMargemCel, aData[nRowCount][nColCount], oArial08, aWidth[nColCount] - 2 * nMargemCel, nRowHeight, , aAlign[nColCount], 0)
			nCol_0 := nCol_1
		next
		nCol_0 := nColInicio
	next
return

/*/{Protheus.doc} aPaginator
	Funcao que separa itens por página
	@type static function
	@author Julio Carvalho Barberino
	@since 14/01/2025
	@version 0
/*/
static function aPaginator(aLinhas /*Array 2D com os dados*/, nCab /*espaço do cabecalho*/, nHei /*espaço da pagina sem cabeçalho e rodapé*/, nRod /*espaço do rodape*/)
	local nI
	local nLen			:= len(aLinhas)
	local nX11			:= nHei - nCab - nRod	// tamanho da pagina 1 de 1
	local nX1N			:= nX11 + nRod			// tamanho da pagina 1 de N
	local nXJN			:= nHei					// tamanho da pagina J de N
	local nXNN			:= nX11 + nCab			// tamanho da pagina N de N
	local aRet			:= {}
	local nPagCont		:= 1
	local nItemCount	:= 1

	if nLen <= nX11 // Cabe na primeira página X11
		aAdd(aRet, aLinhas)
		return aRet
	endIf

	if nLen <= nX1N + nXNN // tem duas paginas
		aAdd(aRet, {}) // cria pagina X1N. A partir de agora, a pagina X1N é aRet[1]
		while nItemCount <= nX1N .and. nItemCount < nLen // Preenchimento da pagina X1N
			aAdd(aRet[1], aLinhas[nItemCount])
			nItemCount += 1 // avança item
		endDo
		nPagCont += 1
		aAdd(aRet, {}) // cria pagina XNN. A partir de agora, a pagina XNN é aRet[2]
		while nItemCount <= nLen // Preenchimento da pagina XNN
			aAdd(aRet[2], aLinhas[nItemCount])
			nItemCount += 1 // avança item
		endDo
		return aRet
	endIf

	if nX1N + nXNN < nLen // tem tres ou mais paginas
		aAdd(aRet, {}) // cria pagina X1N. A partir de agora, a pagina X1N é aRet[1]
		while nItemCount <= nX1N // Preenchimento da pagina X1N
			aAdd(aRet[1], aLinhas[nItemCount])
			nItemCount += 1 // avança item
		endDo

		while nItemCount <= len(aLinhas) // Enquanto puder preencher paginas do tipo XJN
			nPagCont += 1 // avança pagina
			aAdd(aRet, {}) // cria pagina XJN. A partir de agora, a pagina XJN é aRet[nPagCont]
			nI := 1
			while nItemCount <= nLen .and. nI <= nXJN
				aAdd(aRet[nPagCont], aLinhas[nItemCount]) // Preenchimento da pagina XJN
				nItemCount += 1 // avança item
				nI += 1 // avança espaço na pagina
			endDo
		endDo

		if nXNN < len(aRet[nPagCont]) // Excesso de itens na ultima página
			aDel(aRet[nPagCont], len(aRet[nPagCont])) // retira 1 item da ultima pagina
			aSize(aRet[nPagCont], len(aRet[nPagCont]) - 1)
			nItemCount -= 1 // retrocede item
			nPagCont += 1 // avança pagina
			aAdd(aRet, {}) // cria pagina XNN. A partir de agora, a pagina XNN é aRet[nPagCont]
			aAdd(aRet[nPagCont], aLinhas[nItemCount]) // Preenchimento da pagina XNN
			nItemCount += 1 // avança item
			return aRet
		endIf
		return aRet
	endIf
return

/*
	Motivação inicial para criar essas funções se deu durante o desenvolvimento do relatório https://github.com/CarvalhoBarberino/RelatorioPvImpostosMF.
*/

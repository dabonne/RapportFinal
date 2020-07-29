#!/bin/bash

BIBDIR=bibs

if [[ "$BIBDIR" == "" ]]; then
	echo "error : must specify bib entries folder."
	exit 0
fi

PATTERN="%%bibfile%%"
TEMPLATE="texSrc/template.tex"

LIST=`ls $BIBDIR/*.bib | sed -e "s#$BIBDIR/##g" | sed -e "s#.bib##g"`
#LIST=`echo $LIST `

TMPALLBIB="all-refs"
if [[ "$1" == "pdf" ]]; then
	echo $LIST
fi

rm -f $TMPALLBIB.bib
touch $TMPALLBIB.bib
for SPEC in $LIST;
do
	if [[ "$1" == "pdf" ]]; then
		sed -e "s#$PATTERN#$BIBDIR/$SPEC#g" $TEMPLATE > tmp_$SPEC.tex
		make calllatex FILEIN=tmp_$SPEC FILEOUT=$SPEC PDFREADER=ls
	fi
	cat $BIBDIR/$SPEC.bib >> $TMPALLBIB.bib
done

if [[ "$1" == "pdf" ]]; then
	sed -e "s#$PATTERN#$TMPALLBIB#g" $TEMPLATE > $TMPALLBIB.tex
	make calllatex FILEIN=$TMPALLBIB FILEOUT=$TMPALLBIB PDFREADER=ls

	make clean
	rm -v tmp* $TMPALLBIB.tex

	LIST=`ls $BIBDIR/*.bib | sed -e "s#$BIBDIR/##g" | sed -e "s#.bib#.pdf#g"`
	echo pdftk $LIST output all-refs-tk.pdf
	pdftk $LIST output all-refs-tk.pdf
fi

exit

grep title $TMPALLBIB.bib | grep -v book | perl -p -e 's/( [ ]+|\t)/ /g' \
	| perl -p -e 's/ title/title/g' | perl -p -e 's/.*title(.*)/title\1/g' \
	| perl -p -e 's/[ ]?=[ ]?/=/g' | perl -p -e 's/title=//g' | perl -p -e 's/{|}//g'

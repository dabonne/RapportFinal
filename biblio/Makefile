#Makefile

FILEIN=main
FILEOUT=biblio
BIBFILES=*.bib bibs/*.bib

CMD_BIBTEX=bibtex
DOBIB = $(strip $(wildcard $(BIBFILES)))
#PDFREADER=evince
PDFREADER=acroread
PDFREADER_CMD = ps | grep $(PDFREADER) | grep -v grep
CMD=pdflatex




ifeq ($(CMD),latex)
	IGNORE=
else
ifeq ($(CMD),pdflatex)
	IGNORE=\#
else
	IGNORE=abort
endif
endif

all: proper calllatex clean 
ifeq ($(IGNORE),abort)
	@exit
else
ifeq ($(shell $(PDFREADER_CMD)),)
	@$(PDFREADER) $(FILEOUT).pdf &
else
	@-killall $(PDFREADER);
	@sleep 1
	@$(PDFREADER) $(FILEOUT).pdf&
endif
endif

calllatex: $(FILEIN).tex
ifeq ($(IGNORE),abort)
	@echo "unsopported comand : $(CMD)"
	@echo "usage = make [CMD={latex|pdflatex}]"
	@echo "default value is pdflatex."
	@exit
else
	@#the first pass is used to initialize table of contents (and some other informations)
	@$(CMD) $(FILEIN).tex
	@#if the first pass is ok, then nexts should not print any new information : > /dev/null
	#bibtex
ifneq "$(DOBIB)" ""
	$(CMD_BIBTEX) $(FILEIN)
	@$(CMD)  $(FILEIN).tex > /dev/null
endif
	@$(CMD)  $(FILEIN).tex > /dev/null
	@echo " -- end of process | command : $(CMD) --"
	@$(IGNORE)echo "< detect use of latex : call to dvipdf >"
	@$(IGNORE)dvipdf $(FILEIN).dvi $(FILEIN).pdf
	@mv $(FILEIN).pdf $(FILEOUT).pdf
	@echo " -- Opening $(FILEOUT).pdf --"
endif
	
clean:
	@rm -Rfv *~ *.aux *.toc *.log *.dvi *.bbl *.blg *.nav *.out *.snm *.vrb

proper: clean
	@rm -Rfv *.pdf

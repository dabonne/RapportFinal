#Makefile

DOC=these
BIBFILE=./biblio/all-refs.bib
OUTPUT=mon_memoire.pdf

#do not edit

CMD=pdflatex -halt-on-error -8bit
CMDFAST=pdflatex -halt-on-error -8bit -draftmode

include ./config.mk
QUIET?=NO
SIZE?=11
TABLEOFFIGURES?=NO
TABLEOFTABLES?=NO
NOTATIONS?=NO
PREPRINT?=NO

.PHONY: *.pdf $(BIBFILE) $(DOC).bbl resume title test_reqs slides

TIME=/usr/bin/time
ifeq ($(wildcard $(TIME)),)
TIMING=
else
TIMING=$(TIME) -p
endif

CLEANING=.tmp *~ *.aux *.toc *.log *.bbl *.blg *.nav *.out *.nlo *.nls *.lot *.snm *.vrb *.idx *.ilg *.ind *.lof *.ist *.glo *.glg *.gls *.xdy *.synctex.gz *.maf *.mtc*

pdf: export DOPUBLIS=TRUE
all: export DOPUBLIS=TRUE
misc: export DOPUBLIS=TRUE

ifeq ($(QUIET),YES)
	VERB=@
	REDIRECT=> /dev/null 2> /dev/null
endif

rtf: CMD=latex2rtf -t2
rtf: CMDFAST=pdflatex -halt-on-error -8bit -draftmode
########################################
##		Rules
########################################
all: fastcomplete

rtf: fastcomplete

PERL=$(shell which perl)
BASH=$(shell which bash)

test_reqs:
ifeq ($(PERL),)
	$(error "Error : perl not found.")
endif
ifeq ($(BASH),)
	$(error "Error : bash not found.")
endif

fastcomplete: init-shortbook
	@cat $(DOC).tex | \
	sed -e 's#%%body%%#\\input{sources/intro.tex}|%%body%%|\\input{sources/conclu.tex}#g' | \
	sed -e 's#%%body%%#$(patsubst %,|\\glsresetall|\\input{%/main.tex},$(sort $(wildcard sources/chapter*)))|#g' | \
	sed -e 's#%%annexes%%#$(patsubst %,|\\input{%/main.tex},$(sort $(wildcard sources/annexe*)))|#g' | \
	tr '|' '\n' > tmp
	@mv tmp $(DOC).tex
	@$(TIMING) make finalize CMD="$(CMD)"

$(BIBFILE): test_reqs
	@echo "Generating $(DOC).tex"
	@(cd biblio && ./buildAll.sh)

init-report: $(BIBFILE)
	@printf '\\documentclass[a4paper,$(SIZE)pt]{report}\n' > $(DOC).tex
	@printf '\\newcommand{\preprint}{$(PREPRINT)}\n' >> $(DOC).tex
	@printf '\\input{sources/config.tex}\n' >> $(DOC).tex
	@printf '\\begin{document}\n' >> $(DOC).tex
	@printf '\\tableofcontents%%%%{Table des matières}\n' >> $(DOC).tex
	@printf '\\markboth{Table des matières}{Table des matières}\n' >> $(DOC).tex
ifeq ($(TABLEOFFIGURES),YES)
	@printf '\\listoffigures%%%%{Liste des figures}\n' >> $(DOC).tex
	@printf '\\markboth{Liste des figures}{Liste des figures}\n' >> $(DOC).tex
endif
ifeq ($(TABLEOFTABLES),YES)
	@printf '\\listoftables%%%%{Liste des tableaux}\n' >> $(DOC).tex
	@printf '\\markboth{Liste des tableaux}{Liste des tableaux}\n' >> $(DOC).tex
endif
ifeq ($(NOTATIONS),YES)
	@printf '\\printnomenclature%%%%{Liste des notations}\n' >> $(DOC).tex
	@printf '\\markboth{Liste des notations}{Liste des notations}\n' >> $(DOC).tex
	@printf '\\addcontentsline{toc}{chapter}{Liste des notations}\n' >> $(DOC).tex
endif
	@printf '%%%%body%%%%\n' >> $(DOC).tex
	@printf '\\appendix\n' >> $(DOC).tex
	@printf '%%%%annexes%%%%\n' >> $(DOC).tex
	@printf '\\printglossary\n' >> $(DOC).tex
	@printf '\\input{biblio/biblio.tex}\n' >> $(DOC).tex
	@printf '\\end{document}\n' >> $(DOC).tex

init-book: $(BIBFILE)
	@printf '\\documentclass[a4paper, oneside,$(SIZE)pt]{book}\n' > $(DOC).tex
	@printf '\\newcommand{\preprint}{$(PREPRINT)}\n' >> $(DOC).tex
	@printf '\\input{sources/config.tex}\n' >> $(DOC).tex
	@printf '\\begin{document}\n' >> $(DOC).tex
	@printf '\\frontmatter\n' >> $(DOC).tex
	@printf '\\input{sources/frontmatter.tex}\n' >> $(DOC).tex
	@printf '\\tableofcontents%%%%{Table des matières}\n' >> $(DOC).tex
	@printf '\\markboth{Table des matières}{Table des matières}\n' >> $(DOC).tex
ifeq ($(TABLEOFFIGURES),YES)
	@printf '\\listoffigures%%%%{Liste des figures}\n' >> $(DOC).tex
	@printf '\\markboth{Liste des figures}{Liste des figures}\n' >> $(DOC).tex
endif
ifeq ($(TABLEOFTABLES),YES)
	@printf '\\listoftables%%%%{Liste des tableaux}\n' >> $(DOC).tex
	@printf '\\markboth{Liste des tableaux}{Liste des tableaux}\n' >> $(DOC).tex
endif
ifeq ($(NOTATIONS),YES)
	@printf '\\printnomenclature%%%%{Liste des notations}\n' >> $(DOC).tex
	@printf '\\markboth{Liste des notations}{Liste des notations}\n' >> $(DOC).tex
	@printf '\\addcontentsline{toc}{chapter}{Liste des notations}\n' >> $(DOC).tex
endif
	@printf '\\mainmatter\n' >> $(DOC).tex
	@printf '%%%%body%%%%\n' >> $(DOC).tex
	@printf '\\appendix\n' >> $(DOC).tex
	@printf '%%%%annexes%%%%\n' >> $(DOC).tex
	@printf '\\printglossary\n' >> $(DOC).tex
#	@printf '\\input{biblio/publis.tex}\n' >> $(DOC).tex
	@printf '\\input{biblio/biblio.tex}\n' >> $(DOC).tex
#	@printf '\\input{sources/backmatter.tex}\n' >> $(DOC).tex
	@printf '\\end{document}\n' >> $(DOC).tex

init-shortbook: $(BIBFILE)
	@printf '\\documentclass[a4paper, oneside, book,$(SIZE)pt]{book}\n' > $(DOC).tex
	@printf '\\newcommand{\preprint}{$(PREPRINT)}\n' >> $(DOC).tex
	@printf '\\input{sources/config.tex}\n' >> $(DOC).tex
	@grep '\\titre' sources/infos_titlepage.tex | sed -e 's/titre/title/g' >> $(DOC).tex
	@grep '\\Auteur' sources/infos_titlepage.tex | sed -e 's/Auteur/author/g' | sed -e 's/}{/ /g' >> $(DOC).tex
	@printf '\\begin{document}\n' >> $(DOC).tex
	@printf '\\maketitle\n' >> $(DOC).tex
	@printf '\\tableofcontents%%%%{Table des matières}\n' >> $(DOC).tex
	@printf '\\markboth{Table des matières}{Table des matières}\n' >> $(DOC).tex
ifeq ($(TABLEOFFIGURES),YES)
	@printf '\\listoffigures%%%%{Liste des figures}\n' >> $(DOC).tex
	@printf '\\markboth{Liste des figures}{Liste des figures}\n' >> $(DOC).tex
endif
ifeq ($(TABLEOFTABLES),YES)
	@printf '\\listoftables%%%%{Liste des tableaux}\n' >> $(DOC).tex
	@printf '\\markboth{Liste des tableaux}{Liste des tableaux}\n' >> $(DOC).tex
endif
ifeq ($(NOTATIONS),YES)
	@printf '\\printnomenclature%%%%{Liste des notations}\n' >> $(DOC).tex
	@printf '\\markboth{Liste des notations}{Liste des notations}\n' >> $(DOC).tex
	@printf '\\addcontentsline{toc}{chapter}{Liste des notations}\n' >> $(DOC).tex
endif
	@printf '%%%%body%%%%\n' >> $(DOC).tex
	@printf '\\appendix\n' >> $(DOC).tex
	@printf '%%%%annexes%%%%\n' >> $(DOC).tex
	@printf '\\printglossary\n' >> $(DOC).tex
	@printf '\\input{biblio/publis.tex}\n' >> $(DOC).tex
	@printf '\\input{biblio/biblio.tex}\n' >> $(DOC).tex
	@printf '\\end{document}\n' >> $(DOC).tex

biblio: init-report 
	@cat $(DOC).tex | \
	sed -e 's#\\tableofcontents##g' $(DOC).tex > tmp
	@mv tmp $(DOC).tex
	@cd biblio && (cat biblio.tex | sed -e 's#%##g' > tmp ; mv tmp biblio.tex)
	@$(TIMING) make finalize CMD="$(CMD)"
	@cd biblio && (cat biblio.tex | sed -e 's#\\nocite#%\\nocite#g' > tmp ; mv tmp biblio.tex)

misc: init-book title resume
	@cd biblio && (cat biblio.tex | sed -e 's#%##g' > tmp ; mv tmp biblio.tex)
	@$(TIMING) make finalize CMD="$(CMD)"
	@cd biblio && (cat biblio.tex | sed -e 's#\\nocite#%\\nocite#g' > tmp ; mv tmp biblio.tex)

intro: init-report
	@cat $(DOC).tex | \
	sed -e 's#%%body%%#\\input{sources/intro.tex}#g' > tmp
	@mv tmp $(DOC).tex
	@$(TIMING) make finalize CMD="$(CMD)"

chapter%: init-report
	@cat $(DOC).tex | \
	sed -e 's#%%body%%#$(patsubst %,|\\glsresetall|\\input{%/main.tex},$(sort $(wildcard sources/$@*)))|#g' | \
	tr '|' '\n' > tmp
	@mv tmp $(DOC).tex
	@$(TIMING) make finalize CMD="$(CMD)"
	
annexe%: init-report
	@cat $(DOC).tex | \
	sed -e 's#%%body%%#\\appendix|$(patsubst %,|\\glsresetall|\\input{%/main.tex},$(sort $(wildcard sources/$@*)))|#g' | \
	tr '|' '\n' > tmp
	@mv tmp $(DOC).tex
	@$(TIMING) make finalize CMD="$(CMD)"

conclu: init-report
	@cat $(DOC).tex | \
	sed -e 's#%%body%%#\\input{sources/conclu.tex}#g' > tmp
	@mv tmp $(DOC).tex
	@$(TIMING) make finalize CMD="$(CMD)"


pdf: init-book title resume
	@cat $(DOC).tex | \
	sed -e 's#%%body%%#\\input{sources/intro.tex}|%%body%%|\\input{sources/conclu.tex}#g' | \
	sed -e 's#%%body%%#$(patsubst %,|\\glsresetall|\\input{%/main.tex},$(sort $(wildcard sources/chapter*)))|#g' | \
	sed -e 's#%%annexes%%#$(patsubst %,|\\input{%/main.tex},$(sort $(wildcard sources/annexe*)))|#g' | \
	tr '|' '\n' > tmp
	@mv tmp $(DOC).tex
	@$(TIMING) make finalize CMD="$(CMD)"

title: 
	cd miscpages && make title
	cp miscpages/title.pdf $(DOC).pdf
	
resume:
	cd miscpages && make resume
	cp miscpages/resume.pdf $(DOC).pdf

finalize:
	@rm -rf $(CLEANING)
	@echo " >> Latex first pass (fast)"
	$(VERB) $(CMDFAST) $(DOC).tex $(REDIRECT)
ifeq ($(DOBIB),)
	@echo " >> Bibtex"
	-$(VERB) bibtex $(DOC) $(REDIRECT)
endif
ifeq ($(DOPUBLIS),TRUE)
	@echo " >> Bibtex (Publis perso)"
	-$(VERB) bibtex publis $(REDIRECT)
endif
	@echo " >> Glossaire"
	$(VERB) makeglossaries these.glo $(REDIRECT)
ifeq ($(NOTATIONS),YES)
	@echo " >> Makeindex (nomenclature) 1"
	$(VERB) makeindex $(DOC) $(REDIRECT)
	@echo " >> Makeindex (nomenclature) 2"
	$(VERB) makeindex $(DOC).nlo -s nomencl.ist -o $(DOC).nls $(REDIRECT)
	@echo " >> Latex extra pass (fast)"
	$(VERB) $(CMDFAST) $(DOC).tex $(REDIRECT)
	@echo " >> Makeindex (nomenclature) 3"
	$(VERB) makeindex $(DOC).nlo -s nomencl.ist -o $(DOC).nls $(REDIRECT)
endif
	@echo " >> Latex 2nd pass (fast)"
	$(VERB) $(CMDFAST) $(DOC).tex $(REDIRECT)
	@echo " >> Latex last pass"
	$(VERB) $(CMD) $(DOC).tex $(REDIRECT)
	@mv $(DOC).pdf $(OUTPUT)
	@ls -sh $(OUTPUT)

########################################
##		Cleaning
########################################
	
clean:
	rm -rfv $(CLEANING)

proper: clean
	rm -fv $(DOC).pdf $(DOC).tex *.rtf $(BIBFILE) miscpages/*.pdf

########################################
##		Help
########################################

help:
	@echo "Help :"
	@echo "-----------"
	@echo " - make all : builds $(DOC).pdf without title, thanks, resumé"
	@echo " - make rtf : same as make all, but generates a RTF file (requires latex2rtf)"
	@echo " - make pdf : builds the full manuscript"
	@echo " - make finalize : recompiles the pdf without re-generating the $(DOC).tex file"
	@echo " - make clean : cleans folders"
	@echo " - make proper : make clean + delete $(DOC).{pdf,tex,rtf}"
	@echo "-----------"
	@echo " - make intro : builds a pdf containing the introduction only"
	@echo " - make chapterX : chapters matching regular expression X"
	@echo " - make conclu : conclusion only"
	@echo " - make annexeX : same as chapterX, for appendix"
	@echo " - make biblio : builds a pdf containing all the references (nocite{*})"
	@echo " - make misc : builds a pdf containing misc stuff (like title, thanks, ...)"
	@echo "-----------"
	@echo " - make help : prints this help"
	@echo " More doc. at http://www.irisa.fr/prive/Antoine.Morvan/template_these/"
	@echo "-----------"


########################################
##		Personal Rules
########################################

#part1: chapter[1-2]

#part2: chapter[3-5]

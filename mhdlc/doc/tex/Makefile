TEX      = MetaHDL_man.tex
PDF      = $(TEX:.tex=.pdf)
AUXFILES = *.aux *.log *.out *.toc *.lof *.lot *.fls *.fdb_latexmk \
           *.bbl *.blg *.idx *.ind *.ilg *.ist \
           *.glo *.gls *.glg

.PHONY: all clean

all: $(PDF)

$(PDF): $(TEX) *.tex mhdl.sty
	pdflatex -interaction=nonstopmode $(TEX)
	makeglossaries $(TEX:.tex=)
	makeindex $(TEX:.tex=)
	pdflatex -interaction=nonstopmode $(TEX)
	pdflatex -interaction=nonstopmode $(TEX)

clean:
	rm -f $(AUXFILES) $(PDF)

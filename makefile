# Makefile for documentation and tests.

DOC_BUILD = build/doc
TST_BUILD = build/tst

all: doc tst
	@echo All doc build and tests run.

.PHONY : clean
clean:
	rm -rf build/*

doc: README.html README.pdf

%.html: README.md
	mkdir -p $(DOC_BUILD)
	cp -f doc.css $(DOC_BUILD)/
	pandoc -c doc.css -s --toc $< -o $(DOC_BUILD)/$@

%.pdf: README.md
	mkdir -p $(DOC_BUILD)
	pandoc --toc -s $< -o $(DOC_BUILD)/$*.tex
	cd $(DOC_BUILD); pdflatex $*.tex > $*_pdflatex_0.log
	cd $(DOC_BUILD); pdflatex $*.tex > $*_pdflatex_1.log


.PHONY : tst
tst:
	mkdir -p $(TST_BUILD)
	./luapp -i tst/tst0.in -o $(TST_BUILD)/tst0.out
	cp tst/tst0.ref $(TST_BUILD)/tst0.ref
	sed -i 's/USER/$(USER)/' $(TST_BUILD)/tst0.ref
	diff $(TST_BUILD)/tst0.ref $(TST_BUILD)/tst0.out
	./luapp -i tst/tst0.in -o $(TST_BUILD)/tst0_cmdopt.out DEBUG=blah
	cp tst/tst0_cmdopt.ref $(TST_BUILD)/tst0_cmdopt.ref
	sed -i 's/USER/$(USER)/' $(TST_BUILD)/tst0_cmdopt.ref
	diff $(TST_BUILD)/tst0_cmdopt.ref $(TST_BUILD)/tst0_cmdopt.out


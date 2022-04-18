#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")
mkdir out
haxe  -cp src -D doc-gen --macro include('com.sdtk') --no-output -xml doc.xml
haxelib run dox --toplevel-package com.sdtk -i doc.xml -o pages --title "Simple Data Toolkit"
pushd doc-src
pdflatex stc.tex
pdflatex slg.tex
pdflatex calendar.tex
make4ht -c htlatex.cfg stc.tex "xhtml,NoFonts,-css"
make4ht -c htlatex.cfg slg.tex "xhtml,NoFonts,-css"
make4ht -c htlatex.cfg calendar.tex "xhtml,NoFonts,-css"
del *.aux
del *.log
del *.dvi
del *.idv
del *.lg
del *.tmp
del *.xref
del *.4ct
del *.4tc
del *.fls
del *.fdb_latexmk
move *.pdf ..\out
move *.html ..\out
move *.css ..\out
popd
popd
#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")
mkdir out 2> NUL

pushd plugin-jedit-src
#haxe -java ..\out -main SDTKJEditPlugIn --java-lib "C:\Program Files\jEdit\jedit.jar"
javac *.java -cp "C:\Program Files\jEdit\jedit.jar;..\out\sdtk.jar"
mkdir out
move *.class out
copy *.html out
copy *.xml out
copy *.prop* out
cd out
jar cvf sdtk-plugin-jedit.jar *.class *.html *.props *.xml
REM    --resource index.html --resource SDTKJEdit.props --resource actions.xml
REM move *.jar ..\..\out
cd ..
REM rmdir /s /q out
popd

REM move out\out.jar out\sdtk-plugin-jedit.jar > NUL 2> NUL

popd
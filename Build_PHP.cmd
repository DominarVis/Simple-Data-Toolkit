#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")
mkdir out 2> NUL
haxe -php out com.sdtk -cp src -D %* $*
haxe -php out -main com.sdtk.log.Transfer -cp src -D %* $*
haxe -php out -main com.sdtk.table.Converter -cp src -D %* $*
haxe -php out -main com.sdtk.calendar.Create -cp src -D %* $*
REM sh ./Build_Docs
REM cmd /c .\Build_Docs
popd
#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")
mkdir out 2> NUL
haxe -hl out\sdtk-lib.hl com.sdtk -cp src -D %* $*
haxe -hl out\slg.hl -main com.sdtk.log.Transfer -cp src -D %* $*
haxe -hl out\stc.hl -main com.sdtk.table.Converter -cp src -D %* $*
haxe -hl out\calendar.hl -main com.sdtk.calendar.Create -cp src -D %* $*
popd
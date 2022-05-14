#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")
mkdir out 2> NUL
haxe -lua out\sdtk.lua com.sdtk -cp src -D %* $*
haxe -lua out\slc.lua -main com.sdtk.log.Transfer -cp src -D %* $*
haxe -lua out\stc.lua -main com.sdtk.table.Converter -cp src -D %* $*
haxe -lua out\calendar.lua -main com.sdtk.calendar.Create -cp src -D %* $*
sh ./Build_Docs
cmd /c .\Build_Docs
popd
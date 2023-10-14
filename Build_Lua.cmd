#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")
mkdir out 2> NUL
haxe -lua out\sdtk.lua com.sdtk -cp src -D %* $*
MOVE out\sdtk.lua out\sdtk.tmp
TYPE Append_To_Beginning.lua > out\sdtk.lua
TYPE out\sdtk.tmp >> out\sdtk.lua
DEL out\sdtk.tmp

haxe -lua out\slc.lua -main com.sdtk.log.Transfer -cp src -D %* $*
MOVE out\slc.lua out\slc.tmp
TYPE Append_To_Beginning.lua > out\slc.lua
TYPE out\slc.tmp >> out\slc.lua
DEL out\slc.tmp

haxe -lua out\stc.lua -main com.sdtk.table.Converter -cp src -D %* $*
MOVE out\stc.lua out\stc.tmp
TYPE Append_To_Beginning.lua > out\stc.lua
TYPE out\stc.tmp >> out\stc.lua
DEL out\stc.tmp

haxe -lua out\calendar.lua -main com.sdtk.calendar.Create -cp src -D %* $*
MOVE out\calendar.lua out\calendar.tmp
TYPE Append_To_Beginning.lua > out\calendar.lua
TYPE out\calendar.tmp >> out\calendar.lua
DEL out\calendar.tmp

REM sh ./Build_Docs
REM cmd /c .\Build_Docs
popd
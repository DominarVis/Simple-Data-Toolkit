#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")
mkdir out 2> NUL

ECHO Building Library
DEL out\sdtk-lib-node.js
haxe com.sdtk -js sdtk-lib-node.js -cp src -D JS_NODE -D %* $*
MOVE out\sdtk-lib-node.js out\sdtk-lib-node.tmp
TYPE Append_To_Beginning.txt > out\sdtk-lib-node.js
TYPE out\sdtk-lib-node.tmp >> out\sdtk-lib-node.js
DEL out\sdtk-lib-node.tmp

ECHO Building Simple Table Converter
DEL out\stc-node.js
haxe -js out\stc-node.js -main com.sdtk.table.Converter -cp src -D JS_NODE -D %* $*
MOVE out\stc-node.js out\stc-node.tmp
TYPE Append_To_Beginning.txt > out\stc-node.js
TYPE out\stc-node.tmp >> out\stc-node.js
DEL out\stc-node.tmp

ECHO Building Simple Log Grabber
DEL out\slg-node.js
haxe -js out\slg-node.js -main com.sdtk.log.Transfer -cp src -D JS_NODE -D %* $*
MOVE out\slg-node.js out\slg-node.tmp
TYPE Append_To_Beginning.txt > out\slg-node.js
TYPE out\slg-node.tmp >> out\slg-node.js
DEL out\slg-node.tmp

ECHO Building Simple Calendar
DEL out\calendar-node.js
haxe -js out\calendar-node.js -main com.sdtk.calendar.Create -cp src -D JS_NODE -D %* $*
MOVE out\calendar-node.js out\calendar-node.tmp
TYPE Append_To_Beginning.txt > out\calendar-node.js
TYPE out\calendar-node.tmp >> out\calendar-node.js
DEL out\calendar-node.tmp

sh ./Build_Docs
cmd /c .\Build_Docs
popd
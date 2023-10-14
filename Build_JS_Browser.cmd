#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")
mkdir out 2> NUL

haxelib install jsasync

ECHO Building Library
DEL out\sdtk-lib-browser.js
haxe com.sdtk -js out\sdtk-lib-browser.js -lib jsasync -cp src -D JS_BROWSER -D %* $*
MOVE out\sdtk-lib-browser.js out\sdtk-lib-browser.tmp
TYPE Append_To_Beginning.txt > out\sdtk-lib-browser.js
TYPE src-browser\snowflake.js >> out\sdtk-lib-browser.js
TYPE src-browser\proxy.js >> out\sdtk-lib-browser.js
TYPE out\sdtk-lib-browser.tmp >> out\sdtk-lib-browser.js
DEL out\sdtk-lib-browser.tmp

ECHO Building Simple Table Converter
DEL out\stc-browser.js
haxe -js out\stc-browser.js -main com.sdtk.table.Converter -lib jsasync -cp src -D JS_BROWSER -D %* $*
MOVE out\stc-browser.js out\stc-browser.tmp
TYPE Append_To_Beginning.txt > out\stc-browser.js
TYPE out\stc-browser.tmp >> out\stc-browser.js
DEL out\stc-browser.tmp

ECHO Building Simple Log Grabber
DEL out\slg-browser.js
haxe -js out\slg-browser.js -main com.sdtk.log.Transfer -lib jsasync -cp src -D JS_BROWSER -D %* $*
MOVE out\slg-browser.js out\slg-browser.tmp
TYPE Append_To_Beginning.txt > out\slg-browser.js
TYPE out\slg-browser.tmp >> out\slg-browser.js
DEL out\slg-browser.tmp

ECHO Building Simple Calendar
DEL out\calendar-browser.js
haxe -js out\calendar-browser.js -main com.sdtk.calendar.Create -lib jsasync -cp src -D JS_BROWSER -D %* $*
MOVE out\calendar-browser.js out\calendar-browser.tmp
TYPE Append_To_Beginning.txt > out\calendar-browser.js
TYPE out\calendar-browser.tmp >> out\calendar-browser.js
DEL out\calendar-browser.tmp

popd
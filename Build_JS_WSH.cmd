#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")
mkdir out 2> NUL

ECHO Building Library
DEL out\sdtk-lib-wsh.js
haxe com.sdtk -js out\sdtk-lib-wsh.js -cp src -D JS_WSH -D %* $*
MOVE out\sdtk-lib-wsh.js out\sdtk-lib-wsh.tmp
TYPE Append_To_Beginning.txt > out\sdtk-lib-wsh.js
TYPE out\sdtk-lib-wsh.tmp >> out\sdtk-lib-wsh.js
DEL out\sdtk-lib-wsh.tmp

ECHO Building Simple Table Converter
DEL out\stc-wsh.js
haxe -js out\stc-wsh.js -main com.sdtk.table.Converter -cp src -D JS_WSH -D %* $*
MOVE out\stc-wsh.js out\stc-wsh.tmp
TYPE Append_To_Beginning.txt > out\stc-wsh.js
TYPE Append_To_Beginning_WSH.txt >> out\stc-wsh.js
TYPE out\stc-wsh.tmp >> out\stc-wsh.js
DEL out\stc-wsh.tmp
REM powershell -Command "(gc stc-wsh.js) -replace 'var proto = Object.create\(from\);', 'var proto;if (\"create\" in Object) {proto = Object.create(from);} else {function Inherit() {} Inherit.prototype = from; proto = new Inherit();}' | Out-File -encoding ASCII stc-wsh.js"
REM powershell -Command "(gc stc-wsh.js) -replace 'Object.defineProperty\(js__$Boot_HaxeError.prototype,\"message\",{ get : function\(\) {', 'if (\"defineProperty\" in Object) Object.defineProperty(js__$Boot_HaxeError.prototype,\"message\",{' | Out-File -encoding ASCII stc-wsh.js"
powershell -Command "(gc out\stc-wsh.js) -replace '\.typeof', '[\"typeof\"]' | Out-File -encoding ASCII out\stc-wsh.js"


ECHO Building Simple Log Grabber
DEL out\slg-wsh.js
haxe -js out\slg-wsh.js -main com.sdtk.log.Transfer -cp src -D JS_WSH -D %* $*
MOVE out\slg-wsh.js out\slg-wsh.tmp
TYPE Append_To_Beginning.txt > out\slg-wsh.js
TYPE Append_To_Beginning_WSH.txt >> out\slg-wsh.js
TYPE out\slg-wsh.tmp >> out\slg-wsh.js
DEL out\slg-wsh.tmp


ECHO Building Simple Calendar
DEL out\calendar-wsh.js
haxe -js out\calendar-wsh.js -main com.sdtk.calendar.Create -cp src -D JS_WSH -D %* $*
MOVE out\calendar-wsh.js out\calendar-wsh.tmp
TYPE Append_To_Beginning.txt > out\calendar-wsh.js
TYPE Append_To_Beginning_WSH.txt >> out\calendar-wsh.js
TYPE out\calendar-wsh.tmp >> out\calendar-wsh.js
DEL out\calendar-wsh.tmp

popd
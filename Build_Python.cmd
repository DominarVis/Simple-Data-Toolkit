#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")
mkdir out 2> NUL

ECHO Building Library
DEL out\sdtk.py
haxe --python out/sdtk.py out com.sdtk -cp src -D %* $*
MOVE out\sdtk.py out\sdtk.tmp
TYPE Append_To_Beginning.py > out\sdtk.py
TYPE out\sdtk.tmp >> out\sdtk.py
DEL out\sdtk.tmp

ECHO Building Simple Table Converter
DEL out\slg.py
haxe --python out/slg.py -main com.sdtk.log.Transfer -cp src -D %* $*
MOVE out\slg.py out\slg.tmp
TYPE Append_To_Beginning.py > out\slg.py
TYPE out\slg.tmp >> out\slg.py
DEL out\slg.tmp

ECHO Building Simple Log Grabber
DEL out\stc.py
haxe --python out/stc.py -main com.sdtk.table.Converter -cp src -D %* $*
MOVE out\stc.py out\stc.tmp
TYPE Append_To_Beginning.py > out\stc.py
TYPE out\stc.tmp >> out\stc.py
DEL out\stc.tmp

ECHO Building Simple Calendar
DEL out\calendar.py
haxe --python out/calendar.py -main com.sdtk.calendar.Create -cp src -D %* $*
MOVE out\calendar.py out\calendar.tmp
TYPE Append_To_Beginning.py > out\calendar.py
TYPE out\calendar.tmp >> out\calendar.py
DEL out\calendar.tmp

ECHO Building Simple Puller
DEL out\puller.py
haxe --python out/puller.py -main com.sdtk.puller.Puller -cp src -D %* $*
MOVE out\puller.py out\puller.tmp
TYPE Append_To_Beginning.py > out\puller.py
TYPE out\puller.tmp >> out\puller.py
DEL out\puller.tmp

popd
#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")
mkdir out 2> NUL
haxe -java out com.sdtk -cp src -D %* $*
haxe -java out -main com.sdtk.log.Transfer -cp src -D %* $*
haxe -java out -main com.sdtk.table.Converter -cp src -D %* $*
haxe -java out -main com.sdtk.calendar.Create -cp src -D %* $*
move out\Transfer.jar out\slg.jar > NUL 2> NUL
move out\Create.jar out\calendar.jar > NUL 2> NUL
move out\Converter.jar out\stc.jar > NUL 2> NUL
move out\out.jar out\sdtk.jar > NUL 2> NUL
popd
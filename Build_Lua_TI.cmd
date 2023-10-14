#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")
mkdir out 2> NUL
haxe -lua out\sdtk-ti.lua com.sdtk -cp src -D LUA_TI -D EXCLUDE_PARAMETERS -D EXCLUDE_FILES -D EXCLUDE_DATABASE -D EXCLUDE_PROCESS -D %* $*
MOVE out\sdtk-ti.lua out\sdtk-ti.tmp
TYPE Append_To_Beginning.lua > out\sdtk-ti.lua
TYPE out\sdtk-ti.tmp >> out\sdtk-ti.lua
DEL out\sdtk-ti.tmp

REM haxe -lua out\slc-ti.lua -main com.sdtk.log.Transfer -cp src -D LUA_TI -D EXCLUDE_PARAMETERS -D EXCLUDE_FILES -D EXCLUDE_DATABASE -D EXCLUDE_PROCESS -D %* $*
REM MOVE out\slc-ti.lua out\slc-ti.tmp
REM TYPE Append_To_Beginning.lua > out\slc-ti.lua
REM TYPE out\slc.tmp >> out\slc-ti.lua
REM DEL out\slc-ti.tmp

REM haxe -lua out\stc-ti.lua -main com.sdtk.table.Converter -cp src -D LUA_TI -D EXCLUDE_PARAMETERS -D EXCLUDE_FILES -D EXCLUDE_DATABASE -D EXCLUDE_PROCESS -D %* $*
REM MOVE out\stc-ti.lua out\stc-ti.tmp
REM TYPE Append_To_Beginning.lua > out\stc-ti.lua
REM TYPE out\stc-ti.tmp >> out\stc-ti.lua
REM DEL out\stc-ti.tmp

REM haxe -lua out\calendar-ti.lua -main com.sdtk.calendar.Create -cp src -D LUA_TI -D EXCLUDE_PARAMETERS -D EXCLUDE_FILES -D EXCLUDE_DATABASE -D EXCLUDE_PROCESS -D %* $*
REM MOVE out\calendar-ti.lua out\calendar-ti.tmp
REM TYPE Append_To_Beginning.lua > out\calendar-ti.lua
REM TYPE out\calendar-ti.tmp >> out\calendar-ti.lua
REM DEL out\calendar-ti.tmp

REM sh ./Build_Docs
REM cmd /c .\Build_Docs

SET outputfile=out\temp.lua
SET inputfile=out\sdtk-ti.lua
CALL :PROCESS_FILE

REM SET inputfile=out\slc-ti.lua
REM CALL :PROCESS_FILE

REM SET inputfile=out\stc-ti.lua
REM CALL :PROCESS_FILE

REM SET inputfile=out\calendar-ti.lua
REM CALL :PROCESS_FILE

GOTO DO_EXIT

:PROCESS_FILE
ECHO %inputfile%
ECHO 1
SET search=__lua_lib_luautf8_Utf8.len
SET replace=utf8.len
CALL :DO_REPLACE
ECHO 2
SET search=__lua_lib_luautf8_Utf8.char
SET replace=utf8.char
CALL :DO_REPLACE
ECHO 3
SET search=__lua_lib_luautf8_Utf8.byte
SET replace=utf8.byte
CALL :DO_REPLACE
ECHO 4
SET search=__lua_lib_luautf8_Utf8.find
SET replace=string.find
CALL :DO_REPLACE
ECHO 5
SET search=__lua_lib_luautf8_Utf8.upper
SET replace=string.upper
CALL :DO_REPLACE
ECHO 6
SET search=__lua_lib_luautf8_Utf8.lower
SET replace=string.lower
CALL :DO_REPLACE
ECHO 7
SET search=__lua_lib_luautf8_Utf8.sub
SET replace=string.sub
CALL :DO_REPLACE
ECHO 8
SET search=local _hx_hidden = {__id__=true, hx__closures=true, super=true, prototype=true, __fields__=true, __ifields__=true, __class__=true, __properties__=true, __fields__=true, __name__=true}
SET replace=-
CALL :DO_REPLACE
ECHO 9
SET search=__lua_lib_luautf8_Utf8 = _G.require("lua-utf8")
SET replace=-
CALL :DO_REPLACE
EXIT /B


:DO_REPLACE
setlocal EnableDelayedExpansion

if "%replace%"=="-" (
    set search=%2

    (for /f "delims=" %%i in ('findstr /v /c:"%search%" %inputfile%') do (
        set "line=%%i"
        echo(!line!
    )) > %outputfile%
) else (
    (for /f "delims=" %%i in ('findstr /n "^" %inputfile%') do (
        set "line=%%i"
        set "line=!line:%search%=%replace%!"
        set "line=!line:*:=!"
        echo(!line!
    )) > %outputfile%
    )

xcopy /y %outputfile% %inputfile% >> NUL
EXIT /B

:DO_EXIT
DEL out\temp.lua 2> NUL
popd
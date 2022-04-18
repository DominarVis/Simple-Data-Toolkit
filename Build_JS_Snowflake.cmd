#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")
mkdir out 2> NUL

ECHO Building Library
DEL out\sdtk-snowflake.js
haxe com.sdtk -js out\sdtk-snowflake.js -cp src -D JS_SNOWFLAKE -D EXCLUDE_PARAMETERS -D EXCLUDE_CONTROLS -D EXCLUDE_FILES -D %* $*
MOVE out\sdtk-snowflake.js out\sdtk-snowflake.tmp
TYPE Append_To_Beginning.txt > out\sdtk-snowflake.js
TYPE Append_To_Beginning_SF.txt >> out\sdtk-snowflake.js
TYPE out\sdtk-snowflake.tmp >> out\sdtk-snowflake.js
TYPE Append_To_End_SF.txt >> out\sdtk-snowflake.js
DEL out\sdtk-snowflake.tmp

popd
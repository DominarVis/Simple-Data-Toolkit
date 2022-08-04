#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")

CALL Env.cmd
CALL Update_Version.cmd

MKDIR tmp 2> NUL
MDIR tmp\src 2> NUL

XCOPY /s src\* tmp\src\.

echo { > tmp\haxelib.json
echo "name": "%PACKAGE_NAME%", >> tmp\haxelib.json
echo "url": "%PROJECT_HOME%", >> tmp\haxelib.json
echo "license": "%PROJECT_LICENSE%", >> tmp\haxelib.json
echo "tags": %PACKAGE_TAGS_JSON%, >> tmp\haxelib.json
echo "description": "%PACKAGE_DESCRIPTION%", >> tmp\haxelib.json
echo "version": "%PACKAGE_VERSION%", >> tmp\haxelib.json
echo "classPath": "src/", >> tmp\haxelib.json
echo "releasenote": "%PACKAGE_RELEASE_NOTES%", >> tmp\haxelib.json
echo "contributors": %PACKAGE_AUTHORS_JSON% >> tmp\haxelib.json
REM ,
REM echo "dependencies": %PACKAGE_DEPENDENCIES_JSON% >> tmp\haxelib.json
echo } >> tmp\haxelib.json

del out\sdtk-lib-haxelib.zip
powershell Compress-Archive tmp\* out\sdtk-lib-haxelib.zip
rem haxelib dev "%PACKAGE_NAME%" tmp
pushd tmp
REM haxelib install
REM haxelib dev 
REM haxelib submit
popd


REM RMDIR /S /Q tmp

popd
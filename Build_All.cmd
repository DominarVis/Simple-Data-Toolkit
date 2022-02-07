#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")

sh ./Build_JS_Browser
cmd /c .\Build_JS_Browser

sh ./Build_JS_WSH
cmd /c .\Build_JS_WSH

sh ./Build_Python
cmd /c .\Build_Python

sh ./Build_HashLink
cmd /c .\Build_HashLink

sh ./Build_Java
cmd /c .\Build_Java

sh ./Build_Docs
cmd /c .\Build_Docs

popd
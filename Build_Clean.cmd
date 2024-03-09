#!/bin/sh
@ECHO OFF 2> NUL
pushd . 2> NUL
cd "%~dp0" 2> NUL
cd $(dirname "$0") 2> NUL
python Build.py CLEAN CLEAN
python3 Build.py CLEAN CLEAN
popd
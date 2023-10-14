#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")
RMDIR /S /Q out > NUL 2> NUL
RMDIR /S /Q .ionide > NUL 2> NUL
RMDIR /S /Q pages > NUL 2> NUL
RMDIR /S /Q plugin-jedit-src-actual > NUL 2> NUL
RMDIR /S /Q tmp > NUL 2> NUL
RMDIR /S /Q tmp_choco > NUL 2> NUL
DEL texput.log > NUL 2> NUL
DEL doc.xml > NUL 2> NUL
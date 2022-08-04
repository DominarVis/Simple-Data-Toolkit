#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")

CALL Env.cmd

CALL Build_Clean.cmd

CALL Update_Version.cmd

REM Zip up all source code

mkdir temp
pushd temp
mkdir src
xcopy /s ..\src src
mkdir doc-src
xcopy /s ..\doc-src doc-src
copy /y ..\*.cmd .
copy /y ..\Append*.* .
copy /y ..\lgpl*.* .
copy /y ..\LICENSE*.* .
copy /y ..\R*.* .

powershell Compress-Archive .\* ..\sdtk-src.zip
popd


REM Do all builds

CALL Build_Docs.cmd
CALL Build_Java.cmd
CALL Build_JS_Browser.cmd
CALL Build_JS_WSH.cmd
CALL Build_PHP.cmd
CALL Build_Python.cmd


REM Release all builds

pushd out

(
echo cd /home/frs/project/simple-data-toolkit
echo mkdir %PACKAGE_VERSION%
echo cd %PACKAGE_VERSION%

echo put ../sdtk-src.zip

echo put slg-wsh.js
echo put stc-wsh.js
echo put sdtk-lib-wsh.js
echo put calendar-wsh.js

echo put stc.py
echo put sdtk.py
echo put calendar.py
echo put slg.py

echo put calendar-browser.js
echo put stc-browser.js
echo put slg-browser.js
echo put sdtk-lib-browser.js

echo put sdtk.jar
echo put calendar.jar
echo put stc.jar
echo put slg.jar

echo put sdtk-php.zip

echo put stc.pdf
echo put slg.pdf
echo put stc.html
echo put stc.css
echo put slg.html
echo put slg.css
echo put calendar.pdf
echo put calendar.html
echo put calendar.css

exit
) | sftp -i %SF_KEY_FILE% %SF_USER%@frs.sourceforge.net

popd


(
cd /home/project-web/simple-data-toolkit/htdocs

put ../SimpleMaster-Docs/docs.html

cd app

put ../SimpleMaster-UI/index.html
put out/sdtk-lib-browser.js
put ../FieldEngine/out/fe-browser.js
put ../FieldEngine/src/FieldEngine.css
put ../FieldEngine/src/FieldEngine-Defaults.css

exit
) | sftp -i %SF_KEY_FILE% %SF_USER%@web.sourceforge.net

rmdir /s /d temp

popd




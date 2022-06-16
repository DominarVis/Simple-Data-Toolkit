#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")

CALL Env.cmd

MKDIR tmp 2> NUL

REM CALL Build_CSharp.cmd
COPY out\sdtk.dll tmp

echo ^<?xml version="1.0"?^> > tmp\.nuspec
echo ^<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd"^> >> tmp\.nuspec
echo    ^<metadata^> >> tmp\.nuspec
echo        ^<!-- Identifier that must be unique within the hosting gallery --^> >> tmp\.nuspec
echo        ^<id^>%PACKAGE_NAME%^</id^> >> tmp\.nuspec
echo: >> tmp\.nuspec
echo        ^<!-- Package version number that is used when resolving dependencies --^> >> tmp\.nuspec
echo        ^<version^>%PACKAGE_VERSION%^</version^> >> tmp\.nuspec
echo: >> tmp\.nuspec
echo        ^<!-- Authors contain text that appears directly on the gallery --^> >> tmp\.nuspec
echo        ^<authors^>%PACKAGE_AUTHORS%^</authors^> >> tmp\.nuspec
echo: >> tmp\.nuspec
echo        ^<!--  >> tmp\.nuspec
echo            Owners are typically nuget.org identities that allow gallery >> tmp\.nuspec
echo            users to easily find other packages by the same owners.   >> tmp\.nuspec
echo        --^> >> tmp\.nuspec
echo        ^<owners^>%PACKAGE_OWNERS%^</owners^> >> tmp\.nuspec
echo:         >> tmp\.nuspec
echo        ^<!-- Project URL provides a link for the gallery --^> >> tmp\.nuspec
echo        ^<projectUrl^>%PROJECT_HOME%^</projectUrl^> >> tmp\.nuspec
echo: >> tmp\.nuspec
echo        ^<!-- License information is displayed on the gallery --^> >> tmp\.nuspec
echo        ^<license type="expression"^>%PROJECT_LICENSE%^</license^> >> tmp\.nuspec
echo: >> tmp\.nuspec
echo: >> tmp\.nuspec
echo        ^<!-- Icon is used in Visual Studio's package manager UI --^> >> tmp\.nuspec
echo        ^<icon^>%PACKAGE_ICON%^</icon^> >> tmp\.nuspec
echo: >> tmp\.nuspec
echo        ^<!--  >> tmp\.nuspec
echo            If true, this value prompts the user to accept the license when >> tmp\.nuspec
echo            installing the package.  >> tmp\.nuspec
echo        --^> >> tmp\.nuspec
echo        ^<requireLicenseAcceptance^>false^</requireLicenseAcceptance^> >> tmp\.nuspec
echo: >> tmp\.nuspec
echo        ^<!-- Any details about this particular release --^> >> tmp\.nuspec
echo        ^<releaseNotes^>%PACKAGE_RELEASE_NOTES%^</releaseNotes^> >> tmp\.nuspec
echo: >> tmp\.nuspec
echo        ^<!--  >> tmp\.nuspec
echo            The description can be used in package manager UI. Note that the >> tmp\.nuspec
echo            nuget.org gallery uses information you add in the portal.  >> tmp\.nuspec
echo        --^> >> tmp\.nuspec
echo        ^<description^>%PACKAGE_DESCRIPTION%^</description^> >> tmp\.nuspec
echo: >> tmp\.nuspec
echo        ^<!-- Copyright information --^> >> tmp\.nuspec
echo        ^<copyright^>%PACKAGE_COPYRIGHT%^</copyright^> >> tmp\.nuspec
echo: >> tmp\.nuspec
echo        ^<!-- Tags appear in the gallery and can be used for tag searches --^> >> tmp\.nuspec
echo        ^<tags^>PACKAGE_TAGS^</tags^> >> tmp\.nuspec
echo: >> tmp\.nuspec
echo        ^<!-- Dependencies are automatically installed when the package is installed --^> >> tmp\.nuspec
echo        ^<dependencies^> >> tmp\.nuspec
echo        %PACKAGE_DEPENDENCIES% >> tmp\.nuspec
echo        ^</dependencies^> >> tmp\.nuspec
echo    ^</metadata^> >> tmp\.nuspec
echo: >> tmp\.nuspec
echo    ^<!-- A readme.txt to display when the package is installed --^> >> tmp\.nuspec
echo    ^<files^> >> tmp\.nuspec
echo        ^<file src="%PACKAGE_README%" target="" /^> >> tmp\.nuspec
echo        ^<file src="%PACKAGE_ICON%" target="" /^> >> tmp\.nuspec
echo    ^</files^> >> tmp\.nuspec
echo ^</package^> >> tmp\.nuspec

powershell Compress-Archive tmp\* out\sdtk-lib.zip
MOVE out\sdtk-lib.zip out\sdtk-lib.nupkg
popd
RMDIR /S /Q tmp

popd
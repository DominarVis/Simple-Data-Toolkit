#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")

CALL Env.cmd
CALL Update_Version.cmd

MKDIR tmp 2> NUL
MKDIR tmp\tools 2> NUL

CALL Build_CSharp.cmd
COPY out\%PROGRAM_NAME%.exe tmp\tools
COPY lgpl-3.0.txt tmp\tools\LICENSE.txt

echo ^<?xml version="1.0" encoding="utf-8"?^> > tmp\stc.nuspec
echo ^<!-- Read this before creating packages: https://docs.chocolatey.org/en-us/create/create-packages --^> >> tmp\stc.nuspec
echo ^<!-- It is especially important to read the above link to understand additional requirements when publishing packages to the community feed aka dot org (https://community.chocolatey.org/packages). --^> >> tmp\stc.nuspec
echo: >> tmp\stc.nuspec
echo ^<!-- Test your packages in a test environment: https://github.com/chocolatey/chocolatey-test-environment --^> >> tmp\stc.nuspec
echo: >> tmp\stc.nuspec
echo ^<!-- >> tmp\stc.nuspec
echo This is a nuspec. It mostly adheres to https://docs.nuget.org/create/Nuspec-Reference. Chocolatey uses a special version of NuGet.Core that allows us to do more than was initially possible. As such there are certain things to be aware of: >> tmp\stc.nuspec
echo: >> tmp\stc.nuspec
echo * the package xmlns schema url may cause issues with nuget.exe >> tmp\stc.nuspec
echo * Any of the following elements can ONLY be used by choco tools - projectSourceUrl, docsUrl, mailingListUrl, bugTrackerUrl, packageSourceUrl, provides, conflicts, replaces >> tmp\stc.nuspec
echo * nuget.exe can still install packages with those elements but they are ignored. Any authoring tools or commands will error on those elements >> tmp\stc.nuspec
echo --^> >> tmp\stc.nuspec
echo: >> tmp\stc.nuspec
echo ^<!-- You can embed software files directly into packages, as long as you are not bound by distribution rights. --^> >> tmp\stc.nuspec
echo ^<!-- * If you are an organization making private packages, you probably have no issues here --^> >> tmp\stc.nuspec
echo ^<!-- * If you are releasing to the community feed, you need to consider distribution rights. --^> >> tmp\stc.nuspec
echo ^<!-- Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one. --^> >> tmp\stc.nuspec
echo ^<package xmlns="http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd"^> >> tmp\stc.nuspec
echo    ^<metadata^> >> tmp\stc.nuspec
echo        ^<!-- == PACKAGE SPECIFIC SECTION == --^> >> tmp\stc.nuspec
echo        ^<!-- This section is about this package, although id and version have ties back to the software --^> >> tmp\stc.nuspec
echo        ^<!-- id is lowercase and if you want a good separator for words, use '-', not '.'. Dots are only acceptable as suffixes for certain types of packages, e.g. .install, .portable, .extension, .template --^> >> tmp\stc.nuspec
echo        ^<!-- If the software is cross-platform, attempt to use the same id as the debian/rpm package(s) if possible. --^> >> tmp\stc.nuspec
echo: >> tmp\stc.nuspec
echo        ^<id^>%PROGRAM_NAME%^</id^> >> tmp\stc.nuspec
echo: >> tmp\stc.nuspec
echo        ^<!-- version should MATCH as closely as possible with the underlying software --^> >> tmp\stc.nuspec
echo        ^<!-- Is the version a prerelease of a version? https://docs.nuget.org/create/versioning#creating-prerelease-packages --^> >> tmp\stc.nuspec
echo        ^<!-- Note that unstable versions like 0.0.1 can be considered a released version, but it's possible that one can release a 0.0.1-beta before you release a 0.0.1 version. If the version number is final, that is considered a released version and not a prerelease. --^> >> tmp\stc.nuspec
echo        ^<version^>%PROGRAM_VERSION%^</version^> >> tmp\stc.nuspec
echo: >> tmp\stc.nuspec
echo        ^<!-- == SOFTWARE SPECIFIC SECTION == --^> >> tmp\stc.nuspec
echo        ^<!-- This section is about the software itself --^> >> tmp\stc.nuspec
echo        ^<title^>%PROGRAM_TITLE%^</title^> >> tmp\stc.nuspec
echo        ^<authors^>%PACKAGE_AUTHORS%^</authors^> >> tmp\stc.nuspec
echo        ^<!-- projectUrl is required for the community feed --^> >> tmp\stc.nuspec
echo        ^<projectUrl^>%PROJECT_HOME%^</projectUrl^> >> tmp\stc.nuspec
echo        ^<!-- There are a number of CDN Services that can be used for hosting the Icon for a package. More information can be found here: https://docs.chocolatey.org/en-us/create/create-packages#package-icon-guidelines --^> >> tmp\stc.nuspec
echo        ^<!-- Here is an example using Githack --^> >> tmp\stc.nuspec
echo        ^<!--^<iconUrl^>http://rawcdn.githack.com/__REPLACE_YOUR_REPO__/master/icons/stc.png^</iconUrl^>--^> >> tmp\stc.nuspec
echo        ^<licenseUrl^>%PROJECT_LICENSE_URL%^</licenseUrl^> >> tmp\stc.nuspec
echo        ^<packageSourceUrl^>%PROJECT_SOURCE_URL%^</packageSourceUrl^> >> tmp\stc.nuspec
echo        ^<docsUrl^>%PROJECT_DOCS_URL%^</docsUrl^> >> tmp\stc.nuspec
echo        ^<copyright^>%PACKAGE_COPYRIGHT%^</copyright^> >> tmp\stc.nuspec
echo        ^<!-- If there is a license Url available, it is required for the community feed --^> >> tmp\stc.nuspec
echo        ^<tags^>%PROGRAM_TAGS%^</tags^> >> tmp\stc.nuspec
echo        ^<summary^>%PROGRAM_SUMMARY%^</summary^> >> tmp\stc.nuspec
echo        ^<description^>%PROGRAM_DESCRIPTION%^</description^> >> tmp\stc.nuspec
echo    ^</metadata^> >> tmp\stc.nuspec
echo: >> tmp\stc.nuspec
echo    ^<!-- A readme.txt to display when the package is installed --^> >> tmp\stc.nuspec
echo    ^<files^> >> tmp\stc.nuspec
echo        ^<file src="%tools\**" target="tools" /^> >> tmp\stc.nuspec
echo    ^</files^> >> tmp\stc.nuspec
echo ^</package^> >> tmp\stc.nuspec

echo VERIFICATION Verification is intended to assist the Chocolatey moderators and community in verifying that this package's contents are trustworthy. > tmp\tools\VERIFICATION.txt
echo %PROJECT_VERIFICATION% >> tmp\tools\VERIFICATION.txt
echo: >> tmp\tools\VERIFICATION.txt
echo To verify the binaries: >> tmp\tools\VERIFICATION.txt
echo: >> tmp\tools\VERIFICATION.txt
echo You can pull the EXEs from here: https://sourceforge.net/projects/simple-data-toolkit/files/ >> tmp\tools\VERIFICATION.txt
echo or you can build them from the source like so: >> tmp\tools\VERIFICATION.txt
echo * Ensure you have Git installed. >> tmp\tools\VERIFICATION.txt
echo * Run `git clone https://github.com/Vis-LLC/Simple-Data-Toolkit.git` >> tmp\tools\VERIFICATION.txt
REM * Switch to the tag of the released version. For instance: 
REM    `git checkout 0.10.11`
echo * Run `Build_CSharp.cmd` (`.\Build_CSharp.cmd` in PowerShell) >> tmp\tools\VERIFICATION.txt
echo * Once that is successfully completed, head into out >> tmp\tools\VERIFICATION.txt
echo    folder where you will find stc.exe. >> tmp\tools\VERIFICATION.txt
echo * Verify the checksum you find there with the checksum shown on the package  >> tmp\tools\VERIFICATION.txt
echo    page of the community repository. >> tmp\tools\VERIFICATION.txt
echo: >> tmp\tools\VERIFICATION.txt
echo This project falls under the LGPL 3.0 license.  This can be found here: https://www.gnu.org/licenses/lgpl-3.0.en.html >> tmp\tools\VERIFICATION.txt


pushd tmp
choco pack
popd

MOVE tmp\*.nupkg out\%PROGRAM_NAME%.nupkg
popd
RMDIR /S /Q tmp
choco apikey --key %CHOCO_KEY% --source https://push.chocolatey.org/
choco push out\%PROGRAM_NAME%.nupkg --source https://push.chocolatey.org/
popd
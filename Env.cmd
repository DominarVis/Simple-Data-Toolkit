#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")

SET PACKAGE_NAME=com.sdtk
SET PACKAGE_VERSION=0.1.2
SET PACKAGE_AUTHORS=Franklin E. Powers, Jr.
SET PACKAGE_AUTHORS_EMAIL=info@vis-software.com
SET PACKAGE_OWNERS=fpowersjr
SET PROJECT_HOME=https://sourceforge.net/projects/simple-data-toolkit/
SET PROJECT_LICENSE=LGPL-3
SET PACKAGE_ICON=
SET PACKAGE_RELEASE_NOTES=
SET PACKAGE_DESCRIPTION=Simple Data Toolkit - Manipulate CSV, TSV, PSV and other data formats
SET PACKAGE_COPYRIGHT=Copyright (C) 2019 Vis LLC
SET PACKAGE_TAGS=csv
SET PACKAGE_DEPENDENCIES=
SET PACKAGE_README=

SET PROGRAM_NAME=stc
SET PROGRAM_VERSION=%PACKAGE_VERSION%
SET PROGRAM_TITLE=Simple Data Toolkit - Simple Table Converter
SET PROGRAM_TAGS=%PACKAGE_TAGS%
SET PROGRAM_SUMMARY=This tool can be used to convert tabular data from one format to another.
SET PROGRAM_DESCRIPTION=This tool can be used to convert tabular data from one format to another.

popd
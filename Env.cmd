#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")

SET PACKAGE_NAME=com.sdtk
SET PACKAGE_VERSION=0.2.1
SET PACKAGE_AUTHORS=Franklin E. Powers, Jr.
SET PACKAGE_AUTHORS_JSON=["Franklin E. Powers, Jr."]
SET PACKAGE_AUTHORS_EMAIL=info@vis-software.com
SET PACKAGE_OWNERS=fpowersjr
SET PROJECT_HOME=https://vis-software.com/#sdtk
SET PROJECT_LICENSE=LGPL-3
SET PROJECT_LICENSE_NUGET=LGPL-3.0-or-later
SET PACKAGE_ICON=
SET PACKAGE_RELEASE_NOTES=
SET PACKAGE_DESCRIPTION=Simple Data Toolkit - Manipulate CSV, TSV, PSV and other data formats
SET PACKAGE_COPYRIGHT=Copyright (C) 2019 Vis LLC
SET PACKAGE_TAGS=csv
SET PACKAGE_TAGS_JSON=["csv"]
SET PACKAGE_DEPENDENCIES=
SET PACKAGE_DEPENDENCIES_JSON=[]
SET PACKAGE_README=
SET PROJECT_SOURCE_URL=https://github.com/Vis-LLC/Simple-Data-Toolkit
SET PROJECT_LICENSE_URL=https://github.com/Vis-LLC/Simple-Data-Toolkit/blob/main/LICENSE
SET PROJECT_LICENSE_URL_NUGET=https://licenses.nuget.org/LGPL-3.0-or-later
SET PROJECT_DOCS_URL=https://simple-data-toolkit.sourceforge.io/docs.html
SET PROJECT_VERIFICATION=This package is published by the Vis LLC, the owner of the project itself. The binaries are the .Net build of the source code for Simple Data Toolkit.

SET PROGRAM_NAME=stc
SET PROGRAM_VERSION=%PACKAGE_VERSION%
SET PROGRAM_TITLE=Simple Data Toolkit - Simple Table Converter
SET PROGRAM_TAGS=%PACKAGE_TAGS%
SET PROGRAM_SUMMARY=This tool can be used to convert tabular data from one format to another.
SET PROGRAM_DESCRIPTION=This tool can be used to convert tabular data from one format to another.

popd
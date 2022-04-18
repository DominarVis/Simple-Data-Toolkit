#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")

SET PACKAGE_NAME=com.vis.sdtk
SET PACKAGE_VERSION=0.1.1
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

popd
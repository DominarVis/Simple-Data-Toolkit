#!/bin/sh
@ECHO OFF
pushd .
cd "%~dp0"
cd $(dirname "$0")

echo /* > src\com\sdtk\std\Version.hx
echo     Copyright (C) 2019 Vis LLC - All Rights Reserved >> src\com\sdtk\std\Version.hx
echo: >> src\com\sdtk\std\Version.hx
echo    This program is free software: you can redistribute it and/or modify >> src\com\sdtk\std\Version.hx
echo    it under the terms of the GNU Lesser General Public License as published by >> src\com\sdtk\std\Version.hx
echo    the Free Software Foundation, either version 3 of the License, or >> src\com\sdtk\std\Version.hx
echo    (at your option) any later version. >> src\com\sdtk\std\Version.hx
echo: >> src\com\sdtk\std\Version.hx
echo    This program is distributed in the hope that it will be useful, >> src\com\sdtk\std\Version.hx
echo    but WITHOUT ANY WARRANTY; without even the implied warranty of >> src\com\sdtk\std\Version.hx
echo    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the >> src\com\sdtk\std\Version.hx
echo    GNU General Public License for more details. >> src\com\sdtk\std\Version.hx
echo: >> src\com\sdtk\std\Version.hx
echo    You should have received a copy of the GNU Lesser General Public License >> src\com\sdtk\std\Version.hx
echo    along with this program.  If not, see <https://www.gnu.org/licenses/>. >> src\com\sdtk\std\Version.hx
echo */ >> src\com\sdtk\std\Version.hx
echo: >> src\com\sdtk\std\Version.hx
echo /* >> src\com\sdtk\std\Version.hx
echo    Simple Data Toolkit >> src\com\sdtk\std\Version.hx
echo    Standard/Core Library - Source code can be found on SourceForge.net >> src\com\sdtk\std\Version.hx
echo */ >> src\com\sdtk\std\Version.hx
echo: >> src\com\sdtk\std\Version.hx
echo package com.sdtk.std; >> src\com\sdtk\std\Version.hx
echo: >> src\com\sdtk\std\Version.hx
echo @:expose >> src\com\sdtk\std\Version.hx
echo @:nativeGen >> src\com\sdtk\std\Version.hx
echo class Version { >> src\com\sdtk\std\Version.hx
echo  private static var _code : String = "%PACKAGE_VERSION%"; >> src\com\sdtk\std\Version.hx
echo  public static function get() : String { return _code; } >> src\com\sdtk\std\Version.hx
echo } >> src\com\sdtk\std\Version.hx
)  >> src\com\sdtk\std\Version.hx

popd
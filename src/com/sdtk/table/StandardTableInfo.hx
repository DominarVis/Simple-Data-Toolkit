/*
    Copyright (C) 2019 Vis LLC - All Rights Reserved

    This program is free software : you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <https ://www.gnu.org/licenses/>.
*/

/*
    Simple Data Toolkit
    Simple Table Converter (STC) - Source code can be found in Converter.hx in Haxe on SourceForge.net
*/

package com.sdtk.table;

/**
  HTML table structure
**/
@:expose
@:nativeGen
class StandardTableInfo implements TableInfo {
  public static var instance : StandardTableInfo = new StandardTableInfo();

  private function new() {
  }

  public function Tag() : Array<String> {
    return [ "TABLE" ];
  }

  public function HeaderRow() : Array<String> {
    return [ "TR" ];
  }

  public function HeaderCell() : Array<String> {
    return [ "TH", "TD" ];
  }

  public function Row() : Array<String> {
    return [ "TR" ];
  }

  public function Cell() : Array<String> {
    return [ "TD" ];
  }
}
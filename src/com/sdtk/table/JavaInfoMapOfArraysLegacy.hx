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
  CSV file structure
**/
@:expose
@:nativeGen
class JavaInfoMapOfArraysLegacy extends JavaInfoAbstract {
  private function new() {
    super();
  }

  private static var _instance : CodeInfo;

  public static function instance() : CodeInfo {
    if (_instance == null) {
        _instance = new JavaInfoMapOfArraysLegacy();
    }
    return _instance;
  }

  public override function start() : String {
    return mapStartLegacy();
  }

  public override function rowEnd() : String {
    return arrayEnd();
  }

  public override function end() : String {
    return mapEndLegacy();
  }

  public override function rowStart(name : String, index : Int) : String {
    return mapRowStartLegacy(name, index) + arrayStart();
  }

  public override function intEntry(data : Int, name : String, index : Int) {
    return arrayIntEntry(data, name, index);
  }

  public override function boolEntry(data : Bool, name : String, index : Int) {
    return arrayBoolEntry(data, name, index);
  }

  public override function floatEntry(data : Float, name : String, index : Int) {
    return arrayFloatEntry(data, name, index);
  } 

  public override function otherEntry(data : String, name : String, index : Int) {
    return arrayOtherEntry(data, name, index);
  } 

  public override function nullEntry(name : String, index : Int) {
    return arrayNullEntry(name, index);
  }
}
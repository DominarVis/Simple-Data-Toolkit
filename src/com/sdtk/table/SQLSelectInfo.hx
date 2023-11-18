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
class SQLSelectInfo implements CodeInfo {
  private function new() { }

  private static var _instance : CodeInfo;

  public static function instance() : CodeInfo {
    if (_instance == null) {
        _instance = new SQLSelectInfo();
    }
    return _instance;
  }

  private var _appendBeginning : String = "";
  private var _appendEnd : String = "";

  public function start() : String {
    return _appendBeginning;
  }

  public function end() : String {
    return _appendEnd;
  }  

  public function rowStart(name : String, index : Int) : String {
    return "SELECT ";
  }

  public function betweenRows() : String {
    return "\nUNION ALL\n";
  }

  public function rowEnd() : String {
    return "\nFROM dual";
  }

  public function intEntry(data : Int, name : String, index : Int) : String {
    if (name != null && name != "") {
      return data + " AS \"" + name + "\"";
    } else {
      return Std.string(data);
    }
  }

  public function boolEntry(data : Bool, name : String, index : Int) : String {
    if (name != null && name != "") {
      return data + " AS \"" + name + "\"";
    } else {
      return Std.string(data);
    }
  }
  
  public function floatEntry(data : Float, name : String, index : Int) : String {
    if (name != null && name != "") {
      return data + " AS \"" + name + "\"";
    } else {
      return Std.string(data);
    }
  }

  public function otherEntry(data : String, name : String, index : Int) : String {
    if (name != null && name != "") {
      return "'" + data + "' AS \"" + name + "\"";
    } else {
      return "'" + data + "'";
    }
  }

  public function nullEntry(name : String, index : Int) : String {
    if (name != null && name != "") {
      return "null AS \"" + name + "\"";
    } else {
      return "null";
    }
  }

  public function betweenEntries() : String {
    return ",";
  }
  
  public function replacements() : Array<String> {
    return ["''", "'"];
  }

  public static function createTable(name : String) {
    var info = new SQLSelectInfo();
    info._appendBeginning = "CREATE TABLE " + name + " AS\n";
    info._appendEnd = ";";
    return info;
  }

  public static function createOrReplaceTable(name : String) {
    var info = new SQLSelectInfo();
    info._appendBeginning = "CREATE OR REPLACE TABLE " + name + " AS\n";
    info._appendEnd = ";";
    return info;
  }

  public static function insertIntoTable(name : String) {
    var info = new SQLSelectInfo();
    info._appendBeginning = "INSERT INTO " + name + "\n";
    info._appendEnd = ";";
    return info;
  }
}
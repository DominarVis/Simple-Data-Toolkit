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
class PythonInfoAbstract implements CodeInfo {
  private function new() {
  }

  public function start() : String {
    return "";
  }

  public function end() : String {
    return "";
  }

  private function arrayStart() : String {
    return "[";
  }

  public function arrayEnd() : String {
    return "]";
  }  

  private function mapStart() : String {
    return "{";
  }

  public function mapEnd() : String {
    return "}";
  }  
  
  public function rowStart(name : String, index : Int) : String {
    return "";
  }

  public function rowEnd() : String {
    return "";
  }

  public function betweenRows() : String {
    return ",";
  }

  public function mapRowEnd() : String {
    return "}";
  }

  public function arrayRowEnd() : String {
    return "";
  }

  private function arrayRowStart(name : String, index : Int) : String {
    return "";
  }

  private function mapRowStart(name : String, index : Int) : String {
      if (name != null && name != "") {
        return "\"" + name + "\": ";
      } else {
        return index + ": ";
      }
  }

  private function mapIntEntry(data : Int, name : String, index : Int) {
    if (name != null && name != "") {
      return "\"" + name + "\": " + data;
    } else {
      return index + ": " + data;
    }
  }

  private function mapBoolEntry(data : Bool, name : String, index : Int) {
    if (name != null && name != "") {
      return "\"" + name + "\": " + data;
    } else {
      return index + ": " + data;
    }
  }

  private function mapFloatEntry(data : Float, name : String, index : Int) {
    if (name != null && name != "") {
      return "\"" + name + "\": " + data;
    } else {
      return index + ": " + data;
    }
  } 

  private function mapOtherEntry(data : String, name : String, index : Int) {
    if (name != null && name != "") {
      return "\"" + name + "\": \"" + data + "\"";
    } else {
      return index + ": \"" + data + "\"";
    }
  } 

  private function mapNullEntry(name : String, index : Int) {
    if (name != null && name != "") {
      return "\"" + name + "\": None";
    } else {
      return index + ": None";
    }
  }   

  private function arrayIntEntry(data : Int, name : String, index : Int) {
    return Std.string(data);
  }

  private function arrayBoolEntry(data : Bool, name : String, index : Int) {
    return Std.string(data);
  }

  private function arrayFloatEntry(data : Float, name : String, index : Int) {
    return Std.string(data);
  } 

  private function arrayOtherEntry(data : String, name : String, index : Int) {
    return "\"" + data + "\"";
  } 

  private function arrayNullEntry(name : String, index : Int) {
    return "None";
  }   

  public function intEntry(data : Int, name : String, index : Int) {
    return null;
  }

  public function boolEntry(data : Bool, name : String, index : Int) {
    return null;
  }

  public function floatEntry(data : Float, name : String, index : Int) {
    return null;
  } 

  public function otherEntry(data : String, name : String, index : Int) {
    return null;
  } 

  public function nullEntry(name : String, index : Int) {
    return null;
  }   

  public function betweenEntries() : String {
    return ",";
  }
  
  public function replacements() : Array<String> {
    return ["\\\"", "\"", "\\\n", "\n", "\\\t", "\t"];
  }
}
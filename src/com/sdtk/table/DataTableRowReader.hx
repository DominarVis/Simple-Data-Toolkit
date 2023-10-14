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
  Defines interface and defaults for reading table rows.
**/
@:expose
@:nativeGen
class DataTableRowReader extends DataEntryReader {
  private static var _watch : Stopwatch = Stopwatch.getStopwatch("fromStringToType");
  private var _alwaysString : Bool = false;

  /**
    Convert a row from one data structure to another.
  **/
  public function convertTo(rowWriter : DataTableRowWriter) {
    var aSingle : Array<DataTableRowWriter> = new Array<DataTableRowWriter>();
    aSingle.push(rowWriter);
    convertToAll(aSingle);
  }

  private function fromStringToType(str : String) : Dynamic {
    _watch.start();
    var result : Dynamic = null;

    if (_alwaysString) {
      result = str;
    } else {
      var isInt : Bool = true;
      var isHex : Bool = true;
      var isFloat : Bool = true;
      var foundPoint : Bool = false;
      var foundComma : Bool = false;
      var foundX : Bool = false;
      var i : Int = 0;
  
      switch (str.toLowerCase()) {
        case "false":
          result = false;
        case "true":
          result = true;
        default:
          while (i < str.length) {
            switch (str.charAt(i)) {
              case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
              case "A", "B", "C", "D", "E", "F", "a", "b", "c", "d", "e", "f":
                isInt = false;
                isFloat = false;
              case ".":
                if (foundPoint) {
                  isFloat = false;
                  break;
                } else {
                  foundPoint = true;
                }
                isHex = false;
                isInt = false;
              case ",":
                foundComma = true;
              case "X", "x":
                if (foundX) {
                  isHex = false;
                  break;
                } else {
                  foundX = true;
                }
                isFloat = false;
                isInt = false;
              default:
                isFloat = false;
                isHex = false;
                isInt = false;
                break;
            }
            i++;
          }

          if (foundComma) {
            str = StringTools.replace(str, ",", "");
          }

          if (isFloat) {
            result = Std.parseFloat(str);
          } else if (isHex) {
            if (foundX) {
              result = Std.parseInt(str);
            } else {
              result = Std.parseInt("0x" + str);
            }
          } else if (isInt) {
            result = Std.parseInt(str);
          } else {
            #if python
              if (str.indexOf("datetime.datetime(") == 0) {
                str = StringTools.replace(str, "datetime.datetime(", "");
                str = StringTools.replace(str, ")", "");
                var str2 : Array<String> = str.split(",");
                var i2 : Array<Int> = new Array<Int>();
                i2.resize(str2.length);
                var i : Int = 0;
                while (i < i2.length) {
                  i2[i] = Std.parseInt(StringTools.trim(str2[i]));
                  i++;
                }
                result = new Date(i2[0], i2[1], i2[2], i2[3], i2[4], i2[5]);
              } else {
            #end
            result = str;
            #if python
            }
            #end
          }
      }
    }
    _watch.end();
    return result;
  }

  #if(cs || java)
    public function toHaxeMap(map : Map<String, Dynamic>) : Map<String, Dynamic> {
  #else
    public function toHaxeMap<A>(map : Map<String, A>) : Map<String, A> {
  #end
    convertTo(MapRowWriter.continueWrite(cast map, true, null, null));
    return map;
  }

  public function toNativeMap<A>(map : Dynamic, keyField : String, valueField : String) : Map<String, A> {
    if (map != null) {
      map = com.sdtk.std.Normalize.nativeToHaxe(map);
    }
    return com.sdtk.std.Normalize.haxeToNative(cast toHaxeMap(map));
  }

  public function toObject<A>(map : A, keyField : String, valueField : String) : A {
    // TODO
    return null;
  }

  /**
    Convert a row from one data structure to multiple target data structures.
  **/
  public function convertToAll(rowWriters : Iterable<DataTableRowWriter>) {
    start();
    for (rowWriter in rowWriters) {
      rowWriter.start();
    }
    while (hasNext()) {
      var data : Dynamic = next();
      var sName : String = name();
      var iIndex : Int = index();
      for (rowWriter in rowWriters) {
      	if (rowWriter != null) {
          rowWriter.write(data, sName, iIndex);
        }
      }
    }
  }

  public function alwaysString(?value : Null<Bool>) : Bool {
    if (value == null) {
      return _alwaysString;
    } else {
      _alwaysString = value;
      return _alwaysString;
    }
  }
}
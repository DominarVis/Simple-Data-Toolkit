/*
    Copyright (C) 2019 Vis LLC - All Rights Reserved

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

/*
    Simple Data Toolkit
    Simple Table Converter (STC) - Source code can be found in Converter.hx in Haxe on SourceForge.net
*/

package com.sdtk.table;

import com.sdtk.std.*;

@:nativeGen
class JSONHandler implements KeyValueHandler {
  private function new() { }

  private static var _instance : KeyValueHandler;

  public static function instance() : KeyValueHandler {
    if (_instance == null) {
        _instance = new JSONHandler();
    }
    return _instance;
  }

  public function favorReadAll() : Bool {
    return true;
  }

  public function oneRowPerFile() : Bool {
    return false;
  }

  private static function readValue(rReader : Reader) : String {
    var sbBuffer : StringBuf = new StringBuf();
    while (rReader.hasNext()) {
      sbBuffer.add(rReader.next());
    }
    return sbBuffer.toString();
  }

  public function read(rReader : Reader) : Map<String, Dynamic> {
    return cast com.sdtk.std.Normalize.nativeToHaxe(com.sdtk.std.Normalize.parseJson(readValue(rReader)));
  }

  public function write(wWriter : Writer, mMap : Map<String, Dynamic>, name : String, index : Int) : Void {
    if (index > 0) {
      wWriter.write(",");
    } else if (index == 0 && name == null) {
      wWriter.write("[");
    } else if (index == 0) {
      wWriter.write("{");
    }
    if (name != null) {
      wWriter.write("\"");
      wWriter.write(name);
      wWriter.write("\":");
    }
    wWriter.write(haxe.Json.stringify(mMap));
  }

  public function writeEnd(wWriter : Writer, lastName : String, lastIndex : Int) : Void {
    if (lastName != null) {
      wWriter.write("}");
    } else {
      wWriter.write("]");
    }
  }

  public function readAll(rReader : Reader, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void {
    var dData : Any = com.sdtk.std.Normalize.parseJson(readValue(rReader));
    if (Std.isOfType(dData, Array)) {
      var aValues : Array<Dynamic> = cast dData;
      for (value in aValues) {
        aMaps.push(cast com.sdtk.std.Normalize.nativeToHaxe(value));
        aNames.push(aMaps.length - 1);
      }
    } else {
      var m : Map<Dynamic, Dynamic> = com.sdtk.std.Normalize.nativeToHaxe(dData);
      #if (hax_ver >= 4)
      for (keyRow => valueRow in m) {
      #else
      for (keyRow in m.keys()) {
        var valueRow : Dynamic = m[keyRow];
      #end
        aMaps.push(cast com.sdtk.std.Normalize.nativeToHaxe(valueRow));
        aNames.push(keyRow);
      }
    }
  }

  public function writeAll(wWriter : Writer, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void {
    if (aNames[0] == 0 && aNames[aNames.length - 1] == (aNames.length - 1)) {
      var aValues : Array<Dynamic> = new Array<Dynamic>();
      for (value in aMaps) {
        aValues.push(value);
      }
      wWriter.write(haxe.Json.stringify(aValues));
    } else {
      var i : Int = 0;
      wWriter.write("{\n");
      while (i < aNames.length) {
        var aName : Dynamic = aNames[i];
        var sName : String = Std.string(aName);
        var mValue : Map<String, Dynamic> = aMaps[i];

        if (aName == sName) {
          wWriter.write("\"");
          wWriter.write(sName);
          wWriter.write("\"");
        } else {
          wWriter.write(sName);
        }

        wWriter.write(":");
        write(wWriter, mValue, null, -1);
        wWriter.write(",\n");
        i++;
      }
      wWriter.write("}");
    }
  }
}
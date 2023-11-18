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
class INIHandler implements KeyValueHandler {
  private function new() { }

  private static var _instance : KeyValueHandler;

  public static function instance() : KeyValueHandler {
    if (_instance == null) {
        _instance = new INIHandler();
    }
    return _instance;
  }

  public function favorReadAll() : Bool {
    return true;
  }

  public function oneRowPerFile() : Bool {
    return false;
  }

  private static function convertFrom(sValue : String) : String {
    sValue = StringTools.trim(sValue);
    sValue = StringTools.replace(sValue, "\\\\", "\\");
    sValue = StringTools.replace(sValue, "\\'", "'");
    sValue = StringTools.replace(sValue, "\\\"", "\"");
    sValue = StringTools.replace(sValue, "\\0", "\x00");
    sValue = StringTools.replace(sValue, "\\a", "\x07");
    sValue = StringTools.replace(sValue, "\\b", "\x08");
    sValue = StringTools.replace(sValue, "\\t", "\t");
    sValue = StringTools.replace(sValue, "\\r", "\r");
    sValue = StringTools.replace(sValue, "\\n", "\n");
    sValue = StringTools.replace(sValue, "\\;", ";");
    sValue = StringTools.replace(sValue, "\\#", "#");
    sValue = StringTools.replace(sValue, "\\=", "=");
    sValue = StringTools.replace(sValue, "\\:", ":");
    // TODO - \x????
    return sValue;
  }

  private static function convertTo(sValue : String) : String {
    sValue = StringTools.replace(sValue, "\\", "\\\\");
    sValue = StringTools.replace(sValue, "'", "\\'");
    sValue = StringTools.replace(sValue, "\"", "\\\"");
    sValue = StringTools.replace(sValue, "\x00", "\\0");
    sValue = StringTools.replace(sValue, "\x07", "\\a");
    sValue = StringTools.replace(sValue, "\x08", "\\b");
    sValue = StringTools.replace(sValue, "\t", "\\t");
    sValue = StringTools.replace(sValue, "\r", "\\r");
    sValue = StringTools.replace(sValue, "\n", "\\n");
    sValue = StringTools.replace(sValue, ";", "\\;");
    sValue = StringTools.replace(sValue, "#", "\\#");
    sValue = StringTools.replace(sValue, "=", "\\=");
    sValue = StringTools.replace(sValue, ":", "\\:");
    sValue = StringTools.trim(sValue);
    // TODO - \x????
    return sValue;
  }

  public function read(rReader : Reader) : Map<String, Dynamic> {
    rReader = rReader.switchToLineReader();
    var mMap : Map<String, Dynamic> = new Map<String, Dynamic>();
    while (rReader.hasNext()) {
      var sLine : String = rReader.peek();
      var sFirst : String = sLine.charAt(0);
      if (sFirst == "[") {
        break;
      } else if (sFirst == ";" || (sFirst == "#" && sLine.charAt(1) == " ")) {
        rReader.next();
        continue;
      } else {
        var iIndex : Int = sLine.indexOf("=");
        mMap.set(convertFrom(sLine.substr(0, iIndex)), convertFrom(sLine.substr(iIndex + 1)));
        rReader.next();
      }
    }
    return mMap;
  }

  public function write(wWriter : Writer, mMap : Map<String, Dynamic>, name : String, index : Int) : Void {
    wWriter = wWriter.switchToLineWriter();
    
    {
      var value : Dynamic = mMap["__name__"];
      if (value != null) {
        wWriter.write("[" + convertTo(Std.string(value)) + "]\n");
        value = null;
      }
    }
    
    #if (hax_ver >= 4)
    for (key => value in mMap) {
    #else
    for (key in mMap.keys()) {
      var value : Dynamic = mMap[key];
    #end
      if (key != "__name__") {
        wWriter.write(convertTo(key) + "=" + convertTo(Std.string(value)) + "\n");
      }
    }
  }

  public function writeEnd(wWriter : Writer, lastName : String, lastIndex : Int) : Void { }

  public function readAll(rReader : Reader, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void {
    rReader = rReader.switchToLineReader();
    while (rReader.hasNext()) {
      var sLine : String = rReader.peek();
      var sFirst : String = sLine.charAt(0);
      if (sFirst == ";" || (sFirst == "#" && sLine.charAt(1) == " ")) {
        continue;
      } else if (sFirst == "[") {
        var sKey : String = sLine.substr(1);
        if (sKey.charAt(sKey.length - 1) == "\n") {
          sKey = sKey.substr(0, sKey.length - 1);
        }
        if (sKey.charAt(sKey.length - 1) == "]") {
          sKey = sKey.substr(0, sKey.length - 1);
        }
        sKey = convertTo(sKey);
        rReader.next();
        aMaps.push(read(rReader));
        aNames.push(sKey);
      } else {
        aMaps.push(read(rReader));
        aNames.push("");
      }
    }
  }

  public function writeAll(wWriter : Writer, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void {
    var i : Int = 0;
    wWriter = wWriter.switchToLineWriter();
    while (i < aMaps.length) {
      wWriter.write("[" + convertTo(aNames[i]) + "]");
      write(wWriter, aMaps[i++], null, 0);
    }
  }
}
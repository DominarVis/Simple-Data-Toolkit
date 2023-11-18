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
class PropertiesHandler implements KeyValueHandler {
  private function new() { }

  private static var _instance : KeyValueHandler;

  public static function instance() : KeyValueHandler {
    if (_instance == null) {
        _instance = new PropertiesHandler();
    }
    return _instance;
  }

  public function favorReadAll() : Bool {
    return true;
  }

  public function oneRowPerFile() : Bool {
    return true;
  }

  private static function convertFrom(sValue : String, rReader : Null<Reader>) : String {
    sValue = StringTools.replace(sValue, "\\\\", "\\");
    sValue = StringTools.replace(sValue, "\\ ", " ");
    if (rReader != null) {
      while (StringTools.endsWith(sValue, "\\")) {
        sValue = sValue.substr(0, sValue.length - 1);
        if (rReader.hasNext()) {
          rReader.next();
          sValue += rReader.peek();
        } else {
          break;
        }
      }
    }
    if (StringTools.endsWith(sValue, "\n")) {
      sValue = sValue.substr(0, sValue.length - 1);
    }
    // TODO - \u????
    return sValue;
  }

  private static function convertTo(sValue : String) : String {
    sValue = StringTools.replace(sValue, "\\", "\\\\");
    sValue = StringTools.replace(sValue, " ", "\\ ");
    sValue = StringTools.replace(sValue, "\n", "\\\n");
    // TODO - \u????
    return sValue;
  }

  public function read(rReader : Reader) : Map<String, Dynamic> {
    rReader = rReader.switchToLineReader();
    var mMap : Map<String, Dynamic> = new Map<String, Dynamic>();
    while (rReader.hasNext()) {
      var sLine : String = rReader.peek();
      var sFirst : String = sLine.charAt(0);
      if (sFirst == "!" || sFirst == "#") {
        rReader.next();
        continue;
      } else {
        var iIndex1 : Int = sLine.indexOf("=");
        var iIndex2 : Int = sLine.indexOf(":");
        var iIndexFinal : Int = iIndex1 < 0 ? iIndex2 : iIndex2 < 0 ? iIndex1 : iIndex1 < iIndex2 ? iIndex1 : iIndex2;
        mMap.set(convertFrom(StringTools.trim(sLine.substr(0, iIndexFinal)), null), convertFrom(StringTools.ltrim(sLine.substr(iIndexFinal + 1)), rReader));
        rReader.next();
      }
    }
    return mMap;
  }

  public function write(wWriter : Writer, mMap : Map<String, Dynamic>, name : String, index : Int) : Void {
    wWriter = wWriter.switchToLineWriter();
      #if (hax_ver >= 4)
      for (key => value in mMap) {
      #else
      for (key in mMap.keys()) {
        var value : Dynamic = mMap[key];
      #end
      wWriter.write(convertTo(key) + "=" + convertTo(Std.string(value)) + "\n");
    }
  }

  public function writeEnd(wWriter : Writer, lastName : String, lastIndex : Int) : Void { }  

  public function readAll(rReader : Reader, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void {
    aMaps.push(read(rReader));
    aNames.push("");
  }

  public function writeAll(wWriter : Writer, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void {
    write(wWriter, aMaps[0], null, 0);
  }
}
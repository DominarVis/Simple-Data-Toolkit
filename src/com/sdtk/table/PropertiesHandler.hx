package com.sdtk.table;

import com.sdtk.std.*;

@:nativeGen
class PropertiesHandler implements KeyValueHandler {
  private function new() { }

  public static var instance : KeyValueHandler = new PropertiesHandler();

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

  public function write(wWriter : Writer, mMap : Map<String, Dynamic>) : Void {
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

  public function readAll(rReader : Reader, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void {
    aMaps.push(read(rReader));
    aNames.push("");
  }

  public function writeAll(wWriter : Writer, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void {
    write(wWriter, aMaps[0]);
  }
}
package com.sdtk.table;

import com.sdtk.std.*;

@:nativeGen
class SplunkHandler implements KeyValueHandler {
  private function new() { }

  public static var instance : KeyValueHandler = new SplunkHandler();

  public function favorReadAll() : Bool {
    return true;
  }

  public function oneRowPerFile() : Bool {
    return false;
  }

  private static function convertTo(sValue : String) : String {
    sValue = StringTools.replace(sValue, " ", "");
    sValue = StringTools.replace(sValue, "\t", "");
    sValue = StringTools.replace(sValue, "\n", "");
    sValue = StringTools.replace(sValue, "\r", "");
    return sValue;
  }

  public function read(rReader : Reader) : Map<String, Dynamic> {
    var i : Int = 0;
    rReader = rReader.switchToLineReader();
    var mMap : Map<String, Dynamic> = new Map<String, Dynamic>();
    var sLine : Array<String> = rReader.next().split(" ");

    for (sPart in sLine) {
      var iIndex : Int = sPart.indexOf("=");
      if (iIndex > 0) {
        var sKey : String = sPart.substr(0, iIndex);
        var sValue : String = sPart.substr(iIndex + 1);
        mMap.set(sKey, sValue);
      } else {
        mMap.set(Std.string(i), sPart);
      }
    }

    return mMap;
  }

  public function write(wWriter : Writer, mMap : Map<String, Dynamic>) : Void {
    var sbStart : StringBuf = new StringBuf();
    var sbBuffer : StringBuf = new StringBuf();
    wWriter = wWriter.switchToLineWriter();
    #if (hax_ver >= 4)
    for (key => value in mMap) {
    #else
    for (key in mMap.keys()) {
      var value : Dynamic = mMap[key];
    #end
      if (Std.parseInt(key) != null) {
        sbStart.add(value);
        sbStart.add(" ");
      } else {
        sbBuffer.add(key);
        sbBuffer.add("=");
        sbBuffer.add(convertTo(Std.string(value)));
        sbBuffer.add(" ");
      }
    }
    sbStart.add(sbBuffer);
    sbStart.add("\n");
    wWriter.write(sbStart.toString());
  }

  public function readAll(rReader : Reader, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void {
    rReader = rReader.switchToLineReader();
    while (rReader.hasNext()) {
      aMaps.push(read(rReader));
      aNames.push("");
    }
  }

  public function writeAll(wWriter : Writer, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void {
    var i : Int = 0;
    wWriter = wWriter.switchToLineWriter();

    while (i < aMaps.length) {
      write(wWriter, aMaps[i++]);
    }
  }
}
package com.sdtk.table;

import com.sdtk.std.*;

@:nativeGen
class JSONHandler implements KeyValueHandler {
  private function new() { }

  public static var instance : KeyValueHandler = new JSONHandler();

  public function favorReadAll() : Bool {
    return true;
  }

  public function oneRowPerFile() : Bool {
    return false;
  }

  private static function buildMap(dData : haxe.DynamicAccess<Dynamic>) {
    var mMap : Map<String, Dynamic> = new Map<String, Dynamic>();
    #if (hax_ver >= 4)
    for (key => value in dData) {
    #else
    for (key in dData.keys()) {
      var value : Dynamic = dData[key];
    #end
      mMap.set(key, value);
    }
    return mMap;
  }

  private static function readValue(rReader : Reader) : String {
    var sbBuffer : StringBuf = new StringBuf();
    while (rReader.hasNext()) {
      sbBuffer.add(rReader.next());
    }
    return sbBuffer.toString();
  }

  public function read(rReader : Reader) : Map<String, Dynamic> {
    return buildMap(haxe.Json.parse(readValue(rReader)));
  }

  public function write(wWriter : Writer, mMap : Map<String, Dynamic>) : Void {
    wWriter.write(haxe.Json.stringify(mMap));
  }

  public function readAll(rReader : Reader, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void {
    var dData : haxe.DynamicAccess<Dynamic> = haxe.Json.parse(readValue(rReader));
    
    #if (hax_ver >= 4)
    for (keyRow => valueRow in dData) {
    #else
    for (keyRow in dData.keys()) {
      var valueRow : Dynamic = dData[keyRow];
    #end
      aMaps.push(buildMap(valueRow));
      aNames.push(keyRow);
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
        write(wWriter, mValue);
        wWriter.write(",\n");
        i++;
      }
      wWriter.write("}");
    }
  }
}
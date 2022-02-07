package com.sdtk.table;

import com.sdtk.std.*;

@:nativeGen
interface KeyValueHandler {
  function favorReadAll() : Bool;
  function oneRowPerFile() : Bool;

  function read(rReader : Reader) : Map<String, Dynamic>;
  function write(wWriter : Writer, mMap : Map<String, Dynamic>) : Void;
  function readAll(rReader : Reader, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void;
  function writeAll(wWriter : Writer, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void;
}
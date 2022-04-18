package com.sdtk.table;

import com.sdtk.std.*;

@:expose
@:nativeGen
class KeyValueReader extends DataTableReader {
  private var _handler : Null<KeyValueHandler> = null;
  private var _reader : Null<Reader> = null;
  private var _maps : Null<Array<Map<String, Dynamic>>> = null;
  private var _names : Null<Array<Dynamic>> = null;
  private var _columns : Null<Array<Dynamic>> = null;

  private function new(fshHandler : KeyValueHandler, rReader : Reader) {
    super();
    _handler = fshHandler;
    _reader = rReader;
  }

  public static function createINIReader(rReader : Reader) {
    return new KeyValueReader(INIHandler.instance, rReader);
  }

  public static function createJSONReader(rReader : Reader) {
    return new KeyValueReader(JSONHandler.instance, rReader);
  }

  public static function createPropertiesReader(rReader : Reader) {
    return new KeyValueReader(PropertiesHandler.instance, rReader);
  }

  public static function createSplunkReader(rReader : Reader) {
    return new KeyValueReader(SplunkHandler.instance, rReader);
  }

  private function check() : Void {
    _maps = new Array<Map<String, Dynamic>>();
    _names = new Array<Dynamic>();
    _handler.readAll(_reader, _maps, _names);
    _columns = new Array<Dynamic>();
    var mDefinedColumns : Map<String, Int> = new Map<String, Int>();
    for (mMap in _maps) {
      #if (hax_ver >= 4)
      for (key => value in mMap) {
      #else
      for (key in mMap.keys()) {
        var value : Dynamic = mMap[key];
      #end
        var keyString : String = "" + key;
        if (mDefinedColumns.get(keyString) == null) {
          mDefinedColumns.set(keyString, _columns.length);
          _columns.push(key);
        }
      }
    }
  }

  private override function startI() : Void {
    _reader.start();
    check();
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_reader != null) {
      _reader.dispose();
      _reader = null;
      _handler = null;
      _maps = null;
      _names = null;
      _columns = null;
      super.dispose();
    }
  }

  public override function hasNext() : Bool {
    return index() < _maps.length - 1;
  }

  public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
  	if (hasNext()) {
      if (rowReader == null) {
        rowReader = new KeyValueRowReader(_maps[index() + 1], _columns);
      } else {
        var rr : KeyValueRowReader = cast rowReader;
        rr.reuse(_maps[index() + 1], _columns);
      }
      incrementTo(_names[index() + 1], rowReader, index() + 1);
      return value();
    } else {
      return null;
    }
  }

  public override function next() : Dynamic {
      return nextReuse(null);
  }
}

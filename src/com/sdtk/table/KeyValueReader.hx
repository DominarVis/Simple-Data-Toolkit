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

@:expose
@:nativeGen
class KeyValueReader extends DataTableReader {
  private var _handler : Null<KeyValueHandler> = null;
  private var _reader : Null<Reader> = null;
  private var _maps : Null<Array<Map<String, Dynamic>>> = null;
  private var _names : Null<Array<Dynamic>> = null;
  private var _columns : Null<Array<Dynamic>> = null;

  public function new(fshHandler : KeyValueHandler, rReader : Reader) {
    super();
    _handler = fshHandler;
    _reader = rReader;
  }

  public override function flip() : DataTableWriter {
    return new KeyValueWriter(_handler, _reader.flip());
  }  

  public static function createINIReader(rReader : Reader) {
    return new KeyValueReader(INIHandler.instance(), rReader);
  }

  public static function createJSONReader(rReader : Reader) {
    return new KeyValueReader(JSONHandler.instance(), rReader);
  }

  public static function createPropertiesReader(rReader : Reader) {
    return new KeyValueReader(PropertiesHandler.instance(), rReader);
  }

  public static function createSplunkReader(rReader : Reader) {
    return new KeyValueReader(SplunkHandler.instance(), rReader);
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
        rowReader = MapRowReader.readWholeMap(cast _maps[index() + 1]);
      } else {
        var rr : MapRowReader<Dynamic> = cast rowReader;
        rr.reuse(cast _maps[index() + 1], null, null);
      }
      incrementTo(null, rowReader, index() + 1);
      return rowReader;
    } else {
      return null;
    }
  }

  public override function next() : Dynamic {
      return nextReuse(null);
  }

  public override function reset() : Void {
    _reader.reset();
    _maps = null;
    _names = null;
    _columns = null;
  }  
}

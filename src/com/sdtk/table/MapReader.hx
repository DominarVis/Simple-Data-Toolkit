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
  Defines interface for processing maps as tables.
**/
@:expose
@:nativeGen
class MapReader<A> extends DataTableReader {
  private var _map : Map<Dynamic, Dynamic>;
  private var _iterator : Iterator<Dynamic>;

  private function new(map : Map<Dynamic, Dynamic>) {
    super();
    _map = map;
    _iterator = _map.keys();
  }
  
  /**
    Read the whole map.
  **/
  public static function readWholeMap<A>(map : Map<Dynamic, Dynamic>) : MapReader<A> {
    return new MapReader(map);
  }

  public override function hasNext() : Bool {
    return _iterator.hasNext();
  }

  public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
    if (rowReader == null) {
      rowReader = MapRowReader.continueRead(_map, _iterator);
    } else {
      var rr : MapRowReader<Dynamic> = cast rowReader;
      rr.reuse(_map, _iterator, null);
    }
    _value = rowReader;
    return rowReader;
  }
  
  public override function next() : Dynamic {
    return nextReuse(null);
  }

  public override function iterator() : Iterator<Dynamic> {
    return new MapReader<A>(_map);
  }

  public override function reset() : Void {
    _iterator = _map.keys();
  }  

  #if(cs || java)
    public override function toHaxeMap(map : Map<String, Dynamic>, keyField : String, valueField : String) : Map<String, Dynamic> {
  #else
    public override function toHaxeMap<A2>(map : Map<String, A2>, keyField : String, valueField : String) : Map<String, A2> {
  #end
    for (key in _map.keys()) {
      map.set(key, _map.get(key));
    }
    return map;
  }
}

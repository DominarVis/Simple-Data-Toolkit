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

import com.sdtk.std.*;

/**
**/
@:expose
@:nativeGen
class MapWriter<A> extends DataTableWriter {
  private var _map : Map<Dynamic, Dynamic>;
  private var _expandable : Bool;
  private var _keyField : String;
  private var _valueField : String;

  private function new(map : Map<Dynamic, Dynamic>, expandable : Bool, keyField : String, valueField : String) {
    super();
    reuse(map, expandable, keyField, valueField);
  }

  public function reuse(map : Map<Dynamic, Dynamic>, expandable : Bool, keyField : String, valueField : String) : Void {
    _map = map;
    _expandable = expandable;
    _keyField = keyField;
    _valueField = valueField;
  }
  
  /**
    Write to the entries that are already defined in the map.
   **/
  public static function writeToWholeMap<A>(map : Map<Dynamic, Dynamic>, keyField : String, valueField : String) : MapWriter<A> {
    return new MapWriter<A>(map, false, keyField, valueField);
  }
  
  /**
    Write to all entries into the map.
   **/  
  public static function writeToExpandableMap<A>(map : Map<Dynamic, Dynamic>, keyField : String, valueField : String) : MapWriter<A> {
    return new MapWriter<A>(map, true, keyField, valueField);
  }

  public override function start() : Void {
  }

  public override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    var rowWriter : MapRowWriter<A> = MapRowWriter.continueWriteReuse(_map, _expandable, _keyField, _valueField, cast rowWriter);
    return rowWriter;
  }

  public override function flip() : DataTableReader {
    return MapReader.readWholeMap(_map);
  }    

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_map != null) {
      _map = null;
      _keyField = null;
      _valueField = null;
    }
  }
}
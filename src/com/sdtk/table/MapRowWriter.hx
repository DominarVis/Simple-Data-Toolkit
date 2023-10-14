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
  Defines interface for processing maps as table rows.
**/
@:expose
@:nativeGen
class MapRowWriter<A> extends DataTableRowWriter {
  private var _map : Map<Dynamic, Dynamic>;
  private var _expandable : Bool;
  private var _keyField : String;
  private var _valueField : String;
  private var _keyCurrent : Dynamic;
  private var _valueCurrent : Dynamic;
  private var _got : Int;

  private function new(map : Map<Dynamic, Dynamic>, expandable : Bool, keyField : String, valueField : String) {
    super();
    reuse(map, expandable, keyField, valueField);
  }

  public function reuse(map : Map<Dynamic, Dynamic>, expandable : Bool, keyField : String, valueField : String) {
    _map = map;
    _expandable = expandable;
    _keyField = keyField;
    _valueField = valueField;
    _keyCurrent = null;
    _valueCurrent = null;
    _got = 0;
  }

  /**
    Continue writing a map from the specified location.
  **/
  public static function continueWrite<A>(map : Map<Dynamic, Dynamic>, expandable : Bool, keyField : String, valueField : String) : MapRowWriter<A> {
    return continueWriteReuse(map, expandable, keyField, valueField, null);
  }

  /**
    Continue writing a map from the specified location.
  **/
  public static function continueWriteReuse<A>(map : Map<Dynamic, Dynamic>, expandable : Bool, keyField : String, valueField : String, rowWriter : Null<MapRowWriter<A>>) : MapRowWriter<A> {
    if (rowWriter == null) {
      rowWriter = new MapRowWriter(map, expandable, keyField, valueField);
    } else {
      rowWriter.reuse(map, expandable, keyField, valueField);
    }
    return rowWriter;
  }

  public override function write(data : Dynamic, name : String, index : Int) : Void {
    if (_map != null) {
      if (_keyField == null) {
        if (_expandable) {
          _map.set(name, data);
        } else {
          // TODO
          _map.set(name, data);
        }
      } else {
        if (name == _keyField) {
          _keyCurrent = data;
          _got++;
        } else if (name == _valueField) {
          _valueCurrent = data;
          _got++;
        }
        if (_got == 2) {
          _map.set(_keyCurrent, _valueCurrent);
          _got = 0;
        }
      }
    }
  }
  
  public function reset() : Void { }
  
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
      _keyCurrent = null;
      _valueCurrent = null;
      _got = 0;
    }
  }
}

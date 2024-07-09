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
class MapRowReader<A> extends DataTableRowReader {
  private var _map : Map<Dynamic, Dynamic>;
  private var _iterator : Iterator<Dynamic>;
  private var _nextKey : Dynamic;
  private var _originalKey : Dynamic;
  private var _whole : Bool;

  private function new(map : Map<Dynamic, Dynamic>, iterator : Iterator<Dynamic>, nextKey : Dynamic) {
    super();
    reuse(map, iterator, nextKey);
  }

  public function reuse(map : Map<Dynamic, Dynamic>, iterator : Iterator<Dynamic>, nextKey : Dynamic) {
    _map = com.sdtk.std.Normalize.nativeToHaxe(map);
    if (iterator == null) {
      _iterator = _map.keys();
      _whole = true;
    } else {
      _iterator = iterator;
      _whole = false;
    }

    if (nextKey != null) {
      _nextKey = nextKey;
      _originalKey = _nextKey;
    } else {
      _nextKey = _iterator.next();
      _originalKey = _nextKey;
    }

    _started = false;
    _index = -1;
    _rawIndex = -1;
    _started = false;
    _value = null;
  }

  /**
    Continue reading a map from the specified location.
  **/
  public static function continueRead<A>(map : Map<Dynamic, Dynamic>, iterator : Iterator<Dynamic>) : MapRowReader<A> {
    return new MapRowReader(map, iterator, null);
  }

  /**
    Read entire map.
  **/
  public static function readWholeMap<A>(map : Map<Dynamic, Dynamic>) : MapRowReader<A> {
    return new MapRowReader(map, null, null);
  }

  public override function hasNext() : Bool {
    if (_index == -1) {
      return _nextKey != null;
    } else if (_whole) {
      return _iterator.hasNext() || _nextKey != null;
    } else {
     return false;
    }
  }

  public override function next() : Dynamic {
    if (_nextKey == null) {
      return null;
    } else {
      _name = Std.string(_nextKey);
      _value = _map.get(_nextKey);
      incrementTo(_name, _value, _index + 1);
      if (_whole) {
        _nextKey = _iterator.next();
      } else {
        _nextKey = null; 
      }
      return _value;
    }
  }

  public override function iterator() : Iterator<Dynamic> {
    return new MapRowReader(_map, _whole ? null : _iterator, _whole ? null : _nextKey);
  }

  public function reset() : Void {
    if (_whole) {
      _iterator = _map.keys();
    } else {
      _nextKey = _originalKey;
    }
  }
  
  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_map != null) {
      _map = null;
      _iterator = null;
      _nextKey = null;
      _originalKey = null;
    }
  }
}

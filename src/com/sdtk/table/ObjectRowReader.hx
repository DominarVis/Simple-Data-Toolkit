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
  Defines interface for processing arrays as table rows.
**/
@:expose
@:nativeGen
class ObjectRowReader<A> extends DataTableRowReader {
  private var _i : Int;
  private var _fields : Array<String>;
  private var _o : Any;

  private function new(o : Any) {
    super();
    _fields = Reflect.fields(o);
    reuse(o);
  }

  public function reuse(o : Any) {
    _o = o;
    _i = 0;
    _started = false;
    _index = -1;
    _rawIndex = -1;
    _started = false;
    _value = null;
  }

  /**
    Read entire object.
  **/
  public static function readWholeObject<A>(o : Any) : ObjectRowReader<A> {
    return readWholeObjectReuse(o, null);
  }
  /**
    Read entire object.
  **/
  public static function readWholeObjectReuse<A>(o : Any, rowReader : Null<ObjectRowReader<A>>) : ObjectRowReader<A> {
    if (rowReader == null) {
      rowReader = new ObjectRowReader(o);
    } else {
      rowReader.reuse(o);
    }
    return rowReader;
  }

  public override function hasNext() : Bool {
    return _i < _fields.length;
  }

  public override function next() : Dynamic {
    _value = Reflect.field(_o, _fields[_i]);
    incrementTo(_fields[_i], _value, _i);
    _i += 1;
    return _value;
  }

  public override function iterator() : Iterator<Dynamic> {
    return new ObjectRowReader(_o);
  }

  public function reset() : Void {
    _i = 0;
  }
  
  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_fields != null) {
      _fields = null;
      _o = null;
    }
  }
}

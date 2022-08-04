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
class ArrayRowReader<A> extends DataTableRowReader {
  private var _i : Int;
  private var _info : ArrayInfo<A>;

  private function new(info : ArrayInfo<A>) {
    super();
    reuse(info);
  }

  public function reuse(info : ArrayInfo<A>) {
    _info = info;
    _i = info._start;
    _started = false;
    _index = -1;
    _rawIndex = -1;
    _started = false;
    _value = null;
  }

  /**
    Continue reading an array from the specified location.
  **/
  public static function continueRead<A>(info : ArrayInfo<A>, start : Int, end : Int) : ArrayRowReader<A> {
    return continueReadReuse(info, start, end, null);
  }

  /**
    Read only a section of an array.
  **/
  public static function readPartOfArray<A>(arr : Array<A>, start : Int, end : Int, increment : Int) : ArrayRowReader<A> {
    return readPartOfArrayReuse(arr, start, end, increment, null);
  }

  /**
    Read entire array.
  **/
  public static function readWholeArray<A>(arr : Array<A>) : ArrayRowReader<A> {
    return readWholeArrayReuse(arr, null);
  }

  /**
    Continue reading an array from the specified location.
  **/
  public static function continueReadReuse<A>(info : ArrayInfo<A>, start : Int, end : Int, rowReader : Null<ArrayRowReader<A>>) : ArrayRowReader<A> {
    var info : ArrayInfo<A> = new ArrayInfo<A>(info._arr, start, end, info._entriesInRow, info._increment, info._rowIncrement);
    if (rowReader == null) {
      rowReader = new ArrayRowReader(info);
    } else {
      rowReader.reuse(info);
    }
    return rowReader;
  }

  /**
    Read only a section of an array.
  **/
  public static function readPartOfArrayReuse<A>(arr : Array<A>, start : Int, end : Int, increment : Int, rowReader : Null<ArrayRowReader<A>>) : ArrayRowReader<A> {
    var info : ArrayInfo<A> = new ArrayInfo<A>(arr, start, end, arr.length - 1, increment, 1);
    if (rowReader == null) {
      rowReader = new ArrayRowReader(info);
    } else {
      rowReader.reuse(info);
    }
    return rowReader;
  }

  /**
    Read entire array.
  **/
  public static function readWholeArrayReuse<A>(arr : Array<A>, rowReader : Null<ArrayRowReader<A>>) : ArrayRowReader<A> {
    var info : ArrayInfo<A> = new ArrayInfo<A>(arr, 0, arr.length - 1, arr.length - 1, 1, 0);
    if (rowReader == null) {
      rowReader = new ArrayRowReader(info);
    } else {
      rowReader.reuse(info);
    }
    return rowReader;
  }

  public override function hasNext() : Bool {
    return _i <= _info._end;
  }

  public override function next() : Dynamic {
    _name = Std.string(_index);
    _value = _info._arr[_i];
    incrementTo(null, _value, _i);
    _i += _info._increment;
    return _value;
  }

  public override function iterator() : Iterator<Dynamic> {
    return new ArrayRowReader(_info);
  }

  public function reset() : Void {
    _i = _info._start;
  }
  
  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_info != null) {
      _info = null;
    }
  }
}

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
  Defines interface for processing arrays as tables.
**/
@:expose
@:nativeGen
class ArrayReader<A> extends DataTableReader {
  private var _i : Int;
  private var _info : ArrayInfo<A>;

  private function new(info : ArrayInfo<A>) {
    super();
    _info = info;
    _i = info._start;
  }
  
  /**
    Converts a 1 dimensional array into a 2 dimensional table.
  **/
  public static function readSlicesOfArray<A>(arr : Array<A>, start : Int, end : Int, entriesInRow : Int, increment : Int, rowIncrement : Int) : ArrayReader<A> {
    return new ArrayReader(new ArrayInfo<A>(arr, start, end, entriesInRow, increment, rowIncrement));   
  }
    
  /**
    Reads a section of an array.
  **/
  public static function readPartOfArray<A>(arr : Array<A>, start : Int, end : Int, increment : Int) : ArrayReader<A> {
    return new ArrayReader(new ArrayInfo<A>(arr, start, end, arr.length - 1, increment, 1));
  }
  
  /**
    Read the whole array.
  **/
  public static function readWholeArray<A>(arr : Array<A>) : ArrayReader<A> {
    return new ArrayReader(new ArrayInfo<A>(arr, 0, arr.length - 1, arr.length - 1, 1, 0));
  }

  public override function hasNext() : Bool {
    return _i <= _info._end;
  }

  public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
    if (rowReader == null) {
      rowReader = ArrayRowReader.continueRead(_info, _i, _i + _info._entriesInRow - 1);
    } else {
      var rr : ArrayRowReader<Dynamic> = cast rowReader;
      rr.reuse(cast _info._arr[_i]);
    }
    _value = rowReader;
    _i += _info._rowIncrement;
    return rowReader;
  }
  
  public override function next() : Dynamic {
    return nextReuse(null);
  }

  public override function iterator() : Iterator<Dynamic> {
    return new ArrayReader<A>(_info);
  }

  public override function reset() : Void {
    _i = _info._start;
  }  
}

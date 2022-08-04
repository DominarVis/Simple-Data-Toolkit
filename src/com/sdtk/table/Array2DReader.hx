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
class Array2DReader<A> extends DataTableReader {
  private var _i : Int;
  private var _info : Array2DInfo<A>;

  private function new(info : Array2DInfo<A>) {
    super();
    _info = info;
    _i = info._start;
  }

  /**
    Read the whole array.
  **/
  public static function readWholeArray<A>(arr : Array<Array<A>>) : Array2DReader<A> {
    return new Array2DReader<A>(new Array2DInfo<A>(arr, 0, arr.length - 1, arr.length - 1, 1, 1));
  }

  public static function readWholeArrayI<Dynamic>(arr : Array<Dynamic>) : Array2DReader<Dynamic> {
    return new Array2DReader<Dynamic>(new Array2DInfo<Dynamic>(cast arr, 0, arr.length - 1, arr.length - 1, 1, 1));
  }

  public static function reuse<A>(info : Array2DInfo<A>) : Array2DReader<A> {
    return new Array2DReader(info);
  }

  public override function hasNext() : Bool {
    return _i <= (_info._end < 0 ? _info._arr.length - 1 : _info._end);
  }

  public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
    if (rowReader == null) {
      rowReader = ArrayRowReader.readWholeArray(_info._arr[_i]);
    } else {
      var rr : ArrayRowReader<Dynamic> = cast rowReader;
      rr.reuse(cast _info._arr[_i]);
    }
    incrementTo(null, rowReader, _i);
    _i += _info._rowIncrement;
    return rowReader;
  }
  
  public override function next() : Dynamic {
    return nextReuse(null);
  }

  public override function iterator() : Iterator<Dynamic> {
    return new Array2DReader<A>(_info);
  }

  public function flip() : Array2DWriter<A> {
    return Array2DWriter.reuse(_info);
  }
  
  public override function headerRowNotIncluded() : Bool {
    return false;
  }

  public override function reset() : Void {
    _i = _info._start;
  }
}

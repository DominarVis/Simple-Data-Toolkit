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
class ArrayOfMapsReader<A> extends DataTableReader {
  private var _i : Int;
  private var _info : ArrayInfo<A>;

  private function new(info : ArrayInfo<A>) {
    super();
    _info = info;
    _i = info._start;
  }

  /**
    Read the whole array.
  **/
  public static function readWholeArray<A>(arr : Array<Map<String, A>>) : ArrayOfMapsReader<A> {
    return new ArrayOfMapsReader<A>(new ArrayInfo<A>(arr, 0, arr.length - 1, arr.length - 1, 1, 1));
  }

  public static function readWholeArrayI<Dynamic>(arr : Array<Dynamic>) : ArrayOfMapsReader<Dynamic> {
    return new ArrayOfMapsReader<Dynamic>(new ArrayInfo<Dynamic>(cast arr, 0, arr.length - 1, arr.length - 1, 1, 1));
  }

  public static function reuse<A>(info : ArrayInfo<A>) : ArrayOfMapsReader<A> {
    return new ArrayOfMapsReader(info);
  }

  public override function hasNext() : Bool {
    return _i <= (_info._end < 0 ? _info._arr.length - 1 : _info._end);
  }

  public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
    if (rowReader == null) {
      rowReader = MapRowReader.readWholeMap(cast _info._arr[_i]);
    } else {
      var rr : MapRowReader<Dynamic> = cast rowReader;
      rr.reuse(cast _info._arr[_i], null, null);
    }
    incrementTo(null, rowReader, _i);
    _i += _info._rowIncrement;
    return rowReader;
  }
  
  public override function next() : Dynamic {
    return nextReuse(null);
  }

  public override function iterator() : Iterator<Dynamic> {
    return new ArrayOfMapsReader<A>(_info);
  }

  // TODO
  public function flip() : Array2DWriter<A> {
    return null;
  }
  
  public override function headerRowNotIncluded() : Bool {
    return true;
  }

  public override function reset() : Void {
    _i = _info._start;
  }

  #if(cs || java)
    public override function toArrayOfHaxeMaps(arr : Array<Map<String, Dynamic>>) : Array<Map<String, Dynamic>> {
  #else
    public override function toArrayOfHaxeMaps<A>(arr : Array<Map<String, A>>) : Array<Map<String, A>> {
  #end  
    return cast _info._arr.slice(_info._start, (_info._end < 0 ? _info._arr.length - 1 : _info._end));
  }
}

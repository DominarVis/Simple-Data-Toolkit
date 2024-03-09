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
class ArrayOfMapsWriter<A> extends DataTableWriter {
  private var _i : Int;
  private var _info : ArrayOfMapsInfo<A>;

  private function new(info : ArrayOfMapsInfo<A>) {
    super();
    _info = info;
    _i = info._start;
  }

  /**
    Read the whole array.
  **/
  public static function writeToWholeArray<A>(arr : Array<Map<String, A>>) : ArrayOfMapsWriter<A> {
    return new ArrayOfMapsWriter<A>(new ArrayOfMapsInfo<A>(arr, 0, arr.length - 1, arr.length - 1, 1, 1));
  }
  
  public static function writeToExpandableArrayI<A>(arr : Null<Array<Dynamic>>) : ArrayOfMapsWriter<Dynamic> {
    if (arr == null) {
      arr = new Array<Map<String, A>>();
    }
    return new ArrayOfMapsWriter<Dynamic>(new ArrayOfMapsInfo<Dynamic>(cast arr, 0, -1, -1, 1, 1));
  }

  public static function writeToExpandableArray<A>(arr : Null<Array<Map<String, A>>>) : ArrayOfMapsWriter<A> {
    if (arr == null) {
      arr = new Array<Map<String, A>>();
    }
    return new ArrayOfMapsWriter<A>(new ArrayOfMapsInfo<A>(arr, 0, -1, -1, 1, 1));
  }

  public static function reuse<A>(info : ArrayOfMapsInfo<A>) : ArrayOfMapsWriter<A> {
    return new ArrayOfMapsWriter(info);
  }

  public override function start() : Void {
  }

  private override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    #if cs
      var arr : Array<Dynamic> = _info._arr;
    #else
      var arr : Array<Map<String, A>> = _info._arr;
    #end
    if (_info._end >= 0 && (index + _info._start) > _info._end) {
      return null;
    }
    while (arr.length <= _i) {
      arr.push(cast new Map<String, A>());
    }
    var rowWriter : MapRowWriter<A> = MapRowWriter.continueWriteReuse(cast arr[_i], true, null, null, cast rowWriter);
    _i += _info._rowIncrement;
    return rowWriter;
  }

  public override function flip() : DataTableReader {
    return ArrayOfMapsReader.reuse(_info);
  }
  
  public function getArray() : Array<Map<String, A>> {
    #if cs
      var arr : Dynamic = _info._arr;
      return cast arr;
    #else
      return _info._arr;
    #end
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
  
  public override function writeHeaderFirst() : Bool {
    return false;
  }
  
  public override function writeRowNameFirst(): Bool {
  	return true;
  }
}

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
class Array2DWriter<A> extends DataTableWriter {
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
  public static function writeToWholeArray<A>(arr : Array<Array<A>>) : Array2DWriter<A> {
    return new Array2DWriter<A>(new Array2DInfo<A>(arr, 0, arr.length - 1, arr.length - 1, 1, 1));
  }
  
  public static function writeToExpandableArray<A>(arr : Null<Array<Array<A>>>) : Array2DWriter<A> {
    if (arr == null) {
      arr = new Array<Array<A>>();
    }
    return new Array2DWriter<A>(new Array2DInfo<A>(arr, 0, -1, -1, 1, 1));
  }

  public static function reuse<A>(info : Array2DInfo<A>) : Array2DWriter<A> {
    return new Array2DWriter(info);
  }

  public override function start() : Void {
  }

  private override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    #if cs
      var arr : Array<Dynamic> = _info._arr;
    #else
      var arr : Array<Array<A>> = _info._arr;
    #end
    if (_info._end >= 0 && (index + _info._start) > _info._end) {
      return null;
    }
    while (arr.length <= _i) {
      arr.push(new Array<A>());
    }
    var rowWriter : ArrayRowWriter<A> = ArrayRowWriter.writeToExpandableArrayReuse(arr[_i], cast rowWriter);
    _i += _info._rowIncrement;
    return rowWriter;
  }

  public function flip() : Array2DReader<A> {
    return Array2DReader.reuse(_info);
  }
  
  public function getArray() : Array<Array<A>> {
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
    return true;
  }
  
  public override function writeRowNameFirst(): Bool {
  	return true;
  }
}

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
class ArrayWriter<A> extends DataTableWriter {
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
  public static function writeToSlicesOfArray<A>(arr : Array<A>, start : Int, end : Int, entriesInRow : Int, increment : Int, rowIncrement : Int) : ArrayWriter<A> {
    return new ArrayWriter<A>(new ArrayInfo<A>(arr, start, end, entriesInRow, increment, rowIncrement));
  }
    
  /**
    Reads a section of an array.
  **/
  public static function writeToPartOfArray<A>(arr : Array<A>, start : Int, end : Int, increment : Int) : ArrayWriter<A> {
    return new ArrayWriter<A>(new ArrayInfo<A>(arr, start, end, arr.length - 1, increment, 1));
  }
  
  /**
    Read the whole array.
  **/
  public static function writeToWholeArray<A>(arr : Array<A>) : ArrayWriter<A> {
    return new ArrayWriter<A>(new ArrayInfo<A>(arr, 0, arr.length - 1, arr.length - 1, 1, 0));
  }
  
  public static function writeToExpandableArray<A>(arr : Null<Array<A>>) : ArrayWriter<A> {
    return new ArrayWriter<A>(new ArrayInfo<A>(arr, 0, -1, -1, 1, 0));
  }

  public override function start() : Void {
  }

  public override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
  	if (_info._end >= 0 && (index + _info._start) > _info._end) {
      return null;
    }
    var rowWriter : ArrayRowWriter<A> = ArrayRowWriter.continueWriteReuse(_info, _i, _i + _info._entriesInRow - 1, cast rowWriter);
    _i += _info._rowIncrement;
    return rowWriter;
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
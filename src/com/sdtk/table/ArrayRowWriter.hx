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
class ArrayRowWriter<A> extends DataTableRowWriter {
  private var _i : Int;
  private var _info : ArrayInfo<A>;

  private function new(info : ArrayInfo<A>) {
    super();
    reuse(info);
  }

  public function reuse(info : ArrayInfo<A>) {
    _info = info;
    _i = info._start;
  }

  /**
    Continue writing an array from the specified location.
  **/
  public static function continueWrite<A>(info : ArrayInfo<A>, start : Int, end : Int) : ArrayRowWriter<A> {
    return continueWriteReuse(info, start, end, null);
  }

  /**
    Write to only a section of an array.
  **/
  public static function writeToPartOfArray<A>(arr : Array<A>, start : Int, end : Int, increment : Int) : ArrayRowWriter<A> {
    return writeToPartOfArrayReuse(arr, start, end, increment, null);
  }

  /**
    Write to entire array.
  **/
  public static function writeToWholeArray<A>(arr : Array<A>) : ArrayRowWriter<A> {
    return writeToWholeArrayReuse(arr, null);
  }

  public static function writeToExpandableArray<A>(arr : Array<A>) : ArrayRowWriter<A> {
    return writeToExpandableArrayReuse(arr, null);
  }  
  
  /**
    Continue writing an array from the specified location.
  **/
  public static function continueWriteReuse<A>(info : ArrayInfo<A>, start : Int, end : Int, rowWriter : Null<ArrayRowWriter<A>>) : ArrayRowWriter<A> {
    var info : ArrayInfo<A> = new ArrayInfo<A>(info._arr, start, end, info._entriesInRow, info._increment, info._rowIncrement);
    if (rowWriter == null) {
      rowWriter = new ArrayRowWriter(info);
    } else {
      rowWriter.reuse(info);
    }
    return rowWriter;
  }

  /**
    Write to only a section of an array.
  **/
  public static function writeToPartOfArrayReuse<A>(arr : Array<A>, start : Int, end : Int, increment : Int, rowWriter : Null<ArrayRowWriter<A>>) : ArrayRowWriter<A> {
    var info : ArrayInfo<A> = new ArrayInfo<A>(arr, start, end, arr.length - 1, increment, 1);
    if (rowWriter == null) {
      rowWriter = new ArrayRowWriter(info);
    } else {
      rowWriter.reuse(info);
    }
    return rowWriter;    
  }

  /**
    Write to entire array.
  **/
  public static function writeToWholeArrayReuse<A>(arr : Array<A>, rowWriter : Null<ArrayRowWriter<A>>) : ArrayRowWriter<A> {
    var info : ArrayInfo<A> = new ArrayInfo<A>(arr, 0, arr.length - 1, arr.length - 1, 1, 0);
    if (rowWriter == null) {
      rowWriter = new ArrayRowWriter(info);
    } else {
      rowWriter.reuse(info);
    }
    return rowWriter;    
  }

  public static function writeToExpandableArrayReuse<A>(arr : Array<A>, rowWriter : Null<ArrayRowWriter<A>>) : ArrayRowWriter<A> {
    var info : ArrayInfo<A> = new ArrayInfo<A>(arr, 0, -1, -1, 1, 0);
    if (rowWriter == null) {
      rowWriter = new ArrayRowWriter(info);
    } else {
      rowWriter.reuse(info);
    }
    return rowWriter;    
  } 

  public override function write(data : Dynamic, name : String, index : Int) : Void {
    if (_info != null) {
      if (_info._end >= 0 && (index + _info._start) > _info._end) {
        return;
      }
      var arr : Array<A> = _info._arr;
      while (arr.length <= index) {
        arr.push(null);
      }
      arr[index] = data;
    }
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

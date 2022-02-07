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
  Defines interface for interpreting arrays.
**/
@:nativeGen
class ArrayInfo<A> {
  public var _arr : Array<A>;
  public var _start : Int;
  public var _end : Int;
  public var _entriesInRow : Int;
  public var _increment : Int;
  public var _rowIncrement : Int;

  /*
    Included because some implementations of Haxe can't use the above constructor properly in some subclasses.

    We couldn't do an overload because some implementations don't support that.
  */
  public function new(arr : Dynamic, start : Int, end : Int, entriesInRow : Int, increment : Int, rowIncrement : Int) {
    _arr = cast arr;
    _start = start;
    _end = end;
    _entriesInRow = entriesInRow;
    _increment = increment;
    _rowIncrement = rowIncrement;
  }
}

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
  Defines interface for interpreting arrays of Objects.
**/
@:nativeGen
class ArrayOfObjectsInfo<A> extends ArrayInfo<A> {
  public var _constructor : Void->A;

  public function new(arr : Array<A>, start : Int, end : Int, entriesInRow : Int, increment : Int, rowIncrement : Int, constructor : Void->A) {
    super(arr, start, end, entriesInRow, increment, rowIncrement);
    _constructor = constructor;
  }
}

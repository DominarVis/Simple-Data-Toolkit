/*
    Copyright (C) 2019 Vis LLC - All Rights Reserved

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

/*
    Simple Data Toolkit
    Simple Table Converter (STC) - Source code can be found in Converter.hx in Haxe on SourceForge.net
*/

package com.sdtk.table;

import com.sdtk.std.*;

@:expose
@:nativeGen
class KeyValueRowReader extends DataTableRowReader {
  private var _map : Null<Map<String, Dynamic>> = null;
  private var _columns : Null<Array<Dynamic>> = null;

  public function new(mMap : Map<String, Dynamic>, cColumns : Null<Array<Dynamic>>) {
    super();
    reuse(mMap, cColumns);
  }

  public function reuse(mMap : Map<String, Dynamic>, cColumns : Null<Array<Dynamic>>) {
    _map = mMap;
    _columns = cColumns;
    _index = -1;
    _rawIndex = -1;
    _started = false;
    _value = null;
  }

  private override function startI() : Void {
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    _map = null;
    _columns = null;
  }

  public override function hasNext() : Bool {
    return index() < _columns.length - 1;
  }

  public override function next() : Dynamic {
    var sColumn : String = _columns[index() + 1];
    incrementTo(sColumn, _map.get(sColumn), index() + 1);
    return value();
  }
}

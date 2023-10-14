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

#if(!EXCLUDE_DATABASE)
@:nativeGen
class DatabaseRowReader extends DataTableRowReader {
  private var _reader : Null<DatabaseReader>;

  public function new(reader : DatabaseReader) {
    super();
    reuse(reader);
  }

  public function reuse(reader : DatabaseReader) {
    _reader = reader;
    _index = -1;
  }

  public override function hasNext() : Bool {
    return index() < (_reader.columns() - 1);
  }

  private override function startI() : Void {
  }

  public override function next() : Dynamic {
    incrementTo(_reader.columnName(index() + 1), _reader.readColumn(index() + 1), -1);
    return value();
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    _reader = null;
  }
}
#end
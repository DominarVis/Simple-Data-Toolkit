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
  Adapts TableReaderI to the STC table reader interface.
**/
@:expose
@:nativeGen
class TableReader extends DataTableReader {
  private var _reader : TableReaderI;
  private var _header : Array<String>;

  private function new(tdInfo : TableInfo, oElement : Dynamic) {
    super();
    _reader = new TableReaderI(tdInfo, oElement);
    _index = -1;
    _header = new Array<String>();
  }

  public override function hasNext() : Bool {
    return _reader.hasNext();
  }

  public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
    if (_reader.hasNext()) {
      _index++;
      _name = _reader.peek();
      if (rowReader == null) {
        rowReader = new TableRowReader(_reader.next(), _header);
      } else {
        var rr : TableRowReader = cast rowReader;
        rr.reuse(_reader.next(), _header);
      }
      _value = rowReader;
    } else {
      _value = null;
      return null;
    }

    return rowReader;
  }

  public override function next() : Dynamic {
    return nextReuse(null);
  }

  public static function createStandardTableReader(oElement : Dynamic) {
    return new TableReader(StandardTableInfo.instance, oElement);
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    _reader = null;
    _header = null;
  }
}
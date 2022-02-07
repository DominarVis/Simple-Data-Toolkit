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
  Adapts TableRowReaderI to the STC table row reader interface.
**/
@:expose
@:nativeGen
class TableRowReader extends DataTableRowReader {
  private var _reader : TableRowReaderI;
  private var _isHeader : Bool;
  private var _header : Array<String>;

  public function new(trReader : TableRowReaderI, aHeader : Array<String>) {
    super();
    reuse(trReader, aHeader);
  }

  public function reuse(trReader : TableRowReaderI, aHeader : Array<String>) : Void {
    _isHeader = Type.getClass(trReader) == TableHeaderRowReaderI;
    _header = aHeader;
    _reader = trReader;
    _index = -1;
    _started = false;
    _value = null;
  }

  public override function hasNext() : Bool {
    return _reader.hasNext();
  }

  public override function next() : Dynamic {
    if (_reader.hasNext()) {
      _index++;

      if (_isHeader) {
        _name = _reader.peek();
        _header.push(_name);
      } else {
        _name = _header[_index];
      }

      return _reader.next();
    } else {
      return null;
    }
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
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
  Defines row filtering for reading a table.
**/
@:expose
@:nativeGen
class RowFilterDataTableReader extends DataTableReader {
    private var _filter : Null<Filter>;
    private var _reader : Null<DataTableReader>;
    private var _buffer : Null<Array<String>>;
    private var _bufferReader : Null<ArrayRowReader<String>>;
    private var _bufferReaderPrevious : Null<ArrayRowReader<String>>;
    private var _buffer2 : Null<Array<String>>;
    private var _switch : Int = 0;

  public function new(dtrReader : DataTableReader, fFilter : Filter) {
    super();
    _filter = fFilter;
    _reader = dtrReader;
    _buffer = new Array<String>();
    _buffer2 = new Array<String>();
  }

  private override function startI() : Void {
    _reader.start();
    check(true);
  }

  private function check(reuse : Bool) : Void {
    var rowReader : Null<DataTableRowReader> = _reader.next();
    if (rowReader != null) {
      _bufferReader = null;
      while (rowReader != null && _bufferReader == null) {
        rowReader.start();
        var row = rowReader.next();
        if (_filter.filter(row) != null) {
          var buffer : Array<String>;
          switch (_switch) {
            case 0:
              buffer = _buffer;
            default:
              buffer = _buffer2;
          }
          while (buffer.length > 0) {
            buffer.pop();
          }
          buffer.push(row);
          while (rowReader.hasNext()) {
            buffer.push(rowReader.next());
          }
          if (reuse || _bufferReaderPrevious == null) {
            _bufferReader = ArrayRowReader.readWholeArrayReuse(buffer, _bufferReaderPrevious);
          } else {
            _bufferReader = ArrayRowReader.readWholeArray(buffer);
          }
        } else {
          while (rowReader.hasNext()) {
            rowReader.next();
          }
          rowReader = _reader.next();
        }
      }
    } else {
      _bufferReader = null;
      dispose();
    }
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
      if (_reader != null) {
          super.dispose();
          _filter = null;
          _reader = null;
          _buffer = null;
          _bufferReader = null;
          _bufferReaderPrevious = null;
      }
  }

  public override function hasNext() : Bool {
    return _buffer != null;
  }

  private function nextI(reuse : Bool) {
    var current : Null<ArrayRowReader<String>>;
    current = _bufferReader;
    switch (_switch) {
      case 0:
        _switch = 122;
      default:
        _switch = 0;
    }
    incrementTo(_reader.name(), current);
    check(reuse);
    _bufferReaderPrevious = current;
    return current;
  }

  public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
    return nextI(true);
  }

  public override function next() : Dynamic {
    return nextI(false);
  }
 
  public override function isAutoNamed() : Bool {
  	 return _reader.isAutoNamed();
  }

  public override function isNameIndex() : Bool {
  	 return _reader.isNameIndex();
  }
  
  public override function headerRowNotIncluded() : Bool {
    return _reader.headerRowNotIncluded();
  }    
}

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
  Adapts delimited files (like CSV, PSV, etc) to STC table reader interface.
**/
@:expose
@:nativeGen
class DelimitedReader extends DataTableReader {
  private var _info : Null<DelimitedInfo> = null;
  private var _reader : Reader;
  private var _done : Bool = false;
  private var _header : Null<Array<String>> = null;
  private var _noHeaderIncluded : Bool = false;

  public function new(diInfo : DelimitedInfo, rReader : Reader) {
    super();
    _info = diInfo;
    _reader = rReader;
  }

  private override function startI() : Void {
    _reader.start();
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (!_done) {
      _done = true;
      _reader.dispose();
    }
  }

  public override function hasNext() : Bool {
    return _reader.hasNext();
  }

  public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
    while (_reader.hasNext() && (_reader.peek() == _info.rowDelimiter())) {
      _reader.next();
    }
    if (!_reader.hasNext()) {
      rowReader = null;
    } else {
      if (_header == null) {
        _header = new Array<String>();
        if (rowReader == null) {
          rowReader = new DelimitedRowReader(_info, _reader, _header, !_noHeaderIncluded);
        } else {
          var rr : DelimitedRowReader = cast rowReader;
          rr.reuse(_info, _reader, _header, true);
        }
      } else {
        if (rowReader == null) {
          rowReader = new DelimitedRowReader(_info, _reader, _header, false);
        } else {
          var rr : DelimitedRowReader = cast rowReader;
          rr.reuse(_info, _reader, _header, false);
        }
        
      }
    }
    incrementTo(null, rowReader, _reader.rawIndex());
    return rowReader;
  }
  
  public override function next() : Dynamic {
    return nextReuse(null);
  }

  public static function createRawReader(reader : Reader) {
    return new DelimitedReader(RAWInfo.instance, reader);
  }  

  public static function createCSVReader(reader : Reader) {
    return new DelimitedReader(CSVInfo.instance, reader);
  }

  public static function createTSVReader(reader : Reader) {
    return new DelimitedReader(TSVInfo.instance, reader);
  }

  public static function createPSVReader(reader : Reader) {
    return new DelimitedReader(PSVInfo.instance, reader);
  }
  
  public override function headerRowNotIncluded() : Bool {
    return _noHeaderIncluded;
  }

  public override function noHeaderIncluded(noHeader : Bool) : Void {
    _noHeaderIncluded = noHeader;
  }

  public override function allowNoHeaderInclude() : Bool {
    return true;
  }  

  public function skipRows(rows : Int) : Void {
    var noHeaderIncluded : Bool = _noHeaderIncluded;
    var reader : DataTableRowReader = null;
    while (rows > 0) {
      reader = cast nextReuse(reader);
      rows--;
    }
    _noHeaderIncluded = noHeaderIncluded;
  }

  public override function reset() : Void {
    _reader.reset();
    _header = null;
    _done = false;
  }

  public override function getColumns() : Array<String> { 
    return _header;
  }
}

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
  Adapts delimited files (like CSV, PSV, etc) to STC table writer interface.
**/
@:expose
@:nativeGen
class DelimitedWriter extends DataTableWriter {
  private var _info : Null<DelimitedInfo> = null;
  private var _writer : Writer;
  private var _done : Bool = false;
  private var _noHeaderIncluded : Bool = false;

  public function new(diInfo : DelimitedInfo, wWriter : Writer) {
    super();
    _info = diInfo;
    _writer = wWriter;
  }

  public override function start() : Void {
    _writer.start();
  }

  public function noHeaderIncluded(noHeader : Bool) : Void {
    _noHeaderIncluded = noHeader;
  }    

  public override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    if (rowWriter == null) {
      rowWriter = new DelimitedRowWriter(_info, _writer);
    } else {
      var rw : DelimitedRowWriter = cast rowWriter;
      rw.reuse(_info, _writer);
    }
    return rowWriter;
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (!_done) {
      _done = true;
      _writer.dispose();
    }
  }
  
  public override function writeHeaderFirst() : Bool {
    return !_noHeaderIncluded;
  }
  
  public override function writeRowNameFirst() : Bool {
  	return true;
  }

  public static function createCSVWriter(writer : Writer) {
    return new DelimitedWriter(CSVInfo.instance, writer);
  }

  public static function createTSVWriter(writer : Writer) {
    return new DelimitedWriter(TSVInfo.instance, writer);
  }

  public static function createPSVWriter(writer : Writer) {
    return new DelimitedWriter(PSVInfo.instance, writer);
  }
}
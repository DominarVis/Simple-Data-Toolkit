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
  Defines interface and defaults for writing tables.
**/
@:expose
@:nativeGen
class DataTableWriter implements com.sdtk.std.Disposable {
  private var _written : Int = 0;
	
  public function new() { }

  /**
    Indicates the beginning of writing.
  **/
  public function start() : Void {
  }

  public function writeStart(name : String, index : Int) : DataTableRowWriter {
    return writeStartReuse(name, index, null);
  }

  public function writeStartReuse(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
  	if (!canWrite()) {
      return null;
  	} else {
      var dtrwWriter : DataTableRowWriter = writeStartI(name, index, rowWriter);
      _written++;
      return dtrwWriter;
    }
  }
  
  private function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    return null;
  }
  
  public function writeHeaderFirst() : Bool {
    return false;
  }
  
  public function writeRowNameFirst(): Bool {
  	return false;
  }
  
  public function oneRowPerFile() : Bool {
    return false;
  }
  
  public function canWrite() : Bool {
  	return _written <= 0 || !oneRowPerFile();
  }

  // TODO - Make sure this is everywhere
  public function flip() : DataTableReader {
    return null;
  }
  
  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public function dispose() : Void {
  }
}

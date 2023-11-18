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
class FileSystemWriter extends DataTableWriter {
  private var _handler : Null<FileSystemHandler> = null;
  private var _writer : Null<Writer> = null;
  private var _previous : Null<FileSystemRowWriter> = null;

  private function new(fshHandler : FileSystemHandler, wWriter : Writer) {
    super();
    _handler = fshHandler;
    _writer = wWriter;
  }

  public static function createCMDDirWriter(wWriter : Writer) {
    return new FileSystemWriter(CMDDirHandler.instance(), wWriter);
  }

  /**
    Indicates the beginning of writing.
  **/
  public override function start() : Void {
    _writer.start();
  }

  private override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    if (rowWriter == null) {
      _previous = new FileSystemRowWriter(_handler, _writer, _previous, 0);
    } else {
      _previous = cast rowWriter;
      _previous.reuse(_handler, _writer, _previous, 0);
    }
    
    return _previous;
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_writer != null) {
      _writer.dispose();
      _writer = null;
      _handler = null;
      _previous = null;
      super.dispose();
    }
  }
}

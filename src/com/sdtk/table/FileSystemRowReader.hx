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

@:nativeGen
class FileSystemRowReader extends DataTableRowReader {
  private var _handler : Null<FileSystemHandler> = null;
  private var _reader : Null<Reader> = null;
  private var _current : Null<FileInfo> = null;
  private var _array : Null<Array<Dynamic>>;
  private static var _fields : Array<String> = ["Drive", "Label", "Serial", "Directory", "Owner", "File", "Short", "True", "Modified", "Size", "Type"];

  public function new(fshHandler : FileSystemHandler, rReader : Reader, fsrrPrevious : Null<FileSystemRowReader>) {
    super();
    reuse(fshHandler, rReader, fsrrPrevious);
  }

  public function reuse(fshHandler : FileSystemHandler, rReader : Reader, fsrrPrevious : Null<FileSystemRowReader>) : Void {
    _handler = fshHandler;
    _reader = rReader;
    if (fsrrPrevious != null) {
      _current = _handler.next(_reader, fsrrPrevious._current);
      fsrrPrevious._current = null;
    } else {
      _current = _handler.next(_reader, null);
    }
    if (_current != null) {
      _array = new Array<Dynamic>();
      _array.push(_current.getDrive());
      _array.push(_current.getLabel());
      _array.push(_current.getSerial());
      _array.push(_current.getDirectory());
      _array.push(_current.getOwner());
      _array.push(_current.getName());
      _array.push(_current.getShortName());
      _array.push(_current.getTrueName());
      _array.push(_current.getDate());
      _array.push(_current.getSize());
      _array.push(_current.getIsDirectory() ? "Directory" : _current.getIsJunction() ? "Junction" : "File");
    }
    _index = -1;
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
    if (_reader != null) {
      _reader.dispose();
      _reader = null;
      _handler = null;
      _array = null;
      // Don't set _current to null, since it needs to be used by the next RowReader.
    }
  }

  public override function hasNext() : Bool {
    return _current != null && index() < _array.length;
  }

  public override function next() : Dynamic {
    incrementTo(_fields[index()], _array[index()], index());
    return value();
  }
}

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
class KeyValueRowWriter extends DataTableRowWriter {
  private var _handler : Null<KeyValueHandler> = null;
  private var _writer : Null<Writer> = null;
  private var _name : Null<String> = null;
  private var _rowIndex : Int;
  private var _map : Null<Map<String, Dynamic>>;

  public function new(fshHandler : KeyValueHandler, wWriter : Writer, name : String, index : Int) {
    super();
    reuse(fshHandler, wWriter, name, index);
  }

  public function reuse(fshHandler : KeyValueHandler, wWriter : Writer, name : String, index : Int) : Void {
    if (_writer != null) {
      _handler.write(_writer, _map, _name, _rowIndex);
    }
    _handler = fshHandler;
    _writer = wWriter;
    _name = name;
    _rowIndex = index;
    _map = new Map<String, Dynamic>();    
  }  

  public override function start() : Void {
    _writer.start();
  }

  public override function write(data : Dynamic, name : String, index : Int) : Void {
    if (data != null) {
      _map.set(name, data);
    }
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_writer != null) {
      _handler.write(_writer, _map, _name, _rowIndex);
      _writer = null;
      _handler = null;
      _name = null;
      _map = null;
      super.dispose();
    }
  }
}

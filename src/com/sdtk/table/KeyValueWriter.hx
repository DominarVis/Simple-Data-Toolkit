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
class KeyValueWriter extends DataTableWriter {
  private var _handler : Null<KeyValueHandler> = null;
  private var _writer : Null<Writer> = null;
  private var _lastName : Null<String> = null;
  private var _lastIndex : Null<Int> = null;

  private function new(fshHandler : KeyValueHandler, wWriter : Writer) {
    super();
    _handler = fshHandler;
    _writer = wWriter;
  }

  public static function createINIWriter(wWriter : Writer) {
    return new KeyValueWriter(INIHandler.instance(), wWriter);
  }

  public static function createJSONWriter(wWriter : Writer) {
    return new KeyValueWriter(JSONHandler.instance(), wWriter);
  }

  public static function createPropertiesWriter(wWriter : Writer) {
    return new KeyValueWriter(PropertiesHandler.instance(), wWriter);
  }

  public static function createSplunkWriter(wWriter : Writer) {
    return new KeyValueWriter(SplunkHandler.instance(), wWriter);
  }

  public override function start() : Void {
    _writer.start();
  }

  private override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    if (rowWriter == null) {
      rowWriter = new KeyValueRowWriter(_handler, _writer, name, index);
    } else {
      var rw : KeyValueRowWriter = cast rowWriter;
      rw.reuse(_handler, _writer, name, index);
    }
    return rowWriter;
  }
  
  public override function oneRowPerFile() : Bool {
    return _handler.oneRowPerFile();
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_writer != null) {
      _handler.writeEnd(_writer, _lastName, _lastIndex);
      _writer.dispose();
      _writer = null;
      _handler = null;
      _lastName = null;
      _lastIndex = null;
      super.dispose();
    }
  }
}

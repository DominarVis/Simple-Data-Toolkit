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
/*

import com.sdtk.std.*;

/**
  Adapts code files (like SQL, JavaScript, etc) to STC table writer interface.
**/
/*
@:expose
@:nativeGen
class DocumentWriter extends DataTableWriter {
  private var _info : Null<DocumentInfo> = null;
  private var _writer : Writer;
  private var _done : Bool = false;

  public function new(diInfo : DocumentInfo, wWriter : Writer) {
    super();
    _info = diInfo;
    _writer = wWriter;
  }

  public override function start() : Void {
    _writer.start();
  }

  public override function writeStartI(name : String, index : Int) : DataTableRowWriter {
    if (_written == 0) {
        _writer.write(_info.start());
    } else {
        _writer.write(_info.betweenRows());
    }
    _writer.write(_info.rowStart(name, index));
    return new CodeRowWriter(_info, _writer);
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (!_done) {
      _writer.write(_info.end());
      _done = true;
      _writer.dispose();
    }
  }
  
  public override function writeHeaderFirst() : Bool {
    return false;
  }
  
  public override function writeRowNameFirst() : Bool {
  	return false;
  }

  public static function createSQLSelectWriter(writer : Writer) {
    return new CodeWriter(SQLSelectInfo.instance, writer);
  }
/*
  public static function createJSONMapOfMapWriter(writer : Writer) {
    return new CodeWriter(JSONMapOfMapInfo.instance, writer);
  }

  public static function createJSONMapOfArrayWriter(writer : Writer) {
    return new CodeWriter(JSONMapOfArrayInfo.instance, writer);
  }

  public static function createJSONArrayOfMapWriter(writer : Writer) {
    return new CodeWriter(TSVInfo.instance, writer);
  }

  public static function createJSONArrayOfArrayWriter(writer : Writer) {
    return new CodeWriter(PSVInfo.instance, writer);
  }*/
//}
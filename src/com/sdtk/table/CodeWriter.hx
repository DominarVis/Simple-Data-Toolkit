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
  Adapts code files (like SQL, JavaScript, etc) to STC table writer interface.
**/
@:expose
@:nativeGen
class CodeWriter extends DataTableWriter {
  private var _info : Null<CodeInfo> = null;
  private var _writer : Writer;
  private var _done : Bool = false;

  public function new(diInfo : CodeInfo, wWriter : Writer) {
    super();
    _info = diInfo;
    _writer = wWriter;
  }

  public override function start() : Void {
    _writer.start();
  }

  public override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    if (_written == 0) {
        _writer.write(_info.start());
    }
    if (rowWriter == null) {
      _writer.write(_info.rowStart(name, index));
      rowWriter = new CodeRowWriter(_info, _writer);
    } else {
      var rw : CodeRowWriter = cast rowWriter;
      rw.reuse(_info, _writer);
      _writer.write(_info.betweenRows());
      _writer.write(_info.rowStart(name, index));
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

  public static function createCSharpArrayOfArraysWriter(writer : Writer) {
    return new CodeWriter(CSharpInfoArrayOfArrays.instance, writer);
  }

  public static function createCSharpArrayOfMapsWriter(writer : Writer) {
    return new CodeWriter(CSharpInfoArrayOfMaps.instance, writer);
  }  

  public static function createCSharpMapOfArraysWriter(writer : Writer) {
    return new CodeWriter(CSharpInfoMapOfArrays.instance, writer);
  }

  public static function createCSharpMapOfMapsWriter(writer : Writer) {
    return new CodeWriter(CSharpInfoMapOfMaps.instance, writer);
  }

  public static function createPythonArrayOfArraysWriter(writer : Writer) {
    return new CodeWriter(PythonInfoArrayOfArrays.instance, writer);
  }

  public static function createPythonArrayOfMapsWriter(writer : Writer) {
    return new CodeWriter(PythonInfoArrayOfMaps.instance, writer);
  }  

  public static function createPythonMapOfArraysWriter(writer : Writer) {
    return new CodeWriter(PythonInfoMapOfArrays.instance, writer);
  }

  public static function createPythonMapOfMapsWriter(writer : Writer) {
    return new CodeWriter(PythonInfoMapOfMaps.instance, writer);
  }      

  public static function createHaxeArrayOfArraysWriter(writer : Writer) {
    return new CodeWriter(HaxeInfoArrayOfArrays.instance, writer);
  }

  public static function createHaxeArrayOfMapsWriter(writer : Writer) {
    return new CodeWriter(HaxeInfoArrayOfMaps.instance, writer);
  }  

  public static function createHaxeMapOfArraysWriter(writer : Writer) {
    return new CodeWriter(HaxeInfoMapOfArrays.instance, writer);
  }

  public static function createHaxeMapOfMapsWriter(writer : Writer) {
    return new CodeWriter(HaxeInfoMapOfMaps.instance, writer);
  }

  public static function createJavaArrayOfArraysWriter(writer : Writer) {
    return new CodeWriter(JavaInfoArrayOfArrays.instance, writer);
  }

  public static function createJavaArrayOfMapsWriter(writer : Writer) {
    return new CodeWriter(JavaInfoArrayOfMaps.instance, writer);
  }  

  public static function createJavaMapOfArraysWriter(writer : Writer) {
    return new CodeWriter(JavaInfoMapOfArrays.instance, writer);
  }

  public static function createJavaMapOfMapsWriter(writer : Writer) {
    return new CodeWriter(JavaInfoMapOfMaps.instance, writer);
  }

  public static function createJavaArrayOfMapsWriterLegacy(writer : Writer) {
    return new CodeWriter(JavaInfoArrayOfMapsLegacy.instance, writer);
  }  

  public static function createJavaMapOfArraysWriterLegacy(writer : Writer) {
    return new CodeWriter(JavaInfoMapOfArraysLegacy.instance, writer);
  }

  public static function createJavaMapOfMapsWriterLegacy(writer : Writer) {
    return new CodeWriter(JavaInfoMapOfMapsLegacy.instance, writer);
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
}
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
**/
@:expose
@:nativeGen
class ObjectWriter<A> extends DataTableWriter {
  private var _o : A;
  private var _keyField : String;
  private var _valueField : String;

  private function new(o : A, keyField : String, valueField : String) {
    super();
    reuse(o, keyField, valueField);
  }

  public function reuse(o : A, keyField : String, valueField : String) : Void {
    _o = o;
    _keyField = keyField;
    _valueField = valueField;
  }
  
  /**
    Write to the entries to an object.
   **/
  public static function writeToWholeObject<A>(o : A, keyField : String, valueField : String) : ObjectWriter<A> {
    return new ObjectWriter<A>(o, keyField, valueField);
  }
  
  public override function start() : Void {
  }

  public override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    var rowWriter : ObjectRowWriter<A> = ObjectRowWriter.continueWriteReuse(_o, _keyField, _valueField, cast rowWriter);
    return rowWriter;
  }

  public override function flip() : DataTableReader {
    return ObjectReader.readWholeObject(_o,);
  }  

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_o != null) {
      _o = null;
      _keyField = null;
      _valueField = null;
    }
  }
}
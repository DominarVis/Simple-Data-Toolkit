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
  Defines interface for processing objects as table rows.
**/
@:expose
@:nativeGen
class ObjectRowWriter<A> extends DataTableRowWriter {
  private var _o : Any;
  private var _keyField : String;
  private var _valueField : String;
  private var _keyCurrent : Dynamic;
  private var _valueCurrent : Dynamic;
  private var _got : Int;
  private var _fields : Map<String, String>;  

  private function new(o : Any, keyField : String, valueField : String) {
    super();
    _fields = new Map<String, String>();
    for (field in Reflect.fields(o)) {
      _fields.set(field, field);
    }
    reuse(o, keyField, valueField);
  }

  public function reuse(o : Any, keyField : String, valueField : String) {
    _o = o;
    _keyField = keyField;
    _valueField = valueField;
    _keyCurrent = null;
    _valueCurrent = null;
    _got = 0;
  }

  /**
    Continue writing an object from the specified location.
  **/
  public static function continueWrite<A>(o : Any, keyField : String, valueField : String) : ObjectRowWriter<A> {
    return continueWriteReuse(o, keyField, valueField, null);
  }

  /**
    Continue writing an object from the specified location.
  **/
  public static function continueWriteReuse<A>(o : Any, keyField : String, valueField : String, rowWriter : Null<ObjectRowWriter<A>>) : ObjectRowWriter<A> {
    if (rowWriter == null) {
      rowWriter = new ObjectRowWriter(o, keyField, valueField);
    } else {
      rowWriter.reuse(o, keyField, valueField);
    }
    return rowWriter;
  }

  public override function write(data : Dynamic, name : String, index : Int) : Void {
    if (_o != null) {
      if (_keyField == null) {
        if (_fields.get(name) != null) {
          Reflect.setField(_o, name, data);
        }
      } else {
        if (name == _keyField) {
          _keyCurrent = data;
          _got++;
        } else if (name == _valueField) {
          _valueCurrent = data;
          _got++;
        }
        if (_got == 2) {
          Reflect.setField(_o, _keyCurrent, _valueCurrent);
          _got = 0;
        }
      }
    }
  }
  
  public function reset() : Void { }
  
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
      _keyCurrent = null;
      _valueCurrent = null;
      _got = 0;
    }
  }
}

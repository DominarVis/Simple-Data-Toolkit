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
  Defines interface for processing objects as tables.
**/
@:expose
@:nativeGen
class ObjectOfArraysWriter<A> extends DataTableWriter {
  private var _o : A;
  private var _iterator : Iterator<Dynamic>;

  private function new(o : A) {
    super();
    reuse(o);
  }

  public function reuse(o : A) : Void {
    _o = o;
    _iterator = Reflect.fields(_o).iterator();
  }
  
  /**
    Write to the entries to an object.
   **/
  public static function writeToWholeObject<A>(o : A) : ObjectOfArraysWriter<A> {
    return new ObjectOfArraysWriter<A>(o);
  }

  public override function start() : Void {
  }

  private override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    var field : String = _iterator.next();
    // TODO
    // var value : Array<Dynamic> = Reflect.field(_o, field);
    var value : Array<Dynamic> = new Array<Dynamic>();
    return ArrayRowWriter.writeToExpandableArrayReuse(value, cast rowWriter);
  }

  public override function flip() : DataTableReader {
    return ObjectOfArraysReader.readWholeObject(_o);
  }      
  
  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_o != null) {
      _o = null;
      _iterator = null;
    }
  }
}

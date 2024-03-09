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
class ObjectOfObjectsWriter<A, B> extends DataTableWriter {
  private var _o : A;
  private var _iterator : Iterator<Dynamic>;
  private var _constructor : String->Int->B;

  private function new(o : A, constructor : String->Int->B) {
    super();
    reuse(o, constructor);
  }

  public function reuse(o : A, constructor : String->Int->B) : Void {
    _o = o;
    _iterator = Reflect.fields(_o).iterator();
    _constructor = constructor;
  }
  
  /**
    Write to the entries to an object.
   **/
  public static function writeToWholeObject<A, B>(o : A, constructor : Void->B) : ObjectOfObjectsWriter<A, B> {
    return new ObjectOfObjectsWriter<A,B>(o, function (name : String, index : Int) : B { return constructor(); });
  }

  public static function writeToWholeObjectWithField<A, B>(o : A, constructor : String->B) : ObjectOfObjectsWriter<A, B> {
    return new ObjectOfObjectsWriter<A,B>(o, function (name : String, index : Int) : B { return constructor(name); });
  }  

  public static function writeToWholeObjectWithIndex<A, B>(o : A, constructor : Int->B) : ObjectOfObjectsWriter<A, B> {
    return new ObjectOfObjectsWriter<A,B>(o, function (name : String, index : Int) : B { return constructor(index); });
  }

  public static function writeToWholeObjectWithFieldAndIndex<A, B>(o : A, constructor : String->Int->B) : ObjectOfObjectsWriter<A, B> {
    return new ObjectOfObjectsWriter<A,B>(o, constructor);
  }  
  
  public override function start() : Void {
  }

  private override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    var field : String = _iterator.next();
    var value : B = _constructor(field, _written);
    var rowWriter : ObjectRowWriter<A> = ObjectRowWriter.continueWriteReuse(cast value, null, null, cast rowWriter);
    return rowWriter;
  }

  public override function flip() : DataTableReader {
    return ObjectOfObjectsReader.readWholeObject(_o);
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
      _constructor = null;
    }
  }
}

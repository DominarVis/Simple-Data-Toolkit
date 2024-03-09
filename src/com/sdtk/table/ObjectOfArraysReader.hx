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
class ObjectOfArraysReader<A> extends DataTableReader {
  private var _o : Dynamic;
  private var _iterator : Iterator<Dynamic>;

  private function new(o : Dynamic) {
    super();
    _o = o;
    _iterator = Reflect.fields(_o).iterator();
  }
  
  /**
    Read the whole object.
  **/
  public static function readWholeObject<A>(o : A) : ObjectOfArraysReader<A> {
    return new ObjectOfArraysReader(o);
  }

  public override function hasNext() : Bool {
    return _iterator.hasNext();
  }

  public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
    var field : String = _iterator.next();
    _value = Reflect.field(_o, field);
    if (rowReader == null) {
      rowReader = ArrayRowReader.readWholeArray(cast _value);
    } else {
      var rr : ArrayRowReader<Dynamic> = cast rowReader;
      ArrayRowReader.readWholeArrayReuse(cast _value, rr);
    }
    incrementTo(field, rowReader, _index + 1);
    return rowReader;
  }  
  
  public override function next() : Dynamic {
    return nextReuse(null);
  }

  public override function iterator() : Iterator<Dynamic> {
    return new ObjectOfArraysReader<A>(_o);
  }

  public override function flip() : DataTableWriter {
    return ObjectOfArraysWriter.writeToWholeObject(_o);
  }    

  public override function reset() : Void {
    _iterator = Reflect.fields(_o).iterator();
    super.reset();
  }  
}

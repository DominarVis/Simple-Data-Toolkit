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
  Adapts delimited files (like CSV, PSV, etc) to STC table reader interface.
**/
@:expose
@:nativeGen
class DatabaseReader extends DataTableReader {
  private static var _mappings : Array<String> = null;
  private static var _finalMappings : Map<String, Dynamic->Dynamic->String->Array<String>->DatabaseReader> = null;
  private static var _columnMappings : Map<String, Dynamic->Dynamic->Array<String>> = null;
  private static var _retrievalTypes : Map<String, Dynamic->Dynamic->Int->Dynamic> = new Map<String, Dynamic->Dynamic->Int->Dynamic>();
  private static var _retrievalPrepTypes : Map<String, Dynamic->Dynamic> = new Map<String, Dynamic->Dynamic>();
  private var _done : Bool = false;

  public function new() {
    super();
  }

  private static function initMappings() : Void {
    if (_mappings == null) {
      _mappings = new Array<String>();
      _mappings.push("execute");
      _mappings.push("__iter__");
      _mappings.push("iterator");
      //_mappings.put("createStatement", dbCreateStatement);
      //_mappings.put("cursor", dbCursor);

      _finalMappings = new Map<String, Dynamic->Dynamic->String->Array<String>->DatabaseReader>();
      _finalMappings.set("next", dbIterator);
      _finalMappings.set("__next__", dbIterator);
      _finalMappings.set("fetch", dbIterator);

      _columnMappings = new Map<String, Dynamic->Dynamic->Array<String>>();
      _columnMappings.set("__iter__-description", columnDescription);
      _columnMappings.set("execute-getColumnName", columnGetColumnName);

      _retrievalTypes = new Map<String, Dynamic->Dynamic->Int->Dynamic>();
      _retrievalTypes.set("", getArrayValue);
      _retrievalTypes.set("getColumnValue", getColumnValue);

      _retrievalPrepTypes = new Map<String, Dynamic->Dynamic>();
      _retrievalPrepTypes.set("", getArrayPrep);
      _retrievalPrepTypes.set("getColumnValue", noPrep);      
    }
  }
 
  public static function read(o : Dynamic) : DatabaseReader {
    initMappings();
    var trail : Map<String, Dynamic> = new Map<String, Dynamic>();
    var t : Dynamic = getTypeIfNeeded(o);
    for (mapping in _mappings) {
      var o2 : Dynamic = executeFunctionIfThere(o, t, mapping, trail);
      if (o2 != null) {
        o = o2;
        t = getTypeIfNeeded(o);
      }
    }
    for (mapping in _finalMappings.keys()) {
      if (hasFunction(t, mapping)) {
        return cast _finalMappings[mapping](o, t, mapping, getColumnNames(o, t, trail));
      }
    }
    return null;
  }

  private static function getArrayValue(o : Dynamic, t : Dynamic, i : Int) : Dynamic {
    #if js
      return cast js.Syntax.code("{0}[{1}]", o, i);
    #elseif python
      return cast python.Syntax.code("{0}[{1}]", o, i);
    #elseif cs
      // TODO
      return null;
    #elseif java
      // TODO
      return null;
    #else
      var r : Array<Dynamic> = cast o;
      return o[i];
    #end    
  }

  private static function getArrayPrep(o : Dynamic) : Dynamic {
    #if js
      // TODO
      return null;
    #elseif python
      return cast python.Syntax.code("list({0})", o);
    #elseif cs
      // TODO
      return null;
    #elseif java
      // TODO
      return null;
    #elseif php
      return o;
    #else
      return o;
    #end    
  }

  private static function getColumnValue(o : Dynamic, t : Dynamic, i : Int) : Dynamic {
    #if js
      return cast js.Syntax.code("{0}.getColumnValue({1} + 1)", o, i);
    #elseif python
      return cast python.Syntax.code("{0}.getColumnValue({1} + 1)", o, i);
    #elseif cs
      // TODO
      return null;
    #elseif java
      // TODO
      return null;
    #else
      // TODO
      return null;
    #end
  }

  private static function noPrep(o : Dynamic) : Dynamic {
    return o;
  }  

  private static function dbIterator(o : Dynamic, t : Dynamic, mapping : String, columns : Array<String>) : DatabaseReader {
    return new DatabaseIteratorReader(o, t, mapping, columns);
  }

  private static function getTypeIfNeeded(o : Dynamic) : Dynamic {
    #if(python || js || php)
      return o;
    #elseif cs
      // TODO
      return null;
    #elseif java
      // TODO
      return null;
    #else
      return o;
    #end
  }

  private static function hasFunction(t : Dynamic, f : String) : Bool {
    #if js
      return cast js.Syntax.code("Object.prototype.hasOwnProperty.call({0}, {1})", t, f);
    #elseif python
      return cast python.Syntax.code("hasattr({0}, {1})", t, f);
    #elseif cs
      // TODO
      return false;
    #elseif java
      // TODO
      return false;
    #elseif php
      return cast php.Syntax.code("method_exists({0}, {1})", t, f);
    #else
      return Reflect.hasField(t, f);
    #end
  }

  private static function executeFunction(o : Dynamic, t : Dynamic, f : String) : Dynamic {
    #if js
      return cast js.Syntax.code("{0}[{1}]({2})", t, f, o);
    #elseif python
      return cast python.Syntax.code("getattr({0}, {1})()", o, f);
    #elseif cs
      // TODO
      return null;
    #elseif java
      // TODO
      return null;
    #elseif php
      return cast php.Syntax.code("{0}->{1}", o, f);      
    #else
      return Reflect.callMethod(o, cast Reflect.field(t, f), null);
    #end
  }

  private static function executeFunctionIfThere(o : Dynamic, t : Dynamic, f : String, ?trail : Null<Map<String, Dynamic>> = null) : Dynamic {
    if (hasFunction(t, f)) {
      if (trail != null) {
        trail.set(f, o);
        try {
          return executeFunction(o, t, f);
        } catch (msg : Any) {
          return null;
        }
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  private static function columnDescription(o : Dynamic, t : Dynamic) : Array<String> {
    #if python
      // TODO - Revise?
      var col : String = cast python.Syntax.code("','.join([col[0] for col in {0}.description])", o);
      return col.split(",");
    #else
      // TODO
      return null;
    #end
  }

  private static function columnGetColumnName(o : Dynamic, t : Dynamic) : Array<String> {
    #if js
      var count : Int = cast js.Syntax.code("{0}.getColumnCount()", o);
      var columns : Array<String> = new Array<String>();
      var i : Int = 1;
      while (i <= count) {
        columns.push(cast js.Syntax.code("{0}.getColumnName({1})", o, i));
        i++;
      }
      return columns;
    #else
      // TODO
      return null;
    #end
  }

  private static function getColumnNames(o : Dynamic, t : Dynamic, trail : Map<String, Dynamic>) : Array<String> {
    for (mapping in _columnMappings.keys()) {
      var map : Array<String> = mapping.split("-");
      var f : String = map[map.length - 1];
      var ref : String;
      if (map.length == 1) {
        ref = null;
      } else {
        ref = map[0];
      }
      if (ref == null) {
        if (hasFunction(t, f)) {
          return _columnMappings.get(mapping)(o, t);
        }
      } else {
        var refO : Dynamic = trail.get(ref);
        if (refO != null) {
          var refT : Dynamic = getTypeIfNeeded(refO);
          if (hasFunction(refT, f)) {
            return _columnMappings.get(mapping)(refO, refT);
          }
        }
      }
    }
    return null;
  }

  public override function reset() : Void {
    // TODO
  }    
}

@:nativeGen
class DatabaseIteratorReader extends DatabaseReader {
  private var _columns : Array<String>;
  private var _data : Dynamic;
  private var _dataType : Dynamic;
  private var _mapping : String;
  private var _retrieval : Null<Dynamic->Dynamic->Int->Dynamic> = null;
  private var _prep : Null<Dynamic->Dynamic> = null;
  private var _next : Dynamic;
  private var _current : Dynamic;
  
  public function new(data : Dynamic, dataType : Dynamic, mapping : String, columns : Array<String>) {
    super();
    _columns = columns;
    _data = data;
    _dataType = dataType;
    _mapping = mapping;
    getRetrievalType();
  }

  private function doNext() : Void {
    _next = null;
    try {
      _next = DatabaseReader.executeFunction(_data, _dataType, _mapping);
    } catch (msg : Any) { }
  }

  public function columns() : Int {
    return _columns.length;
  }

  public function columnName(i : Int) : String {
    return _columns[i];
  }

  public function readColumn(i : Int) : Dynamic {
    return _retrieval(_current, _dataType, i);
  }

  private function getRetrievalType() : Void {
    doNext();
    if (_next != null) {
      for (mapping in DatabaseReader._retrievalTypes.keys()) {
        if (mapping != "") {
          if (DatabaseReader.hasFunction(_dataType, mapping)) {
            _retrieval = DatabaseReader._retrievalTypes.get(mapping);
            _prep = DatabaseReader._retrievalPrepTypes.get(mapping);
          }
        }
      }
      if (_retrieval == null) {
        _retrieval = DatabaseReader._retrievalTypes.get("");
        _prep = DatabaseReader._retrievalPrepTypes.get("");
      }
    }
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (!_done) {
      DatabaseReader.executeFunctionIfThere(_data, _dataType, "close");
      DatabaseReader.executeFunctionIfThere(_data, _dataType, "dispose");
      _columns = null;
      _data = null;
      _dataType = null;
    }
  }

  public override function hasNext() : Bool {
    return _next != null;
  }

  public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
    _current = _prep(_next);
    doNext();
    if (rowReader == null) {
      return new DatabaseIteratorRowReader(this);
    } else {
      var rr : DatabaseIteratorRowReader = cast rowReader;
      rr.reuse(this);
      return rr;
    }
  }
  
  public override function next() : Dynamic {
    return nextReuse(null);
  }
}

@:nativeGen
class DatabaseIteratorRowReader extends DataTableRowReader {
  private var _reader : Null<DatabaseIteratorReader>;

  public function new(reader : DatabaseIteratorReader) {
    super();
    reuse(reader);
  }

  public function reuse(reader : DatabaseIteratorReader) {
    _reader = reader;
    _index = -1;
  }

  public override function hasNext() : Bool {
    return index() < _reader.columns();
  }

  private override function startI() : Void {
  }

  public override function next() : Dynamic {
    incrementTo(_reader.columnName(index() + 1), _reader.readColumn(index() + 1), -1);
    return value();
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    _reader = null;
  }
}


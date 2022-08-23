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

#if(!JS_BROWSER)
import com.sdtk.std.*;

/**
  Adapts database queries to STC table reader interface.
**/
@:expose
@:nativeGen
class DatabaseReader extends DataTableReader {
  private var _done : Bool = false;
  private var _cur : #if java
    java.sql.ResultSet
  #elseif cs
    Dynamic
  #elseif python
    Dynamic
  #elseif JS_SNOWFLAKE
    Dynamic
  #elseif JS_WSH
    Dynamic
  #elseif php
    Dynamic
  #else // Hashlink
    sys.db.ResultSet
  #end;
  #if python
    private var _row : Dynamic;
  #end
  #if php
    private var _connector : Int;
    private var _rowValues : Array<Dynamic>;
    private static inline var CONNECTOR_MYSQL : Int = 0;
    private static inline var CONNECTOR_SQLITE : Int = 1;
    private static inline var CONNECTOR_ORACLE : Int = 2;
    private static inline var CONNECTOR_SQLSERVER : Int = 3;
    private static inline var CONNECTOR_SNOWFLAKE : Int = 4;
    private static inline var CONNECTOR_POSTGRES : Int = 5;
  #end
  private var _reading : Bool = false;
  private var _hold : Dynamic = null;

  #if cs
    private var _reader : Bool;

    @:functionCode("return o is System.Data.Common.DbDataReader;")
    private static function checkIfReader(o : Dynamic) : Bool {
      return false;
    }

    @:functionCode("
      if (o is System.Data.DataSet) {
          System.Data.DataSet ds = (System.Data.DataSet) o;
          o = ds.Tables[0];
      }
      if (o is System.Data.DataTable) {
        System.Data.DataTable dt = (System.Data.DataTable)o;
        return dt.Select();
      } else {
          return o;
      }
    ")
    private static function getRowCollection(o : Dynamic) : Dynamic {
      return null;
    }

    @:functionCode("
      if (reader) {
        System.Data.Common.DbDataReader r = (System.Data.Common.DbDataReader) o;
        return r.FieldCount;
      } else {
        System.Data.DataRow[] r = (System.Data.DataRow[]) o;
        return r[0].Table.Columns.Count;
    }")
    private static function getFieldCount(o : Dynamic, reader : Bool) : Int {
      return 0;
    }

    @:functionCode("
      if (reader) {
        System.Data.Common.DbDataReader r = (System.Data.Common.DbDataReader) o;
        return r.GetName(i);
      } else {
        System.Data.DataRow[] r = (System.Data.DataRow[]) o;
        return r[0].Table.Columns[i].ColumnName;
      }
    ")
    private static function getColumnName(i : Int, o : Dynamic, reader : Bool) : String {
      return null;
    }

    @:functionCode("
      if (reader) {
        System.Data.Common.DbDataReader r = (System.Data.Common.DbDataReader) o;
        return r.GetFieldValue<object>(i);
      } else {
        System.Data.DataRow[] r = (System.Data.DataRow[]) o;
        return r[j].ItemArray[i];
      }
    ")
    private static function readColumnNumber(i : Int, j : Int, o : Dynamic, reader : Bool) : Dynamic {
      return null;
    }

    @:functionCode("
      if (reader) {
        System.Data.Common.DbDataReader r = (System.Data.Common.DbDataReader) o;
        return r.Read();
      } else {
        System.Data.DataRow[] r = (System.Data.DataRow[]) o;
        return j < (r.Length - 1);
      }
    ")
    private static function readNext(o : Dynamic, reader : Bool, j : Int) : Bool {
      return false;
    }
  #end
  private var _columns : Array<String>;

  private function new(cur : Dynamic) {
    super();
    _cur = cast cur;
    #if cs
      _reader = checkIfReader(cur);
      if (!_reader) {
        _reader = getRowCollection(_reader);
      }
    #end
    checkColumns();
    finalPrep();
  }
 
  public static function read(o : Dynamic) : DatabaseReader {
    #if JS_SNOWFLAKE
      js.Syntax.code("if (!!({0}['execute']) { {0} = {0}['execute'](); }", o);
      return new DatabaseReader(o);
    #elseif python
      return new DatabaseReader(o);
    #elseif cs
      return new DatabaseReader(o);
    #elseif JS_WSH
      return new DatabaseReader(o);
    #elseif JS_NODE
      // TODO
    #elseif java
      return new DatabaseReader(o);
    #elseif php
      var sType : String = cast php.Syntax.code("get_class({0})", o).toLowerCase();
      var r : DatabaseReader = new DatabaseReader(o);
      if (sType.indexOf("mysql") >= 0) {
        r._connector = CONNECTOR_MYSQL;
      } else if (sType.indexOf("sqlite") >= 0) {
        r._connector = CONNECTOR_SQLITE;
      } else if (sType.indexOf("pdo") >= 0) {
        r._connector = CONNECTOR_SNOWFLAKE;
      } else if (sType.indexOf("oci") >= 0) {
        r._connector = CONNECTOR_ORACLE;
      } else if (sType.indexOf("sqlsrv") >= 0) {
        r._connector = CONNECTOR_SQLSERVER;
      } else if (sType.indexOf("pg") >= 0) {
        r._connector = CONNECTOR_POSTGRES;
      }
      return r;
    #else // HASHLINK
      return new DatabaseReader(o);
    #end
  }

  public function columns() : Int {
    return _columns.length;
  }

  public function nextRow() : Bool {
    #if java
      return _cur.next();
    #elseif cs
      return readNext(_cur, _reader, _index);
    #elseif JS_WSH
      cast js.Syntax.code("{0}.MoveNext()", _cur);
      return js.Syntax.code("!({0}.EOF)", _cur);
    #elseif JS_SNOWFLAKE
      return cast js.Syntax.code("{0}.next()", _cur);
    #elseif python
      _row = cast python.Syntax.code("{0}.__next__()", _cur);
      return _row != null;
    #elseif php
      var rowValues : Iterable<Dynamic> = null;
      switch (_connector) {
        case CONNECTOR_MYSQL:
          rowValues = cast php.Syntax.code("{0}::fetch_array()", _cur);
        case CONNECTOR_SQLITE:
          rowValues = cast php.Syntax.code("{0}::fetchArray()", _cur);
        case CONNECTOR_SNOWFLAKE:
          rowValues = cast php.Syntax.code("{0}->fetch()", _cur);
        case CONNECTOR_ORACLE:
          rowValues = cast php.Syntax.code("oci_fetch_array({0})", _cur);
        case CONNECTOR_SQLSERVER:
          rowValues = cast php.Syntax.code("sqlsrv_fetch_array({0})", _cur);
        case CONNECTOR_POSTGRES:
          rowValues = cast php.Syntax.code("pg_fetch_row({0})", _cur);
      }
      _rowValues = null;
      if (rowValues != null) {
        _rowValues = new Array<String>();
        _rowValues.resize(cast php.Syntax.code("count({0})", rowValues));
        for (v in rowValues) {
          _rowValues.push(v);
        }
      }
      return _rowValues != null;
    #else // Hashlink
      return _cur.next();
    #end
  }

  private function checkColumns() : Void {
    if (_columns == null) {
      #if java
        var metaData : java.sql.ResultSetMetaData = _cur.getMetaData();
        var columns : Int = metaData.getColumnCount();
        _columns = new Array<String>();
        _columns.resize(columns);
        var i : Int = 0;
        while (i < columns) {
          _columns[i] = metaData.getColumnName(i + 1);
          i++;
        }
      #elseif cs
        var columns : Int = getFieldCount(_cur, _reader);
        _columns = new Array<String>();
        _columns.resize(columns);
        var i : Int = 0;
        while (i < columns) {
          _columns[i] = getColumnName(i, _cur, _reader);
          i++;
        }
      #elseif JS_WSH
        var columns : Int = cast js.Syntax.code("{0}.Fields.Count", _cur);
        _columns = new Array<String>();
        _columns.resize(columns);
        var i : Int = 0;
        while (i < columns) {
          _columns[i] = js.Syntax.code("{0}.Fields({1}).Name", _cur, i);
          i++;
        }
      #elseif JS_SNOWFLAKE
        var columns : Int = cast js.Syntax.code("{0}.getColumnCount()", _cur);
        _columns = new Array<String>();
        _columns.resize(columns);
        var i : Int = 1;
        while (i <= columns) {
          _columns[i - 1] = js.Syntax.code("{0}.getColumnName({1}", _cur, i);
          i++;
        }
      #elseif python
        _columns = new Array<String>();
        var it : Iterable<Dynamic> = cast python.Syntax.code("{0}.description", _cur);
        for (description in it) {
          _columns.push(cast python.Syntax.code("{0}[0]", description));
        }
      #elseif php
        _columns = new Array<String>();
        var columns : Int = null;
        var metaData : Dynamic = null;

        switch (_connector) {
          case CONNECTOR_MYSQL:
            columns = cast php.Syntax.code("{0}->field_count", _cur);
          case CONNECTOR_SQLITE:
            columns = cast php.Syntax.code("{0}::numColumns()", _cur);
          case CONNECTOR_SNOWFLAKE:
            columns = cast php.Syntax.code("{0}->columnCount()", _cur);
          case CONNECTOR_ORACLE:
            columns = cast php.Syntax.code("oci_num_fields({0})", _cur);
          case CONNECTOR_SQLSERVER:
            columns = cast php.Syntax.code("sqlsrv_num_fields({0})", _cur);
            metaData = cast php.Syntax.code("sqlsrv_field_metadata({0})", _cur);
          case CONNECTOR_POSTGRES:
            columns = cast php.Syntax.code("pg_num_fields({0})", _cur);
        }

        _columns.resize(columns);
        var i : Int = 0;
        while (i < columns) {
          var column : String = null;
          switch (_connector) {
            case CONNECTOR_MYSQL:
              column = cast php.Syntax.code("{0}::fetch_field_direct({1})", _cur, i);
            case CONNECTOR_SQLITE:
              column = cast php.Syntax.code("{0}::columnName({1})", _cur, i);
            case CONNECTOR_SNOWFLAKE:
              column = cast php.Syntax.code("{0}->getColumnMeta({1})[\"name\"]", _cur, i);
            case CONNECTOR_ORACLE:
              column = cast php.Syntax.code("oci_field_name({0}, {1})", _cur, i + 1);
            case CONNECTOR_SQLSERVER:
              column = cast php.Syntax.code("{0}[{1}][\"Name\"]", metaData, i);
            case CONNECTOR_POSTGRES:
              column = cast php.Syntax.code("pg_field_name ({0}, {1})", _cur, i);
          }
          _columns[i] = column;
          i++;
        }
      #else // Hashlink
        _columns = _cur.getFieldsNames();
      #end
    }
  }

  private function finalPrep() : Void {
    #if python
      _cur = cast python.Syntax.code("{0}.__iter__()", _cur);
    #elseif JS_WSH
      js.Syntax.code("{0}.MoveFirst()", _cur);
    #end
  }

  public function columnName(i : Int) : String {
    return _columns[i];
  }

  public function readColumn(i : Int) : Dynamic {
    _reading = false;
    #if java
      return _cur.getObject(i + 1);
    #elseif cs
      return readColumnNumber(i, _index, _cur, _reader);
    #elseif JS_WSH
      return js.Syntax.code("{0}.Fields({1}).Value", _cur, i);
    #elseif JS_SNOWFLAKE
      return js.Syntax.code("{0}.getColumnValue({1})", _cur, i + 1);
    #elseif python
      return python.Syntax.code("{0}[{1}]", _row, i);
    #elseif php
      return _rowValues[i];
    #else // Hashlink
      return _cur.getResult(i);
    #end
  }

  public override function hasNext() : Bool {
    if (!_reading) {
      if (nextRow()) {
        _reading = true;
      } else {
        _reading = false;
      }
    }
    return _reading;
  }

  public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
    if (rowReader == null) {
      return new DatabaseRowReader(this);
    } else {
      var rr : DatabaseRowReader = cast rowReader;
      rr.reuse(this);
      return rr;
    }
  }
  
  public override function next() : Dynamic {
    return nextReuse(null);
  }

  public override function reset() : Void {
    // TODO
  }    

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    super.dispose();
    _hold = null;
    #if java
      var cur : java.sql.ResultSet = cast _cur;
      cur.close();
    #elseif JS_WSH
      js.Syntax.code("{0}.Close()", _cur);
    #elseif cs

    #end
  }  

  public function hold(o : Dynamic) : Void {
    _hold = o;
  }
}
#end
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

#if(!EXCLUDE_DATABASE)

#if JS_BROWSER
  import jsasync.JSAsync.jsasync;
#end

@:expose
@:nativeGen
class DatabaseReaderLoginOptions {
  private var _values : Map<String, Any>;
  private var _cancelClose : Bool = false;

  public inline function new(values : Map<String, Any>) {
    _values = values;
  }

  public function user(v : String) : DatabaseReaderLoginOptions {
    _values["user"] = v;
    return this;
  }

  public function password(v : String) : DatabaseReaderLoginOptions {
    _values["password"] = v;
    return this;
  }

  public function account(v : String) : DatabaseReaderLoginOptions {
    _values["account"] = v;
    return this;
  }

  public function warehouse(v : String) : DatabaseReaderLoginOptions {
    _values["warehouse"] = v;
    return this;
  }

  public function role(v : String) : DatabaseReaderLoginOptions {
    _values["role"] = v;
    return this;
  }

  public function database(v : String) : DatabaseReaderLoginOptions {
    _values["database"] = v;
    return this;
  }

  public function schema(v : String) : DatabaseReaderLoginOptions {
    _values["schema"] = v;
    return this;
  }

  public function host(v : String) : DatabaseReaderLoginOptions {
    _values["host"] = v;
    return this;
  }  

  public function file(v : String) : DatabaseReaderLoginOptions {
    _values["file"] = v;
    return this;
  }

  public function driver(v : String) : DatabaseReaderLoginOptions {
    _values["driver"] = v;
    return this;
  }

  public function size(v : Int) : DatabaseReaderLoginOptions {
    _values["size"] = v;
    return this;
  }

  #if JS_BROWSER
    public function useworkers(v : Bool) : DatabaseReaderLoginOptions {
      _values["useworkers"] = v;
      return this;
    }

    public function key(v : Dynamic) : DatabaseReaderLoginOptions {
      _values["key"] = v;
      return this;
    }    
  #end

  #if(JS_WSH || cs)
    #if cs
      @:functionCode("return Microsoft.Win32.Registry.LocalMachine;")
      private static function getLocalMachine() : Dynamic {
        return null;
      }

      @:functionCode("((Microsoft.Win32.RegistryKey)o).Close();")
      private static function closeRegistryKey(o : Dynamic) : Void { }

      @:functionCode("return ((Microsoft.Win32.RegistryKey)o).OpenSubKey(@s);")
      private static function getSubKey(o : Dynamic, s : String) : Dynamic {
        return null;
      }

      @:functionCode("return ((Microsoft.Win32.RegistryKey)o).GetValueNames();")
      private static function getKeyValues(o : Dynamic) : cs.NativeArray<String> {
        return null;
      }
    #end
    private static function populateDriverI() : Array<String> {
      var keyPath : String = "SOFTWARE\\ODBC\\ODBCINST.INI\\ODBC Drivers";
      var drivers : Array<String> = new Array<String>();

      #if js
        var registryPath : String = "winmgmts:{impersonationLevel=impersonate}!\\\\.\\root\\default";
        var localMachine : Int = 0x80000002;
        var registry : Dynamic = cast js.Syntax.code("GetObject({0})", registryPath);
        var objReg : Dynamic = js.Syntax.code("{0}.Get(\"StdRegProv\")", registry);
        var objMethod : Dynamic = js.Syntax.code("{0}.Methods_.Item(\"EnumValues\")", objReg);
        var objParamsIn : Dynamic = js.Syntax.code("{0}.InParameters.SpawnInstance_()", objMethod);
        js.Syntax.code("{0}.hDefKey = {1}", objParamsIn, localMachine);
        js.Syntax.code("{0}.sSubKeyName = {1}", objParamsIn, keyPath);
        var objParamsOut : Dynamic = js.Syntax.code("{0}.ExecMethod_({1}.Name, {2})", objReg, objMethod, objParamsIn);
        var names : Dynamic = js.Syntax.code("{0}.sNames.toArray()", objParamsOut);
        var i : Int = 0;
        while (i < js.Syntax.code("{0}.length", names)) {
          drivers.push(cast js.Syntax.code("{0}[{1}]", names, i));
          i++;
        }
      #else
        var localMachine : Dynamic = getLocalMachine();
        var driversKey : Dynamic = getSubKey(localMachine, keyPath);
        for (driver in getKeyValues(driversKey)) {
          drivers.push(driver);
        }
        closeRegistryKey(driversKey);
        closeRegistryKey(localMachine);
      #end
      return drivers;
    }

    private static function populateDriver(values : Map<String, Dynamic>) : Void {
      if (values["driver"] == null) {
        var drivers : Array<String> = populateDriverI();
        for (driver in drivers) {
          if (StringTools.contains(driver.toLowerCase(), values["connector"].toLowerCase())) {
            if (values["driver"] != null) {
              if (driver > values["driver"]) {
                values["driver"] = driver;
              }
            } else {
              values["driver"] = driver;
            }
          }
        }
      }
    }
  #end

  #if cs
    @:functionCode("
      System.Data.Common.DbConnection con;
      string t = null;
      string a = null;
      switch (connector) {
        case \"sqlserver\":
          t = \"System.Data.SqlClient.SqlConnection\";
          a = \"System.Data.SqlClient\";
          break;
        case \"mysql\":
          t = \"MySql.Data.MySqlClient.MySqlConnection\";
          a = \"MySql.Data.dll\";
          break;
        case \"snowflake\":
          t = \"Snowflake.Data.Client.SnowflakeDbConnection\";
          a = \"Snowflake.Data\";
          break;
        case \"sqlite\":
          t = \"Microsoft.Data.Sqlite.SqliteConnection\";
          a = \"Microsoft.Data.Sqlite\";
          break;
        case \"postgres\":
          t = \"Npgsql.NpgsqlConnection\";
          a = \"Npgsql\";
          break;
        case \"oracle\":
          t = \"Oracle.DataAccess.Client.OracleConnection\";
          a = \"Oracle.DataAccess\";
          break;
      }
      object o;
      if (a != null) {
        o = System.Reflection.Assembly.LoadFrom(a).GetType(t).GetConstructors()[0].Invoke(null);
      } else {
        o = System.Type.GetType(t, false).GetConstructors()[0].Invoke(null);
      }
      con = (System.Data.Common.DbConnection)o;
      con.ConnectionString = s;
      con.Open();
      return con;
    ")
    private static function createConnection(s : String, connector : String) : Dynamic {
      return null;
    }

    @:functionCode("
      System.Data.DataSet con = new System.Data.DataSet();
      con.ReadXml(s, System.Data.XmlReadMode.InferSchema);
      return con;
    ")
    private static function readDataSet(s : String) : Dynamic {
      return null;
    }

    @:functionCode("
      System.Data.Common.DbConnection c = (System.Data.Common.DbConnection)o;
      c.Close();
    ")
    private static function closeThis(o : Dynamic) : Void { }

    @:functionCode("
      System.Data.DataSet ds = (System.Data.DataSet)o;
      ds.Dispose();
    ")
    private static function disposeThis(o : Dynamic) : Void { }

    @:functionCode("
      System.Data.Common.DbConnection c = (System.Data.Common.DbConnection) o;
      System.Data.Common.DbCommand command = c.CreateCommand();
      command.CommandText = query;
      command.CommandType = System.Data.CommandType.Text;
      return command.ExecuteReader();
    ")
    private static function selectThis(o : Dynamic, query : String) : Dynamic {
      return null;
    }

    @:functionCode("
      System.Data.DataSet ds = (System.Data.DataSet) o;
      return ds.Tables[0].Select(query);
    ")
    private static function selectThis2(o : Dynamic, query : String) : Dynamic {
      return null;
    }
  #end

  #if JS_BROWSER @:jsasync #end public function connect(?callback : Dynamic->Void) : Dynamic {
    var connector : String = StringTools.trim(_values["connector"]).toLowerCase();
    var con : Dynamic = null;
    #if python
      switch (connector) {
        case "mysql":
          python.Syntax.code("import mysql.connector");
          con = cast python.Syntax.code("mysql.connector.connect(user={0}, password={1}, database={2}, host={3})", _values["user"], _values["password"], _values["database"], _values["host"]);
        case "snowflake":
          python.Syntax.code("import snowflake.connector as connector");
          con = cast python.Syntax.code("connector.connect(user={0}, password={1}, database={2}, role={3}, account={4}, warehouse={5}, schema={6})", _values["user"], _values["password"], _values["database"], _values["role"], _values["account"], _values["warehouse"], _values["schema"]);
        case "sqlserver":
          python.Syntax.code("import pyodbc");
          var connectString : String;
          if (_values["driver"] == null) {
            _values["driver"] = "ODBC Driver 18 for SQL Server";
          }
          connectString = "DRIVER={" + _values["driver"] + "};SERVER=" + _values["host"] + ";DATABASE=" + _values["database"] + ";UID=" + _values["user"] + ";PWD=" + _values["password"];
          con = cast python.Syntax.code("pyodbc.connect({0})", connectString);
        case "oracle":
          python.Syntax.code("import cx_Oracle");
          var connectString : String;
          connectString = _values["user"] + "/" + _values["password"] + "@" + _values["host"] + "/" + _values["database"];
          con = cast python.Syntax.code("cx_Oracle.connect({0})", connectString);
        case "sqlite":
          python.Syntax.code("import sqlite3");
          con = cast python.Syntax.code("sqlite3.connect({0})", _values["file"]);
        case "postgres":
          python.Syntax.code("import psycopg2");
          var connectString : String;
          connectString = "host='" + _values["host"] + "' dbname='" + _values["database"] + "' user='" + _values["user"] + "' password='" + _values["password"] + "'";
          con = cast python.Syntax.code("psycopg2.connect({0})", connectString);
        case "derby":
          // TODO
        case "dataset":
          //TODO          
      }
      if (callback != null) {
        var cur : Dynamic = cast python.Syntax.code("{0}.cursor()", con);
        try {
          callback(cur);
        } catch (ex : Any) {}
        if (!_cancelClose) {
          python.Syntax.code("{0}.close()", cur);
          python.Syntax.code("{0}.close()", con);
        } else {
          _values["cur"] = cur;
          _values["con"] = con;
        }
        return null;
      } else {
        _values["con"] = con;
        return con;
      }
    #elseif java
      switch (connector) {
        case "mysql":
          try {
            java.lang.Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
          } catch (ex : Any) {
            try {
              java.lang.Class.forName("com.mysql.jdbc.Driver");
            } catch (ex : Any) { }
          }
          
          var connectString : String;
          connectString = "jdbc:" +  connector + "://" + _values["host"] + "/" + _values["database"] + "?user=" + _values["user"] + "&password=" + _values["password"];
          con = java.sql.DriverManager.getConnection(connectString);
        case "snowflake":
          try {
            java.lang.Class.forName("com.snowflake.client.jdbc.SnowflakeDriver").newInstance();
          } catch (ex : Any) { }
          var connectString : String;
          connectString = "jdbc:" +  connector + "://" + _values["account"] + ".snowflakecomputing.com";
          var prop : java.util.Properties = new java.util.Properties();
          prop.put("user", _values["user"]);
          prop.put("password", _values["password"]);
          prop.put("db", _values["database"]);
          prop.put("schema", _values["schema"]);
          prop.put("warehouse", _values["warehouse"]);
          prop.put("role", _values["role"]);
          con = java.sql.DriverManager.getConnection(connectString, prop);
        case "sqlserver":
          try {
            java.lang.Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver").newInstance();
          } catch (ex : Any) { }
          var connectString : String;
          connectString = "jdbc:" +  connector + "://" + _values["host"] + ";databaseName=" + _values["database"] + ";user=" + _values["user"] + ";password=" + _values["password"];// ";encrypt=false;";  
          con = java.sql.DriverManager.getConnection(connectString); 
        case "oracle":
          try {
            java.lang.Class.forName("oracle.jdbc.driver.OracleDriver").newInstance();
          } catch (ex : Any) { }          
          var connectString : String;
          connectString = "jdbc:" +  connector + ":thin:" + _values["user"] + "/" + _values["password"] + "@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=" + _values["host"] + ")(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=)))";
          con = java.sql.DriverManager.getConnection(connectString); 
        case "sqlite":
          try {
            java.lang.Class.forName("org.sqlite.JDBC").newInstance();
          } catch (ex : Any) { }          
          con = java.sql.DriverManager.getConnection("jdbc:sqlite:" + _values["file"]); 
        case "postgres":
          try {
            java.lang.Class.forName("org.postgresql.Driver").newInstance();
          } catch (ex : Any) { }          
          var connectString : String;
          connectString = "jdbc:" +  connector + "://" + _values["host"] + "/" + _values["database"];
          con = java.sql.DriverManager.getConnection(connectString, _values["user"], _values["password"]); 
        case "derby":
          try {
            java.lang.Class.forName("org.apache.derby.jdbc.EmbeddedDriver").newInstance();
          } catch (ex : Any) { }          
          var connectString : String;
          connectString  = "jdbc:" + connector + ":;databaseName=" + _values["database"];
          //jdbc:derby:sample
          //jdbc:derby:;databaseName=databaseName
          //jdbc:derby:jar:(pathToArchive)databasePathWithinArchive
          //jdbc:derby:classpath:databasePathWithinArchive          
          case "dataset":
            //TODO          
      }

      if (callback != null) {
        var con2 : java.sql.Connection = cast con;
        try {
          callback(con);
        } catch (ex : Any) { }
        if (!_cancelClose) {
          con2.close();
        }
        return null;
      } else {
        return con;
      }
    #elseif cs
      switch (connector) {
        case "mysql":
          // Mysql
          var connectString : String = "uid=" + _values["user"] + ";pwd=" + _values["password"] + ";database=" +  _values["database"] + ";server=" + _values["host"] + ";";
          con = createConnection(connectString, connector);
        case "snowflake":
          var connectString : String = "Server=" + _values["account"] + ".snowflakecomputing.com;Database=" + _values["database"] + ";uid=" + _values["user"] + ";pwd=" + _values["password"] + ";";
          con = createConnection(connectString, connector);
        case "sqlserver":
          var connectString : String = "Data Source=" + _values["host"] + "; Initial Catalog=" + _values["database"] + "; Integrated Security=SSPI;Provider=SQLOLEDB; User ID=" + _values["user"] + "; Password=" + _values["password"] + ";";
          con = createConnection(connectString, connector);
        case "oracle":
          var connectString : String = "Data Source=" + _values["database"] + "; User ID=" + _values["user"] + "; Password=" + _values["password"] + ";";
          con = createConnection(connectString, connector);
        case "sqlite":
          var connectString : String = "Database=" + _values["file"] + ";";
          con = createConnection(connectString, connector);
        case "postgres":
          var connectString : String = "Server=" + _values["host"] + ";Database=" + _values["database"] + ";UID=" + _values["user"] + ";pwd=" + _values["password"] + ";";
          con = createConnection(connectString, connector);
        case "derby":
          // TODO
        case "dataset":
          con = readDataSet(_values["file"]);
      }
      if (callback != null) {
        try {
          callback(con);
        } catch (ex : Any) {}
        if (!_cancelClose) {
          switch (connector) {
            case "dataset":
              disposeThis(con);
            default:
              closeThis(con);
          }
        }
        return null;
      } else {
        return con;
      }
    #elseif php
      switch (connector) {
        case "mysql":
          con = php.Syntax.code("new mysqli({0}, {1}}, {2}, {3}, {4})", _values["host"], _values["user"], _values["password"], _values["database"], _values["port"]);
        case "snowflake":
          con = php.Syntax.code("new PDO(\"snowflake:account=\" + {0}, {1}, {2}", _values["account"], _values["user"], _values["password"]);
        case "sqlserver":
          con = php.Syntax.code("sqlsrv_connect({0}, array(\"Database\" => {1}, \"Uid\" => {2}, \"PWD\" => {3}))", _values["host"], _values["database"], _values["user"], _values["password"]);
        case "oracle":
          var connectString : String = "//" + _values["host"] + "/" + _values["database"];
          con = php.Syntax.code("oci_connect({0}, {1}, {2})", _values["user"], _values["password"], connectString);
        case "sqlite":
          con = php.Syntax.code("new SQLite3({0})", _values["file"]);
        case "postgres":
          var connectString : String;
          connectString = "host='" + _values["host"] + "' dbname='" + _values["database"] + "' user='" + _values["user"] + "' password='" + _values["password"] + "'";
          con = php.Syntax.code("pg_connect({0})", connectString);
        case "derby":
          // TODO
        case "dataset":
          //TODO          
      }
      if (callback != null) {
        try {
          callback(con);
        } catch (ex : Any) {}
        if (!_cancelClose) {
          switch (connector) {
            case "mysql", "sqlite":
              php.Syntax.code("{0}.close()", con);
            case "snowflake":
              // Intentionally blank
            case "sqlserver":
              // Intentionally blank
            case "oracle":
              php.Syntax.code("oci_close({0})", con);
            case "postgres":
              php.Syntax.code("pg_close({0})", con);
          }
        }
        return null;
      } else {
        return con;
      }
    #elseif JS_BROWSER
      switch (connector) {
        case "sqlite":
          // TODO - Add additional options?
          con = js.Syntax.code("await initSqlJs({0})", null);
          con = js.Syntax.code("await fetch({0})", _values["file"]);
          con = js.Syntax.code("await {0}.arrayBuffer()", con);
          con = js.Syntax.code("new SQL.Database(new Uint8Array({0}))", con);
        case "websql":
          con = js.Syntax.code("openDatabase({0}, {1}, {2}, {3})", _values["database"], "1.0", "", _values["size"]);
        case "alasql":
          con = null; // Intentionally set to null, since AlaSQL doesn't need this.
        case "indexeddb":
          con = js.Syntax.code("await (new Promise(resolve => { var request = window.indexedDB.open({0}); request.onsuccess = function() { resolve(request.result); }; request.onerror = function() { resolve(null); }; }))", _values["database"]);
        case "jsstore":
          {
            var useworkers : Null<Bool> = cast _values["useworkers"];
            if (useworkers == null || useworkers == false) {
              con = js.Syntax.code("new JsStore.Connection();");
            } else {
              con = js.Syntax.code("new JsStore.Connection(new Worker('jsstore.worker.js'));");
            }
          }
          case "snowflake":
            con = js.Syntax.code("{ jwt: await databases.snowflake.login({0}.h.account, {0}.h.user, {0}.h.key), account: {0}.h.account, timeout: 60, database: {0}.h.database, schema: null, warehouse: null, role: null, }", _values);
          case "proxy":
            con = js.Syntax.code("{ user: {0}.h.user, password: {0}.h.password, account: {0}.h.account, warehouse: {0}.h.warehouse, role: {0}.h.role, database: {0}.h.connector, schema: {0}.h.schema, house: {0}.h.host, file: {0}.h.file, driver: {0}.h.driver, size: {0}.h.size, }", _values);
      }

      if (callback != null) {
        try {
          callback(con);
        } catch (ex : Any) {}
        if (!_cancelClose) {
          switch (connector) {
            case "sqlite":
              js.Syntax.code("{0}.close()", con);
          }
        }
        return con;
      } else {
        return con;
      }      
    #elseif JS_WSH
      switch (connector) {
        case "mysql":
          // Mysql
          populateDriver(_values);
          var connectString : String = "Driver={" + _values["driver"] + "};uid=" + _values["user"] + ";pwd=" + _values["password"] + ";database=" + _values["database"] + ";server=" + _values["host"] + ";";
          con = js.Syntax.code("new ActiveXObject(\"ADODB.Connection\")");
          js.Syntax.code("{0}.Open({1})", con, connectString);
        case "snowflake":
          var connectString : String = "Driver={SnowflakeDSIIDriver};Server=" + _values["account"] + ".snowflakecomputing.com;Database=" + _values["database"] + ";uid=" + _values["user"] + ";pwd=" + _values["password"] + ";";
          con = js.Syntax.code("new ActiveXObject(\"ADODB.Connection\")");
          js.Syntax.code("{0}.Open({1})", con, connectString);
        case "sqlserver":
          var connectString : String = "Data Source=" + _values["host"] + "; Initial Catalog=" + _values["database"] + "; Integrated Security=SSPI;Provider=SQLOLEDB; User ID=" + _values["user"] + "; Password=" + _values["password"] + ";";
          con = js.Syntax.code("new ActiveXObject(\"ADODB.Connection\")");
          js.Syntax.code("{0}.Open({1})", con, connectString);
        case "oracle":
          var connectString : String = "Provider=OraOLEDB.Oracle; Data Source=" + _values["database"] + "; User ID=" + _values["user"] + "; Password=" + _values["password"] + ";";
          con = js.Syntax.code("new ActiveXObject(\"ADODB.Connection\")");
          js.Syntax.code("{0}.Open({1})", con, connectString);
        case "sqlite":
          // SQLite3 ODBC Driver
          populateDriver(_values);
          var connectString : String = "DRIVER=" + _values["driver"] + "; Database=" + _values["file"] + ";";
          con = js.Syntax.code("new ActiveXObject(\"ADODB.Connection\")");
          js.Syntax.code("{0}.Open({1})", con, connectString);
        case "postgres":
          populateDriver(_values);
          var connectString = "Driver=" + _values["driver"]  +";Server=" + _values["host"] + ";Database=" + _values["database"] + ";UID=" + _values["user"] + ";pwd=" + _values["password"] + ";";
          con = js.Syntax.code("new ActiveXObject(\"ADODB.Connection\")");
          js.Syntax.code("{0}.Open({1})", con, connectString);
        case "derby":
          // TODO
        case "dataset":
           //TODO
      }
      if (callback != null) {
        try {
          callback(con);
        } catch (ex : Any) {}
        if (!_cancelClose) {
          js.Syntax.code("{0}.Close()", con);
        }
        return null;
      } else {
        return con;
      }
    #elseif JS_SNOWFLAKE
      return null;
    #elseif JS_NODE
      //TODO
    #else // HASHLINK
      switch (connector) {
        case "mysql":
          var c : Dynamic = Type.resolveClass("sys.db.Mysql");
          con = Reflect.callMethod(c, cast Reflect.field(c, "connect"), [{user: _values["user"], port: _values["port"], pass: _values["password"], host: _values["host"], database: _values["database"]}]); 
          //con = sys.db.Mysql.connect({user: _values["user"], port: _values["port"], pass: _values["password"], host: _values["host"], database: _values["database"]});
        case "sqlite":
          con = sys.db.Sqlite.open(_values["file"]); 
      }

      if (callback != null) {
        var con2 : sys.db.Connection = cast con;
        try {
          callback(con);
        } catch (ex : Any) { }
        if (!_cancelClose) {
          con2.close();
        }
        return null;
      } else {
        return con;
      }    
      #end
  }

  public function test() : Bool {
    var r : Bool = false;
    try {
      connect(function (o : Dynamic) : Void {
        r = true;
      });
    } catch (ex : Any) { }
    return r;
  }

  private function cancelClose() : Void {
    _cancelClose = true;
  }

  #if JS_BROWSER @:jsasync #end public function query(query : String, ?params : Map<String, Dynamic>, ?callback : Dynamic->Void) : Dynamic {
    var connector : String = StringTools.trim(_values["connector"]).toLowerCase();
    var r : Dynamic;
    if (params != null) {
      // Generic parameter insertion.
      // TODO - Replace with platform/database specific ones.
      switch (connector) {
        default:
          for (param in params) {
            var value : Dynamic = params[param];
            if (value == null) {
              value = "null";
            } else if (Std.isOfType(value, Int) || Std.isOfType(value, Float) /* TODO - || Std.isOfType(value, haxe.Int64)*/) {
              value = "" + value;
            } else if (Std.isOfType(value, Bool)) {
              var d : Date = cast value;
              value = "DATETIME('" + d.toString() + "')";
            } else if (Std.isOfType(value, Date)) {
              var b : Bool = cast value;
              value = value ? "true" : "false";
            } else {
              value = StringTools.replace(cast value, "'", "''");
              value = "'" + value + "'";
            }
            query = StringTools.replace(query, "@" + param, value);
            query = StringTools.replace(query, ":" + param, value);
            query = StringTools.replace(query, "(" + param + ")", value);
          }
      }
    }
    connect(#if JS_BROWSER @:jsasync #end function (cur : Dynamic) : Void {
      #if python
        python.Syntax.code("{0}.execute({1})", cur, query);
        r = cur;
        if (callback != null) {
          callback(r);
        } else {
          cancelClose();
        }
      #elseif java
        var cur2 : java.sql.Connection = cast cur;
        var stmt : java.sql.Statement = cur2.createStatement();
        stmt.execute(query);
        var results : java.sql.ResultSet = stmt.getResultSet();
        r = results;
        if (callback != null) {
          try {
            callback(r);
          } catch (ex : Any) { }
          if (!_cancelClose) {
            results.close();
            stmt.close();
          }
        } else {
          cancelClose();
        }
      #elseif cs
        switch (connector) {
          case "dataset":
            r = selectThis2(cur, query);
            if (callback != null) {
              callback(r);
            } else {
              cancelClose();
            }
          default:
            r = selectThis(cur, query);
            if (callback != null) {
              try {
                callback(r);
              } catch (ex : Any) { }
            } else {
              cancelClose();
            }
        }
      #elseif php
        switch (connector) {
          case "mysql", "sqlite", "snowflake":
            r = php.Syntax.code("{0}::query({1})", cur, query);
          case "sqlserver":
            r = php.Syntax.code("sqlsrv_query({0}, {1})", cur, query);
          case "oracle":
            r = php.Syntax.code("oci_execute(oci_parse({0}, {1}))", cur, query);
          case "postgres":
            r = php.Syntax.code("pg_query({0}, {1})", cur, query);
          default:
            r = null;
        }
        if (callback != null) {
          callback(r);
          switch (connector) {
            case "mysql", "sqlite", "snowflake", "oracle", "postgres":
              // Intentionally left blank
            case "sqlserver":
              r = php.Syntax.code("sqlsrv_free_stmt({0})", r);
          }
        } else {
          cancelClose();
        }
      #elseif JS_BROWSER
        r = null;
        switch (connector) {
          case "sqlite":
            r = js.Syntax.code("{0}.exec({1})", cur, query);
          case "websql":
            r = js.Syntax.code("await (new Promise(resolve => { {0}.transaction(function (tx) { tx.executeSql({1}, [], function (tx, results) { resolve(result); }, null); }); }))", cur, query);
          case "alasql":
            r = js.Syntax.code("alasql({0})", query);
          case "indexeddb":
            // TODO
          case "jsstore":
            r = js.Syntax.code("{0}.select({1})", cur, query);
          case "snowflake":
            r = js.Syntax.code("await databases.snowflake.execute({0}.jwt, {0}.account, {1}, {0}.timeout, {0}.database, {0}.schema, {0}.warehouse, {0}.role, {2}, {3})", cur, query, params, callback);
          case "proxy":
            r = js.Syntax.code("await databases.proxy.execute({0}, {1}, {2}, {3})", cur, query, params, callback);
          default:
            r = null;
        }
        if (callback != null) {
          callback(r);
        } else {
          cancelClose();
        }
      #elseif JS_NODE
        //TODO
      #elseif JS_WSH
        r = js.Syntax.code("new ActiveXObject(\"ADODB.Recordset\")");
        js.Syntax.code("{0}.Open({1}, {2})", r, query, cur);
        if (callback != null) {
          try {
            callback(r);
          } catch (ex : Any) { }
          if (!_cancelClose) {
            js.Syntax.code("{0}.Close()", r);
          }
        } else {
          cancelClose();
        }
      #elseif JS_SNOWFLAKE
        r = js.Syntax.code("snowflake.createStatement({ sqlText: {0} }).execute()", query);
      #else // HASHLINK
        var cur2 : sys.db.Connection = cast cur;
        r = cur2.request(query);
        if (callback != null) {
          try {
            callback(r);
          } catch (ex : Any) { }
        } else {
          cancelClose();
        }
      #end
    });
    if (callback != null) {
      return null;
    } else {
      return r;
    }
  }

  #if JS_BROWSER @:jsasync #end public function queryForReader(query : String, ?params : Map<String, Dynamic>, ?callback : DataTableReader->Void) : DataTableReader {
    var r : DatabaseReader;
    this.query(query, params, function (cur : Dynamic) : Void {
      r = DatabaseReader.read(cur);
      r.hold(_values);
      if (callback != null) {
        try {
          callback(r);
        } catch (ex : Any) { }
        r.dispose();
      } else {
        cancelClose();
      }
    });
    if (callback != null) {
      return null;
    } else {
      return r;
    }
  }
}
#end
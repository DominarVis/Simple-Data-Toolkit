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
@:expose
@:nativeGen
class DatabaseReaderOptions {
  private var _values : Map<String, Any> = new Map<String, Any>();

  public inline function new() {  }

  public function mysql() : DatabaseReaderLoginOptions {
    return database("mysql");
  }

  public function snowflake() : DatabaseReaderLoginOptions {
    return database("snowflake");
  }

  public function oracle() : DatabaseReaderLoginOptions {
    return database("oracle");
  }
    
  public function sqlite() : DatabaseReaderLoginOptions {
    return database("sqlite");
  }

  public function derby() : DatabaseReaderLoginOptions {
    return database("derby");
  }

  public function sqlServer() : DatabaseReaderLoginOptions {
    return database("sqlserver");
  }  

  public function postgres() : DatabaseReaderLoginOptions {
    return database("postgres");
  }

  public function dataset() : DatabaseReaderLoginOptions {
    return database("dataset");
  }  

  public function database(s : String) : DatabaseReaderLoginOptions {
    _values["connector"] = s;
    return new DatabaseReaderLoginOptions(_values);
  }

  public static function parse(s : String, ?query : StringBuf) : DatabaseReaderLoginOptions {
    var o1 : DatabaseReaderOptions = new DatabaseReaderOptions();
    var o2 : DatabaseReaderLoginOptions = null;
    var values : Map<String, String> = new Map<String, String>();
    for (s2 in s.split(";")) {
        var s3 : Array<String> = s2.split("=");
        values[StringTools.trim(s3[0]).toLowerCase()] = StringTools.trim(s3[1]);
    }
    for (k in values.keys()) {
        switch (k) {
            case "dbtype":
                switch (values[k].toLowerCase()) {
                    case "mysql":
                        o2 = o1.mysql();
                    case "snowflake":
                        o2 = o1.snowflake();
                    case "oracle":
                        o2 = o1.oracle();
                    case "sqlite":
                        o2 = o1.sqlite();
                    case "derby":
                        o2 = o1.derby();
                    case "sqlserver":
                        o2 = o1.sqlServer();
                    case "postgres":
                        o2 = o1.postgres();
                    case "dataset":
                        o2 = o1.dataset();
                }
        }
    }
    for (k in values.keys()) {
        var v : String = values[k];
        switch (k) {
            case "user":
                o2 = o2.user(v);
            case "password":
                o2 = o2.password(v);
            case "account":
                o2 = o2.account(v);
            case "warehouse":
                o2 = o2.warehouse(v);
            case "role":
                o2 = o2.role(v);
            case "database":
                o2 = o2.database(v);
            case "schema":
                o2 = o2.schema(v);
            case "host":
                o2 = o2.host(v);
            case "file":
                o2 = o2.file(v);
            case "driver":
                o2 = o2.driver(v);
            case "query":
                query.add(v);
        }
    }
    return o2;
  }
}
#end
/*
    Copyright (C) 2023 Vis LLC - All Rights Reserved

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
    ISTAR - Insanely Simple Transfer And Reporting
*/

package com.sdtk.api;

#if(!EXCLUDE_APIS && js)
@:expose
@:nativeGen
class SQLAPI extends ExecutorAPI {
    private static var _SQL : Dynamic = null;
    private static var _DB : Dynamic = null;
    private static var _instance : SQLAPI;

    private function new() {
        super("SQL");
    }

    public static function instance() : ExecutorAPI {
        if (_instance == null) {
            _instance = new SQLAPI();
        }
        return _instance;
    }    

    public override function acceptedFormat() : String {
        return "SQL";
    }
    
    public override function execute(script : String, mapping : Map<String, String>, callback : com.sdtk.table.DataTableReader->Void) : Void {
        requireInit(function () {
            var init : String = "";
            var finish : String = "";
            init += "CREATE TABLE dual AS SELECT 'X' AS dummy;\n";
            finish += "DROP TABLE dual;\n";
            if (mapping != null) {
                mapping = com.sdtk.std.Normalize.nativeToHaxe(mapping);
                for (i in mapping.keys()) {
                    init += "CREATE TABLE " + i + " AS " + mapping[i] + ";\n";
                    finish += "DROP TABLE " + i + ";\n";
                }
            }
            if (init.length > 0) {
                _DB.run(init);
            }
            var stmt : Dynamic = null;
            try {
                stmt = js.Syntax.code("{0}.prepare({1})", _DB, script);
            } catch (ex) {

            }
            init = null;
            script = null;
            mapping = null;
            try {
                callback(com.sdtk.table.DatabaseReader.read(stmt));
            } catch (ex) {
            }
            if (finish.length > 0) {
                _DB.run(finish);
            }
            finish = null;
        });
    }

    private override function startInit(callback : Void->Void) : Void {
        load(js.Browser.document.location.protocol.toLowerCase().indexOf("file") == 0 ? "sql-asm.js" : "/sql-wasm.js", function () {
            js.Syntax.code("initSqlJs({ }).then({0})", function(SQL : Dynamic){
                _SQL = SQL;
                _DB = js.Syntax.code("new SQL.Database()");
                callback();
            });
        });
    }

    public override function keywords() : Array<String> {
        return ["ADD", "ALL", "ALTER", "AND", "ANY", "AS", "ASC", "BETWEEN", "BY", "CASE", "CHECK", "COLUMN", "CONSTRAINT", "CREATE", "DATABASE", "DEFAULT", "DELETE", "DESC", "DISTINCT", "DROP", "DUAL", "EXEC", "EXISTS", "FOREIGN", "FROM", "GROUP", "HAVING", "IN", "INDEX", "INNER", "INSERT", "INTO", "IS", "JOIN", "LEFT", "LIKE", "LIMIT", "NOT", "NULL", "OR", "ORDER", "OUTER", "PRIMARY", "PROCEDURE", "ROWNUM", "REPLACE", "SELECT", "SET", "TABLE", "TOP", "TRUNCATE", "UNION", "UNIQUE", "UPDATE", "VALUES", "VIEW", "WHERE"];
    }    

    public override function keywordsAreCaseSensitive() : Bool {
        return false;
    }    
}
#end
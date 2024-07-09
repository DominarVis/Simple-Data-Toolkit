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
class PythonAPI extends ExecutorAPI {
    private static var _instance : PythonAPI;

    private function new() {
        super("Python");
    }

    public static function instance() : ExecutorAPI {
        if (_instance == null) {
            _instance = new PythonAPI();
        }
        return _instance;
    }    

    public override function acceptedFormat() : String {
        return "Python";
    }
    
    public override function execute(script : String, mapping : Map<String, String>, readers : Map<String, com.sdtk.table.DataTableReader>, callback : Dynamic->Void) : Void {
        requireInit(function () {
            var init : String = "";
            if (mapping != null) {
                mapping = cast com.sdtk.std.Normalize.nativeToHaxe(mapping);
                for (i in mapping) {
                    init += i + " = " + haxe.Json.stringify(mappingValueToType(mapping[i])) + "\n";
                }
            }
            if (readers != null) {
                for (i in readers.keys()) {
                    var writer : com.sdtk.std.StringWriter = new com.sdtk.std.StringWriter(null);
                    readers[i].convertTo(com.sdtk.table.CodeWriter.createPythonArrayOfMapsWriter(writer));
                    init += i + " = " + writer.toString() + "\n";
                }
            }            
            var r = js.Syntax.code("pyscript.runtime.run({0} + {1})", init, script);
            init = null;
            script = null;
            mapping = null;
            var o : Dynamic = null;
            try {
                o = r.toJs();
            } catch (ex : Any) { }
            exportReader(o, r, callback);
            try {
                r.destroy();
            } catch (ex : Any) { }
            r = null;
        });
    }

    private override function startInit(callback : Void->Void) : Void {
        load((js.Browser.document.location.protocol.toLowerCase().indexOf("file") == 0 ? "" : "/") + "pyscript.js", callback, ["pyscript.runtime.interpreter.runPython"]);
    }

    public override function keywords() : Array<String> {
        return ["and", "as", "assert", "break", "class", "continue", "def", "del", "elif", "else", "except", "False", "finally", "for", "from", "global", "if", "import", "is", "in", "lambda", "None", "nonlocal", "not", "or", "pass", "raise", "return", "True", "try", "while", "with", "yield"];
    }    
}
#end
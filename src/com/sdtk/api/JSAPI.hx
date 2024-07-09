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
class JSAPI extends ExecutorAPI {
    private static var _instance : JSAPI;

    private function new() {
        super("JavaScript");
    }

    public static function instance() : ExecutorAPI {
        if (_instance == null) {
            _instance = new JSAPI();
        }
        return _instance;
    }    

    public override function acceptedFormat() : String {
        return "JSON";
    }
    
    public override function execute(script : String, mapping : Map<String, String>, readers : Map<String, com.sdtk.table.DataTableReader>, callback : Dynamic->Void) : Void {
        requireInit(function () {
            mapping = cast com.sdtk.std.Normalize.nativeToHaxe(mapping);
            var init : String = "";
            if (mapping != null) {
                for (i in mapping.keys()) {
                    init += "const " + i + " = " + haxe.Json.stringify(mappingValueToType(mapping[i])) + ";\n";
                }
            }
            if (readers != null) {
                for (i in readers.keys()) {
                    var writer : com.sdtk.std.StringWriter = new com.sdtk.std.StringWriter(null);
                    readers[i].convertTo(com.sdtk.table.KeyValueWriter.createJSONWriter(writer));
                    init += "const " + i + " = " + writer.toString() + ";\n";
                }
            }            
            var r : Dynamic = js.Lib.eval("(function () { " + init + script + "})")();
            init = null;
            script = null;
            mapping = null;
            exportReader(r, null, callback);
        });
    }

    private override function startInit(callback : Void->Void) : Void {
        callback();
    }

    public override function keywords() : Array<String> {
        return ["abstract", "arguments", "await", "boolean", "break", "byte", "case", "catch", "char", "class", "const", "continue", "debugger", "default", "delete", "do", "double", "else", "enum", "eval", "export", "extends", "false", "final", "finally", "float", "for", "function", "goto", "if", "implements", "import", "in", "instanceOf", "int", "interface", "let", "long", "native", "new", "null", "package", "private", "protected", "public", "return", "short", "static", "super", "switch", "synchronized", "this", "throw", "throws", "transient", "true", "try", "typeof", "var", "void", "volatile", "while", "with", "yield"];
    }     
}
#end
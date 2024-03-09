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
class CobolAPI extends ExecutorAPI {
    private static var _instance : CobolAPI;

    private function new() {
        super("Cobol");
    }

    public static function instance() : ExecutorAPI {
        if (_instance == null) {
            _instance = new CobolAPI();
        }
        return _instance;
    }    

    public override function acceptedFormat() : String {
        return "Cobol";
    }
    
    public override function execute(script : String, mapping : Map<String, String>, callback : Dynamic->Void) : Void {
        requireInit(function () {
            var program = js.Syntax.code("cobolscript.compileProgram({0})", script);
            if (mapping != null) {
                mapping = com.sdtk.std.Normalize.nativeToHaxe(mapping);
                for (key in mapping.keys()) {
                    mapping.set(key, mappingValueToType(mapping.get(key)));
                }
                mapping = com.sdtk.std.Normalize.haxeToNative(mapping);
                js.Syntax.code("{0}.data = {1}", program, mapping);
                mapping = null;
            }
            var o : Dynamic = js.Syntax.code("{0}.run(cobolscript.getRuntime())", program);
            exportReader(o, null, callback);
        });
    }

    private override function startInit(callback : Void->Void) : Void {
        var prefix : String = js.Browser.document.location.protocol.toLowerCase().indexOf("file") == 0 ? "" : "/";
        load(prefix + "lexers.js", callback);
        load(prefix + "parsers.js", callback);
        load(prefix + "cobolscript.js", callback);
    }

    public override function keywords() : Array<String> {
        return ["ACCEPT", "ADD", "ALTER", "AND", "CALL", "CANCEL", "CLOSE", "COMMIT", "COMPUTE", "CONTINUE", "DELETE", "DISPLAY", "DIVIDE", "ELSE", "END-ADD", "END-CALL", "END-COMPUTE", "END-DELETE", "END-DIVIDE", "END-EVALUATE", "END-IF", "END-MULTIPLY", "END-READ", "END-RETURN", "END-REWRITE", "END-SEARCH", "END-START", "END-STRING", "END-SUBTRACT", "END-UNSTRING", "END-WRITE", "ENTRY", "EVALUATE", "EXEC", "EXIT", "FD", "FILE", "IDENTIFICATION", "IF", "INITIALIZE", "INSPECT", "MOVE", "MULTIPLY", "NOT", "OR", "PERFORM", "READ", "REWRITE", "SEARCH", "SECTION", "SELECT", "SET", "START", "STOP", "STRING", "SUBTRACT", "UNSTRING", "WRITE"];
    }   
    
    public override function keywordsAreCaseSensitive() : Bool {
        return false;
    }      
}
#end
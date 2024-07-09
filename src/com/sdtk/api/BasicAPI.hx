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
class BasicAPI extends ExecutorAPI {
    private static var _instance : BasicAPI;

    private function new() {
        super("Basic");
    }

    public static function instance() : ExecutorAPI {
        if (_instance == null) {
            _instance = new BasicAPI();
        }
        return _instance;
    }    

    public override function acceptedFormat() : String {
        return "Cobol";
    }
    
    public override function execute(script : String, mapping : Map<String, String>, readers : Map<String, com.sdtk.table.DataTableReader>, callback : Dynamic->Void) : Void {
        requireInit(function () {
            var context = js.Syntax.code("new basicscript.context()");
            if (mapping != null) {
                mapping = cast com.sdtk.std.Normalize.nativeToHaxe(mapping);
                for (key in mapping.keys()) {
                    js.Syntax.code("{0}.setValue({1}, {2})", context, key, mappingValueToType(mapping.get(key)));
                }
            }
            // TODO - readers
            var program = js.Syntax.code("basicscript.execute({0}, {1})", script, context);
            if (mapping != null) {
                for (key in mapping.keys()) {
                    mapping[key] = js.Syntax.code("{0}.getValue({1})", context, key);
                }
            }
            exportReader(mapping, null, callback);
        });
    }

    private override function startInit(callback : Void->Void) : Void {
        var prefix : String = js.Browser.document.location.protocol.toLowerCase().indexOf("file") == 0 ? "" : "/";
        load(prefix + "bslexer.js", callback);
        load(prefix + "bscommands.js", callback);
        load(prefix + "bsexpressions.js", callback);
        load(prefix + "bsparser.js", callback);
        load(prefix + "basicscript.js", callback);
    }

    public override function keywords() : Array<String> {
        return ["BREAK", "CONTINUE", "DIM", "ELSE", "FOR", "IF", "RETURN", "STEP", "TO", "WHILE" ];
    }    

    public override function keywordsAreCaseSensitive() : Bool {
        return false;
    }      
}
#end
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

#if(!EXCLUDE_APIS && JS_BROWSER)
@:expose
@:nativeGen
class CodeMirrorAPI extends API {
    private static var _instance : CodeMirrorAPI;
    private static var _editor : Dynamic;

    private function new() {
        super("CodeMirror");
    }

    public static function value(editor : Dynamic) : String {
        return editor.state.doc.toString();
    }

    private static function instance() : CodeMirrorAPI {
        if (_instance == null) {
            _instance = new CodeMirrorAPI();
        }
        return _instance;
    }

    public static function open(code : String, type : String, mappings : Dynamic, readonly : Bool, callback : Dynamic->Void) : Void {
        _editor = null;
        instance().requireInit(function () : Void {
            try {
                js.Syntax.code("const { basicSetup, EditorView } = CM[\"codemirror\"]");
                
                var module : Dynamic = null;
                var language : Dynamic = null;
                var scope : Dynamic = null;
                // TODO - Add C#
                // TODO - Add Haxe
                    
                switch (type) {
                    case "JavaScript": {
                        js.Syntax.code("const { javascript, javascriptLanguage, scopeCompletionSource } = CM[\"@codemirror/lang-javascript\"]; module = javascript; language = javascriptLanguage; scope = scopeCompletionSource;");                       
                    }
                    case "HTMLTable": {
                        js.Syntax.code("const { html, htmlLanguage, htmlCompletionSource } = CM[\"@codemirror/lang-html\"]; module = html; language = htmlLanguage; scope = htmlCompletionSource;");
                    }
                    case "Java": {
                        js.Syntax.code("const { java, javaLanguage } = CM[\"@codemirror/lang-java\"]; module = java; language = javaLanguage;");
                    }
                    case "JSON": {
                        js.Syntax.code("const { json, jsonLanguage } = CM[\"@codemirror/lang-json\"]; module = json; language = jsonLanguage;");
                    } 
                    case "Python": {
                        js.Syntax.code("const { python, pythonLanguage, localCompletionSource } = CM[\"@codemirror/lang-python\"]; module = python; language = pythonLanguage; scope = localCompletionSource;");
                    }
                    case "SQL": {
                        js.Syntax.code("const { sql, SQLite, schemaCompletionSource } = CM[\"@codemirror/lang-sql\"]; module = sql; language = SQLite; scope = schemaCompletionSource;");
                    }
                    default:
                        callback(null);
                        return;
                }
    
                if (scope == null) {
                    scope = function () { return null; };
                }
    
                if (language.data != null && mappings != null) {
                    scope = language.data.of(
                        {
                            autocomplete: scope(mappings)
                        }
                    );
                } else {
                    scope = null;
                }
    
                _editor = js.Syntax.code("new EditorView({ doc: {0}, extensions: {1} == null ? [basicSetup, {2}()] : [basicSetup, {2}(), {1}], parent: document.querySelector(\"#dCodeEditor\"), })", code, scope, module);
                callback(_editor);
            } catch (ex : Any) {
                callback(null);
            }
        });
    }

    private override function startInit(callback : Void->Void) : Void {
        load((js.Browser.document.location.protocol.toLowerCase().indexOf("file") == 0 ? "" : "/") + "codemirror.js", callback);
    }
}
#end
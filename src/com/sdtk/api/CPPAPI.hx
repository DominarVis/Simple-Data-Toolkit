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
class CPPAPI extends ExecutorAPI {
    private static var _instance : CPPAPI;

    private function new() {
        super("C++");
    }

    public static function instance() : ExecutorAPI {
        if (_instance == null) {
            _instance = new CPPAPI();
        }
        return _instance;
    }    

    public override function acceptedFormat() : String {
        return "C++";
    }
    
    public override function execute(script : String, mapping : Map<String, String>, readers : Map<String, com.sdtk.table.DataTableReader>, callback : Dynamic->Void) : Void {
        requireInit(function () {
            var init : String = "";
            if (mapping != null) {
                mapping = cast com.sdtk.std.Normalize.nativeToHaxe(mapping);
                for (i in mapping) {
                    var mappingValue : Dynamic = mappingValueToType(mapping[i]);
                    var vType : String = null ;
                    switch (Type.typeof(mappingValue)) {
                        case TBool:
                            vType = "bool";
                        case TFloat:
                            vType = "double";
                        case TInt:
                            vType = "int";
                        case TClass(String):
                            vType = "std::string";
                        default:
                            vType = "std::string";
                    }
                    init += vType + " " + i + " = " + haxe.Json.stringify(mappingValue) + ";\n";
                }
                mapping = null;
            }
            // TODO - readers
            var output : StringBuf = new StringBuf();
            var config : Dynamic = {
                stdio: {
                    write: function(s : String) {
                        output.add(s);
                    }
                },
                unsigned_overflow: "error"
            };
            var o : Dynamic = js.Syntax.code("JSCPP.run({0}, \"\", {1})", init + script, config);
            exportReader(o, null, callback);
        });
    }

    private override function startInit(callback : Void->Void) : Void {
        var prefix : String = js.Browser.document.location.protocol.toLowerCase().indexOf("file") == 0 ? "" : "/";
        load(prefix + "JSCPP.es5.min.js", callback);
    }

    public override function keywords() : Array<String> {
        return [
            "#define", "#else", "#elif", "#endif", "#error", "#if", "#ifdef", "#include", "#undef", "#using", "#line", "#pragma", "#region",
            "alignas", "alignof", "and", "and_eq", "asm", "atomic_cancel", "atomic_commit", "atomic_noexcept", "auto", "bitand", "bitor", "bool", "break", "case", "catch", "char", "char8_t", "char16_t", "char32_t", "class", "compl", "concept", "const", "consteval", "constexpr", "constinit", "const_cast", "continue", "co_await", "co_return", "co_yield", "decltype", "default", "delete", "do",
            "double", "dynamic_cast", "else", "enum", "explicit", "export", "extern", "false", "final", "float", "for", "friend", "goto", "if", "import", "inline", "int", "long", "module", "mutable", "namespace", "new", "noexcept", "not", "not_eq", "nullptr", "operator", "or", "or_eq", "override", "private", "protected", "public", "reflexpr", "register", "reinterpret_cast", "requires",
            "return", "short", "signed", "sizeof", "static", "struct", "switch", "synchronized", "template", "this", "thread_local", "throw", "true", "transaction_safe", "transaction_safe_dynamic", "try", "typedef", "typeid", "typename", "union", "unsigned", "using", "virtual", "void", "volatile", "wchar_t", "while", "xor", "xor_eq"
        ];
    }   

    public override function keywordsAreCaseSensitive() : Bool {
        return false;
    }      
}
#end
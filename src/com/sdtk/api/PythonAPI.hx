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
    
    public override function execute(script : String, mapping : Map<String, String>, callback : Dynamic->Void) : Void {
        requireInit(function () {
            var init : String = "";
            for (i in mapping) {
                init += i + " = " + mapping[i] + "\n";
            }
            var r = js.Syntax.code("pyscript.runtime.run({0} + {1})", init, script);
            init = null;
            script = null;
            mapping = null;
            var o : Dynamic = r.toJs();
            var arr : Array<Dynamic> = new Array<Dynamic>();
            arr.resize(o.length);
            var i : Int = 0;
        
            while (i < o.length) {
                var o2 : Dynamic = o[i];
                var v : Dynamic = js.Syntax.code("{ }");
                var iterator : Dynamic = o2.keys();
                var cur : Dynamic = iterator.next();
                while (cur != null && cur.value != null && cur.done == false) {
                    v[cur.value] = o2.get(cur.value);
                    cur = iterator.next();
                }
                arr[i] = v;
                i++;
            }
            r.destroy();
            r = null;
            callback(com.sdtk.table.ArrayOfObjectsReader.readWholeArray(cast arr));
        });
    }

    private override function startInit(callback : Void->Void) : Void {
        load((js.Browser.document.location.protocol.toLowerCase().indexOf("file") == 0 ? "" : "/") + "pyscript.js", callback);
    }
}
#end
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
    
    public override function execute(script : String, mapping : Map<String, String>, callback : Dynamic->Void) : Void {
        requireInit(function () {
            var init : String = "";
            for (i in mapping) {
                init += "const " + i + mapping[i] + ";\n";
            }
            var r : Dynamic = js.Lib.eval("(function () { " + init + script + "})")();
            init = null;
            script = null;
            mapping = null;
            callback(com.sdtk.table.ArrayOfObjectsReader.readWholeArray(r));
        });
    }

    private override function startInit(callback : Void->Void) : Void {
        callback();
    }
}
#end
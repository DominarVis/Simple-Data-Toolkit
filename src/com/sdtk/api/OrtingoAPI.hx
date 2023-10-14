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

#if !EXCLUDE_APIS
// TODO
@:nativeGen
class OrtingoAPI extends API {
    private static var _ortingoRoot : String = "ortingo.com/";
    private static var _postsAPI : String = "users";

    private static var _instance : OrtingoAPI;
    
    private function new() {
        super("Ortingo");
    }

    public static function instance() : OrtingoAPI {
        if (_instance == null) {
            _instance = new OrtingoAPI();
        }
        return _instance;
    }

    public static function posts(callback : Dynamic->Void, owner : String) : Void {
        instance().fetch("GET", _ortingoRoot, _postsAPI, null, null, owner, null, function (r) {
            callback(r);
        });
    }

    public function postsAPI() : InputAPI {
        return OrtingoAPIPosts.instance();
    }
}

@:nativeGen
class OrtingoAPIPosts extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Cloud - Ortingo - Posts");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new OrtingoAPIPosts();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["owner"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        OrtingoAPI.posts(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, cast mapping["owner"]);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        //findElementsByClass(["href"], "item");
        //findElementsByClass(["span"], "post");
        //findElementsByClass(["span"], "title");
        //findElementsByClass(["span"], "subtitle");
        //findElementsByClass(["p"], "item_info");
        //item.split("/") - Last entry is id of post
        callback(data, com.sdtk.table.ArrayOfObjectsReader.readWholeArray(haxe.Json.parse(data).result));
    }    
}
#end
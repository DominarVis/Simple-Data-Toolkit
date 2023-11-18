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
@:nativeGen
class TableauAPI extends API {
    private static var _tableauRoot : String = "10ay.online.tableau.com/api/3.5/sites";
    private static var _tableauSigninRoot : String = "10ay.online.tableau.com/api/3.5";
    private static var _viewAPI : String = "/views/";
    private static var _dataAPI : String = "/data";
    private static var _signinAPI : String = "/auth/signin";

    private static var _instance : TableauAPI;

    private var _token : String;
    private var _user : String;
    private var _site : String;

    private function new() {
        super("Tableau");
    }

    public static function instance() : TableauAPI {
        if (_instance == null) {
            _instance = new TableauAPI();
        }
        return _instance;
    }

    // TODO - public static function list

    public static function pull(callback : Dynamic->Void, user : String, password : String, site : String, view : String) : Void {
        login(function (response : Dynamic) {
            instance().fetch("GET", _tableauRoot, site + _viewAPI + view + _dataAPI, null, true, null, null, function (r) {
                callback(r);
            });
        }, user, password, site);
    }

    public static function pullAPI() : InputAPI {
        return TableauAPIPull.instance();
    }

    public static function login(callback : Dynamic->Void, user : String, password : String, site : String) {
        var instance : TableauAPI = instance();
        if (user == instance._user && site == instance._site && instance._token != null) {
            callback(true);
        } else {
            var params = {
                "credentials": {
                    "name": user,
                    "password": password,
                    "site": {
                        "contentUrl": site
                    }
                }
            };
            instance.fetch("POST", _tableauSigninRoot, _signinAPI, null, null, null, haxe.Json.stringify(params), function (response : Dynamic) {
                instance._token = haxe.Json.parse(response).credentials.token;
                instance._user = user;
                instance._site = site;
                callback(response);
            });
        }
    }

    private override function getAuthorizationHeader() : String {
        return "X-Tableau-Auth";
    }

    private override function getAuthorizationHeaderBearer() : String {
        return "";
    }

    private override function getAccessToken() : String {
        return _token;
    }
}

@:nativeGen
class TableauAPIPull extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Reporting - Tableau - View");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new TableauAPIPull();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["user", "password", "site", "view"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        TableauAPI.pull(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, cast mapping["user"], cast mapping["password"], cast mapping["site"], cast mapping["view"]);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        callback(data, com.sdtk.table.ArrayOfObjectsReader.readWholeArray(haxe.Json.parse(data).token_transfers));
    }    
}
#end
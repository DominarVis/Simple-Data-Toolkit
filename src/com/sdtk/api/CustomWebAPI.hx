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
@:expose
@:nativeGen
class CustomWebAPI extends API {
    private var _url : String;
    private var _method : String;
    private var _query : Array<CustomWebAPIParam>;
    private var _queryByKey : Map<String, CustomWebAPIParam>;
    private var _headers : Array<CustomWebAPIParam>;
    private var _headersByKey : Map<String, CustomWebAPIParam>;
    private var _body : String;
    private var _bodyType : String;
    private var _cookies : Array<CustomWebAPIParam>;
    private var _cookiesByKey : Map<String, CustomWebAPIParam>;

    private function new(name : String) {
        super(name);
    }

    /* TODO -
    public static function fromJSON(json : String) : Map<String, CustomWebAPI> {
        return fromMaps(cast haxe.Json.parse(json));
    }*/

    private static function loadParam(params : Array<CustomWebAPIParam>, paramsByKey : Map<String, CustomWebAPIParam>, map : Map<String, Dynamic>) : Void {
        map = com.sdtk.std.Normalize.nativeToHaxe(map);
        var param : CustomWebAPIParam = new CustomWebAPIParam();
        param._name = map.get("name");
        param._value = map.get("value");
        param._comments = map.get("comments");
        params.push(param);
        paramsByKey.set(param._name, param);
    }

    private static function loadParams(params : Array<CustomWebAPIParam>, paramsByKey : Map<String, CustomWebAPIParam>, map : Map<String, Dynamic>) : Void {
        if (map != null) {
            map = com.sdtk.std.Normalize.nativeToHaxe(map);
            for (k in map.keys()) {
                loadParam(params, paramsByKey, cast map.get(k));
            }
        }
    }

    public static function fromMap(map : Map<String, Dynamic>) : CustomWebAPI {
        map = com.sdtk.std.Normalize.nativeToHaxe(map);
        var api : CustomWebAPI = new CustomWebAPI(map.get("name"));
        api._url = map.get("url");
        api._method = map.get("method");
        api._body = map.get("body");
        api._bodyType = map.get("bodyType");
        loadParams(api._headers, api._headersByKey, map.get("headers"));
        loadParams(api._cookies, api._cookiesByKey, map.get("cookies"));
        loadParams(api._query, api._queryByKey, map.get("query"));
        return api;
    }

    public static function fromMaps(map : Map<String, Dynamic>) : Map<String, CustomWebAPI> {
        var apis : Map<String, CustomWebAPI> = new Map<String, CustomWebAPI>();
        map = com.sdtk.std.Normalize.nativeToHaxe(map);
        for (k in map.keys()) {
            var api : CustomWebAPI = fromMap(cast map.get(k));
            apis.set(api._name, api);
        }
        return apis;
    }

    private static function saveParam(param : CustomWebAPIParam) : Map<String, Dynamic> {
        var map : Map<String, Dynamic> = new Map<String, Dynamic>();
        map.set("name", param._name);
        map.set("value", param._value);
        map.set("comments", param._comments);
        return map;
    }

    private static function saveParams(params : Array<CustomWebAPIParam>) : Map<String, Dynamic> {
        var map : Map<String, Dynamic> = new Map<String, Dynamic>();
        for (p in params) {
            map.set(p._name, saveParam(p));
        }
        return map;
    }

    public function toMap() : Map<String, Dynamic> {
        var map : Map<String, Dynamic> = new Map<String, Dynamic>();
        map.set("name", _name);
        map.set("url", _url);
        map.set("method", _method);
        map.set("body", _body);
        map.set("bodyType", _bodyType);
        map.set("headers", saveParams(_headers));
        map.set("cookies", saveParams(_cookies));
        map.set("query", saveParams(_query));
        return map;
    }

    private function buildString(params : Array<CustomWebAPIParam>) : String {
        var s : StringBuf = new StringBuf();
        if (params.length > 0) {
            s.add("?");
            for (p in params) {
                s.add(StringTools.urlEncode(p._name));
                s.add("=");
                s.add(StringTools.urlEncode(p._value));
                s.add("&");
            }
            var s2 : String = s.toString();
            return s2.substring(0, s2.length - 1);
        } else {
            return "";
        }
    }

    private function buildQuery() : String {
        return buildString(_query);
    }

    private function buildMap(params : Map<String, CustomWebAPIParam>) : Map<String, String> {
        var v : Map<String, String> = new Map<String, String>();
        for (k in params.keys()) {
            v.set(k, params.get(k)._value);
        }
        return v;
    }

    private function buildHeaders() : Map<String, String> {
        return buildMap(_headersByKey);
    }

    private function buildCookies() : Map<String, String> {
        return buildMap(_cookiesByKey);
    }

    public function execute(callback : String->Void) : Void {
        fetch(_method, _url, "", null, null, buildQuery(), _body, function (r) {
            callback(r);
        }, buildHeaders(), buildCookies());
    }
}

@:expose
@:nativeGen
class CustomWebAPIParam {
    public function new() { }

    public var _name : String;
    public var _value : String;
    public var _comments : String;
}
#end
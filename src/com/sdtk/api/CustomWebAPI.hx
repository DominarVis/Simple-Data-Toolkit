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
    private var _userHeader : String;
    private var _user : String;
    private var _authorizationHeader : String;
    private var _authorizationHeaderBearer : String;
    private var _keyParameter : String;
    private var _key : String;
    private var _accessToken : String;

    private function new(name : String) {
        super(name);
    }

    public static function singleFromJSON(json : String) : CustomWebAPI {
        return fromMap(cast com.sdtk.std.Normalize.parseJson(json));
    }

    public static function multipleFromJSON(json : String) : Map<String, CustomWebAPI> {
        return fromMaps(cast com.sdtk.std.Normalize.parseJson(json));
    }

    public function toJSON() : String {
        return haxe.Json.stringify(toMap());
    }

    private static function loadParam(params : Array<CustomWebAPIParam>, paramsByKey : Map<String, CustomWebAPIParam>, map : Map<String, Dynamic>) : Void {
        map = cast com.sdtk.std.Normalize.nativeToHaxe(map);
        var param : CustomWebAPIParam = new CustomWebAPIParam();
        param._name = map.get("name");
        param._value = map.get("value");
        param._comments = map.get("comments");
        params.push(param);
        paramsByKey.set(param._name, param);
    }

    private static function loadParams(params : Array<CustomWebAPIParam>, paramsByKey : Map<String, CustomWebAPIParam>, map : Map<String, Dynamic>) : Void {
        if (map != null) {
            map = cast com.sdtk.std.Normalize.nativeToHaxe(map);
            for (k in map.keys()) {
                loadParam(params, paramsByKey, cast map.get(k));
            }
        }
    }

    public static function create(name : String, url : String = null, method : String = null, body : String = null, bodyType : String = null, query : Map<String, String> = null, headers : Map<String, String> = null, cookies : Map<String, String> = null) : CustomWebAPI {
        var api : CustomWebAPI = new CustomWebAPI(name);
        if (url == null && (name.indexOf("http://") == 0 || name.indexOf("https://") == 0)) {
            api._url = name;
        } else {
            api._url = url;
        }
        if (method == null) {
            api._method = "GET";
        } else {
            api._method = method;
        }
        if (body == null) {
            api._body = null;
        } else {
            api._body = body;
        }
        if (bodyType == null) {
            api._bodyType = null;
        } else {
            api._bodyType = bodyType;
        }
        if (query != null) {
            query = cast com.sdtk.std.Normalize.nativeToHaxe(query);
            for (k in query.keys()) {
                api.addQueryParameter(k, query.get(k), "");
            }
        }
        if (headers != null) {
            headers = cast com.sdtk.std.Normalize.nativeToHaxe(headers);
            for (k in headers.keys()) {
                api.addHeader(k, headers.get(k), "");
            }
        }
        if (cookies != null) {
            cookies = cast com.sdtk.std.Normalize.nativeToHaxe(cookies);
            for (k in cookies.keys()) {
                api.addCookie(k, cookies.get(k), "");
            }
        }
        return api;
    }

    public static function fromMap(map : Map<String, Dynamic>) : CustomWebAPI {
        map = cast com.sdtk.std.Normalize.nativeToHaxe(map);
        var api : CustomWebAPI = new CustomWebAPI(map.get("name"));
        api._url = map.get("url");
        api._method = map.get("method");
        api._body = map.get("body");
        api._bodyType = map.get("bodyType");
        api._userHeader = map.get("userHeader");
        api._user = map.get("user");
        api._authorizationHeader = map.get("authorizationHeader");
        api._authorizationHeaderBearer = map.get("authorizationHeaderBearer");
        api._keyParameter = map.get("keyParameter");
        api._key = map.get("key");
        api._accessToken = map.get("accessToken");
        loadParams(api._headers, api._headersByKey, map.get("headers"));
        loadParams(api._cookies, api._cookiesByKey, map.get("cookies"));
        loadParams(api._query, api._queryByKey, map.get("query"));
        return api;
    }

    public static function fromMaps(map : Map<String, Dynamic>) : Map<String, CustomWebAPI> {
        var apis : Map<String, CustomWebAPI> = new Map<String, CustomWebAPI>();
        map = cast com.sdtk.std.Normalize.nativeToHaxe(map);
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
        map.set("userHeader", _userHeader);
        map.set("user", _user);
        map.set("authorizationHeader", _authorizationHeader);
        map.set("authorizationHeaderBearer", _authorizationHeaderBearer);
        map.set("keyParameter", _keyParameter);
        map.set("key", _key);
        map.set("accessToken", _accessToken);
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

    public function getQuery() : Array<CustomWebAPIParam> {
        return _query;
    }

    public function getQueryByKey() : Map<String, CustomWebAPIParam> {
        return _queryByKey;
    }

    public function addQueryParameter(name : String, value : String, comments : String) : Void {
        var param : CustomWebAPIParam = new CustomWebAPIParam();
        param._name = name;
        param._value = value;
        param._comments = comments;
        _query.push(param);
        _queryByKey.set(name, param);
    }

    public function getHeaders() : Array<CustomWebAPIParam> {
        return _headers;
    }

    public function getHeadersByKey() : Map<String, CustomWebAPIParam> {
        return _headersByKey;
    }

    public function addHeader(name : String, value : String, comments : String) : Void {
        var param : CustomWebAPIParam = new CustomWebAPIParam();
        param._name = name;
        param._value = value;
        param._comments = comments;
        _headers.push(param);
        _headersByKey.set(name, param);
    }

    public function getCookies() : Array<CustomWebAPIParam> {
        return _cookies;
    }

    public function getCookiesByKey() : Map<String, CustomWebAPIParam> {
        return _cookiesByKey;
    }

    public function addCookie(name : String, value : String, comments : String) : Void {
        var param : CustomWebAPIParam = new CustomWebAPIParam();
        param._name = name;
        param._value = value;
        param._comments = comments;
        _cookies.push(param);
        _cookiesByKey.set(name, param);
    }

    public function getBody() : String {
        return _body;
    }

    public function setBody(body : String) : Void {
        _body = body;
    }

    public function getBodyType() : String {
        return _bodyType;
    }

    public function setBodyType(bodyType : String) : Void {
        _bodyType = bodyType;
    }

    public function getUrl() : String {
        return _url;
    }

    public function setUrl(url : String) : Void {
        _url = url;
    }

    public function getMethod() : String {
        return _method;
    }

    public function setMethod(method : String) : Void {
        _method = method;
    }

    public function setLogin(user : String, password : String) : Void {
        _userHeader = null;
        _user = user;
        _accessToken = password;
    }

    public function setUserHeader(userHeader : String, user : String) : Void {
        _userHeader = userHeader;
        _user = user;
    }

    public function setAccessToken(header : String, accessToken : String, bearer : String = "") : Void {
        _accessToken = accessToken;
        _authorizationHeader = header;
        _authorizationHeaderBearer = bearer;
    }

    public function setKeyParameter(parameter : String, key : String) : Void {
        _keyParameter = parameter;
        _key = key;
    }

    private override function getUserHeader() : String {
        return _userHeader;
    }

    private override function getUser() : String {
        return _user;
    }

    private override function getAuthorizationHeader() : String {
        return _authorizationHeader;
    }

    private override function getAuthorizationHeaderBearer() : String {
        return _authorizationHeaderBearer;
    }

    private override function getKeyParameter() : String {
        return _keyParameter;
    }

    private override function getKey() : String {
        return _key;
    }

    private override function getAccessToken() : String {
        return _accessToken;
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
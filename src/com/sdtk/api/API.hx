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

import haxe.Http;

#if !EXCLUDE_APIS
@:nativeGen
class API {
    private var _inited : Bool;
    private var _progress : APILoadProgress = null;
    private var _name : String;

    public function new(name : String) {
        _name = name;
    }

    public function name() : String {
        return _name;
    }

    public function fetch(method : String, root : String, api : String, key : Null<Bool>, accessToken : Null<Bool>, query : String, body : Null<String>, callback : Dynamic->Void, ?headers : Map<String, String> = null, ?cookies : Map<String, String> = null) : Void {
        if (query == null) {
            query = "";
        }
        if (key == null) {
            key = (getKey() != null);
        }
        if (accessToken == null) {
            accessToken = (getAccessToken() != null && getAuthorizationHeader() != null);
        }
        var cookieToSend : StringBuf = null;
        if (cookies != null) {
            cookieToSend = new StringBuf();
            for (c in cookies.keys()) {
                cookieToSend.add(c);
                cookieToSend.add("=");
                cookieToSend.add(cookies.get(c));
                cookieToSend.add("; ");
            }
        }
        var url : String = "https://" + root + "/" + api + query + (key ? (query == "" ? "?" : "&") + getKeyParameter() + "=" + getKey() : "");
        #if JS_BROWSER
            var xhr : js.html.XMLHttpRequest = new js.html.XMLHttpRequest("");
            xhr.withCredentials = true;
            xhr.onreadystatechange = function () : Void {
                if (xhr.readyState != js.html.XMLHttpRequest.DONE) {
                    return;
                }
                callback(xhr.responseText);
            };
            xhr.open(method, url);
            if (accessToken) {
                xhr.setRequestHeader(getAuthorizationHeader(), getAuthorizationHeaderBearer() + getAccessToken());
            }
            if (getUserHeader() != null) {
                xhr.setRequestHeader(getUserHeader(), getUser());
            }
            if (headers != null) {
                for (header in headers.keys()) {
                    xhr.setRequestHeader(header, headers.get(header));
                }
            }
            if (cookieToSend != null) {
                xhr.setRequestHeader("Cookie", cookieToSend.toString());
            }
            if (getUser() != null && getUserHeader() == null && getAccessToken() != null) {
                xhr.setRequestHeader('Authorization', 'Basic ' + js.Syntax.code("btoa({0})", getUser() + ':' + getAccessToken()));
            }
            xhr.send(body);
        #elseif python
            python.Syntax.code("import urllib.request");
            python.Syntax.code("import urllib.parse");
            python.Syntax.code("import ssl");
            var h : Dynamic = cast python.Syntax.code("{{}}");
            python.Syntax.code("{0}[\"User-Agent\"] = {1}", h, "SimpleData-Toolkit");
            if (accessToken) {
                python.Syntax.code("{0}[{1}] = {2}", h, getAuthorizationHeader(), getAuthorizationHeaderBearer() + getAccessToken());
            }
            if (getUserHeader() != null) {
                h.set(getUserHeader(), getUser());
            }
            if (body != null && body.indexOf("--divider--sdtk--") >= 0) {
                python.Syntax.code("{0}[{1}] = {2}", h, "Content-Type", "multipart/related; boundary=--divider--sdtk--");
            }
            if (body != null) {
                // TODO - Remove?
                //body = cast python.Syntax.code("urllib.parse.urlencode({0})", body);
                body = cast python.Syntax.code("{0}.encode('utf-8')", body);
            }
            if (headers != null) {
                for (header in headers.keys()) {
                    python.Syntax.code("{0}[{1}] = {2}", h, header, headers.get(header));
                }
            }
            if (cookieToSend != null) {
                python.Syntax.code("{0}[{1}] = {2}", h, "Cookie", cookieToSend.toString());
            }
            var context : Dynamic = python.Syntax.code("ssl._create_unverified_context()");

            if (getUser() != null && getUserHeader() == null && getAccessToken() != null) {
                var passwordManager : Dynamic = cast python.Syntax.code("urllib.request.HTTPPasswordMgrWithDefaultRealm()");
                python.Syntax.code("{0}.add_password(None, {1}, {2}, {3})", passwordManager, url, this.getUser(), this.getAccessToken());
                var authHandler : Dynamic = cast python.Syntax.code("urllib.request.HTTPBasicAuthHandler({0})", passwordManager);
                var opener : Dynamic = cast python.Syntax.code("urllib.request.build_opener(authHandler)");
                python.Syntax.code("urllib.request.install_opener({0})", opener);
            }

            var r : Dynamic = python.Syntax.code("urllib.request.urlopen(urllib.request.Request({0}, method={1}, data={2}, headers={3}), context={4})", url, method, body, h, context);
            var d : String = python.Syntax.code("{0}.read()", r);
            var encoding : Dynamic = python.Syntax.code("{0}.info().get_content_charset('utf-8')", r);
            d = cast python.Syntax.code("{0}.decode({1})", d, encoding);
            callback(d);
        #elseif JS_WSH
            var xhr : Dynamic = cast js.Syntax.code("new ActiveXObject('Microsoft.XMLHTTP')"); // new ActiveXObject("MSXML2.ServerXMLHTTP.6.0");
            js.Syntax.code("{0}.open({1}, {2}, false)", xhr, method, url);
            js.Syntax.code("{0}.setRequestHeader({1}, {2})", xhr, "User-Agent", "SimpleData-Toolkit");
            if (accessToken) {
                js.Syntax.code("{0}.setRequestHeader({1}, {2})", xhr, getAuthorizationHeader(), getAuthorizationHeaderBearer() + getAccessToken());
            }
            if (getUserHeader() != null) {
                js.Syntax.code("{0}.setRequestHeader({1}, {2})", xhr, getUserHeader(), getUser());
            }
            if (body != null) {
                js.Syntax.code("{0}.send({1})", xhr, body);
            } else {
                js.Syntax.code("{0}.send()", xhr);
            }
            if (headers != null) {
                for (header in headers.keys()) {
                    js.Syntax.code("{0}.setRequestHeader({1}, {2})", xhr, header, headers.get(header));
                }
            }
            if (cookieToSend != null) {
                js.Syntax.code("{0}.setRequestHeader({1}, {2})", xhr, "Cookie", cookieToSend.toString());
            }
            if (getUser() != null && getUserHeader() == null && getAccessToken() != null) {
                js.Syntax.code("{0}.setRequestHeader('Authorization', 'Basic ' + btoa{1})", xhr, getUser() + ':' + getAccessToken());
            }
            callback(js.Syntax.code("{0}.responseText", xhr));
        #elseif php
            var ch : Dynamic = php.Syntax.code("curl_init()");
            var headers : Dynamic = php.Syntax.code("array()");
            php.Syntax.code("array_push({0}, {1})", headers, "User-Agent: SimpleData-Toolkit");
            php.Syntax.code("curl_setopt({0}, CURLOPT_URL, {1})", ch, url);
            switch (method) {
                case "POST":
                    php.Syntax.code("curl_setopt({0}, CURLOPT_POST, 1)", ch);
                case "DELETE", "PUT", "PATCH", "GET":
                    php.Syntax.code("curl_setopt({0}, CURLOPT_CUSTOMREQUEST, {1})", ch, method);
            }
            switch (method) {
                case "POST", "PUT", "PATCH":
                    php.Syntax.code("curl_setopt({0}, CURLOPT_POSTFIELDS, {1})", ch, body);
            }
            if (accessToken) {
                php.Syntax.code("array_push({0}, {1})", headers, "" + getAuthorizationHeader() + ":" + getAuthorizationHeaderBearer() + getAccessToken());
            }
            if (getUserHeader() != null) {
                php.Syntax.code("array_push({0}, {1})", headers, "" + getUserHeader() + ":" + getUser());
            }
            if (body != null && body.indexOf("--divider--sdtk--") >= 0) {
                php.Syntax.code("array_push({0}, {1})", headers, "Content-Type: multipart/related; boundary=--divider--sdtk--");
            }
            if (headers != null) {
                for (header in headers.keys()) {
                    php.Syntax.code("array_push({0}, {1})", headers, "" + header + ":" + headers.get(header));
                }
            }
            if (cookieToSend != null) {
                php.Syntax.code("curl_setopt({0}, CURLOPT_COOKIE, {1})", ch, cookieToSend.toString());
            }
            if (getUser() != null && getUserHeader() == null && getAccessToken() != null) {
                php.Syntax.code("curl_setopt({0}, CURLOPT_HTTPAUTH, CURLAUTH_BASIC)", ch);
                php.Syntax.code("curl_setopt({0}, CURLOPT_USERPWD, {1})", ch, getUser() + ":" + getAccessToken());
            }
            php.Syntax.code("curl_setopt({0}, CURLOPT_HTTPHEADER, {1})", ch, headers);
            php.Syntax.code("curl_setopt({0}, CURLOPT_RETURNTRANSFER, true)", ch);
            php.Syntax.code("curl_setopt({0}, CURLOPT_SSL_VERIFYHOST, false)", ch);
            php.Syntax.code("curl_setopt({0}, CURLOPT_SSL_VERIFYPEER, false)", ch);
            var data : Dynamic = php.Syntax.code("curl_exec({0})", ch);
            php.Syntax.code("curl_close({0})", ch);
            callback(data);
        #else
            var http : haxe.Http = new Http(url);

            http.setHeader("User-Agent", "SimpleData-Toolkit");
            if (accessToken) {
                http.setHeader(getAuthorizationHeader(), getAuthorizationHeaderBearer() + getAccessToken());
            }
            if (getUserHeader() != null) {
                http.setHeader(getUserHeader(), getUser());
            }
            if (headers != null) {
                for (header in headers.keys()) {
                    http.setHeader(header, headers.get(header));
                }
            }
            if (cookieToSend != null) {
                http.setHeader("Cookie", cookieToSend.toString());
            }
            if (getUser() != null && getUserHeader() == null && getAccessToken() != null) {
                http.setHeader('Authorization', 'Basic ' + haxe.crypto.Base64.encode(getUser() + ':' + getAccessToken()));
            }
            switch (method) {
                case "GET":
                    http.request();
                    callback(http.responseData);
                case "DELETE":
                    var responseBytes = new haxe.io.BytesOutput();
                    http.customRequest(true, responseBytes, method);
                    var response = responseBytes.getBytes();
                    callback(response);
                case "POST", "PATCH", "PUT":
                    var responseBytes = new haxe.io.BytesOutput();
                    http.setPostData(body);
                    http.customRequest(true, responseBytes, method);
                    var response = responseBytes.getBytes();
                    callback(response);
            }
        #end
    }

    private function normalizeMapping(mapping : Map<String, String>) : Map<String, String> {
        return cast com.sdtk.std.Normalize.haxeMapValuesToStrings(cast com.sdtk.std.Normalize.nativeToHaxe(mapping));
    }

    private function getUserHeader() : String {
        return null;
    }

    private function getUser() : String {
        return null;
    }

    private function getAuthorizationHeader() : String {
        return "Authorization";
    }

    private function getAuthorizationHeaderBearer() : String {
        return "Bearer ";
    }

    private function getKeyParameter() : String {
        return "key";
    }

    private function getKey() : String {
        return null;
    }

    private function getAccessToken() : String {
        return null;
    }

    private function load(file : String, callback : Void->Void) : Void {
        if (_progress == null) {
            _progress = new APILoadProgress();
        }
        _progress._files.push(file);
        #if JS_BROWSER
            var e : Dynamic = js.Browser.document.createElement("script");
            e.setAttribute("async", "");
            e.setAttribute("defer", "");
            e.setAttribute("src", file);
            e.onload = function () : Void {
                _progress._done++;
                if (_progress._done >= _progress._files.length) {
                    callback();
                }
            };
            js.Browser.document.head.appendChild(e);
        #end
    }

    private function requireAPI(api : API, callback : Void->Void) : Void {
        api.requireInit(callback);
    }

    private function startInit(callback : Void->Void) : Void {
        callback();
    }

    private function requireInit(callback : Void->Void) : Void {
        if (_inited) {
            callback();
        } else {
            startInit(function () : Void {
                _progress = null;
                _inited = true;
                callback();
            });
        }
    }

    public function parse(value : String) : InputAPI {
        return null;
    }

    private static function findEndOfTag(data : String, tag : Int) : Int {
        var check : Array<Int> = new Array<Int>();
        var search : String -> Void = function (c : String) : Void {
            var r : Int = data.indexOf(c, tag);
            if (r >= 0) {
                check.push(r);
            }
        }
        search(">");
        search(" ");
        search("\t");
        search("\n");
        search("\r");  

        check.sort(function (a : Int, b : Int) : Int {
            return a - b;
        });

        return check[0] - 1;
    }

    private function findElementsByClass(data : String, tags : Array<String>, c : String, includeTagInResults : Bool = false, includeBodyInResults : Bool = true) : Array<String> {
        var check : Array<Int> = new Array<Int>();
        var results : Array<String> = new Array<String>();

        for (tag in tags) {
            var i : Int = 0;
            while (true) {
                i = data.indexOf("<" + tag, i);
                if (i < 0) {
                    break;
                }
                check.push(i);
                i++;
            }
        }
        
        for (tagToCheck in check) {
            var myTag : String = data.substring(tagToCheck + 1, findEndOfTag(data, tagToCheck) + 1);
            var endOfTag : Int = data.indexOf(">", tagToCheck);
            if (c != null) {
                var startOfClass : Int = data.indexOf("class=", tagToCheck);
                if (startOfClass < 0 || startOfClass > endOfTag) {
                    continue;
                }
                var endOfClass : Int = data.indexOf("\"", startOfClass + 7);
                var endOfClass2 : Int = data.indexOf("\'", startOfClass + 7);
                if (endOfClass2 >= 0 && endOfClass2 < endOfClass) {
                    endOfClass = endOfClass2;
                }
                if (endOfClass < 0 || endOfClass > endOfTag) {
                    continue;
                }
                var indexOfC : Int = data.indexOf(c, startOfClass + 7);
                if (indexOfC < 0 || indexOfC > endOfClass) {
                    continue;
                }
                var beforeClass : String = data.charAt(indexOfC - 1);
                var afterClass : String = data.charAt(indexOfC + c.length);
                switch (beforeClass) {
                    case " ", "\"", "'", "\t":
                    default:
                        continue;
                }
                switch (afterClass) {
                    case " ", "\"", "'", "\t", "=":
                    default:
                        continue;
                }
            }
            var endOfData : Int = data.indexOf("</" + myTag + ">", endOfTag);
            var nestedSearch : Int = endOfTag;
            while (true) {
                if (endOfData < 0) {
                    break;
                }
                var nested : Int = data.indexOf("<" + myTag, nestedSearch);
                if (nested > 0 && endOfData > nested) {
                    nestedSearch = nested + myTag.length + 2;
                    var possibleEnd : Int = data.indexOf("</" + myTag, endOfData + 1);
                    if (possibleEnd > 0) {
                        endOfData = possibleEnd;
                    }
                } else {
                    if (includeTagInResults) {
                        results.push(data.substring(tagToCheck, endOfTag));
                    }
                    if (includeBodyInResults) {
                        results.push(data.substring(endOfTag + 1, endOfData));
                    }
                    break;
                }
            }
        }

        return results;
    }
}

@:nativeGen
class APILoadProgress {
    public var _files : Array<String>;
    public var _done : Int = 0;

    public function new() {
        _files = new Array<String>();
    }
}
#end
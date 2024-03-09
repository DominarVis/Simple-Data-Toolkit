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
class OrtingoAPI extends API {
    private static var _ortingoRoot : String = "ortingo.com";
    private static var _postsAPI : String = "users/";

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

    public static function posts(callback : Dynamic->Void, owner : String, privateData : Null<Bool>) : Void {
        instance().fetch("GET", _ortingoRoot, _postsAPI, null, null, owner + (privateData == true ? "/private" : ""), null, function (r) {
            callback(r);
        });
    }

    public static function suggestions(callback : Dynamic->Void, query : String) : Void {
        instance().fetch("GET", _ortingoRoot, "handlers/dom-triggered/suggestions?", null, null, "q=" + StringTools.urlEncode(query), null, function (r) {
            callback(r);
        });
    }

    public static function comments(callback : Dynamic->Void, owner : String, privateData : Null<Bool>, id : String) : Void {
        instance().fetch("GET", _ortingoRoot, _postsAPI, null, null, owner + (privateData == true ? "/private" : "") + "/" + id, null, function (r) {
            callback(r);
        });
    }

    public static function postsAPI() : InputAPI {
        return OrtingoAPIPosts.instance();
    }

    public static function suggestionsAPI() : InputAPI {
        return OrtingoAPISuggestions.instance();
    }

    public static function commentsAPI() : InputAPI {
        return OrtingoAPIComments.instance();
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
        return ["owner", "private"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        var privateData : Null<Bool> = false;
        if (mapping["private"] == null) {
            privateData = false;
        } else {
            switch (StringTools.trim(mapping["private"]).charAt(0).toUpperCase()) {
                case "T", "Y", "1":
                    privateData = true;
                case "F", "N", "0":
                    privateData = false;
            }
        }
        OrtingoAPI.posts(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, cast mapping["owner"], privateData);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        var map : Array<Map<String, String>> = new Array<Map<String, String>>();
        var posts : Array<String> = findElementsByClass(data, ["a"], "item", true);
        var tag : Bool = true;
        var url : String = null;
        var id : String = null;
        var owner : String = null;
        for (post in posts) {
            if (tag) {
                var href : Int = post.indexOf("href=");
                if (href >= 0) {
                    href += 6;
                    var endOfHref1 : Int = post.indexOf("\"", href);
                    var endOfHref2 : Int = post.indexOf("\'", href);
                    var endOfHref : Int;
                    endOfHref1 = endOfHref1 < 0 ? post.length : endOfHref1;
                    endOfHref2 = endOfHref2 < 0 ? post.length : endOfHref2;
                    endOfHref = endOfHref1 < endOfHref2 ? endOfHref1 : endOfHref2;
                    url = post.substring(href, endOfHref);
                    id = url.substring(url.lastIndexOf("/") + 1);
                    owner = url.substring(url.lastIndexOf("/", url.lastIndexOf("/") - 1));
                }
            } else {
                var postMap : Map<String, String> = new Map<String, String>();
                postMap.set("post", findElementsByClass(post, ["span"], "post")[0]);
                postMap.set("title", findElementsByClass(post, ["span"], "title")[0]);
                postMap.set("subtitle", findElementsByClass(post, ["span"], "subtitle")[0]);
                postMap.set("url", url);
                postMap.set("id", id);
                postMap.set("owner", owner);
                if (postMap.get("post") == null) {
                    continue;
                }
                url = null;
                id = null;
                owner = null;
                map.push(postMap);
            }
            tag = !tag;
        }
        callback(data, com.sdtk.table.ArrayOfMapsReader.readWholeArray(map));
    }
}

@:nativeGen
class OrtingoAPISuggestions extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Cloud - Ortingo - Suggestions");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new OrtingoAPISuggestions();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["query"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        OrtingoAPI.suggestions(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, cast mapping["query"]);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        var map : Array<Map<String, String>> = new Array<Map<String, String>>();
        var posts : Array<String> = findElementsByClass(data, ["a"], "item", true);
        var tag : Bool = true;
        var url : String = null;
        var id : String = null;
        var owner : String = null;
        for (post in posts) {
            if (tag) {
                var href : Int = post.indexOf("href=");
                if (href >= 0) {
                    href += 6;
                    var endOfHref1 : Int = post.indexOf("\"", href);
                    var endOfHref2 : Int = post.indexOf("\'", href);
                    var endOfHref : Int;
                    endOfHref1 = endOfHref1 < 0 ? post.length : endOfHref1;
                    endOfHref2 = endOfHref2 < 0 ? post.length : endOfHref2;
                    endOfHref = endOfHref1 < endOfHref2 ? endOfHref1 : endOfHref2;
                    url = post.substring(href, endOfHref);
                    id = url.substring(url.lastIndexOf("/") + 1);
                    owner = url.substring(url.lastIndexOf("/", url.lastIndexOf("/") - 1));
                }
            } else {
                var postMap : Map<String, String> = new Map<String, String>();
                postMap.set("post", findElementsByClass(post, ["span"], "description")[0]);
                postMap.set("title", findElementsByClass(post, ["span"], "title")[0]);
                postMap.set("subtitle", findElementsByClass(post, ["span"], "subtitle")[0]);
                postMap.set("url", url);
                postMap.set("id", id);
                postMap.set("owner", owner);
                url = null;
                id = null;
                owner = null;
                map.push(postMap);
            }
            tag = !tag;
        }
        callback(data, com.sdtk.table.ArrayOfMapsReader.readWholeArray(map));
    }    
}

@:nativeGen
class OrtingoAPIComments extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Cloud - Ortingo - Comments");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new OrtingoAPIComments();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["owner", "private", "id"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        var privateData : Null<Bool> = false;
        if (mapping["private"] == null) {
            privateData = false;
        } else {
            switch (StringTools.trim(mapping["private"]).charAt(0).toUpperCase()) {
                case "T", "Y", "1":
                    privateData = true;
                case "F", "N", "0":
                    privateData = false;
            }
        }
        OrtingoAPI.comments(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, cast mapping["owner"], privateData, cast mapping["id"]);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        var map : Array<Map<String, String>> = new Array<Map<String, String>>();
        var posts : Array<String> = findElementsByClass(data, ["div"], "comment", true);
        var tag : Bool = true;
        var id : String = null;
        for (post in posts) {
            if (tag) {
                var idStart : Int = post.indexOf("id=");
                if (idStart >= 0) {
                    idStart += 4;
                    var endOfId1 : Int = post.indexOf("\"", idStart);
                    var endOfId2 : Int = post.indexOf("\'", idStart);
                    var endOfId : Int;
                    endOfId1 = endOfId1 < 0 ? post.length : endOfId1;
                    endOfId2 = endOfId2 < 0 ? post.length : endOfId2;
                    endOfId = endOfId1 < endOfId2 ? endOfId1 : endOfId2;
                    id = post.substring(idStart, endOfId);
                }
            } else {
                var postMap : Map<String, String> = new Map<String, String>();
                var replyTo : String = null;
                var links : Array<String> = findElementsByClass(post, ["a"], null, true);
                if (links.length > 2) {
                    replyTo = links[2];
                    var end : Int = replyTo.lastIndexOf("/");
                    var start : Int = replyTo.lastIndexOf("/", end - 1);
                    replyTo = replyTo.substring(start + 1, end);
                }
                postMap.set("post", findElementsByClass(post, ["p"], null)[0]);
                postMap.set("owner", findElementsByClass(post, ["span"], "commenter_profile_link")[0]);
                postMap.set("id", id);
                postMap.set("replyTo", replyTo);
                postMap.set("commentDate", findElementsByClass(post, ["h5"], null)[0]);
                id = null;
                map.push(postMap);
            }
            tag = !tag;
        }
        callback(data, com.sdtk.table.ArrayOfMapsReader.readWholeArray(map));
    }    
}
#end
/*
TODO

Cookie: session_id=PMZXA6Z5ACS3J4AY.60CQ59FN46SVQFXJ


To Comment:
https://ortingo.com/users/60CQ59FN46SVQFXJ/test
comment: Test
submit_comment: Leave comment

To delete:
https://ortingo.com/users/60CQ59FN46SVQFXJ/private/
item_name: test.php
item_size: 175
delete_item: Delete


To post:
https://ortingo.com/create?path=/simple-data-toolkit-tutorial-ieee-events-api-python

path: /simple-data-toolkit-tutorial-ieee-events-api-python
title: Simple Data Toolkit - Tutorial - IEEE Events API - Python
subtitle: 
post: Simple Data Toolkit provides an unofficial API for reading events from the IEEE API.   (At the time of this writing, the release of this is pending for complete support, but it is coming soon)

files[]: (binary)
confirm: Save post


To post:
https://ortingo.com/create?path=/private&ref=nnb

path: /private
ref: nnb
title: Test 123
subtitle: Test 123
post: Test 123
files[]: (binary)
confirm: Save note
*/
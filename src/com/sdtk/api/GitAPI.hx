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
class GitAPI extends API {
    private static var _gitRoot : String = "api.github.com";
    private static var _reposAPI : String = "repos";
    private static var _usersAPI : String = "users";
    private static var _instance : GitAPI;
    private static var _apiKey : String = null;
    private static var _user : String = null;

    private function new() {
        super("Git");
    }

    public static function instance() : GitAPI {
        if (_instance == null) {
            _instance = new GitAPI();
        }
        return _instance;
    }

    public function files(callback : Dynamic->Void, owner : String, repo : String, ?branch : String = "main", ?recursive : Int = 1) : Void {
        try {
            fetch("GET", _gitRoot, _reposAPI, null, null, "/" + owner + "/" + repo + "/git/trees/" + branch + "?recursive=" + recursive, null, callback);
        } catch (ex : Any) {
            if (branch == "main") {
                files(callback, owner, repo, "master", recursive);
            }
        }
    }

    public function filesAPI() : InputAPI {
        return GitAPIFiles.instance();
    }    

    public function repos(callback : Dynamic->Void, owner : String) : Void {
        fetch("GET", _gitRoot, _usersAPI, null, null, "/" + owner + "/repos", null, callback);
    }

    public function reposAPI() : InputAPI {
        return GitAPIRepos.instance();
    }        

    public function branches(callback : Dynamic->Void, owner : String, repo : String) : Void {
        fetch("GET", _gitRoot, _reposAPI, null, null, "/" + owner + "/" + repo + "/branches", null, callback);
    }

    public function branchesAPI() : InputAPI {
        return GitAPIBranches.instance();
    }            

    public function commits(callback : Dynamic->Void, owner : String, repo : String, ?branch : String = "main") : Void {
        if (branch == "main" || branch == "master") {
            fetch("GET", _gitRoot, _reposAPI, null, null, "/" + owner + "/" + repo + "/commits", null, callback);
        } else {
            branches(function (r : Dynamic) : Void {
                var sha : String = null;
                var arr : Array<Dynamic> = cast r;
                for (branch in arr) {
                    if (branch.name == branch) {
                        sha = branch.commit.sha;
                    }
                }
                fetch("GET", _gitRoot, _reposAPI, null, null, "/" + owner + "/" + repo + "/commits?sha=" + sha, null, callback);
            }, owner, repo);
        }
    }    

    public function commitsAPI() : InputAPI {
        return GitAPICommits.instance();
    }

    public function retrieve(callback : Dynamic->Dynamic->Void, owner : String, repo : String, path : String, ?tag : String = "main") : Void {
        try {
            fetch("GET", _gitRoot, _reposAPI, null, null, "/" + owner + "/" + repo + "/contents/" + path + (tag != null ? "?ref=" + tag : ""), null, function (r : Dynamic) {
                function base64ToSomething(b64) : Dynamic{
                    try {
                        #if js
                            return js.Browser.window.atob(b64);
                        #elseif python
                            python.Syntax.code("import base64");
                            python.Syntax.code("return base64.b64decode({0})", b64);
                        #else
                            return haxe.crypto.Base64.decode(b64);
                        #end
                    } catch (e : Any) {
                        #if js
                            if (js.Syntax.code("{0}.code", e) == js.Syntax.code("DOMException.INVALID_CHARACTER_ERR")) {
                                var byteString = js.Browser.window.atob(b64);
                                var byteArray = new js.lib.Uint8Array(byteString.length);
                                var i : Int = 0;
                                while (i < byteString.length) {
                                    byteArray[i] = byteString.charCodeAt(i);
                                    i++;
                                }

                                return byteArray;
                            }
                        #else
                        #end
                    }
                    return null;
                }
                r = haxe.Json.parse(cast r);
                callback(base64ToSomething(r.content), {
                    //r.content, {
                    name: r.name,
                    path: r.path,
                    sha: r.sha,
                    size: r.size,
                    url: r.url,
                    html_url: r.html_url,
                    git_url: r.git_url,
                    download_url: r.download_url,
                    type: r.type,
                    encoding: r.encoding,
                    _links: r._links,
                });
            });
        } catch (ex : Any) {
            if (tag == "main") {
                retrieve(callback, owner, repo, path, "master");
            }
        }
    }

    public function retrieveAPI() : InputAPI {
        return GitAPIRetrieve.instance();
    } 
    
    private override function getUserHeader() : String {
        if (_user == null) {
            return null;
        } else {
            return "Username";
        }
    }

    private override function getUser() : String {
        return _user;
    }

    private override function getAuthorizationHeader() : String {
        if (_apiKey == null) {
            return null;
        } else if (_apiKey.indexOf("github_pat_") == 0) {
            return "Password";
        } else {
            return "Authorization";
        }
    }

    private override function getAuthorizationHeaderBearer() : String {
        if (_apiKey == null) {
            return null;
        } else if (_apiKey.indexOf("github_pat_") == 0) {
            return "";
        } else {
            return "token ";
        }
    }

    private override function getAccessToken() : String {
        return _apiKey;
    }

    public function setKey(key : String) : Void {
        _apiKey = key;
    }
    
    public function setUser(user : String) : Void {
        _user = user;
    }

    public override function parse(value : String) : InputAPI {
        var mapping : Map<String, String> = new Map<String, String>();
        var parts1 : Array<String> = value.split(":");
        switch (parts1[0]) {
            case "https":
                var parts2 : Array<String> = value.split("/");
                switch (parts2.length) {
                    case 5:
                        mapping.set("owner", parts2[3]);
                        mapping.set("repo", parts2[4].split(".")[0]);
                        return GitAPIRetrieveAll.instance().wrapWithMapping(mapping);
                    case 8:
                        var fileParts : Array<String> = parts2[7].split("?");
                        mapping.set("owner", parts2[4]);
                        mapping.set("repo", parts2[5]);
                        mapping.set("path", fileParts[0]);
                        if (fileParts.length > 1) {
                            mapping.set("branch", fileParts[1].split("=")[1]);
                        }
                        return GitAPIRetrieveAll.instance().wrapWithMapping(mapping);
                    case 9:
                        // TODO
                        // Example - https://api.github.com/repos/Vis-LLC/Restricted-Roller/git/blobs/e91fab7ab6677d3b435373de6340cc46c31ca67f
                }
            case "x-github-client":
                var parts2 : Array<String> = value.split("/");
                mapping.set("owner", parts2[6]);
                mapping.set("repo", parts2[7]);
                return GitAPIRetrieveAll.instance().wrapWithMapping(mapping);
            case "git-client":
                var parts2 : Array<String> = StringTools.urlDecode(value.split("=")[1]).split("/");
                mapping.set("owner", parts2[3]);
                mapping.set("repo", parts2[4]);
                return GitAPIRetrieveAll.instance().wrapWithMapping(mapping);
        }

        return null;
    }
}

@:nativeGen
class GitAPIFiles extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Version Control System - GitHub - Files");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new GitAPIFiles();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["owner", "repo", "branch"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        GitAPI.instance().files(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, cast mapping["owner"], cast mapping["repo"], cast mapping["branch"]);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        callback(data, com.sdtk.table.ArrayOfObjectsReader.readWholeArray(haxe.Json.parse(data).tree));
    }    

    public override function externalKey() : String {
        return "path";
    }

    public override function externalValue() : String {
        return "url";
    }
}

@:nativeGen
class GitAPIRepos extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Version Control System - GitHub - Repo");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new GitAPIRepos();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["owner"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        GitAPI.instance().repos(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, cast mapping["owner"]);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        callback(data, com.sdtk.table.ArrayOfObjectsReader.readWholeArray(haxe.Json.parse(data)));
    }    
}

@:nativeGen
class GitAPIBranches extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Version Control System - GitHub - Branches");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new GitAPIBranches();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["owner", "repo"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        GitAPI.instance().branches(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, cast mapping["owner"], cast mapping["repo"]);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        var arr : Array<Dynamic> = haxe.Json.parse(data);
        for (o in arr) {
            o.commit_url = o.commit.url;
            o.commit = o.commit.sha;
        }
        callback(data, com.sdtk.table.ArrayOfObjectsReader.readWholeArrayI(cast arr));
    }    
}

@:nativeGen
class GitAPICommits extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Version Control System - GitHub - Commits");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new GitAPICommits();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["owner", "repo", "branch"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        GitAPI.instance().commits(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, cast mapping["owner"], cast mapping["repo"], cast mapping["branch"]);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        var arr : Array<Dynamic> = haxe.Json.parse(data);
        for (o in arr) {
            o.author = o.author.login;
            o.author_email = o.commit.author.email;
            o.comment_count = o.commit.comment_count;
            o.commit_message = o.commit.message;
            o.date = o.commit.date;
            o.committer = o.committer.login;
            o.committer_email = o.commit.committer.email;
            o.commit = o.commit.url;
            var parentsI : Array<Dynamic> = cast o.parents;
            var parents : Array<String> = new Array<String>();
            for (parent in parentsI) {
                parents.push(parent.sha);
            }
            o.parents = parents.join(",");
        }
        callback(data, com.sdtk.table.ArrayOfObjectsReader.readWholeArrayI(cast arr));
    }
}

@:nativeGen
class GitAPIRetrieve extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Version Control System - GitHub - Retrieve");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new GitAPIRetrieve();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["owner", "repo", "branch", "path", "format"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        GitAPI.instance().retrieve(function (r : Dynamic, info : Dynamic) {
            parseData(r, mapping, callback);
        }, cast mapping["owner"], cast mapping["repo"], cast mapping["path"], cast mapping["branch"]);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        callback(data, null);
    }    

    public override function externalKey() : String {
        return "name";
    }

    public override function externalValue() : String {
        return "content";
    }
}

@:nativeGen
class GitAPIRetrieveAll extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Version Control System - GitHub - RetrieveAll");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new GitAPIRetrieveAll();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["owner", "repo", "branch"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        GitAPI.instance().files(function (r : Dynamic) {
            var arr : Array<haxe.DynamicAccess<Dynamic>> = cast haxe.Json.parse(cast r).tree;
            var result : Map<String, Dynamic> = new Map<String, Dynamic>();
            var next : Void->Void;
            var i : Int = -1;
            next = function () : Void {
                i++;
                if (i >= arr.length) {
                    callback(null, com.sdtk.table.MapReader.readWholeMap(result));
                    return;
                } else {
                    GitAPI.instance().retrieve(function (r : Dynamic, info : Dynamic) {
                        result.set(arr[i].get(GitAPIFiles.instance().externalKey()), r);
                        next();
                    }, cast mapping["owner"], cast mapping["repo"], arr[i].get(GitAPIFiles.instance().externalKey()), cast mapping["branch"]);
                }
            };
            next();
        }, cast mapping["owner"], cast mapping["repo"], cast mapping["branch"]);
    } 

    public override function externalKey() : String {
        return "name";
    }

    public override function externalValue() : String {
        return "content";
    }
}
#end
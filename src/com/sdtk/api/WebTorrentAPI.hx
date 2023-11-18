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

#if(!EXCLUDE_APIS && JS_BROWSER)
@:nativeGen
class WebTorrentAPI extends API {
    private static var _instance : WebTorrentAPI;
    private var _client : Dynamic;

    private function new() {
        super("WebTorrent");
    }

    public static function instance() : WebTorrentAPI {
        if (_instance == null) {
            _instance = new WebTorrentAPI();
        }
        return _instance;
    }

    private override function startInit(callback : Void->Void) : Void {
        load((js.Browser.document.location.protocol.toLowerCase().indexOf("file") == 0 ? "" : "/") + "webtorrent.min.js", function () {
            _client = js.Syntax.code("new WebTorrent()");
            callback();
        });
    }       

    public static function download(callback : Dynamic->Void, torrentId : String, ?file : String = null) : Void {
        instance().requireInit(function () : Void {
            instance()._client.add(torrentId, function (torrent : Dynamic) : Void {
                if (file != null) {
                    torrent.files.find(function (f) {
                        return f == file;
                    }).getBuffer(function (err, buffer) : Void{
                        callback(buffer);
                    });
                } else {
                    callback(torrent);
                }
            });
        });
    }

    public static function upload(callback : Dynamic->Void, name : String, body : String) : Void {
        instance().requireInit(function () : Void {
            instance()._client.seed(js.Syntax.code("new File([{0}], {1})", body, name), function (torrent : Dynamic) : Void {
                callback(torrent.magnetURI);
            });
        });
    }

    public static function filesAPI() : InputAPI {
        return WebTorrentAPIFiles.instance();
    }

    public static function retrieveAPI() : InputAPI {
        return WebTorrentAPIRetrieve.instance();
    }    
}

@:nativeGen
class WebTorrentAPIFiles extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Cloud - WebTorrent - Files");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new WebTorrentAPIFiles();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["torrentId"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        WebTorrentAPI.download(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, cast mapping["torrentId"], null);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        // TODO
        callback(null, null);
    }    
}

@:nativeGen
class WebTorrentAPIRetrieve extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Cloud - WebTorrent - Retrieve");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new WebTorrentAPIRetrieve();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["torrentId", "file"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        WebTorrentAPI.download(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, cast mapping["torrentId"], cast mapping["file"]);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        // TODO
        callback(null, null);
    }    
}
#end
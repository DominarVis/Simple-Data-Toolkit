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
class IEEEAPI extends API {
    private static var _ieeeRoot : String = "events.vtools.ieee.org/RST";
    private static var _eventsAPI : String = "/events/api/public/v4/events";
    private static var _maxLimit : Int = 10000;

    private static var _instance : IEEEAPI;

    private function new() {
        super("IEEE");
    }

    public static function instance() : IEEEAPI {
        if (_instance == null) {
            _instance = new IEEEAPI();
        }
        return _instance;
    }

    public static function events(callback : Dynamic->Void, limit : Null<Int>, start : Null<Date>, end : Null<Date>) : Void {
        if (limit == null) {
            limit = _maxLimit;
        }
        // TODO
        //if (limit <= _maxLimit) {
        if (true) {
            instance().fetch("GET", _ieeeRoot, _eventsAPI, null, null, "/list?limit=" + limit + "&sort=-start-time" + (start == null && end == null ? "" : "?span=" + (start == null ? "" : "" + start) + "~" + (end == null ? "" : "" + end)), null, function (r) {
                var o : Dynamic = haxe.Json.parse(r);
                callback(o);
            });
        }
    }

    public static function eventsAPI() : InputAPI {
        return IEEEAPIEvents.instance();
    }
}

@:nativeGen
class IEEEAPIEvents extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Cloud - IEEE - Events");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new IEEEAPIEvents();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["start", "end", "limit"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        var limit : Null<Int> = null;
        if (mapping["limit"] != null && mapping["limit"] != "") {
            limit = Std.parseInt(mapping["limit"]);
        }
        var start : Null<Date> = null;
        if (mapping["start"] != null && mapping["start"] != "") {
            start = Date.fromString(mapping["start"]);
        }
        var end : Null<Date> = null;
        if (mapping["end"] != null && mapping["end"] != "") {
            end = Date.fromString(mapping["end"]);
        }
        IEEEAPI.events(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, limit, start, end);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        if (!Std.isOfType(data, String)) {
            data = haxe.Json.stringify(data);
        }
        callback(data, com.sdtk.table.ArrayOfObjectsReader.readWholeArray(haxe.Json.parse(data).data));
    }    
}
#end
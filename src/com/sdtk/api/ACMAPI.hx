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
class ACMAPI extends API {
    private static var _acmRoot : String = "www.acm.org";
    private static var _eventsAPI : String = "/conferences/conference-events";

    private static var _instance : ACMAPI;

    private function new() {
        super("ACM");
    }

    public static function instance() : ACMAPI {
        if (_instance == null) {
            _instance = new ACMAPI();
        }
        return _instance;
    }

    public static function events(callback : Dynamic->Void, start : Null<Date>) : Void {
        if (start == null) {
            start = Date.now();
        }
        instance().fetch("GET", _acmRoot, _eventsAPI, null, null, "?startDate0=" + start.toString().split(" ")[0].split("-").join("") + "&eventType0=Conferences&view0=month", null, function (r) {
            var o : Dynamic = com.sdtk.std.Normalize.parseJson(r);
            callback(o);
        });
    }

    public static function eventsAPI() : InputAPI {
        return ACMAPIEvents.instance();
    }
}

@:nativeGen
class ACMAPIEvents extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Cloud - ACM - Events");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new ACMAPIEvents();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["start"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        var start : Null<Date> = null;
        if (mapping["start"] != null && mapping["start"] != "") {
            start = Date.fromString(mapping["start"]);
        } else {
            start = Date.now();
        }
        start = new Date(Date.now().getFullYear(), Date.now().getMonth(), 1, 0, 0, 0);
        mapping["start"] = start.toString().split(" ")[0];        
        ACMAPI.events(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, start);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        var map : Array<Map<String, String>> = new Array<Map<String, String>>();
        var days : Array<String> = findElementsByClass(data, ["li"], "day");
        var currentDate : Null<Date> = null;
        if (mapping.get("start") != null) {
            currentDate = Date.fromString(mapping.get("start"));
        } else {
            currentDate = Date.now();
        }
        var year : Int = currentDate.getFullYear();
        var month : Int = currentDate.getMonth();
        for (day in days) {
            var currentDay : String = StringTools.trim(findElementsByClass(day, ["div"], "date")[0]);
            var events : Array<String> = findElementsByClass(day, ["div"], "event");
            currentDate = new Date(year, month, Std.parseInt(currentDay), 0, 0, 0);
            var currentDateAsString : String = currentDate.toString().split(" ")[0];
            for (event in events) {
                var eventMap : Map<String, String> = new Map<String, String>();
                eventMap.set("date", currentDateAsString);
                eventMap.set("event-time", StringTools.trim(findElementsByClass(event, ["div"], "event-time")[0]));
                var desc : String = StringTools.trim(findElementsByClass(event, ["div"], "event-desc")[0]);
                eventMap.set("title", StringTools.trim(findElementsByClass(event, ["a"], null)[0]));
                var linkStart = desc.indexOf("href=\"") + 6;
                var linkEnd = desc.indexOf("\"", linkStart);
                eventMap.set("link", desc.substring(linkStart, linkEnd));
                map.push(eventMap);
            }
        }
        callback(data, com.sdtk.table.ArrayOfMapsReader.readWholeArray(map));
    }    
}
#end
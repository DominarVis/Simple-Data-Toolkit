package com.sdtk.calendar;

/*
    Copyright (C) 2019 Vis LLC - All Rights Reserved

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

/*
    Simple Data Toolkit
    Simple Calendar - Source code can be found on SourceForge.net
*/

import com.sdtk.std.*;

#if JS_BROWSER
    import com.sdtk.std.JS_BROWSER.Document;
    import com.sdtk.std.JS_BROWSER.Element;
#end

/**
    Implements standard routines for processing calendar events.
**/
@:expose
@:nativeGen
class BTCFormat implements CalendarInviteFormat<Reader, Writer> {
    private static var _instance : CalendarInviteFormat<Reader, Writer>;

    public static function instance() : CalendarInviteFormat<Reader, Writer> {
        if (_instance == null) {
            _instance = new BTCFormat();
        }
        return _instance;
    }

    private function new() { }

    public function convertDateTime(dDateTime : Date) : String {
        return dDateTime.toString();
    }

    public function convert(ciInvite : CalendarInvite, wWriter : Writer) : Void {
        var mMap : Map<String, Dynamic> = new Map<String, Dynamic>();
        var mAttributes : Map<String, Dynamic> = new Map<String, Dynamic>();
        var iTime : Int = cast ciInvite.created.getTime() / 1000;
        mMap.set("block_time", iTime);
        mMap.set("hash", ciInvite.uid);
        com.sdtk.table.JSONHandler.instance().write(wWriter, mMap, null, -1);
    }

    public function convertToString(ciInvite : CalendarInvite) : String {
        var sw : com.sdtk.std.StringWriter = new com.sdtk.std.StringWriter(null);
        convert(ciInvite, sw);
        return sw.toString();
    }

    private function toArray(field : String, d : Dynamic) : Array<String> {
        var a : Array<String> = new Array<String>();
        if (Std.isOfType(d, Array)) {
            var aD : Array<Dynamic> = cast d;
            for (d in aD) {
                var mMap : Map<String, Dynamic> = cast com.sdtk.std.Normalize.nativeToHaxe(d);
                if (mMap.exists(field)) {
                    var s : String = mMap.get(field);
                    if (s != null && s.length > 0) {
                        a.push(s);
                    }
                }
            }
        }
        return a;
    }

    public function read(rReader : Reader) : CalendarInvite {
        var ciInvite : CalendarInvite = new CalendarInvite();
        var mMap : Map<String, Dynamic>;
        if (Std.isOfType(rReader, com.sdtk.table.DataTableRowReader)) {
            var rr : com.sdtk.table.DataTableRowReader = cast rReader;
            mMap = rr.toHaxeMap(null);
        } else if (Std.isOfType(rReader, Reader)) {
            mMap = com.sdtk.table.JSONHandler.instance().read(rReader);
        } else {
            mMap = cast com.sdtk.std.Normalize.nativeToHaxe(rReader);
        }
        ciInvite.created = Date.fromTime(mMap.get("block_time") * 1000);
        ciInvite.start = ciInvite.created;
        ciInvite.end = ciInvite.created;
        ciInvite.uid = mMap.get("hash");
        ciInvite.groupUid = mMap.get("block_hash");
        ciInvite.cost = mMap.get("fee");
        ciInvite.from = toArray("prev_addresses", mMap.get("inputs"));
        ciInvite.to = toArray("addresses", mMap.get("outputs"));
        ciInvite.format = this;

        return ciInvite;
    }

    public function arrayToReader(aArray : Array<CalendarInvite>) : com.sdtk.table.DataTableReader {
        return null;
    }

    public function mapToReader(aArray : Map<String, CalendarInvite>) : com.sdtk.table.DataTableReader {
        return null;
    }

    public function validColumns() : Array<String> {
        return ["created", "start", "end", "uid", "groupUid", "cost", "from", "to"];
    }
}

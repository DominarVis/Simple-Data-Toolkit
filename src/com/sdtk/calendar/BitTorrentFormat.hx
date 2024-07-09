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
class BitTorrentFormat implements CalendarInviteFormat<Reader, Writer> {
    private static var _instance : CalendarInviteFormat<Reader, Writer>;

    public static function instance() : CalendarInviteFormat<Reader, Writer> {
        if (_instance == null) {
            _instance = new BitTorrentFormat();
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
        var iTime : Int = cast ciInvite.created.getTime();
        mMap.set("timeStamp", iTime);
        mMap.set("hash", ciInvite.uid);
        mMap.set("block", ciInvite.groupUid);
        mMap.set("ownerAddress", ciInvite.from);
        mMap.set("toAddress", ciInvite.to);
        com.sdtk.table.JSONHandler.instance().write(wWriter, mMap, null, -1);
    }

    public function convertToString(ciInvite : CalendarInvite) : String {
        var sw : com.sdtk.std.StringWriter = new com.sdtk.std.StringWriter(null);
        convert(ciInvite, sw);
        return sw.toString();
    }

    public function read(rReader : Reader) : CalendarInvite {
        var ciInvite : CalendarInvite = new CalendarInvite();
        var mMap : Map<String, Dynamic>;
        var mCost : Map<String, Dynamic>;
        if (Std.isOfType(rReader, com.sdtk.table.DataTableRowReader)) {
            var rr : com.sdtk.table.DataTableRowReader = cast rReader;
            mMap = rr.toHaxeMap(null);
        } else if (Std.isOfType(rReader, Reader)) {
            mMap = com.sdtk.table.JSONHandler.instance().read(rReader);
        } else {
            mMap = cast com.sdtk.std.Normalize.nativeToHaxe(rReader);
        }
        mCost = mMap.get("cost");
        if (mCost == null) {
            mCost = mMap;
        } else {
            mCost = cast com.sdtk.std.Normalize.nativeToHaxe(mCost);
        }
        ciInvite.created = Date.fromTime(mMap.get("timestamp"));
        ciInvite.start = ciInvite.created;
        ciInvite.end = ciInvite.created;
        ciInvite.groupUid = mMap.get("block");
        ciInvite.cost = mCost.get("gas");
        ciInvite.from = mMap.get("ownerAddress");
        ciInvite.to = mMap.get("toAddress");
        ciInvite.uid = mMap.get("hash");
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
        return ["created", "start", "end", "uid", "from", "to", "cost", "groupUid"];
    }    
}

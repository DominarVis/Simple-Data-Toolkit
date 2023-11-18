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

package com.sdtk.calendar;

import com.sdtk.table.*;

/**
    Implements standard routines for processing calendar events.
**/
@:expose
@:nativeGen
class TableFormat implements CalendarInviteFormat<DataTableReader, DataTableWriter> {
    public var sDateTimeFormat : String;

    private static var _instance : CalendarInviteFormat<DataTableReader, DataTableWriter>;

    public static function instance() : CalendarInviteFormat<DataTableReader, DataTableWriter> {
        if (_instance == null) {
            _instance = new TableFormat();
        }
        return _instance;
    }

    private function new() { }

    public function convertDateTime(dDateTime : Date) : String {
        // TODO
        return DateTools.format(dDateTime, sDateTimeFormat);
    }

    public function toDateTime(sValue : String) : Null<Date> {
        // TODO
        try {
            return new Date(Std.parseInt(sValue.substring(0, 4)), Std.parseInt(sValue.substr(4, 2)), Std.parseInt(sValue.substr(6, 2)), Std.parseInt(sValue.substr(9, 2)), Std.parseInt(sValue.substr(11, 2)), Std.parseInt(sValue.substr(13, 2)));
        }
        catch (message : Dynamic) {
            return null;
        }
    }

    public function convert(ciInvite : CalendarInvite, wWriter : DataTableWriter) : Void {
        // TODO
    }

    public function convertToString(ciInvite : CalendarInvite) : String {
        // TODO
        return "";
    }

    public function read(rReader : DataTableReader) : CalendarInvite {
        // TODO
        var ciInvite : CalendarInvite = new CalendarInvite();
        return ciInvite;
    }

    public function arrayToReader(aArray : Array<CalendarInvite>) : com.sdtk.table.DataTableReader {
        return null;
    }

    public function mapToReader(aArray : Map<String, CalendarInvite>) : com.sdtk.table.DataTableReader {
        return null;
    }

    public function validColumns() : Array<String> {
        return null;
    }       
}
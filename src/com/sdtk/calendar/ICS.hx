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

import com.sdtk.std.*;

#if JS_BROWSER
    import com.sdtk.std.JS_BROWSER.Document;
    import com.sdtk.std.JS_BROWSER.Element;
#end

/**
    Implements interface for the standard ICS/VCalendar format.

    https://tools.ietf.org/html/rfc5545
**/
@:expose
@:nativeGen
class ICS extends AbstractCalendarInviteFormat {
    private static var _instance : CalendarInviteFormat<Reader, Writer>;

    public static function instance() : CalendarInviteFormat<Reader, Writer> {
        if (_instance == null) {
            _instance = new ICS();
        }
        return _instance;
    }

    private function new() {
        super(
            "%y%m%dT%H%M%SZ",
            "BEGIN:VCALENDAR\nVERSION:2.0\nPRODID:-//hacksw/handcal//NONSGML v1.0//EN\nBEGIN:VEVENT\n",
            "END:VEVENT\nEND:VCALENDAR",
            "UID",
            "DTSTAMP",
            "DTSTART",
            "DTEND",
            "SUMMARY",
            ":",
            "\n",
            1024
        );
    }
}
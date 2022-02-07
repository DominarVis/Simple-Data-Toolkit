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
    Implements interface for sending event to console.
**/
@:expose
@:nativeGen
class ConsoleFormat extends AbstractCalendarInviteFormat {
    public static var instance : CalendarInviteFormat<Reader, Writer> = new ConsoleFormat();

    private function new() {
        super(
            "%y-%m-%d T%H%M%SZ",
            null,
            null,
            "UID",
            "Created",
            "Start",
            "End",
            "Summary",
            ": ",
            "\n",
            1024
        );
    }
}
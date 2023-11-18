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
import com.sdtk.calendar.Parameters;

/**
    Program for manipulating calendar invites.
**/
@:expose
@:nativeGen
class Create {
    #if !EXCLUDE_PARAMETERS
    static public function main() : Void {
        var pParameters : Parameters = new Parameters();

        if (pParameters.getNothing()) {
            var cifOutputFormat : CalendarInviteFormat<Reader, Writer> = ICS.instance();
            cifOutputFormat.convert(pParameters.getInvite(), new StdoutWriter());
        } else if (pParameters.getInvalid()) {
            return;
        } else {
            if (pParameters.getInput() != null && pParameters.getOutput() != null) {
                var cifInputFormat : CalendarInviteFormat<Reader, Writer> = ICS.instance();
                var cifOutputFormat : CalendarInviteFormat<Reader, Writer> = ICS.instance();
                var ciInvite : CalendarInvite = cifInputFormat.read(new FileReader(pParameters.getInput()));
                cifOutputFormat.convert(ciInvite, new FileWriter(pParameters.getOutput(), false));
            } else if (pParameters.getInput() != null) {
                var cifInputFormat : CalendarInviteFormat<Reader, Writer> = ICS.instance();
                var ciInvite : CalendarInvite = cifInputFormat.read(new FileReader(pParameters.getInput()));
                var cifOutputFormat : CalendarInviteFormat<Reader, Writer> = ConsoleFormat.instance();
                cifOutputFormat.convert(ciInvite, new StdoutWriter());
            } else {
                var cifOutputFormat : CalendarInviteFormat<Reader, Writer> = ICS.instance();
                cifOutputFormat.convert(pParameters.getInvite(), new FileWriter(pParameters.getOutput(), false));
            }
        }
    }
    #end
}

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

/**
    Defines interface for manipulating different calendar formats.
**/
@:expose
@:nativeGen
interface CalendarInviteFormat<R, W> {
    public function convertDateTime(dDateTime : Date) : String;
    public function convert(ciInvite : CalendarInvite, wWriter : W) : Void;
    public function convertToString(ciInvite : CalendarInvite) : String;
    public function read(rReader : R) : CalendarInvite;
    public function arrayToReader(aArray : Array<CalendarInvite>) : com.sdtk.table.DataTableReader;
    public function mapToReader(aArray : Map<String, CalendarInvite>) : com.sdtk.table.DataTableReader;
    public function validColumns() : Array<String>;
}

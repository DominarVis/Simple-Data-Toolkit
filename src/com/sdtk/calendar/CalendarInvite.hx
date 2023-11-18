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

/**
    Data structure for handling calendar invites.
**/
@:expose
@:nativeGen
class CalendarInvite {
    public var created : Null<Date>;
    public var start : Null<Date>;
    public var end : Null<Date>;
    public var summary : Null<String>;
    public var uid : Null<String>;
    public var groupUid : Null<String>;
    public var schedulingType : ScheduleType;
    public var actionExecute : Null<String>;
    public var actionExecuteIn : Null<String>;
    public var actionExecuteParameters: Null<Array<String>>; 
    public var hosts : Array<String>;  
    public var to : Array<String>;
    public var from : Array<String>;
    public var cost : Float;
    public var location : String;
    public var url : String;

    public var format : CalendarInviteFormat<Dynamic, Dynamic>;

    public function new() { }

    #if python
        public function __str__() : String {
    #else
        public function toString() : String {
    #end
        var sb : StringBuf = new StringBuf();
        if (format == null) {
            for (field in Reflect.fields(this)) {
                if (field != "format") {
                    sb.add(field + ": " + Reflect.field(this, field) + "\n");
                }
            }
        } else {
            for (field in format.validColumns()) {
                sb.add(field + ": " + Reflect.field(this, field) + "\n");
            }
        }
        return sb.toString();
    }
}

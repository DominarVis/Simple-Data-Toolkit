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

@:expose
@:nativeGen
class Executor implements CalendarInviteFormat<CalendarInvite, CalendarInvite> {
    private static var _instance : CalendarInviteFormat<CalendarInvite, CalendarInvite>;

    public static function instance() : CalendarInviteFormat<CalendarInvite, CalendarInvite> {
        if (_instance == null) {
            _instance = new Executor();
        }
        return _instance;
    }

    private function new() { }

    public function convert(ciInvite : CalendarInvite, ciNext : CalendarInvite) : Void {
        if (ciInvite.start != null && Date.now().getTime() > ciInvite.start.getTime() && ciInvite.actionExecute != null && ciInvite.actionExecute != "") {
            #if JS_BROWSER
            #elseif JS_WSH
            #elseif sys
                var orgDir : String = Sys.getCwd();
                var command : String = ciInvite.actionExecute;
                if (ciInvite.actionExecuteIn != null && ciInvite.actionExecuteIn != "") {
                    Sys.setCwd(ciInvite.actionExecuteIn);
                }
                var additionalParameters : Array<String> = new Array<String>();
                if (command.lastIndexOf(".py") == command.length - 3) {
                    additionalParameters.push(command);
                    command = "python";
                }
                if (ciInvite.actionExecuteParameters == null) {
                    ciInvite.actionExecuteParameters = new Array<String>();
                }
                var process = new sys.io.Process(command, additionalParameters.concat(ciInvite.actionExecuteParameters));
                var output = process.stdout.readAll().toString();
                process.close();
                if (ciInvite.actionExecuteIn != null && ciInvite.actionExecuteIn != "") {
                    Sys.setCwd(orgDir);
                }
                if (ciInvite.schedulingType != null && ciInvite.schedulingType != ScheduleType.NONE) {
                    for (field in Reflect.fields(ciInvite)) {
                        Reflect.setField(ciNext, field, Reflect.field(ciInvite, field));
                    }
                    while (ciNext.start.getTime() < Date.now().getTime()) {
                        switch (ciInvite.schedulingType) {
                            case HOURLY:
                                ciNext.start = new Date(ciInvite.start.getFullYear(), ciInvite.start.getMonth(), ciInvite.start.getDate(), ciInvite.start.getHours() + 1, ciInvite.start.getMinutes(), ciInvite.start.getSeconds());
                            case DAILY:
                                ciNext.start = new Date(ciInvite.start.getFullYear(), ciInvite.start.getMonth(), ciInvite.start.getDate() + 1, ciInvite.start.getHours(), ciInvite.start.getMinutes(), ciInvite.start.getSeconds());
                            case WEEKLY:    
                                ciNext.start = new Date(ciInvite.start.getFullYear(), ciInvite.start.getMonth(), ciInvite.start.getDate() + 7, ciInvite.start.getHours(), ciInvite.start.getMinutes(), ciInvite.start.getSeconds());
                            case MONTHLY:
                                ciNext.start = new Date(ciInvite.start.getFullYear(), ciInvite.start.getMonth() + 1, ciInvite.start.getDate(), ciInvite.start.getHours(), ciInvite.start.getMinutes(), ciInvite.start.getSeconds());
                            case YEARLY:
                                ciNext.start = new Date(ciInvite.start.getFullYear() + 1, ciInvite.start.getMonth(), ciInvite.start.getDate(), ciInvite.start.getHours(), ciInvite.start.getMinutes(), ciInvite.start.getSeconds());
                            case NONE:
                                // Intentionally left empty
                                break;
                        }
                    }
                } else {
                    for (field in Reflect.fields(ciInvite)) {
                        Reflect.setField(ciNext, field, Reflect.field(ciInvite, field));
                    }
                    ciNext.end = ciNext.start;
                    ciNext.start = null;
                }
            #end
        } else {
            for (field in Reflect.fields(ciInvite)) {
                Reflect.setField(ciNext, field, Reflect.field(ciInvite, field));
            }
        }

    }

    public function convertAll(aInvites : Array<CalendarInvite>) : Array<CalendarInvite> {
        var aiNewInvites : Array<CalendarInvite> = new Array<CalendarInvite>();
        for (ci in aInvites) {
            var ciNext : CalendarInvite = new CalendarInvite();
            convert(ci, ciNext);
            aiNewInvites.push(ciNext);
        }
        return aiNewInvites;
    }

    public function convertDateTime(dDateTime : Date) : String {
        return null;
    }
    
    public function convertToString(ciInvite : CalendarInvite) : String {
        return null;
    }
    
    public function read(rReader : CalendarInvite) : CalendarInvite {
        return null;
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

    #if !EXCLUDE_PARAMETERS
        static public function main() : Void {
            var file : String = (new com.sdtk.std.Parameters()).getParameter(0);
            var row : Int = 0;
            var reader : com.sdtk.table.KeyValueReader;
            var writer : com.sdtk.table.KeyValueWriter;
            if (file == null) {
                reader = com.sdtk.table.KeyValueReader.createJSONReader(new com.sdtk.std.StdinReader());
                writer = com.sdtk.table.KeyValueWriter.createJSONWriter(new com.sdtk.std.StdoutWriter());
            } else {
                reader = com.sdtk.table.KeyValueReader.createJSONReader((new com.sdtk.std.FileReader(file)).convertToStringReader());
                writer = com.sdtk.table.KeyValueWriter.createJSONWriter(new com.sdtk.std.FileWriter(file, false));
            }
            reader.start();
            writer.start();
            while (reader.hasNext()) {
                var rowReader = reader.next();
                var map : haxe.ds.StringMap<Dynamic> = rowReader.toHaxeMap(new haxe.ds.StringMap<Dynamic>());
                var invite = new CalendarInvite();
                for (field in Reflect.fields(invite)) {
                    var v : Dynamic = map.get(field);
                    if (v != null) {
                        try {
                            var v2 : Date = Date.fromString(cast v);
                            if (v2 != null) {
                                v = v2;
                            }
                        } catch (ex : Any) { }
                        try {
                            var v2 : String = cast v;
                            switch (v2.toUpperCase()) {
                                case "NONE":
                                    v = ScheduleType.NONE;
                                case "HOURLY":
                                    v = ScheduleType.HOURLY;
                                case "DAILY":
                                    v = ScheduleType.DAILY;
                                case "WEEKLY":
                                    v = ScheduleType.WEEKLY;
                                case "MONTHLY":
                                    v = ScheduleType.MONTHLY;
                                case "YEARLY":
                                    v = ScheduleType.YEARLY;
                            }
                        } catch (ex : Any) { }
                        try {
                            var v2 : Int= cast v;
                            switch (v2) {
                                case 0:
                                    v = ScheduleType.NONE;
                                case 1:
                                    v = ScheduleType.HOURLY;
                                case 2:
                                    v = ScheduleType.DAILY;
                                case 3:
                                    v = ScheduleType.WEEKLY;
                                case 4:
                                    v = ScheduleType.MONTHLY;
                                case 5:
                                    v = ScheduleType.YEARLY;
                            }
                        } catch (ex : Any) { }                        
                    }
                    Reflect.setField(invite, field, v);
                }
                var next = new CalendarInvite();
                instance().convert(invite, next);
                var rowWriter = writer.writeStart(null, row);
                rowWriter.start();
                row++;
                var column : Int = 0;
                for (field in Reflect.fields(next)) {
                    rowWriter.write(Reflect.field(next, field), field, column);
                    column++;
                }
                rowReader.dispose();
                rowWriter.dispose();
            }
            reader.dispose();
            writer.dispose();
        }   
    #end 
}
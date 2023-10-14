/*
    Copyright (C) 2023 Vis LLC - All Rights Reserved

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

package com.sdtk.calendar;

import com.sdtk.std.*;

@:expose
@:nativeGen
class CronSchedulerAbstract {
    private var _exec : Bool = false;

    private function new(?exec : Bool = false) {
        _exec = exec;
    }

    private function exec(writer : Writer, command : String, args : Array<String>, ?send : String = null) : String {
        if (writer != null) {
            writer.write(command + " " + args.join(" ") + "\n");
        }
        if (_exec) {
            #if sys
                var process = new sys.io.Process(command, args);
                var output = process.stdout.readAll().toString();
                process.close();
                if (send != null) {
                    process.stdin.writeString(send);
                    process.stdin.flush();
                    process.stdin.close();
                }
                return output;
            #else
                // TODO
                return "";
            #end
        }
        return null;
    }

    private function getListI() : String {
        return exec(null, "crontab", ["-l"]);
    }

    private function getList(folder : Dynamic, ?data : String = null) : Iterable<CronSchedulerTask> {
        if (data == null) {
            data = getListI();
        }
        var arr : Array<CronSchedulerTask> = new Array<CronSchedulerTask>();
        var r = new com.sdtk.std.StringReader(data);
        var field : Int = 0;
        var minute : StringBuf = new StringBuf();
        var hour : StringBuf = new StringBuf();
        var dayOfMonth : StringBuf = new StringBuf();
        var month : StringBuf = new StringBuf();
        var dayOfWeek : StringBuf = new StringBuf();
        var command : StringBuf = new StringBuf();
        while (true) {
            var c = r.next();
            if (c == null) {
                break;
            } else {
                switch (c) {
                    case " ":
                        if (field < 5) {
                            field++;
                        } else {
                            command.add(c);
                        }
                        break;
                    case "\n":
                        field = 0;
                        arr.push(CronSchedulerTaskToMap.build(minute.toString(), hour.toString(), dayOfMonth.toString(), month.toString(), dayOfWeek.toString(), command.toString()));
                        minute = new StringBuf();
                        hour = new StringBuf();
                        dayOfMonth = new StringBuf();
                        month = new StringBuf();
                        dayOfWeek = new StringBuf();
                        command = new StringBuf();
                        break;
                    default:
                        switch (field) {
                            case 0:
                                minute.add(c);
                                break;
                            case 1:
                                hour.add(c);
                                break;
                            case 2:
                                dayOfMonth.add(c);
                                break;
                            case 3:
                                month.add(c);
                                break;
                            case 4:
                                dayOfWeek.add(c);
                                break;
                            case 5:
                                command.add(c);
                                break;
                        }
                }
            }
        }
        return arr;
    }

    private function createTask(writer : Writer, folder : Dynamic, task : String, ?data : String = null) : Dynamic {
        if (data == null) {
            data = getListI();
        }
        if (folder != null) {
            task = "/" + folder + "/" + task;
        }        
        if (data.indexOf(task) < 0) {
            if (writer == null) {
                exec(writer, "crontab", ["-"], data + "\n" + "* * * * * " + task);
            } else {
                // TODO
            }
        }
        return "/" + folder + "/" + task;
    }

    private function deleteTask(writer : Writer, folder : Dynamic, task : String, ?data : String = null, ?add : String = "") : Void {
        if (data == null) {
            data = getListI();
        }
        if (folder != null) {
            task = "/" + folder + "/" + task;
        }
        var index : Int = data.indexOf(task);
        if (index >= 0) {
            var start : Int = data.lastIndexOf("\n", index);
            var end : Int = data.indexOf("\n", index);
            if (writer == null) {
                exec(writer, "crontab", ["-"], data.substring(0, start) + data.substring(end + 1) + add);
            } else {
                // TODO
            }
        }
    }

    // TODO
    private function updateTaskForDate(writer : Writer, task : Dynamic, start : Date, end : Date) : Void { }

    private function updateTaskForSchedule(writer : Writer, task : Dynamic, schedulingType : ScheduleType) : Void {
        var schedule : String = "* * * * *";
        switch (schedulingType) {
            case NONE:
                deleteTask(writer, null, task);
                return;
            case HOURLY:
                schedule = "0 * * * *";
            case DAILY:
                schedule = "0 0 * * *";
            case WEEKLY:
                schedule = "0 0 * * 0";
            case MONTHLY:
                schedule = "0 0 1 * *";
            case YEARLY:
                schedule = "0 0 1 1 *";
        }
        deleteTask(writer, task, schedule, null, "\n" + schedule + " " + task);
    }

    // Intentionally empty
    private function updateTaskForAction(writer : Writer, task : Dynamic, cmd : String, arguments : Array<String>, workingDirectory : String) : Void { }
}

@:expose
@:nativeGen
class CronSchedulerExecutor extends CronSchedulerAbstract {
    public static var instance : CronSchedulerExecutor = new CronSchedulerExecutor();

    private function new() {
        super(true);
    }

    public function convert(ciInvite : CalendarInvite, folder : String) : Void {
        var task : Dynamic = createTask(null, folder, ciInvite.summary);
        updateTaskForDate(null, task, ciInvite.start, ciInvite.end);
        updateTaskForSchedule(null, task, ciInvite.schedulingType);
        updateTaskForAction(null, task, ciInvite.actionExecute, ciInvite.actionExecuteParameters, ciInvite.actionExecuteIn);
    }    
}

@:expose
@:nativeGen
class CronSchedulerText  extends CronSchedulerAbstract {
    public static var instance : CronSchedulerText  = new CronSchedulerText();

    private function new() {
        super(false);
    }

    public function convert(ciInvite : CalendarInvite, wWriter : Writer, folder : String) : Void {
        var task : Dynamic = createTask(wWriter, folder, ciInvite.summary);
        updateTaskForDate(wWriter, task, ciInvite.start, ciInvite.end);
        updateTaskForSchedule(wWriter, task, ciInvite.schedulingType);
        updateTaskForAction(wWriter, task, ciInvite.actionExecute, ciInvite.actionExecuteParameters, ciInvite.actionExecuteIn);
    }

    public function convertToString(ciInvite : CalendarInvite, folder : String) : String {
        var sw : StringWriter = new StringWriter(null);
        convert(ciInvite, sw, folder);
        sw.dispose();
        return sw.toString();
    }    
}

@:expose
@:nativeGen
interface CronSchedulerTask {
    public function minute() : String;
    public function hour() : String;
    public function dayOfMonth() : String;
    public function month() : String;
    public function dayOfWeek() : String;
    public function command() : String;
}

@:expose
@:nativeGen
class CronSchedulerTaskAbstract extends CalendarInvite implements CronSchedulerTask {
    public function new() {
        super();
    }

    private function startDate() : Date {
        var d : Date = Date.now();
        if (hour() != "*") {
            var iHour : Int = Std.parseInt(hour());
            if (iHour < d.getHours()) {
                d = Date.fromTime(d.getTime() + 24 * 60 * 60 * 1000 - (d.getHours() - iHour) * 60 * 60 * 1000);
            }
        }
        if (dayOfMonth() != "*") {
            var iDayOfMonth : Int = Std.parseInt(dayOfMonth());
            if (iDayOfMonth < d.getDate()) {
                d = new Date(d.getFullYear(), d.getMonth() >= 11 ? 0 : d.getMonth() + 1, iDayOfMonth, d.getHours(), d.getMinutes(), d.getSeconds());
            }
        }
        if (month() != "*") {
            var iMonth : Int = Std.parseInt(month());
            if (iMonth < (d.getMonth() + 1)) {
                d = new Date(d.getFullYear() + 1, iMonth, d.getDate(), d.getHours(), d.getMinutes(), d.getSeconds());
            }
        }
        // TODO - Comma separated
        // TODO - Dash separated
        // TODO - dayOfWeek
        return d;
    }

    private function update() {
        created = startDate();
        start = created;
        end = null;
        summary = command();
        // TODO
        //uid =        
    }

    public function minute() : String {
        return null;
    }

    public function hour() : String {
        return null;
    }
    
    public function dayOfMonth() : String {
        return null;
    }

    public function month() : String {
        return null;
    }

    public function dayOfWeek() : String {
        return null;
    }

    public function command() : String {
        return null;
    }
}

@:expose
@:nativeGen
class CronSchedulerTaskToMap extends CronSchedulerTaskAbstract {
    private var _m : Map<String, Dynamic>;

    public function new(m : Map<String, Dynamic>) {
        super();
        _m = m;
        update();
    }

    public static function build(minute : String, hour : String, dayOfMonth : String, month : String, dayOfWeek : String, command : String) : CronSchedulerTaskToMap {
        var map : Map<String, Dynamic> = new Map<String, Dynamic>();
        map.set("minute", minute);
        map.set("hour", hour);
        map.set("dayOfMonth", dayOfMonth);
        map.set("month", month);
        map.set("dayOfWeek", dayOfWeek);
        map.set("command", command);
        return new CronSchedulerTaskToMap(map);
    }

    private function value(v : Dynamic) : Dynamic {
        return v;
    }

    public override function minute() : String {
        return cast value(_m.get("minute"));
    }

    public override function hour() : String {
        return cast value(_m.get("hour"));
    }
    
    public override function dayOfMonth() : String {
        return cast value(_m.get("dayOfMonth"));
    }

    public override function month() : String {
        return cast value(_m.get("month"));
    }

    public override function dayOfWeek() : String {
        return cast value(_m.get("dayOfWeek"));
    }

    public override function command() : String {
        return cast value(_m.get("command"));
    }
}

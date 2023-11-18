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

/*
    Simple Data Toolkit
    Simple Calendar - Source code can be found on SourceForge.net
*/

package com.sdtk.calendar;

import com.sdtk.std.*;

/*

    // Create a trigger that will fire the task at this time every other day
    td.Triggers.Add(new DailyTrigger { DaysInterval = 2 });

*/
@:expose
@:nativeGen
class WindowsTaskSchedulerAbstract {
    private var _exec : Bool = false;

    private function new(?exec : Bool = false) {
        _exec = exec;
    }

    private function exec(writer : Writer, command : String, args : Array<String>) : String {
        if (writer != null) {
            writer.write(command + " " + args.join(" ") + "\n");
        }
        if (_exec) {
            #if sys
                var process = new sys.io.Process(command, args);
                var output = process.stdout.readAll().toString();
                process.close();
                return output;
            #else
                // TODO
                return "";
            #end
        }
        return null;
    }
/*
    #if cs
        private _ts : Dynamic;
    #end
*/
/*
    #if cs
        @:functionCode("
            Microsoft.Win32.TaskScheduler.TaskService ts = new Microsoft.Win32.TaskScheduler.TaskService();
            ts.Connect();
            return ts;
        ")
    #end
*/
    private function connect() : Dynamic {
        return null;
    }

/*
    #if cs
        @:functionCode("return _ts.GetFolder(path);")
    #end
*/
    private function getFolder(path : String) : Dynamic {
        return path;
    }
/*
    #if cs
        @:functionCode("
            Microsoft.Win32.TaskScheduler.TaskFolder tf = (Microsoft.Win32.TaskScheduler.TaskFolder)folder;
            return tf.getTasks(Microsoft.Win32.TaskScheduler._TASK_ENUM_FLAGS.TASK_ENUM_HIDDEN);
        ")
    #end
*/
    private function getList(folder : Dynamic, ?data : String = null) : Iterable<WindowsTaskSchedulerTask> {
        if (data == null) {
            data = exec(null, "schtasks", ["/query", "/v", "/tn", "\\" + folder + "\\", "/fo", "csv"]);
        }
        var d = com.sdtk.table.DelimitedReader.createCSVReader(new com.sdtk.std.StringReader(data)).toArrayOfHaxeMaps(null);
        return convertToObj(cast d);
    }
/*
    #if cs
        @:functionCode("
            Microsoft.Win32.TaskScheduler.TaskFolder tf = (Microsoft.Win32.TaskScheduler.TaskFolder)folder;
            tf.DeleteTask(task);
        ")
    #end
*/
    private function deleteTask(writer : Writer, folder : Dynamic, task : String) : Void {
        exec(writer, "schtasks", ["/delete", "/tn", "\\" + folder + "\\" + task, "/f"]);
    }
/*
    #if cs
        @:functionCode("
            Microsoft.Win32.TaskScheduler.TaskDefinition td = _ts.NewTask();
            Microsoft.Win32.TaskScheduler.TaskFolder tf = (Microsoft.Win32.TaskScheduler.TaskFolder)folder;
            tf.RegisterTaskDefinition(@task, td);
            return td;
        ")
    #end
*/
    private function createTask(writer : Writer, folder : Dynamic, task : String) : Dynamic {
        exec(writer, "schtasks", ["/create", "/tn", "\\" + folder + "\\" + task]);
        return "\\" + folder + "\\" + task;
    }

    /*
    #if cs
        @:functionCode("
            Microsoft.Win32.TaskScheduler.TaskDefinition td = (Microsoft.Win32.TaskScheduler.TaskDefinition)task;
            return td;
        ")        
    #end
    */
    private function updateTaskForDate(writer : Writer, task : Dynamic, start : Date, end : Date) : Void {
        exec(writer, "schtasks", ["/change", "/tn", task,
            "/sd", "" + (start.getMonth() + 1) + "/" + start.getDate() + "/" + start.getFullYear(), "/st", "" + (start.getHours() == 0 ? 12 : (start.getHours() > 12 ? start.getHours() - 12 : start.getHours())) + ":" + start.getMinutes() + " " + (start.getHours() < 12 ? "AM" : "PM"),
            "/ed", "" + (end.getMonth() + 1) + "/" + end.getDate() + "/" + end.getFullYear(), "/et", "" + (end.getHours() == 0 ? 12 : (end.getHours() > 12 ? end.getHours() - 12 : end.getHours())) + ":" + end.getMinutes() + " " + (end.getHours() < 12 ? "AM" : "PM"),
        ]);
    }

    private function updateTaskForSchedule(writer : Writer, task : Dynamic, schedulingType : ScheduleType) : Void {
        var ri : Int = 0;
        switch (schedulingType) {
            case NONE:
                ri = 0;
            case HOURLY:
                ri = 60;
            case DAILY:
                ri = 1440;
            case WEEKLY:
                ri = 10080;
            case MONTHLY:
                // TODO - Improve
                ri = 43200;
            case YEARLY:
                // TODO - Improve
                ri = 525600;
        }
        exec(writer, "schtasks", ["/change", "/tn", task,
            "/ri", "" + ri
        ]);
    }

    /*
    #if cs
        @:functionCode("
            Microsoft.Win32.TaskDefinition td = (Microsoft.Win32.TaskDefinition) task;
            if (type == 0) {
                td.Actions.Add(new Microsoft.Win32.TaskScheduler.ExecAction(path, arguments, workingDirectory));
            } else (type == 1) {

            } else (type == 2) {

            }
            
        ")
    #end
    */
    private function updateTaskForAction(writer : Writer, task : Dynamic, cmd : String, arguments : Array<String>, workingDirectory : String) : Void {
        var execute : String;
        if (workingDirectory == null) {
            if (cmd == null) {
                execute = "";
            } else {
                execute = cmd;
            }
        } else if (cmd != null) {
            execute = workingDirectory + "\\" + cmd;
        } else {
            execute = "";
        }
        if (execute != "" && arguments != null) {
            execute += " " + arguments.join(" ");
        }
        exec(writer, "schtasks", ["/change", "/tn", task,
            "/tr", execute
        ]);
    }

    private static function convertToObj(i : Iterable<Map<String, Dynamic>>) : Iterable<WindowsTaskSchedulerTask> {
        var arr : Array<WindowsTaskSchedulerTask> = new Array<WindowsTaskSchedulerTask>();
        for (m in i) {
            if (m.get("Status") != "Status") {
                arr.push(new WindowsTaskSchedulerTaskToMap(m));
            }
        }
        return arr;
    }
}

@:expose
@:nativeGen
class WindowsTaskSchedulerExecutor extends WindowsTaskSchedulerAbstract {
    private static var _instance : WindowsTaskSchedulerExecutor;

    public static function instance() : WindowsTaskSchedulerExecutor {
      if (_instance == null) {
          _instance = new WindowsTaskSchedulerExecutor();
      }
      return _instance;
    }  

    private function new() {
        super(true);
    }

    public function read(folder : String) : Iterable<CalendarInvite> {
        return cast getList(folder, null);
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
class WindowsTaskSchedulerText extends WindowsTaskSchedulerAbstract {
    private static var _instance : WindowsTaskSchedulerText;

    public static function instance() : WindowsTaskSchedulerText {
      if (_instance == null) {
          _instance = new WindowsTaskSchedulerText();
      }
      return _instance;
    }  

    private function new() {
        super(false);
    }

    public function read(rReader : Reader) : Iterable<CalendarInvite> {
        var sw : StringWriter = new StringWriter(null);
        while (true) {
            var d = rReader.next();
            if (d != null) {
                sw.write(d);
            } else {
                break;
            }
        }
        return cast getList(null, sw.toString());
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
interface WindowsTaskSchedulerTask {
    public function hostName() : String;
    public function taskName() : String;
    public function nextRuntime() : Date;
    public function status() : String;
    public function logonMode() : String;
    public function lastRuntime() : Date;
    public function lastResult() : Null<Int>;
    public function author() : String;
    public function taskToRun() : String;
    public function startIn() : String;
    public function comment() : String;
    public function scheduledTaskState() : String;
    public function idleTime() : String;
    public function powerManagement() : String;
    public function runAsUser() : String;
    public function deleteTaskIfNotRescheduled() : String;
    public function stopTaskIfRunsXHoursAndXMins() : String;
    public function schedule() : String;
    public function scheduleType() : String;
    public function startTime() : String;
    public function startDate() : Date;
    public function endDate() : Date;
    public function days() : String;
    public function months() : String;
    public function repeatEvery() : String;
    public function repeatUntilTime() : String;
    public function repeatUntilDuration() : String;
    public function repeatStopIfStillRunning() : String;
}

@:expose
@:nativeGen
class WindowsTaskSchedulerTaskAbstract extends CalendarInvite implements WindowsTaskSchedulerTask {
    public function new() {
        super();
    }

    private function update() {
        var a : Date = startDate();
        var b : Array<String> = startTime().split(":");
        var b2 : Array<String> = b[2].split(" ");
        b[2] = b2[0];
        b.push(b2[1]);
        var c : Array<Int> = new Array<Int>();
        c[0] = Std.parseInt(b[0]);
        c[1] = Std.parseInt(b[1]);
        c[2] = Std.parseInt(b[2]);
        if (b[3].toUpperCase() == "PM" && c[0] < 12) {
            c[0] += 12;
        } else if (b[3].toUpperCase() == "AM" && c[0] == 12) {
            c[0] = 0;
        }

        created = new Date(a.getFullYear(), a.getMonth(), a.getDate(), c[0], c[1], c[2]);
        start = created;
        end = endDate();
        summary = taskName();
        actionExecute = taskToRun();
        actionExecuteIn = startIn();
        switch (scheduleType()) {
            case "One Time Only":
                schedulingType = NONE;
            case "Daily":
                schedulingType = DAILY;
            case "Weekly":
                schedulingType = WEEKLY;
            case "Monthly":
                schedulingType = MONTHLY;
            default:
                var hour : Int = repeatEvery().indexOf("Hour");
                var minute : Int = repeatEvery().indexOf("Minute");
                if (hour < 0 && minute < 0) {
                    schedulingType = NONE;
                } else {
                    var s : Array<String> = repeatEvery().split(",");
                    for (s2 in s) {
                        hour = 0;
                        minute = 0;
                        var parts : Array<String> = s2.split(" ");
                        var unit : String = parts[1];
                        var value : String = parts[0];
                        switch (unit) {
                            case "Hour":
                                hour = Std.parseInt(value);
                            case "Minute":
                                minute = Std.parseInt(value);
                        }
                    }
                    hour += Math.floor(minute / 60);
                    if (hour > 0 && hour < 24) {
                        schedulingType = HOURLY;
                    } else if (hour >= 24 && hour < 168) {
                        schedulingType = DAILY;
                    } else if (hour >= 168 && hour < 672) {
                        schedulingType = WEEKLY;
                    } else if (hour >= 672 && hour < 8064) {
                        schedulingType = MONTHLY;
                    } else {
                        schedulingType = YEARLY;
                    }
                }
        }
        // TODO
        //actionExecuteParameters
        // TODO
        //uid =        
    }

    public function hostName() : String {
        return null;
    }

    public function taskName() : String {
        return null;
    }

    public function nextRuntime() : Date {
        return null;
    }

    public function status() : String {
        return null;
    }

    public function logonMode() : String {
        return null;
    }

    public function lastRuntime() : Date {
        return null;
    }

    public function lastResult() : Null<Int> {
        return null;
    }

    public function author() : String {
        return null;
    }

    public function taskToRun() : String {
        return null;
    }

    public function startIn() : String {
        return null;
    }

    public function comment() : String {
        return null;
    }

    public function scheduledTaskState() : String {
        return null;
    }

    public function idleTime() : String {
        return null;
    }

    public function powerManagement() : String {
        return null;
    }
    
    public function runAsUser() : String {
        return null;
    }

    public function deleteTaskIfNotRescheduled() : String {
        return null;
    }

    public function stopTaskIfRunsXHoursAndXMins() : String {
        return null;
    }

    public function schedule() : String {
        return null;
    }

    public function scheduleType() : String {
        return null;
    }

    public function startTime() : String {
        return null;
    }

    public function startDate() : Date {
        return null;
    }

    public function endDate() : Date {
        return null;
    }

    public function days() : String {
        return null;
    }

    public function months() : String {
        return null;
    }

    public function repeatEvery() : String {
        return null;
    }

    public function repeatUntilTime() : String {
        return null;
    }

    public function repeatUntilDuration() : String {
        return null;
    }

    public function repeatStopIfStillRunning() : String {
        return null;
    }    
}

@:expose
@:nativeGen
class WindowsTaskSchedulerTaskToMap extends WindowsTaskSchedulerTaskAbstract {
    private var _m : Map<String, Dynamic>;

    public function new(m : Map<String, Dynamic>) {
        super();
        _m = m;
        update();
    }

    private function value(v : Dynamic) : Dynamic {
        if (v == "N/A") {
            return null;
        } else {
            return v;
        }
    }

    public override function hostName() : String {
        return cast value(_m.get("HostName"));
    }

    public override function taskName() : String {
        return cast value(_m.get("TaskName"));
    }

    public override function nextRuntime() : Date {
        return cast value(_m.get("Next Run Time"));
    }

    public override function status() : String {
        return cast value(_m.get("Status"));
    }

    public override function logonMode() : String {
        return cast value(_m.get("Logon Mode"));
    }

    public override function lastRuntime() : Date {
        return cast value(_m.get("Last Run Time"));
    }

    public override function lastResult() : Null<Int> {
        return cast value(_m.get("Last Result"));
    }

    public override function author() : String {
        return cast value(_m.get("Author"));
    }

    public override function taskToRun() : String {
        return cast value(_m.get("Task To Run"));
    }

    public override function startIn() : String {
        return cast value(_m.get("Start In"));
    }

    public override function comment() : String {
        return cast value(_m.get("Comment"));
    }

    public override function scheduledTaskState() : String {
        return cast value(_m.get("Scheduled Task State"));
    }

    public override function idleTime() : String {
        return cast value(_m.get("Idle Time"));
    }

    public override function powerManagement() : String {
        return cast value(_m.get("Power Management"));
    }
    
    public override function runAsUser() : String {
        return cast value(_m.get("Run As User"));
    }

    public override function deleteTaskIfNotRescheduled() : String {
        return cast value(_m.get("Delete Task If Not Rescheduled"));
    }

    public override function stopTaskIfRunsXHoursAndXMins() : String {
        return cast value(_m.get("Stop Task If Runs X Hours and X Mins"));
    }

    public override function schedule() : String {
        return cast value(_m.get("Schedule"));
    }

    public override function scheduleType() : String {
        return cast value(_m.get("Schedule Type"));
    }

    public override function startTime() : String {
        return cast value(_m.get("Start Time"));
    }

    public override function startDate() : Date {
        return cast value(_m.get("Start Date"));
    }

    public override function endDate() : Date {
        return cast value(_m.get("End Date"));
    }

    public override function days() : String {
        return cast value(_m.get("Days"));
    }

    public override function months() : String {
        return cast value(_m.get("Months"));
    }

    public override function repeatEvery() : String {
        return cast value(_m.get("Repeat: Every"));
    }

    public override function repeatUntilTime() : String {
        return cast value(_m.get("Repeat: Until: Time"));
    }

    public override function repeatUntilDuration() : String {
        return cast value(_m.get("Repeat: Until: Duration"));
    }

    public override function repeatStopIfStillRunning() : String {
        return cast value(_m.get("Repeat: Stop If Still Running"));
    }
}

/*
#if cs
@:expose
@:nativeGen
class WindowsTaskSchedulerTaskToTask implements WindowsTaskSchedulerTask {
}
#end
*/
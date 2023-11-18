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
class BrowserTaskScheduler {
    private var _exec : Bool = false;
    private var _tasks : Array<BrowserTask> = new Array<BrowserTask>();

    private function new(?exec : Bool = false) {
        _exec = exec;
    }

    private function exec(writer : Writer, command : String) : Null<Int> {
        if (writer != null) {
            writer.write(command);
        }
        if (_exec) {
            #if js
                return cast js.Syntax.code("eval({0})", command);
            #end
        }
        return null;
    }

    private function createTask(writer : Writer, event : CalendarInvite) : Dynamic {
        var newEvent = new BrowserTask();
        var taskIn = "";
        if (event.actionExecuteIn != null) {
            taskIn = event.actionExecuteIn + ".";
        }
        var taskParameters = "";
        if (event.actionExecuteParameters != null && event.actionExecuteParameters.length > 0) {
            taskParameters = "\"" + event.actionExecuteParameters.join("\", \"") + "\"";
        }
        var task = "function() {\n"
            + "\t" + taskIn + event.actionExecute + "("
            + taskParameters
            + "\t);"
            + "}";
    
        newEvent.command = "setTimeout(" + task + ", new Date(" + event.start.getFullYear() + ", " + event.start.getMonth() + ", " + event.start.getDate() + ", " + event.start.getHours() + ", " + event.start.getMinutes() + ", " + event.start.getSeconds() + ") - Date.now())";
        newEvent.id = exec(writer, newEvent.command);
        newEvent.event = event;
        return newEvent;
    }
}

@:expose
@:nativeGen
class BrowserTask {
    public function new() { }
    public var id : Null<Int>;
    public var command : String;
    public var event : CalendarInvite;
}
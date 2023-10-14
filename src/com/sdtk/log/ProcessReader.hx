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
    Simple Log Grabber (SLG) - Source code can be found on SourceForge.net
*/

package com.sdtk.log;

#if(!EXCLUDE_PROCESS)

import com.sdtk.std.JS_WSH;

#if !EXCLUDE_PROCESS_STDOUT
/**
  Defines interface for receiving log entries from a child process.
**/
@:expose
@:nativeGen
class ProcessReader extends com.sdtk.std.Reader {
  #if sys
    private var _process : sys.io.Process;
  #elseif JS_WSH
    private var _process : WSHProcess;
  #end

  public function new(sCommand : String, sParameters : Array<String>) {
    super();
    #if sys
      _process = new sys.io.Process(sCommand, sParameters);
    #elseif JS_WSH
      var wsh : ActiveXObject = new ActiveXObject("WScript.Shell");
      for (s in sParameters) {
        sCommand += " " + s;
      }
      _process = wsh.Exec(sCommand);
    #elseif JS_NODE
      // TODO
      //var exec = require('child_process').exec;
      //_process = exec(sCommand + )
    #end
  }

  public function get() : Null<String> {
    #if sys
      return _process.stdout.readLine();
    #elseif JS_WSH
      if (!(_process.StdOut.AtEndOfStream)) {
        return _process.StdOut.ReadLine();
      } else {
        return null;
      }
    #elseif JS_NODE
      // TODO
    #else
      return null;
    #end
  }

// TODO
  public function end() : Void {
    #if sys
      try {
        _process.close();
      } catch (msg : Dynamic) {

      }
    #end
  }
}
#end

#end
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

import com.sdtk.std.*;
import com.sdtk.log.Parameters;

#if JS_BROWSER
  import com.sdtk.std.JS_BROWSER.MutableConsole;
#end

// TODO - Add way to control default output
// TODO - Add way to control default input
// TODO - Test Java
// TODO - Test Node JS
// TODO - Test CPP

/**
  Defines process of moving a log entry from a receiver to a sender.
  This also serves as the starting point when running the program as a standalone application.
**/
@:expose
@:nativeGen
class Transfer {
  public function new() {
  }

  /**
    Handles the process of moving a log entry from a receiver to a sender.
	**/
  public function transfer(reader : Reader, writer : Writer) : Void {
    var sLine : String;
    sLine = reader.next();
    while (sLine != null) {
      writer.write(sLine);
      sLine = reader.next();
    }

    reader.dispose();
    writer.dispose();
  }

  /**
    Defines default transfer method.
	**/
  static private function defaultTransfer(sLocation : String, pParameters : Parameters) : Void {
    var rReader : Null<Reader> = null;
    var wWriter : Null<Writer> = null;

    switch (pParameters.getOutputMode()) {
      case 0:
        wWriter = new TSFileWriter(sLocation);
      case 1:
        wWriter = new SysLogWriter();
      case 2:
        wWriter = new PopUpWriter();
      case 3:
        wWriter = new ControlWriter(pParameters.getControlParam());
    }

    wWriter = wWriter.switchToLineWriter();

    switch (pParameters.getInputMode())
    {
      case 0:
        #if !JS_BROWSER
          rReader = new StdinReader();
        #else
          MutableConsole.log = wWriter.write;
        #end
      #if !JS_BROWSER
      case 1:
        rReader = new ProcessReader(pParameters.getProcessParam(), pParameters.getProcessParams());
      #end
    }

    rReader = rReader.switchToLineReader();
    
    if (pParameters.getInclude() != null || pParameters.getExclude() != null) {
      var frReader : FilterReader = new FilterReader(rReader);
      rReader = frReader;
      if (pParameters.getInclude() != null) {
        frReader.addFilter(Filter.parse(pParameters.getInclude(), false));
      }
      if (pParameters.getExclude() != null) {
        frReader.addFilter(Filter.parse(pParameters.getExclude(), true));
      }
    }

    (new Transfer()).transfer(rReader, wWriter);
  }

  /**
    Serves as entry point when running as a standalone application.
	**/
  static public function main() : Void {
    var pParameters = new Parameters();
    var sLocation : Null<String> = null;
    try {
      sLocation = pParameters.getFileParam();
    }
    catch (msg : Dynamic) {
    }
    if (sLocation == null) {
      sLocation = "~/Log";
    }
    var bWindows : Bool = false;
    #if sys
      bWindows = (Sys.systemName().indexOf("Windows") >= 0);
    #elseif JS_WSH
      bWindows = true;
    #elseif JS_NODE
      // TODO
    #end
    if (bWindows) {
      sLocation = StringTools.replace(StringTools.replace(sLocation, "/", "\\"), "~", "%userprofile%");
      #if sys
        var env = Sys.environment();
        for (v in env.keys()) {
          var val : String = env[v];
          sLocation = StringTools.replace(sLocation, "%" + v.toLowerCase() + "%", val);
          sLocation = StringTools.replace(sLocation, "%" + v.toUpperCase() + "%", val);
        }
      #elseif JS_WSH
        var shell = new com.sdtk.std.JS_WSH.ActiveXObject("wscript.shell");
        sLocation = shell.ExpandEnvironmentStrings(sLocation);
      #end
    }
    defaultTransfer(sLocation, pParameters);
  }
}
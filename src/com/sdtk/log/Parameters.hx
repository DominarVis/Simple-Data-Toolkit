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

#if !EXCLUDE_PARAMETERS
/**
  Handles command-line parameters.
**/
@:nativeGen
class Parameters extends com.sdtk.std.Parameters {
  private var _outputMode : Int = 0;
  private var _inputMode : Int = 0;
  private var _process : String;
  private var _processParams : Array<String>;
  private var _file : String;
  private var _outputControlId : String;
  private var _include : Null<String> = null;
  private var _exclude : Null<String> = null;

  public function new() {
    super();
    var i : Int = 0;
    var sParameter : Null<String>;

    do {
      sParameter = getParameter(i);
      if (sParameter != null) {
        if (_process != null) {
          _processParams.push(sParameter);
        } else {
          switch (sParameter.toUpperCase()) {
            case "EVENT", "EVENTS", "EVENTVIEWER", "EVENTLOGGER", "EVENTLOG", "EVENTLOGS":
              _outputMode = 1;
            case "POP", "POPUP", "ALERT", "ALERTS":
              _outputMode = 2;
            case "CONTROL":
              i++;
              _outputControlId = getParameter(i);
              _outputMode = 3;
            case "INCLUDE":
              i++;
              _include  = getParameter(i);
            case "EXCLUDE":
              i++;
              _exclude  = getParameter(i);
            case "VERSION":
              #if JS_BROWSER
                com.sdtk.std.JS_BROWSER.Console.log
              #elseif JS_WSH
                com.sdtk.std.JS_WSH.WScript.Echo
              #elseif JS_NODE
                com.sdtk.std.JS_NODE.Console.log
              #elseif JS_SNOWFLAKE
                com.sdtk.stdcom.sdtk.std.JS_SNOWFLAKE.Logger.log
              #else
                Sys.println
              #end
              (
                "Version 0.1.2"
              );
            default:
              var iPeriod = sParameter.indexOf(".");
              var iHash = sParameter.indexOf("#");

              if (iPeriod == 0 || iHash == 0) {
                _outputControlId = sParameter;
                _outputMode = 3;
              } else if (iPeriod < 0) {
                _process = sParameter;
                _inputMode = 1; 
              } else {
                _file = sParameter;
                _inputMode = 0;
              }
          }
        }
      }
      i++;
    } while (sParameter != null);
  }

  /**
    Handles determining output mode to run in.
    0 indicates using TS files.
    1 indicates using standard system logging.
  **/
  public function getOutputMode() : Int {
    return _outputMode;
  }

  /**
    Handles determining input mode to run in automatically.
    0 indicates using standard in for input.
    1 indicates using running an external process.
  **/
  public function getInputMode() : Int {
    return _inputMode;
  }
  
  /**
    Handles retrieval of the file parameter.
	**/
  public function getFileParam() : String {
    return _file;
  }

  /**
    Handle retrieval of the parameters for a child process.
  **/
  public function getProcessParams() : Array<String> {
    return _processParams;
  }

  /**
    Handles retrieval of the process parameter.
	**/
  public function getProcessParam() : String {
    return _process;
  }

  /**
    Handles retrieval of the control parameter.
  **/
  public function getControlParam() : String {
    return _outputControlId;
  }

  /**
    Handles retrieval of the include parameter.
  **/
  public function getInclude() : Null<String> {
    return _include;
  }

  /**
    Handles retrieval of the include parameter.
  **/
  public function getExclude() : Null<String> {
    return _exclude;
  }
}
#end

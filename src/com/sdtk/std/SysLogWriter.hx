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
    Standard/Core Library - Source code can be found on SourceForge.net
*/

package com.sdtk.std;

#if !EXCLUDE_SYS_LOGS
/**
  Defines interface for sending log entries to the standard system log location.
  For example, on windows, the Windows Event Logs.
**/
@:expose
@:nativeGen
class SysLogWriter extends Writer {
  #if JS_WSH
    var _logger : com.sdtk.std.JS_WSH.ActiveXObject;
  #end

  public function new() {
    super();
    #if JS_WSH
      _logger = new com.sdtk.std.JS_WSH.ActiveXObject("WScript.Shell");
    #end
  }

  public override function write(sLine : String) : Void {
    try {
        var sLineUpper = sLine.toUpperCase();
        var iLevel = 0;
        iLevel = sLineUpper.indexOf("WARN") >= 0 ? 1 : iLevel;
        iLevel = sLineUpper.indexOf("ERR") >= 0 ? 2 : iLevel;
      #if sys
        // TODO
      #elseif JS_WSH
        switch (iLevel) {
          case 0:
            iLevel = 4;
          case 1:
            iLevel = 2;
          default:
            iLevel = 1;
        }
        _logger.LogEvent(iLevel, sLine);
      #elseif JS_NODE
        // TODO
      #elseif JS_BROWSER
        com.sdtk.std.JS_BROWSER.Console.log(sLine);
      #else
        return null;
      #end
    } catch (msg : Dynamic) {
      return;
    }
  }

#if java
  @:native('close') 
#end
  public override function dispose() : Void {
    super.dispose();
    #if JS_WSH
      _logger = null;
    #end
  }
}
#end

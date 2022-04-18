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

import com.sdtk.std.JS_BROWSER;
import com.sdtk.std.JS_WSH;

#if !EXCLUDE_TSFILE
/**
  Defines interface for sending log entries to files based on time stamp.
**/
@:expose
@:nativeGen
class TSFileWriter extends com.sdtk.std.Writer {
  private var _location : String;
  private var _path : String;

  public function new(sLocation : String) {
    super();
    _location = sLocation;
    var sSeparator : String = "";
    #if JS_BROWSER
      sSeparator = "?";
    #elseif JS_SNOWFLAKE
      sSeparator = "?";
    #end
    _path = ((_location == null) ? "" : _location) + sSeparator + Math.ffloor(getTimeStamp() * 1000.0);
    #if sys
      _path = new haxe.io.Path(_path).toString();
    #end
  }

  private function getTimeStamp() : Float {
      #if sys
        return Sys.time();
      #elseif JS_WSH
        return Date.now().getTime() * 1.0;
      #elseif JS_NODE
        return Date.now().getTime() * 1.0;
      #elseif JS_BROWSER
        return Date.now().getTime() * 1.0;
      #elseif JS_SNOWFLAKE
        return Date.now().getTime() * 1.0;        
      #else
        return 0;
      #end
  }

  public override function write(sLine : String) : Void {
    try {
      #if sys
        var out : haxe.io.Output = sys.io.File.append(_path, false);
        try {
          out.writeString(sLine);
          out.writeString("\n");
        }
        catch (msg : Dynamic) {
        }
        out.close();
      #elseif JS_WSH
        var fso : ActiveXObject = new ActiveXObject("Scripting.FileSystemObject");
        var out : FileStreamObject = fso.OpenTextFile(_path, 8, true);
        try {
          out.Write(sLine);
        }
        catch (msg : Dynamic) {
        }
        out.Close();
      #elseif JS_SNOWFLAKE
        // TODO
      #elseif JS_NODE
        // TODO
      #elseif JS_BROWSER
        var xhr : XMLHttpRequest = new XMLHttpRequest();
        //xhr.onreadystatechange : Dynamic;
        xhr.open("GET", _path + "&" + sLine, true);
        xhr.send(null);
      #end
    }
    catch (msg : Dynamic) {
    }
  }
}
#end
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

import com.sdtk.std.JS_BROWSER;

#if !EXCLUDE_STDOUT
/**
  Defines interface for sending log entries to a control.
**/
@:expose
@:nativeGen
class ControlWriter extends Writer {
  #if JS_BROWSER
    private var _control : Element;
    private var _writer : Int;
  #else
    private var _control : Dynamic;
  #end
  private var _id : String;

  public function new(sControl : String) {
    super();
    _id = sControl;
    #if JS_BROWSER
      if (StringTools.startsWith(_id, ".")) {
        _control = Document.getElementsByClassName(_id.substring(1))[0];
      } else if (StringTools.startsWith(_id, "#")) {
        _control = Document.getElementById(_id.substring(1));
      } else {
        _control = Document.getElementById(_id);
      }
      switch (_control.tagName.toUpperCase()) {
        case "DIV":
          _writer = 0;
      }
    #end
  }

  public function send(sLine : String) : Void {
    try {
      #if sys
        // TODO
      #elseif JS_WSH
        // TODO
      #elseif JS_NODE
        // TODO
      #elseif JS_BROWSER
        switch (_writer) {
          case 0:
            _control.innerHTML += sLine + "<br />";
        }
      #else
        return null;
      #end
    } catch (msg : Dynamic) {
      return;
    }
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    _control = null;
  }
}
#end

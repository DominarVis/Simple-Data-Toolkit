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

#if !EXCLUDE_CONTROLS
/**
  Defines interface for reading log entries from a control.
**/
@:expose
@:nativeGen
class ControlReader extends StringReader {
  #if JS_BROWSER
    private var _control : Element;
  #else
    private var _control : Dynamic;
  #end
  private var _id : String;

  private static function getControl(sControl : String) : Null<
    #if JS_BROWSER
      Element
    #else
      Dynamic
    #end
  > {
    #if JS_BROWSER
      if (StringTools.startsWith(sControl, ".")) {
        return Document.getElementsByClassName(sControl.substring(1))[0];
      } else if (StringTools.startsWith(sControl, "#")) {
        return Document.getElementById(sControl.substring(1));
      } else {
        return Document.getElementById(sControl);
      }
    #end

    return null;
  }

  private static function getValue(sControl : String, bPlainText : Bool) : Null<String> {
    #if JS_BROWSER
      var cControl : Element
    #else
      var cControl : Dynamic
    #end
    = getControl(sControl);
    var sValue : Null<String> = null;
    #if JS_BROWSER
      switch (cControl.tagName.toUpperCase()) {
        case "DIV":
          if (bPlainText) {
            sValue = cControl.innerText;
          } else {
            sValue = cControl.innerHTML;
          }
      }
    #end
    return sValue;
  }

  public function new(sControl : String, bPlainText : Bool) {
    super(getValue(sControl, bPlainText));
    _control = getControl(sControl);
    _id = sControl;
  }

#if java
  @:native('close') 
#end
  public override function dispose() : Void {
    super.dispose();
    _control = null;
  }
}
#end

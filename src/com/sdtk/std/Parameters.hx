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

@:expose
@:nativeGen
class Parameters {
    private var _arguments : Array<String>;

    private function getArguments() : Void {
      #if JS_BROWSER
        var eScripts : Array<com.sdtk.std.JS_BROWSER.Element> = com.sdtk.std.JS_BROWSER.Document.getElementsByTagName("script");
        var eScript : com.sdtk.std.JS_BROWSER.Element = eScripts[eScripts.length - 1];
        var sScript : String = eScript.src;
        var regexp : EReg = ~/&|#/ig;
        sScript = regexp.replace(sScript, "?");
        var sArguments : Array<String> = sScript.split("?");
        if (sArguments.length <= 1) {
          return;
        }
        sArguments.shift();
        _arguments = sArguments;
      #elseif JS_WSH
        var sArguments : Array<String> = new Array<String>();
        var iArgument : Int = 0;
        while (true) {
            var sArgument : Null<String> = null;
            try {
              sArgument = JS_WSH.WScript.Arguments(iArgument);
            } catch (msg : Dynamic) {
            }
            if (sArgument != null) {
              sArguments.push(sArgument);
              iArgument++;
            } else {
              break;
            }
        }
        _arguments = sArguments;
      #else
        _arguments = Sys.args();
      #end
    }

    public function getParameter(i : Int) : Null<String> {
      try {
        return _arguments[i];
      } catch (msg : Dynamic) {
        return null;
      }
    }

    public function new() {
        getArguments();
    }
}

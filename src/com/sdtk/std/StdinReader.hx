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

#if JS_WSH
@:expose
@:nativeGen
class StdinReader extends Reader {
    private var _stdin : com.sdtk.std.JS_WSH.FileStreamObject;
    private var _current : Null<String> = null;

    public function new() {
        super();
        var fso : com.sdtk.std.JS_WSH.ActiveXObject = new com.sdtk.std.JS_WSH.ActiveXObject("Scripting.FileSystemObject");
        _stdin = fso.GetStandardStream(0);
    }

    public override function dispose() : Void {
        if (_stdin != null) {
            _stdin.Close();
            _stdin = null;
        }
    }

    private function check() : Void {
        if (_current == null) {
            try {
                _current = _stdin.Read(1);
            } catch (msg : Dynamic) {
                _current = null;
            }
        }
    }

    public override function hasNext() : Bool {
        check();
        return _current != null;
    }

    public override function next() : Null<String> {
        check();
        var sCurrent : String;
        sCurrent = _current;
        _current = null;
        return sCurrent;
    }

    public override function peek() : Null<String> {
        check();
        return _current;
    }
}
#elseif JS_NODE
// TODO
#elseif cs
@:expose
@:nativeGen
class StdinReader extends com.sdtk.std.CSHARP.AbstractReader {
    public function new() {
        super(new com.sdtk.std.CSHARP.StreamReader(com.sdtk.std.CSHARP.SystemI.OpenStandardInput()));
    }
}
#elseif java
@:expose
@:nativeGen
class StdinReader extends com.sdtk.std.JAVA.AbstractReader {
    public function new() {
        super(new com.sdtk.std.JAVA.InputStreamReader(com.sdtk.std.JAVA.SystemI.In));
    }
}
#elseif JS_SNOWFLAKE

#elseif JS_BROWSER

#else
@:expose
@:nativeGen
class StdinReader extends com.sdtk.std.HAXE.AbstractReader {
    public function new() {
        super(Sys.stdin());
    }
}
#end
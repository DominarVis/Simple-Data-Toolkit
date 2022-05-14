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

#if (JS_BROWSER || JS_SNOWFLAKE)
@:expose
@:nativeGen
class StdoutWriterAsync implements WriterAsync {
    private var _writer : StdoutWriter = new StdoutWriter();

    public function done(iBytes : Int, oAttachment : Dynamic) : Void {
    }    

    public function write(sData : String, whHandler : WriterHandler) : WriterAsync {
        if (_writer != null) {
          _writer.write(sData);
          whHandler.done();
        }
        return this;
    }

    public function dispose() : Void {
        if (_writer != null) {
            _writer.dispose();
            _writer = null;
        }
    }
}
#elseif JS_WSH
@:expose
@:nativeGen
class StdoutWriterAsync extends com.sdtk.std.JS_WSH.WriterAsyncAbstract {
    public function new() {
        super(new StdoutWriter());
    }
}
#elseif JS_NODE
// TODO
#elseif java
@:expose
@:nativeGen
class StdoutWriterAsync extends FileWriterAsync {
    public function new() {
        super((Sys.systemName().indexOf("Windows") >= 0) ? "CON" : "/proc/self/fd1");
    }
}
#elseif python

#end
// TODO
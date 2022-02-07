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
class StdinReaderAsync extends com.sdtk.std.JS_WSH.ReaderAsyncAbstractI {
    public function new() {
        super(new StdinReader());
    }
}
#elseif java
@:expose
@:nativeGen
class StdinReaderAsync extends FileReaderAsync {
    public function new() {
        super((Sys.systemName().indexOf("Windows") >= 0) ? "CON" : "/proc/self/fd0");
    }
}
#end
// TODO
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
class Writer
#if java
    extends com.sdtk.std.JAVA.WriterI
#end
#if cpp
    // TODO
#else
    implements Disposable implements Flushable
#end
 {
    public function new() {
        #if java
            super();
        #end
    }

    public function flip() : Reader {
        return null;
    }

    public function start() : Void {
    }

    #if cs
        @:native('Dispose')
    #elseif java
        @:native('close') 
        override
    #end
    public function dispose() : Void {
    }

    #if java
        override
    #end
    public function flush() : Void {
    }

    #if java
        override
    #end
    public function write(str : String) : Void {
    }

    #if java
        @:native('write') public function write2(cbuf : com.sdtk.std.JAVA.CharArray, off : Int, len : Int) : Void {
            this.write(new com.sdtk.std.JAVA.StringI(cbuf, off, len).toString());
        }
    #end

    public function switchToLineWriter() : Writer {
        return new WholeLineWriter(this);
    }

    public function unwrapOne() : Writer {
        return this;
    }

    public function unwrapAll() : Writer {
        return this;
    }
}

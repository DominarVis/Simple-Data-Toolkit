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

#if java
    import haxe.Int64;
#end

@:expose
@:nativeGen
class Reader
#if java
    extends com.sdtk.std.JAVA.ReaderI
#end
#if cpp
    // TODO
#else
    implements Disposable
    implements DataIterator<String>
    implements DataIterable<String>
#end {
    public function new() {
        #if java
            super();
        #end
    }

    public function start() : Void {
    }

    public function rawIndex() : Int {
        return -1;
    }

    public function jumpTo(index : Int) : Void { }

    public function hasNext() : Bool {
        return false;
    }

    public function next() : Null<String> {
        return null;
    }

    public function peek() : Null<String> {
        return null;
    }

    #if cs
        @:native('Dispose')
    #elseif java
        @:native('close')
        override
    #end
    public function dispose() : Void {
    }

    public function iterator() : DataIterator<String> {
        return this;
    }

    public function switchToLineReader() : Reader {
        return new WholeLineReader(this);
    }

    public function unwrapOne() : Reader {
        return this;
    }

    public function unwrapAll() : Reader {
        return this;
    }

    #if java
        public function readI(requested : Int) : com.sdtk.std.JAVA.StringI {
            var buf : StringBuf = new StringBuf();

            while (buf.length < requested) {
                buf.add(next());
            }

            return cast buf.toString();
        }

        public override function read() : Int {
            return readI(1).charAt(0);
        }
        
        #if java
            @:native('read') 
        #end
        public function read2(cbuf : com.sdtk.std.JAVA.CharArray) : Int {
            return read3(cbuf, 0, cbuf.length);
        }

        #if java
            @:native('read') 
        #end
        public function read3(cbuf : com.sdtk.std.JAVA.CharArray, off : Int, len : Int) : Int {
            var s : com.sdtk.std.JAVA.StringI = readI(len - off);
            var copy : Int;

            if (s.length() > len) {
                copy = len;
            } else {
                copy = s.length();
            }

            s.getChars(0, copy, cbuf, off);

            return copy;
        }

        #if java
            @:native('read') 
        #end
        public function read4(target : com.sdtk.std.JAVA.CharBuffer) : Int {
            var s : com.sdtk.std.JAVA.StringI = readI(target.capacity());
            var cb : com.sdtk.std.JAVA.CharBuffer = com.sdtk.std.JAVA.CharBuffer.allocate(s.length());

            cb.append(s);

            return s.length();
        }

        public function ready() : Bool {
            return true;
        }

        #if java
            override
        #end
        public function reset() : Void {
        }

        #if java
            override
        #end        
        public function skip(n : Int64) : Int64 {
            var i : Int64 = n.copy();
            var dec : Int64 = Int64.neg(Int64.make(0, 1));

            while (i > 0) {
                try {
                    next();
                    return Int64.sub(i, dec);
                } catch (msg : Dynamic) {
                    return Int64.sub(n, i);
                }
            }

            return n;
        }

        public function markSupported() : Bool {
            return false;
        }

        public function mark(readAheadLimit : Int) : Void{

        }
    #end
}

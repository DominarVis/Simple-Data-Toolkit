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

// TODO Read user files
// TODO Throw exceptions
// TODO Test

package com.sdtk.std;

#if java
@:native('java.lang.Thread') extern class ThreadI {
    public static function currentThread() : ThreadI;
    public function getContextClassLoader() : ClassLoader;
}

@:native('java.lang.ClassLoader') extern class ClassLoader {
    public function getResourceAsStream(sName : String) : InputStream;
}

@:native('java.io.InputStream') extern class InputStream implements Disposable {
    @:native('close') public function dispose() : Void;
}

@:native('java.io.PrintStream') extern class PrintStream implements Disposable {
    @:native('close') public function dispose() : Void;
    public function flush() : Void;
    public function print(sValue : String) : Void;
}

@:native('java.io.Reader') extern class ReaderI implements Disposable {
    public function new();
    public function read() : Int;
    public function reset() : Void;
    public function skip(i : haxe.Int64) : haxe.Int64;
    @:native('close') public function dispose() : Void;
}

@:native('java.io.InputStreamReader') extern class InputStreamReader extends ReaderI {
    public function new(is : InputStream);
    public override function read() : Int;
    @:native('read') public function bufferRead(cbuf : java.NativeArray<java.StdTypes.Char16>, offset : Int, length : Int) : Int;
    @:native('close') public override function dispose() : Void;
}

@:native('java.lang.System') extern class SystemI {
    @:native('in')  public static var In : InputStream;
    @:native('out') public static var Out : PrintStream;
}

@:javaCanonical('', 'char[]') @:native('char[]') extern class CharArray {
    public var length : Int;
}

@:native('java.io.StringReader') extern class StringReaderI extends ReaderI {
    public function new(str : String);
    @:native('close') public override function dispose() : Void;
    public override function read() : Int;
}

@:native('java.io.FileReader') extern class FileReaderI extends ReaderI {
    public function new(str : String);
    @:native('close') public override function dispose() : Void;
    public override function read() : Int;
}

@:native('java.io.FileWriter') extern class FileWriterI extends WriterI {
    public function new(str : String, append : Bool);
    @:native('close') public override function dispose() : Void;
}

@:native('java.nio.ByteBuffer') extern class ByteBuffer {
    public function flip() : Void;
    public static function allocate(i : Int) : ByteBuffer;
}

@:native('java.nio.CharBuffer') extern class CharBuffer {
    public static function allocate(capacity : Int) : CharBuffer;
    public function append(c : StringI) : CharBuffer;
    public function capacity() : Int;
    public function toString() : String;
}

@:native('java.nio.channels.CompletionHandler') extern interface CompletionHandler<T1, T2> {
    public function completed(result : T1, attachment : T2) : Void;
    public function failed(exc : Throwable, attachment : T2) : Void;
}

@:native('java.nio.channels.AsynchronousByteChannel') extern class AsynchronousByteChannel {
    public function read<A>(buffer : ByteBuffer, attachment : Dynamic, handler : CompletionHandler<Int, A>) : Void;
    public function close() : Void;
}

@:native('java.nio.file.Path') extern class Path {
}

@:native('java.nio.file.Paths') extern class Paths {
    public static function get(path : String) : Path;
}

@:native('java.nio.file.StandardOpenOption') extern class StandardOpenOption {
    public static var READ : StandardOpenOption;
}

@:native('java.nio.channels.AsynchronousFileChannel') extern class AsynchronousFileChannel {
    public static function open(path : Path, option : StandardOpenOption) : AsynchronousFileChannel;
    public function read<A>(buffer : ByteBuffer, position : Int, attachment : Dynamic, handler : CompletionHandler<Int, A>) : Void;
    public function write<A>(src : ByteBuffer, position : Int, attachment : Dynamic, handler : CompletionHandler<Int, A>) : Void;
    public function close() : Void;
}

@:native('java.lang.Throwable') extern class Throwable {
}

@:native('java.nio.charset.Charset') extern class Charset {
    public static function defaultCharset() : Charset;
    public function decode(buffer : ByteBuffer) : CharBuffer;
}

@:native('java.io.Writer') extern class WriterI implements Disposable implements Flushable {
    public function new();
    @:native('close')
    public function dispose() : Void;
    public function flush() : Void;
    public function write(str : String) : Void;
    //@:native('write') public function write2(cbuf : CharArray, off : Int, len : Int) : Void;
}

@:native('java.lang.String') extern class StringI {
    public function new(value : CharArray, offset : Int, count : Int);
    public function charAt(index : Int) : Int;
    public function getChars(srcBegin : Int, srcEnd : Int, dst : CharArray, dstBegin : Int) : Void;
    public function length() : Int;
    public function toString() : String;
}

@:nativeGen
class CompletionHandlerI implements CompletionHandler<Int, Dynamic> {
    private var _usedBy : UsesCompletionHandler;

    public function new(uchUsedBy : UsesCompletionHandler) {
        _usedBy = uchUsedBy;
    }

    public function completed(result : Int, attachment : Dynamic) : Void {
        _usedBy.done(result, attachment);
    }

    public function failed(exc : Throwable, attachment : Dynamic) : Void {
        _usedBy.done(-1, null);
    }
}

@:nativeGen
class AbstractReaderAsync implements ReaderAsync implements UsesCompletionHandler {
    private var _handlers : Array<ReaderHandler>;

    public function new() {
        _handlers = new Array<ReaderHandler>();
    }

    public function readTo(rhHandler : ReaderHandler) : ReaderAsync {
        _handlers.push(rhHandler);
        return this;
    }

    public function done(iBytes : Int, oAttachment : Dynamic) : Void {
    }

    public function send(sData : String) {
        var i : Int = 0;
        while (i < sData.length) {
            var sChar = sData.substr(i, 1);
            for (rhHandler in _handlers) {
                rhHandler.read(sChar);
            }
            i++;
        }
    }

    public function start() : ReaderAsync {
        return this;
    }

    @:native('close') public function dispose() : Void {
        _handlers = null;
    }
}

@:nativeGen
class AbstractReader extends Reader {
    private var _next : Null<String> = null;
    private var _reader : Null<ReaderI>;
    private var _nextRawIndex : Null<Int>;
    private var _rawIndex : Null<Int>;

    public function new(rReader : ReaderI) {
        super();
        _reader = rReader;
        _next = "";
        _nextRawIndex = 0;
        _rawIndex = 0;
    }

    public override function reset() : Void {
        _nextRawIndex = 0;
        try {
            _reader.reset();
        } catch (msg : Dynamic) { }
    }

    public override function rawIndex() : Int {
        return _rawIndex;
    }

    public override function jumpTo(index : Int) : Void {
        if (index < _nextRawIndex) {
            reset();
        }
        try {
            _reader.skip(index - _nextRawIndex);
        } catch (msg : Dynamic) { }
        _nextRawIndex = index;
    }

    public override function start() : Void {
        moveToNext();
    }

    private function moveToNext() {
        try {
            var c : Int = _reader.read();
            if (c > 0) {
                _next = String.fromCharCode(c);
            } else {
                dispose();
            }
        } catch (message : Dynamic) {
            dispose();
        }
    }

    public override function hasNext() : Bool {
        return (_next != null);
    }

    public override function next() : Null<String> {
        var sValue : Null<String> = _next;
        if (sValue != null) {
            moveToNext();
        }
        return sValue;
    }

    public override function peek() : Null<String> {
        return _next;
    }

    @:native('close') public override function dispose() {
        if (_reader != null) {
            try {
                _reader.dispose();
            } catch (msg : Dynamic ) { }
            _reader = null;
            _next = null;
        }
    }

    public override function iterator() : DataIterator<String> {
        return this;
    }
}
#end
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
// TODO Asynchronous

package com.sdtk.std;

#if cs
@:native('System.IO.TextReader') extern class TextReader implements Disposable {
    @:native('Dispose') public function dispose() : Void;
    public function Read() : Int;
    public function ReadLine() : String;
    public function ReadToEnd() : String;
}

@:native('System.IO.TextWriter') extern class TextWriter implements Disposable {
    @:native('Dispose') public function dispose() : Void;
    @:native('Flush') public function flush() : Void;
    public function Write(str : String) : Void;
    public function WriteLine(str : String) : Void;
}

@:native('System.IO.Stream') extern class Stream implements Disposable {
    @:native('Dispose') public function dispose() : Void;
}

@:native('System.IO.StreamReader') extern class StreamReader extends TextReader {
    public function new(s : Stream);
    @:native('Dispose') public function dispose() : Void;
}

@:native('System.IO.StreamWriter') extern class StreamWriter extends TextWriter {
    public function new(s : Stream);
    @:native('Dispose') public function dispose() : Void;
}

@:native('System.Console') extern class SystemI {
    public static function OpenStandardInput() : Stream;
    public static function OpenStandardOutput() : Stream;
    public static function Read() : Int;
    public static function ReadLine() : String;
    public static function Write(str : String) : Void;
    public static function WriteLine(str : String) : Void;
}

@:native('System.IO.StringReader') extern class StringReaderI extends TextReader {
    public function new(str : String);
    public function Read() : Int;
    @:native('Dispose') public function dispose() : Void;
}

@:native('System.IO.FileMode') extern enum FileMode {
    CreateNew; Create; Open; OpenOrCreate; Truncate; Append;
}

@:native('System.IO.File') extern class File {
    public static function OpenText(path : String) : StreamReader;
    public static function Open(path : String, mode: FileMode) : FileStream;
}

@:native('System.IO.FileStream') extern class FileStream extends Stream {
    @:native('Dispose') public override function dispose() : Void;
}

@:nativeGen
class AbstractReader extends Reader {
    private var _next : Null<String> = null;
    private var _nextRawIndex : Null<Int>;
    private var _rawIndex : Null<Int>;
    private var _reader : Null<TextReader>;
    private var _mode : Int = 0;

    public function new(trReader : TextReader) {
        super();
        _reader = trReader;
        _next = "";
        _rawIndex = 0;
        _nextRawIndex = 0;
    }

    public override function reset() : Void {
        _nextRawIndex = 0;
    }

    public override function rawIndex() : Int {
        return _rawIndex;
    }
    
    public override function jumpTo(index : Int) : Void {
        if (index < _nextRawIndex) {
            reset();
        }
        while (_nextRawIndex < index) {
            _reader.Read();
            _nextRawIndex++;
        }
    }

    public override function start() : Void {
        moveToNext();
    }

    private function moveToNext() {
        try {
            _next = null;
            switch (_mode) {
                case 0:
                    var c : Int = _reader.Read();
                    if (c > 0) {
                        _next = String.fromCharCode(c);
                        _nextRawIndex += _next.length;
                    } else {
                        dispose();
                    }
                case 1:
                    _next = _reader.ReadLine();
                    _nextRawIndex += _next.length;
            }
        } catch (message : Dynamic) {
            dispose();
        }
    }

    public override function hasNext() : Bool {
        return (_next != null);
    }

    public override function next() : Null<String> {
        _rawIndex = _nextRawIndex;
        var sValue : Null<String> = _next;
        if (sValue != null) {
            moveToNext();
        }
        return sValue;
    }

    public override function peek() : Null<String> {
        return _next;
    }

    public override function switchToLineReader() : Reader {
        _mode = 1;
        return this;
    }

    public override function unwrapOne() : Reader {
        _mode = 0;
        return this;
    }

    public override function unwrapAll() : Reader {
        _mode = 0;
        return this;
    }

    @:native('Dispose') public override function dispose() {
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

@:nativeGen
class AbstractWriter extends Writer {
    private var _writer : Null<TextWriter>;

    public function new(twWriter : TextWriter) {
        super();
        _writer = twWriter;
    }

    public override function write(str : String) : Void {
        _writer.Write(str);
    }

    public override function flush() : Void {
        _writer.flush();
    }

    @:native('Dispose') public override function dispose() {
        if (_writer != null) {
            try {
                flush();
                _writer.dispose();
            } catch (msg : Dynamic ) { }
            _writer = null;
        }
    }
}
#end
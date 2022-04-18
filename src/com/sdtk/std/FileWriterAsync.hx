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

#if JS_BROWSER
@:expose
@:nativeGen
class FileWriterAsync implements WriterAsync {
    private var _writer : StringWriterAsync = new StringWriterAsync();
    private var _file : String;

    public function new(name : String) {
        _file = name;
    }

    public function done(iBytes : Int, oAttachment : Dynamic) : Void {
    }    

    public function dispose() : Void {
        if (_writer != null) {
            var request : com.sdtk.std.JS_BROWSER.XMLHttpRequest = new com.sdtk.std.JS_BROWSER.XMLHttpRequest();
            request.open('PUT', _file, true);
            request.onload = function () { };
            request.onerror = function () { };
            request.send(_writer.toString());
            _file = null;
            _writer.dispose();
            _writer = null;
        }
    }

    public function write(str : String, whHandler : WriterHandler) : WriterAsync {
        if (_writer != null) {
            _writer.write(str, whHandler);
        }
        return this;
    }
}
#elseif JS_SNOWFLAKE
    // TODO
#elseif JS_WSH
@:expose
@:nativeGen
class FileWriterAsync extends com.sdtk.std.JS_WSH.WriterAsyncAbstract {
    public function new(sName : String, bAppend : Bool) {
        super(new FileWriter(sName, bAppend));
    }
}
#elseif JS_NODE
// TODO
@:expose

#elseif java
@:expose
@:nativeGen
class FileWriterAsync implements WriterAsync {
    private var _channel : com.sdtk.std.JAVA.AsynchronousFileChannel;
    private var _mainHandler : com.sdtk.std.JAVA.CompletionHandlerI;
    private var _buffer : com.sdtk.std.JAVA.ByteBuffer = com.sdtk.std.JAVA.ByteBuffer.allocate(1024);
    private var _position : Int;

    public function new(sPath : String) {
        _position = 0;
        _mainHandler = new com.sdtk.std.JAVA.CompletionHandlerI(this);
        try {
            _channel = com.sdtk.std.JAVA.AsynchronousFileChannel.open(com.sdtk.std.JAVA.Paths.get(sPath), com.sdtk.std.JAVA.StandardOpenOption.READ);
        } catch (msg : Dynamic) { }
    }

    public function done(iBytes : Int, oAttachment : Dynamic) {
        cast(oAttachment, WriterHandler).done();
    }

    public function write(sData : String, whHandler : WriterHandler) : WriterAsync {
        _channel.write(_buffer, cast _position, cast whHandler, cast _mainHandler);
        return this;
    }

    @:native('close') public function dispose() : Void {
        if (_channel != null) {
            try {
                _channel.close();
            } catch (msg : Dynamic ) { }
            _mainHandler = null;
            _buffer = null;
            _channel = null;
            _position = -1;
        }
    }
}
#end
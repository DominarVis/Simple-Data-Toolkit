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
class FileReaderAsync extends ReaderAsyncAbstract {
    private var _request : Null<com.sdtk.std.JS_BROWSER.XMLHttpRequest>;
    private var _reader : Null<StringReaderAsync> = new StringReaderAsync("");
    private var _name : Null<String>;

    public function new(str : String) {
      _name = str;
    }

    public override function start() : ReaderAsync {
        try {
            _request = new com.sdtk.std.JS_BROWSER.XMLHttpRequest();
            _request.open('GET', _name, true);
            _request.onload = function () {
                if (_request.readyState == 4) {
                  if (_request.status == 200) {
                    _reader.setString(_request.responseText);
                    _reader.start();
                  } else {
                    read(null);
                    dispose();
                  }
                }
            };
            _request.onerror = function () {
              read(null);
              dispose();
            };
            _request.send(null);
        } catch (msg : Dynamic) {
            this.dispose();
        }
        return this;
    }

    public override function readTo(rhHandler : ReaderHandler) : ReaderAsync {
        _reader.readTo(rhHandler);
        return this;
    }

    public override function dispose() : Void {
      if (_request != null) {
          _reader.dispose();
          _request = null;
          _reader = null;
          _name = null;
      }
    }
}
#elseif JS_WSH
@:expose
@:nativeGen
class FileReaderAsync extends com.sdtk.std.JS_WSH.ReaderAsyncAbstractI {
    public function new(sName : String) {
        super(new FileReader(sName));
    }
}
#elseif JS_NODE
// TODO
@:expose

#elseif java
@:expose
@:nativeGen
class FileReaderAsync extends com.sdtk.std.JAVA.AbstractReaderAsync {
    private var _channel : com.sdtk.std.JAVA.AsynchronousFileChannel;
    private var _mainHandler : com.sdtk.std.JAVA.CompletionHandlerI;
    private var _buffer : com.sdtk.std.JAVA.ByteBuffer = com.sdtk.std.JAVA.ByteBuffer.allocate(1024);
    private var _position : Int;

    public function new(sValue : String) {
        super();
        _position = 0;
        _mainHandler = new com.sdtk.std.JAVA.CompletionHandlerI(this);
        try {
            _channel = com.sdtk.std.JAVA.AsynchronousFileChannel.open(com.sdtk.std.JAVA.Paths.get(sValue), com.sdtk.std.JAVA.StandardOpenOption.READ);
        } catch (msg : Dynamic) { }
    }

    public override function done(iBytes : Int, oAttachment : Dynamic) : Void {
        if (iBytes > 0) {
            _position += iBytes;
            _buffer.flip();
            send(com.sdtk.std.JAVA.Charset.defaultCharset().decode(_buffer).toString());
            _buffer.flip();
            start();
        } else if (iBytes == 0) {
            for (rhHandler in _handlers) {
                rhHandler.read(null);
            }
            dispose();
        } else {
            for (rhHandler in _handlers) {
                rhHandler.read(null);
            }
            dispose();
        }
    }

    public override function start() : ReaderAsync {
        _channel.read(_buffer, cast _position, cast this, cast _mainHandler);
        return this;
    }

    @:native('close') public override function dispose() : Void {
        if (_channel != null) {
            try {
                _channel.close();
            } catch (msg : Dynamic ) { }
            _buffer = null;
            _channel = null;
            _mainHandler = null;
            super.dispose();
        }
    }
}
#end
// TODO
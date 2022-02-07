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
@:expose
@:nativeGen
class StringReaderAsync extends com.sdtk.std.JAVA.AbstractReaderAsync {
    private var _data : String;
    private var _position : Int;

    public function new(sValue : String) {
        super();
        _data = sValue;
        _position = 0;
    }

    public override function start() : ReaderAsync {
        while (_position < _data.length) {
            send(_data.substr(_position, 1));
            _position++;
        }
        return this;
    }

    @:native('close') public override function dispose() : Void {
        super.dispose();
    }
}
#elseif (JS_BROWSER || JS_WSH)
@:expose
@:nativeGen
class StringReaderAsync extends ReaderAsyncAbstract {
    private var _reader : Null<StringReader>;

    public function new(sValue : String) {
        _reader = new StringReader(sValue);
    }

    public override function start() : ReaderAsync {
        while (_reader.hasNext()) {
            var sValue : String = _reader.next();
            read(sValue);
        }
        return this;
    }

    public function setString(sValue : String) {
        _reader.setString(sValue);
    }

    public override function dispose() {
        if (_reader != null) {
            super.dispose();
            _reader = null;
        }
    }
}
#end

// TODO
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
class StringWriter extends Writer {
    private var _buffer : Null<StringBuf> = null;
    private var _writer : Null<Writer> = null;
    private var _end : Null<String> = null;
    private var _dropping : Int = -1;

    public function new(reuse : Null<StringBuf>) {
      super();
      if (reuse == null) {
        _buffer = new StringBuf();
      } else {
      	_buffer = reuse;
      }
    }

    public function endWith(writer : Writer) : Void {
      _writer = writer;
    }

    #if java
        @:native('close') 
    #end
    public override function dispose() : Void {
      if (_buffer != null) {
        _end = _buffer.toString();
      }
      if (_writer != null) {
        _writer.write(_end);
        _writer.dispose();
        _writer = null;
      }
      _buffer = null;
    }

    public function toString() : String {
      if (_buffer != null) {
        return _buffer.toString();
      } else {
        return _end;
      }
    }

    public override function write(str : String) : Void {
      _buffer.add(str);
      if (_dropping > 0 && _buffer.length > _dropping) {
        _writer.write(_buffer.toString());
        _buffer = new StringBuf();
      }
    }

    public function switchToDroppingCharacters(?chars : Int = 10000) : Writer {
      _dropping = chars;
      return this;
    }    
}

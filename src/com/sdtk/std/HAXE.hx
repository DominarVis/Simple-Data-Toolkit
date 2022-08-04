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

#if (!cs && !java && !JS_BROWSER && !JS_NODE && !JS_WSH && !JS_SNOWFLAKE)
import haxe.io.Input;
import haxe.io.Output;

class AbstractReader extends Reader {
  private var _next : Null<String> = null;
  private var _reader : Null<Input>;
  private var _mode : Int = 0;
  private var _nextRawIndex : Null<Int>;
  private var _rawIndex : Null<Int>;  
  

  public function new(iReader : Input) {
    super();
    _reader = iReader;
    _next = "";
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
    _reader.readString(index - _nextRawIndex);
    _nextRawIndex = index;
  }  

  public override function start() : Void {
    moveToNext();
  }

  private function moveToNext() {
      try {
            switch (_mode) {
                case 0:
                    _next = _reader.readString(1);
                case 1:
                    _next = _reader.readLine();
        }
          
      } catch (message : Dynamic) {
          dispose();
      }
  }

  public override function next() : String {
    var sValue : Null<String> = _next;
    if (sValue != null) {
        moveToNext();
    }
    return sValue;
  }

  public override function peek() : String {
    return _next;
  }

  public override function dispose() {
    if (_reader != null) {
      _reader.close();    
      _reader = null;
      _next = null;
    }
  }

    public override function unwrapOne() : Reader {
        _mode = 0;
        return this;
    }

    public override function unwrapAll() : Reader {
        _mode = 0;
        return this;
    }

    public override function switchToLineReader() : Reader {
        _mode = 1;
        return this;
    }

  public override function hasNext() : Bool {
    return (_next != null);
  }
}

class AbstractWriter extends Writer {
  private var _writer : Null<Output>;

  public function new(oWriter : Output) {
    super();
    _writer = oWriter;
  }

  public override function dispose() : Void {
    if (_writer != null) {
      _writer.close();
      _writer = null;
    }
  }

  public override function flush() : Void {
    _writer.flush();
  }  

  public override function write(str : String) : Void {
    _writer.writeString(str);
  }
}
#end
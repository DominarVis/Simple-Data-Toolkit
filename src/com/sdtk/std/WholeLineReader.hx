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
class WholeLineReader extends Reader {
  private var _empty : Bool = true;
  private var _buffer : StringBuf = new StringBuf();
  private var _list : Null<Array<String>>;
  private var _current : Null<String>;
  private var _reader : Null<Reader>;

  public function new(rReader : Reader) {
    super();
    _reader = rReader;
  }

  private function check() : Void {
     if (_current == null) {
       if (_list != null && _list.length > 0) {
         _current = _list.shift();
       } else if (_empty && _reader.hasNext() == false) {
         return;
       } else {
        try {
          while (true) {
            var s : Null<String> = _reader.next();
            if (s == null && !_empty) {
              s = "\n";
            }
            if (s != null) {
              _buffer.add(s);
              _empty = false;
            }
            if (s == null || s.indexOf("\n") >= 0) {
              var sLines : Array<String> = s.split("\n");
              _buffer.add(sLines[0]);
              _current = _buffer.toString();
              _buffer = new StringBuf();
              if (sLines.length <= 1 || sLines[sLines.length - 1].length == 0) {
                _empty = true;
              } else {
                _buffer.add(sLines[sLines.length - 1]);
                _empty = ([sLines.length - 1].length <= 0);
              }
              var i : Int = 1;
              while (i < sLines.length - 1) {
                _list.push(sLines[i++]);
              }
              break;
            }
          }
        } catch (msg : Dynamic) {
          _current = null;
        }
      }
    }
  }

    public override function hasNext() : Bool {
        check();
        return _current != null;
    }

    public override function next() : Null<String> {
        check();
        var sCurrent : String = _current;
        _current = null;
        return sCurrent;
    }

    public override function peek() : Null<String> {
        check();
        return _current;
    }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
 public override function dispose() : Void {
    if (_reader != null) {
      _reader.dispose();
      _reader = null;
      _buffer = null;
      _current = null;
      _list = null;
    }
  }

      public override function switchToLineReader() : Reader {
        return this;
    }

    public override function unwrapOne() : Reader {
        return _reader;
    }

    public override function unwrapAll() : Reader {
        return _reader.unwrapAll();
    }
}

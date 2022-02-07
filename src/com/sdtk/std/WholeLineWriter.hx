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

/**
  Defines interface for sending log entries to a popup or alert.
**/
@:expose
@:nativeGen
class WholeLineWriter extends Writer {
  private var _empty : Bool = true;
  private var _buffer : StringBuf = new StringBuf();
  private var _writer : Null<Writer>;

  public function new(wWriter : Writer) {
    super();
    _writer = wWriter;
  }

  public override function write(str : String) : Void {
    if (str.lastIndexOf("\n") < 0) {
      _buffer.add(str);
      _empty = false;
    } else {
      var sLines : Array<String> = str.split("\n");
      var iLine : Int = 1;
      for (sLine in sLines) {
          if (iLine == sLines.length) {
              if (sLine.length > 0) {
                _buffer.add(sLine);
              }
          } else if (_empty) {
              _writer.write(str);
          } else {
              _buffer.add(sLine);
              _writer.write(_buffer.toString());
              _buffer = new StringBuf();
              _empty = true;
          }
          iLine++;
      }
    }
  }

    public override function switchToLineWriter() : Writer {
        return this;
    }

    public override function unwrapOne() : Writer {
        return _writer;
    }

    public override function unwrapAll() : Writer {
        return _writer.unwrapAll();
    }

  public override function flush() {
    _writer.flush();
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_writer != null) {
      _writer.dispose();
      _writer = null;
      _buffer = null;
    }
  }
}

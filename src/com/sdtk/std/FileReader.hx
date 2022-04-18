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
class FileReader extends Reader {
    private var _request : Null<com.sdtk.std.JS_BROWSER.XMLHttpRequest>;
    private var _reader : Null<StringReader>;

    public function new(str : String) {
        super();
        try {
            _request = new com.sdtk.std.JS_BROWSER.XMLHttpRequest();
            _request.open('GET', str, false);
            _request.send(null);

            if (_request.status == 200) {
                _reader = new StringReader(_request.responseText);
            }
        } catch (msg : Dynamic) {
            this.dispose();
        }
    }

    public override function rawIndex() : Int {
      return _reader.rawIndex();
    }

    public override function jumpTo(index : Int) : Void {
      _reader.jumpTo(index);
    }

    public override function dispose() : Void {
      if (_request != null) {
          _reader.dispose();
          _request = null;
          _reader = null;
      }
    }

    public override function hasNext() : Bool {
        if (_reader != null) {
          return _reader.hasNext();
        } else {
          return false;
        }
    }

    public override function next() : Null<String> {
        if (_reader != null) {
          return _reader.next();
        } else {
          return null;
        }
    }

    public override function peek() : Null<String> {
        if (_reader != null) {
          return _reader.peek();
        } else {
          return null;
        }
    }

    public function convertToStringReader() : StringReader {
      var sr : StringReader = _reader;
      dispose();
      return sr;
    }
}
#elseif JS_SNOWFLAKE
  // TODO
#elseif JS_WSH
@:expose
@:nativeGen
class FileReader extends Reader {
  private var _in : com.sdtk.std.JS_WSH.FileStreamObject;
  private var _path : String;
  private var _next : Null<String> = null;
  private var _nextRawIndex : Null<Int>;
  private var _currentRawIndex : Null<Int>;

  public function new(sName : String) {
      super();
      _path = sName;
      var fso : com.sdtk.std.JS_WSH.ActiveXObject = new com.sdtk.std.JS_WSH.ActiveXObject("Scripting.FileSystemObject");
      _in = fso.OpenTextFile(_path, 1, false);
      _nextRawIndex = 0;
  }

  public override function rawIndex() : Int {
    return _currentRawIndex;
  }

  public override function jumpTo(index : Int) : Void {
    if (index < _nextRawIndex) {
      var fso : com.sdtk.std.JS_WSH.ActiveXObject = new com.sdtk.std.JS_WSH.ActiveXObject("Scripting.FileSystemObject");
      _in = fso.OpenTextFile(_path, 1, false);
      _nextRawIndex = 0;
    }
    _in.Skip(index - _nextRawIndex);
    _nextRawIndex = index;
    check();
  }

  public override function start() : Void {
    check();
  }

  private function check() : Void {
    if (_in != null) {
        try {
          _next = _in.Read(1);
        }
        catch (msg : Dynamic) {
          _next = null;
          dispose();
        }
        _nextRawIndex++;
    } else {
      _next = null;
    }
  }

  public override function hasNext() : Bool {
    return _next != null;
  }

  public override function next() : String {
    var _current = _next;
    check();
    return _current;
  }

  public override function peek() : String {
    return _next;
  }

  public override function dispose() : Void {
    if (_path != null) {
      _path = null;
      _in.Close();    
      _in = null;
    }
  }

  public function convertToStringReader() : StringReader {
    var s : String = "";
    if (_next != null) {
      s += _next;
    }
    s += _in.ReadAll();
    var sr : StringReader = new StringReader(s);
    this.dispose();
    return sr;
  }
}
#elseif JS_NODE
// TODO
@:expose
#elseif cs
@:expose
@:nativeGen
class FileReader extends com.sdtk.std.CSHARP.AbstractReader {
    private var _path : String;

    public function new(sValue : String) {
        super(com.sdtk.std.CSHARP.File.OpenText(sValue));
        _path = sValue;
    }

    private override function reset() : Void {
      super.reset();
      _reader = com.sdtk.std.CSHARP.File.OpenText(_path);
    }

    public function convertToStringReader() : StringReader {
      var s : String = "";
      if (_next != null) {
        s += _next;
      }
      s += _reader.ReadToEnd();
      var sr : StringReader = new StringReader(s);
      this.dispose();
      return sr;
    }
}
#elseif java
@:expose
@:nativeGen
class FileReader extends com.sdtk.std.JAVA.AbstractReader {
    private var _path : String;

    private static function createReaderI(sValue : String) : Null<com.sdtk.std.JAVA.ReaderI> {
        try {
            return new com.sdtk.std.JAVA.FileReaderI(sValue);
        } catch (msg : Dynamic) {
            return null;
        }
    }

    public function new(sValue : String) {
        super(createReaderI(sValue));
        _path = sValue;
    }

    public function convertToStringReader() : StringReader {
      var reader : JAVA.InputStreamReader = cast _reader;
      var sb : StringBuf = new StringBuf();
      if (_next != null) {
        sb.add(_next);
      }
      var buf : java.NativeArray<java.StdTypes.Char16> = new java.NativeArray<java.StdTypes.Char16>(10000);
      var read : Int;

      try {
        read = reader.bufferRead(buf, 0, buf.length);
      } catch (ex : Any) {
        read = -1;
      }
      while (read > 0) {
        sb.add(java.NativeString.copyValueOf(buf, 0, read));
        try {
          read = reader.bufferRead(buf, 0, buf.length);
        } catch (ex : Any) {
          read = -1;
        }
      }
      var sr : StringReader = new StringReader(sb.toString());
      this.dispose();
      return sr;
    }
}
#else
import haxe.io.Input;
import sys.io.File;
import sys.io.FileInput;

@:expose
@:nativeGen
class FileReader extends com.sdtk.std.HAXE.AbstractReader {
  private var _path : String;

  public function new(sName : String) {
    super(File.read(sName));
    _path = sName;
  }

  private override function reset() : Void {
    super.reset();
    _reader = File.read(_path);
  }  
  
  public function convertToStringReader() : StringReader {
    var sb : StringBuf = new StringBuf();
    if (_next != null) {
      sb.add(_next);
    }
    var s : String = _reader.readString(10000);
    while (s != null && s.length > 0) {
      sb.add(s);
      try {
        s = _reader.readString(10000);
      } catch (msg : Any) {
        s = null;
      }
    }
    var sr : StringReader = new StringReader(sb.toString());
    this.dispose();
    return sr;
  }
}
#end
// TODO
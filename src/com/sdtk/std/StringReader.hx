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
// TODO
@:expose
@:nativeGen
class StringReader extends com.sdtk.std.JAVA.AbstractReader {
    public function new(sValue : String) {
        super(new com.sdtk.std.JAVA.StringReaderI(sValue));
    }

    public function switchToDroppingCharacters(?chars : Int = 10000) : Reader {
        // TODO
        return this;
    }
}
#else
@:nativeGen
interface StringReaderMethod {
    public function moveToNext(index : Int, value : String) : String;
}

@:nativeGen
class StringReaderEachChar implements StringReaderMethod {
    private function new() { }

    private static var _instance : StringReaderMethod;

    public static function instance() : StringReaderMethod {
      if (_instance == null) {
          _instance = new StringReaderEachChar();
      }
      return _instance;
    }  

    public function moveToNext(index : Int, value : String) : String {
        return value.substr(index, 1);
    }
}

@:nativeGen
class StringReaderEachLine implements StringReaderMethod {
    private function new() { }

    private static var _instance : StringReaderMethod;

    public static function instance() : StringReaderMethod {
      if (_instance == null) {
          _instance = new StringReaderEachLine();
      }
      return _instance;
    }  

    public function moveToNext(index : Int, value : String) : String {
        var j = value.indexOf("\n", index);
        if (j < 0) {
            j = value.length;
        }
        return value.substr(index, j - index);
    }
}

@:expose
@:nativeGen
class StringReader extends Reader {
    private var _next : Null<String> = null;
    private var _value : Null<String> = null;
    private var _index : Int = 0;
    private var _method : StringReaderMethod;
    private var _dropping : Int = -1;

    public function new(sValue : String) {
        super();
        _value = sValue;
        _next = "";
        _method = StringReaderEachChar.instance();
        moveToNext();
    }

    public override function reset() : Void {
        _index = 0;
        _next = "";
        moveToNext();
    }

    public override function rawIndex() : Int {
        return _index;
    }

    public override function jumpTo(index : Int) : Void {
        _index = index;
    }

    public function setString(sValue : String) {
        _value = sValue;
    }

    private function moveToNext() {
      try {
        _index += _next.length;
        _next = null;
        if (_dropping > 0 && _index >= _dropping) {
            _value = _value.substr(_index);
            _index = 0;
        }
        _next = _method.moveToNext(_index, _value);
        if (_next != null && _next.length <= 0) {
            _next = null;
        }
      } catch (ex : Dynamic) {
      }
      if (_next == null) {
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

    public override function dispose() {
        if (_value != null) {
            _value = null;
            _next = null;
            _index = -1;
        }
    }

    public override function iterator() : DataIterator<String> {
        return this;
    }

    public override function switchToLineReader() : Reader {
        _method = StringReaderEachLine.instance();
        return this;
    }

    public override function unwrapOne() : Reader {
        _method = StringReaderEachChar.instance();
        return this;
    }

    public override function unwrapAll() : Reader {
        _method = StringReaderEachChar.instance();
        return this;
    }

    public function switchToDroppingCharacters(?chars : Int = 10000) : Reader {
        _dropping = chars;
        return this;
    }
}
#end

// TODO
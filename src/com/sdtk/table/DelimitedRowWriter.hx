/*
    Copyright (C) 2019 Vis LLC - All Rights Reserved

    This program is free software : you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <https ://www.gnu.org/licenses/>.
*/

/*
    Simple Data Toolkit
    Simple Table Converter (STC) - Source code can be found in Converter.hx in Haxe on SourceForge.net
*/

package com.sdtk.table;

import com.sdtk.std.*;

/**
  Adapts delimited files (like CSV, PSV, etc) to STC row writer interface.
**/
@:expose
@:nativeGen
class DelimitedRowWriter extends DataTableRowWriter {
  private var _info : Null<DelimitedInfo> = null;
  private var _writer : Writer;
  private var _written : Bool = false;
  private var _done : Bool = false;
  private static var _watch : Stopwatch = Stopwatch.getStopwatch("DelimitedRowWriter");

  public function new(info : DelimitedInfo, writer : Writer) {
    super();
    reuse(info, writer);
  }

  public function reuse(info : DelimitedInfo, writer : Writer) {
    _done = false;
    if (_written) {
      _writer.write(_info.rowDelimiter());      
    }
    _written = false;
    _info = info;
    _writer = writer;
  }

  public override function write(data : Dynamic, name : String, index : Int) : Void {
    _watch.start();
    var buf : StringBuf = new StringBuf();
    if (!_done) {
      if (_written) {
        //_writer.write(_info.delimiter());
        buf.add(_info.delimiter());
      } else {
        _written = true;
      }
      writeValue(data, buf);
      _writer.write(buf.toString());
    }
    _watch.end();
  }
/*
  private function writeValue(data : Dynamic) : Void {
    if (data != null) {
      switch (Type.typeof(data)) {
        case TInt :
          _writer.write(_info.intStart());
          _writer.write(Std.string(data));
          _writer.write(_info.intEnd());
        case TBool :
          _writer.write(_info.boolStart());
          _writer.write(Std.string(data));
          _writer.write(_info.boolEnd());
        case TFloat :
          _writer.write(_info.floatStart());
          _writer.write(Std.string(data));
          _writer.write(_info.floatEnd());
        case other :
          _writer.write(_info.stringStart());
          _writer.write(Std.string(data));
          _writer.write(_info.stringEnd());
      }
    }
  }
  */

  private function replacement(data : String) : String {
    var replacements : Array<String> = _info.replacements();
    if (replacements != null && replacements.length > 0) {
      var replaceI : Int = 1;
      while (replaceI < replacements.length) {
        data = StringTools.replace(data, replacements[replaceI], replacements[replaceI - 1]);
        replaceI += 2;
      }
    }
    return data;
  }

  private function writeValue(data : Dynamic, buf : StringBuf) : Void {
    if (data != null) {
      var t : Type.ValueType = Type.typeof(data);
      switch (t) {
        case TInt:
          buf.add(_info.intStart());
          buf.add(Std.string(data));
          buf.add(_info.intEnd());
        case TBool:
          buf.add(_info.boolStart());
          buf.add(Std.string(data));
          buf.add(_info.boolEnd());
        case TFloat:
          buf.add(_info.floatStart());
          buf.add(Std.string(data));
          buf.add(_info.floatEnd());
        case other:
          var s : String = Std.string(data);
          #if python
            if (s.indexOf("datetime.datetime(") == 0) {
              s = python.Syntax.code("{0}.strftime(\"%m/%d/%Y %H:%M:%S\")", data);
            }
          #end          
          buf.add(_info.stringStart());
          buf.add(replacement(s));
          buf.add(_info.stringEnd());
      }
    }
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (!_done) {
     _writer.write(_info.rowDelimiter());
     _writer.flush();
     _done = true;
     _written = false;
    }
  }
}

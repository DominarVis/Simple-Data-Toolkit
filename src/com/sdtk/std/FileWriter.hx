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
class FileWriter extends Writer {
  private var _writer : StringWriter = new StringWriter(null);
  private var _file : String;

  public function new(name : String, bAppend : Bool) {
      super();
      _file = name;
  }

  public override function dispose() : Void {
      if (_writer != null) {
          var request : com.sdtk.std.JS_BROWSER.XMLHttpRequest = new com.sdtk.std.JS_BROWSER.XMLHttpRequest();
          request.open('PUT', _file, false);
          request.send(_writer.toString());
          _file = null;
          _writer = null;
      }
  }

  public override function write(str : String) : Void {
      if (_writer != null) {
          _writer.write(str);
      }
  }

  public function convertToStringWriter() : StringWriter {
    var sw : StringWriter = new StringWriter(null);
    sw.endWith(this);
    return sw;
  }    
}
#elseif JS_WSH
@:expose
@:nativeGen
class FileWriter extends Writer {
  private var _out : com.sdtk.std.JS_WSH.FileStreamObject;
  private var _path : String;

  public function new(sName : String, bAppend : Bool) {
      super();
      _path = sName;
      if (!bAppend) {
        open(false);
      }
  }

  private function open(bAppend : Bool) : Void {
      var fso : com.sdtk.std.JS_WSH.ActiveXObject = new com.sdtk.std.JS_WSH.ActiveXObject("Scripting.FileSystemObject");
      _out = fso.OpenTextFile(_path, bAppend ? 8 : 2, true);
  }

  private function close() : Void {
        _out.Close();    
        _out = null;
  }

  private function writeI(str : String) : Void {
        try {
          _out.Write(str);
        }
        catch (msg : Dynamic) {
        }    
  }

  public override function write(str : String) : Void {
    if (_out == null) {
      open(true);
      writeI(str);
      close();
    } else {
      writeI(str);
    }
  }

  public override function dispose() {
    if (_path != null) {
      _path = null;
      if (_out != null) {
        close();
        _out = null;
      }
    }
  }

  public function convertToStringWriter() : StringWriter {
    var sw : StringWriter = new StringWriter(null);
    sw.endWith(this);
    return sw;
  }  
}
#elseif JS_NODE
@:expose
@:nativeGen
class FileWriter extends Writer {
  private var _out : WriterI;
  private var _name : String;
  private var _options : Null<WriteOptions>;

  public function new(sName : String, bAppend : Bool) {
      _name = sName;
      if (!bAppend) {
        _options = null;
        Open(false);
      } else {
        _options = new WriteOptions();
        _options.flags = "a";
      }
  }

  private function Open(bAppend : Bool) : Void {
      _out = FS.createWriteStream(_name, _options);
  }

  private function close() : Void {
        _out.end();
        _out = null;
  }

  private function writeI(str : String) : Void {
        try {
          _out.write(str, null);
        }
        catch (msg : Dynamic) {
        }
  }

  public override function write(str : String) : Void {
    if (_out == null) {
      Open(true);
      writeI(str);
      close();
    } else {
      writeI(str);
    }
  }

  public override function dispose() {
    if (_name != null) {
      _name = null;
      if (_out != null) {
        close();
        _out = null;
      }
    }
  }

  public function convertToStringWriter() : StringWriter {
    var sw : StringWriter = new StringWriter(null);
    sw.endWith(this);
    return sw;
  }  
}
#elseif java
@:expose
@:nativeGen
class FileWriter extends Writer {
  private var _writer : com.sdtk.std.JAVA.FileWriterI;

  public function new(name : String, append : Bool) {
    super();
    try {
      _writer = new com.sdtk.std.JAVA.FileWriterI(name, append);
    } catch (msg : Dynamic) { }
  }

  @:native('close')
  public override function dispose() : Void {
    if (_writer != null) {
      try {
        flush();
        _writer.dispose();
      } catch (msg : Dynamic) { }
      _writer = null;
    }
  }

  public override function flush() : Void {
    try {
      _writer.flush();
    } catch (msg : Dynamic) { }
  }

  public override function write(str : String) : Void {
    try {
      _writer.write(str);
    } catch (msg : Dynamic) { }
  }

  public function convertToStringWriter() : StringWriter {
    var sw : StringWriter = new StringWriter(null);
    sw.endWith(this);
    return sw;
  }    
}
#elseif cs
@:expose
@:nativeGen
class FileWriter extends com.sdtk.std.CSHARP.AbstractWriter {
    public function new(sName : String, bAppend : Bool) {
        super(new com.sdtk.std.CSHARP.StreamWriter(com.sdtk.std.CSHARP.File.Open(sName, bAppend ? com.sdtk.std.CSHARP.FileMode.Append : com.sdtk.std.CSHARP.FileMode.Create)));
    }

    public function convertToStringWriter() : StringWriter {
      var sw : StringWriter = new StringWriter(null);
      sw.endWith(this);
      return sw;
    }    
}
#else
import haxe.io.Output;
import sys.io.File;
import sys.io.FileOutput;

@:expose
class FileWriter extends com.sdtk.std.HAXE.AbstractWriter {
  private static function createWriter(sName : String, bAppend : Bool) : Output {
    if (bAppend) {
      return File.append(sName, false);
    } else {
      return File.write(sName, false);
    }
  }

  public function new(sName : String, bAppend : Bool) {
    super(createWriter(sName, bAppend));
  }

  public function convertToStringWriter() : StringWriter {
    var sw : StringWriter = new StringWriter(null);
    sw.endWith(this);
    return sw;
  }  
}
#end
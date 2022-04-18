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

#if JS_WSH
@:native('WScript') extern class WScript {
  public static function Arguments(arg : Int) : String;
  public static function Echo(arg : String) : Void;
}

@:native('WScript.StdIn') extern class StdIn {
  public static function ReadLine() : String;
}

@:native('FileStreamObject') extern class FileStreamObject {
  public function Write(sData : String) : Void;
  public function WriteLine(sData : String) : Void;
  public function Read(iChars : Int) : String;
  public function ReadAll() : String;
  public function Skip(iChars : Int) : Void;
  public function Close() : Void;
}

@:native('FileSystemObject') extern class FileSystemObject {
  public function OpenTextFile(name : String, iomode : Int, create : Bool, format : Int) : FileStreamObject;
}

@:native('') extern class WSHInput {
  public function ReadLine() : String;
  public var AtEndOfStream : Bool;
}

@:native('') extern class WSHProcess {
  public var StdOut : WSHInput;
}

@:native('ActiveXObject') extern class ActiveXObject {
  public function new(sClass : String);
  public function OpenTextFile(sPath : String, iMode : Int, bAppend : Bool) : FileStreamObject;
  public function run(sPath : String) : Void;
  public function Exec(sPath : String) : WSHProcess;
  public function ExpandEnvironmentStrings(sVars : String) : String;
  public function GetStandardStream(stream : Int) : FileStreamObject;
  public function LogEvent(iLevel : Int, sMessage : String) : Void;
}

@:nativeGen
class ReaderAsyncAbstractI extends ReaderAsyncAbstract {
    private var _reader : Reader;

    public function new(rReader : Reader) {
        _reader = rReader;
    }

    public override function start() : ReaderAsync {
        while (_reader.hasNext()) {
            read(_reader.next());
        }
        this.dispose();
        return this;
    }
}

@:nativeGen
class WriterAsyncAbstract implements WriterAsync {
    private var _writer : Writer;

    public function new(wWriter : Writer) {
        _writer = wWriter;
    }

    public function done(iBytes : Int, oAttachment : Dynamic) : Void {
    }

    public function write(sData : String, whHandler : WriterHandler) : WriterAsync {
        _writer.write(sData);
        whHandler.done();
        return this;
    }

    public function dispose() : Void {
        if (_writer != null) {
            _writer.dispose();
            _writer = null;
        }
    }
}
#end

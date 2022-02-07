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

#if JS_NODE
class RLInterfaceOptions {
  public var input : Dynamic;
  public var output : Dynamic;
  public var completer : Dynamic;
  public var terminal : Bool;
  public var historySize : Int;
  public var prompt : String;
  public var crlfDelay : Int;
  public var removeHistoryDuplicates : Bool;
  public var escapeCodeTimeout : Int;
}

@native('console') extern class Console {
  public static function log(s : String) : Void;
}

@native('') extern class NodeEventStream {
  public function on(sEvent : String, dDelegate : Dynamic) : NodeEventStream;
}

@:jsRequire("readline")
extern class ReadLine {
  function createInterface(options : RLInterfaceOptions) : NodeEventStream;
}

@:native("")
extern class WriteOptions {
  public function new() { }

  public var flags : Null<String>;
  public var encoding : Null<String>;
  public var fd : Null<Int>;
  public var mode : Null<Int>;
  public var autoClose : Null<Bool>;
  public var start : Null<Int>;
}

@:native("")
extern class ReadOptions {
  public function new() { }

  public var flags : Null<String>;
  public var encoding : Null<String>;
  public var fd : Null<Int>;
  public var mode : Null<Int>;
  public var autoClose : Null<Bool>;
  public var start : Null<Int>;
  public var end : Null<Int>;
  public var highWaterMark : Null<Int>;
}

@:native("")
extern class WriterI {
  public function write(data : String, callback : Dynamic);
  public function end() : Void;
}

@:jsRequire("fs")
extern class FS {
  public static function createWriteStream(path : String, options : Null<WriteOptions>) : WriterI;
  public static function createReadStream(path : String, options : Null<ReadOptions>) : ReaderI;
}

@:jsRequire("process")
extern class Process {
  public var stdout : WriterI;
}
#end
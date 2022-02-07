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

/**
  Defines interface and defaults for reading tables.
**/
@:expose
@:nativeGen
class DataEntryReader implements com.sdtk.std.Disposable {
  public function new() { }

  /**
    Contains the name of the column.
  **/
  private var _name : String;

  /**
    Contains the index of the column.
  **/
  private var _index : Int = -1;

  /**
    Contains the value located at the column and row.
  **/
  private var _value : Dynamic;
  
  /**
   * Reader was started.
   */
  private var _started : Bool = false;

  /**
   * Assigned name automatically.
   */
  private var _autoNamed : Bool;
  
  /**
   * Name is identical to index.
   */
  private var _nameIsIndex : Bool;
  
  public function incrementTo(name : Null<String>, value : Dynamic) {
    _index++;
  	var indexAsString : String = Std.string(_index);
    _value = value;
    if (name == null) {
      _name = indexAsString;
      _autoNamed = true;
      _nameIsIndex = true;
    } else {
      _name = name;
      _autoNamed = false;
      _nameIsIndex = (indexAsString == name);
    }
  }

  /**
    Determines if there is another value to be read.
  **/
  public function hasNext() : Bool {
    return false;
  }

  /**
    Loads the next value so it can be read.
  **/
  public function next() : Dynamic {
    return null;
  }

  /**
    Returns an iterator for use in loops.
  **/
  public function iterator() : Iterator<Dynamic> {
    return this;
  }

  /**
    Returns the name of the column.
  **/
  public function name() : String {
    return _name;
  }

  /**
    Returns the index of the column.
  **/
  public function index() : Int {
    return _index;
  }

  /**
    Returns the value located at the column and row.
  **/
  public function value() : Dynamic {
    return _value;
  }
  
  /**
    Assigned name automatically.
  **/
  public function isAutoNamed() : Bool {
  	 return _autoNamed;
  }

  /**
    Name is identical to index.
  **/
  public function isNameIndex() : Bool {
  	 return _nameIsIndex;
  }
   
  /**
    Indicates that reading has begun.
  **/
  public function start() : Void {
    if (!_started) {
      _started = true;
      startI();
    }
  }
  
  private function startI() : Void {
  }

  /**
    Closes/disposes of all data structures required to read the table.
  **/
  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public function dispose() : Void {
  }
}

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
  Handles custom delimited files
**/
@:expose
@:nativeGen
class DelimitedInfoCustom implements DelimitedInfo {
  public var _delimiter : String;
  public var _rowDelimiter : String;
  public var _boolStart : String;
  public var _boolEnd : String;    
  public var _stringStart : String;
  public var _stringEnd : String;
  public var _intStart : String;
  public var _intEnd : String;
  public var _floatStart : String;
  public var _floatEnd : String;
  public var _replacements : Array<String>;

  public function delimiter() : String {
    return _delimiter;
  }

  public function rowDelimiter() : String {
    return _boolStart;
  }

  public function boolStart() : String {
    return _boolStart;
  }

  public function boolEnd() : String {
    return _boolEnd;
  }

  public function stringStart() : String {
    return _stringStart;
  }

  public function stringEnd() : String {
    return _stringEnd;
  }

  public function intStart() : String {
    return _intStart;
  }

  public function intEnd() : String {
    return _intEnd;
  }

  public function floatStart() : String {
    return _floatStart;
  }

  public function floatEnd() : String {
    return _floatEnd;
  }

  public function replacements() : Array<String> {
    return _replacements;
  }

  public function replacementIndicator() : Null<String> {
    return null;
  }
}

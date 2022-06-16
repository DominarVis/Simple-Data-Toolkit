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
  Defines interface for structural information on delimited files (for example: CSV files)
**/
@:expose
@:nativeGen
interface DelimitedInfo {
  public function fileStart() : String;
  public function fileEnd() : String;
  public function delimiter() : String;
  public function rowDelimiter() : String;
  public function boolStart() : String;
  public function boolEnd() : String;    
  public function stringStart() : String;
  public function stringEnd() : String;
  public function intStart() : String;
  public function intEnd() : String;
  public function floatStart() : String;
  public function floatEnd() : String;
  public function replacements() : Array<String>;
  public function replacementIndicator() : Null<String>;
  public function widthMinimum() : Int;
  public function widthMaximum() : Int;
}

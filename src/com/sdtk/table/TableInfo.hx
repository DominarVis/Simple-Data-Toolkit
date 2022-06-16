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

import com.sdtk.std.Writer;

/**
  Defines interface for a table format (for example, the HTML table tag)
**/
@:expose
@:nativeGen
interface TableInfo {
  /**
    The tag that indicates the start of a table.
  **/
  public function Tag() : Array<String>;

  /**
    The tags that indicate the start of a header row.
  **/
  public function HeaderRow() : Array<String>;

  /**
    The tags that indicate the start of a header cell.
  **/
  public function HeaderCell() : Array<String>;

  /**
    The tags that indicate the start of a data row.
  **/
  public function Row() : Array<String>;

  /**
    The tags that indicate the start of a data cell.
  **/
  public function Cell() : Array<String>;

  /**
    Get tag to indicate row number.
  **/
  public function RowNumber(i : Int, e : Dynamic) : Void;

  /**
    Get tag to indicate row name.
  **/
  public function RowName(i : String, e : Dynamic) : Void;

  /**
    Format a row for output
  **/
  public function FormatRowStart(writer : Writer, header : Bool, i : Int, n : String, rowCache : Map<String, Dynamic>, globalCache : Map<String, Dynamic>) : Void;

  public function FormatRowEnd(writer : Writer, header : Bool) : Void;

  public function ColumnNumber(i : Int, e : Dynamic) : Void;

  public function ColumnName(i : String, e : Dynamic) : Void;

  public function setData(data : Dynamic, e : Dynamic) : Void;

  public function FormatCell(writer : Writer, header : Bool, c : Int, cn : String, r : Int, rn : String, data : Dynamic, rowCache : Map<String, Dynamic>, globalCache : Map<String, Dynamic>) : Void;
  
  public function FormatTableStart(writer : Writer) : Void;

  public function FormatTableEnd(writer : Writer) : Void;
}
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
}
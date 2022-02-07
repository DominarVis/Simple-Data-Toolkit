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

#if JS_BROWSER
  import com.sdtk.std.JS_BROWSER.Document;
  import com.sdtk.std.JS_BROWSER.Element;
#end

/**
  Handles reading a header row from a table.
**/
@:nativeGen
class TableHeaderRowReaderI extends AbstractTableReader implements TableRowReaderI {
  public function new(tdInfo : TableInfo, oElement : Dynamic) {
    super(tdInfo, oElement);
  }

  private override function elementCheck(oElement : Dynamic) : Bool {
    #if JS_BROWSER
      return (_info.HeaderCell().indexOf(cast(oElement, Element).tagName.toUpperCase()) >= 0);
    #else
      return false;
    #end
  }

  private override function getValue(oElement : Dynamic) : Dynamic {
    #if JS_BROWSER
      return cast(oElement, Element).innerText;
    #else
      return null;
    #end
  }
}
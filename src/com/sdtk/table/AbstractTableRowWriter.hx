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

@:nativeGen
class AbstractTableRowWriter extends DataTableRowWriter {
  private var _header : Array<String>;
  private var _info : TableInfo;
  #if JS_BROWSER
    private var _element : Element;
  #else
    private var _element : Dynamic;
  #end

  public function new(tdInfo : TableInfo, oElement : Dynamic, sHeader : Array<String>) {
    super();
    reuse(tdInfo, oElement, sHeader);
  }

  public function reuse(tdInfo : TableInfo, oElement : Dynamic, sHeader : Array<String>) {
    _info = tdInfo;
    #if JS_BROWSER
      _element = cast(oElement, Element);
    #else
      _element = oElement;
    #end
    _header = sHeader;
  }

  public function getTag() : String {
    return _info.Cell()[0];
  }

  public override function write(data : Dynamic, name : String, index : Int) : Void {
    #if JS_BROWSER
      var oCell : Element = Document.createElement(getTag());
      oCell.setAttribute("ColumnNumber", "" + index);
      oCell.setAttribute("ColumnName", name);
      oCell.setAttribute("RowNumber", _element.getAttribute("RowNumber"));
      oCell.setAttribute("RowName",  _element.getAttribute("RowName"));
      oCell.innerText = data;
      _element.appendChild(oCell);
    #end
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    _header = null;
    _info = null;
    _element = null;
  }
}
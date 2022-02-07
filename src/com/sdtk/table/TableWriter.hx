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
  Adapts TableWriterI to the STC table writer interface.
**/
@:expose
@:nativeGen
class TableWriter extends DataTableWriter {
  private var _header : Array<String> = new Array<String>();
  private var _info : TableInfo;
  #if JS_BROWSER
    private var _element : Element;
  #else
    private var _element : Dynamic;
  #end

  private function new(tdInfo : TableInfo, oElement : Dynamic) {
    super();
    _info = tdInfo;
    #if JS_BROWSER
      _element = cast(oElement, Element);
    #else
      _element = oElement;
    #end
    _header = new Array<String>();
  }

  private override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    #if JS_BROWSER
      var oRow : Element = Document.createElement(_info.Row()[0]);
      oRow.setAttribute("RowNumber", "" + index);
      oRow.setAttribute("RowName", name);
      _element.appendChild(oRow);
    #else
      var oRow : Dynamic = null;
    #end
    switch (index) {
      case 0:
        rowWriter = new TableFirstRowWriter(_info, oRow, _header);
      case 1:
        rowWriter = new TableRowWriter(_info, oRow, _header);
      default:
        if (rowWriter == null) {
          rowWriter = new TableRowWriter(_info, oRow, _header);
        } else {
          var rw : TableRowWriter = cast rowWriter;
          rw.reuse(_info, oRow, _header);
        }
    }
    return rowWriter;
  }

  private function writeHeader() : DataTableRowWriter {
    #if JS_BROWSER
      var oRow : Element = Document.createElement("tr");
      _element.appendChild(oRow);
    #else
      var oRow : Dynamic = null;
    #end
    return new TableHeaderRowWriter(_info, oRow, _header);
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_header.length > 0) {
      var dtrwWriter = writeHeader();
      try {
        var i : Int = 0;
        for (cell in _header) {
          dtrwWriter.write(cell, cell, i++);
        }
      } catch (message : Dynamic) {
      }
      dtrwWriter.dispose();
    }
    _header = null;
    _info = null;
    _element = null;
  }

  public static function createStandardTableWriter(oElement : Dynamic) {
    return new TableWriter(StandardTableInfo.instance, oElement);
  }
}

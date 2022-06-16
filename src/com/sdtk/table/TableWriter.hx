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
  private var _row : Int;
  private var _rowName : String;
  private var _done : Bool = false;
  private var _globalCache = new Map<String, Dynamic>();
  private var _rowCache = new Map<String, Dynamic>();

  private function new(tdInfo : TableInfo, ?oElement : Dynamic = null) {
    super();
    _info = tdInfo;
    _header = new Array<String>();
    _row = -1;
    _rowName = null;
  }

  public override function start() : Void {
    tableStart();
  }

  private function tableStart() : Void { }
  private function tableEnd() : Void { }
  private function tableRowStart(header : Bool, index : Int, name : String) : Void { }
  private function tableRowEndI(header : Bool) : Void { }
  public function writeCell(header : Bool, data : Dynamic, name : String, index : Int) : Void { }

  private function tableRowEnd() : Void {
    if (_row > 1) {
      tableRowEndI(false);
    } else if (_row == 0) {
      tableRowEndI(true);
    }
  }

  private override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    if (!_done) {
      tableRowEnd();
      tableRowStart(index == 0, index, name);
      _row = index;
      _rowName = name;

      switch (index) {
        case 0:
          rowWriter = new TableHeaderRowWriter(_info, this, _header);
        case 1:
          rowWriter = new TableFirstRowWriter(_info, this, _header);
        case 2:
          rowWriter = new TableRowWriter(_info, this, _header);
        default:
          if (rowWriter == null) {
            rowWriter = new TableRowWriter(_info, this, _header);
          } else {
            var rw : TableRowWriter = cast rowWriter;
            rw.reuse(_info, this, _header);
          }
      }
      return rowWriter;
    } else {
      return null;
    }
  }

  private function disposeI() : Void { }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (!_done) {
      tableRowEnd();
      tableEnd();
      disposeI();
      _header = null;
      _info = null;
      _row = -1;
      _rowName = null;
      _globalCache = null;
      _rowCache = null;
      _done = true;
    }
  }

  public static function createStandardTableWriterForElement(oElement : Dynamic) {
    return new TableWriterElement(StandardTableInfo.instance, oElement);
  }

  public static function createStandardTableWriterForWriter(wWriter : Writer) {
    return new TableWriterString(StandardTableInfo.instance, wWriter);
  }
}

@:nativeGen
class TableWriterString extends TableWriter {
  private var _writer : Writer;

  public function new(tdInfo : TableInfo, writer : Writer) {
    super(tdInfo);
    _writer = writer;
  }

  private override function tableStart() : Void {
    if (!_done) {
      _info.FormatTableStart(_writer);
    }
  }

  private override function tableEnd() : Void {
    if (!_done) {
      _info.FormatTableEnd(_writer);
    }
  }

  private override function tableRowStart(header : Bool, index : Int, name : String) : Void {
    if (!_done) {
      _info.FormatRowStart(_writer, header, index, name, _rowCache, _globalCache);
    }
  }

  private override function tableRowEndI(header : Bool) : Void {
    if (!_done) {
      _info.FormatRowEnd(_writer, header);
      _rowCache = new Map<String, Dynamic>();
    }
  }

  private override function disposeI() : Void {
    _writer.dispose();
    _writer = null;
  }

  public override function writeCell(header : Bool, data : Dynamic, name : String, index : Int) : Void {
    if (!_done) {
      _info.FormatCell(_writer, header, index, name, _row, _rowName, data, _rowCache, _globalCache);
    }
  }

  public override function writeHeaderFirst() : Bool {
    return true;
  }
}

@:nativeGen
class TableWriterElement extends TableWriter {
  #if JS_BROWSER
    private var _element : Element;
    private var _tableElement : Element;
    private var _fragment : Element;
  #else
    private var _element : Dynamic;
    private var _tableElement : Dynamic;
  #end

  public function new(tdInfo : TableInfo, ?oElement : Dynamic = null) {
    super(tdInfo);
    #if JS_BROWSER
      _element = cast(oElement, Element);
    #else
      _element = oElement;
    #end
  }

  private override function tableStart() : Void {
    #if JS_BROWSER
      _fragment = cast js.Syntax.code("document.createDocumentFragment()");
      if (_info.Tag().indexOf(_element.tagName.toLowerCase()) >= 0) {
        _tableElement = _fragment;
      } else {
        _tableElement = Document.createElement(_info.Tag()[0]);
        _fragment.appendChild(_tableElement);
      }
    #end
  }

  private override function tableRowStart(header : Bool, index : Int, name : String) : Void {
    #if JS_BROWSER
      var oRow : Element;
      oRow = Document.createElement(_info.Row()[0]);
      _info.RowNumber(index, oRow);
      _info.RowName(name, oRow);
      _tableElement.appendChild(oRow);
    #else
      var oRow : Dynamic = null;
    #end    
  }

  private function writeHeader() : DataTableRowWriter {
    tableRowStart(true, 0, "");
    return new TableHeaderRowWriter(_info, this, _header);
  }

  private override function disposeI() : Void {
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
      #if JS_BROWSER
        _element.appendChild(_fragment);
      #end
    }
    _element = null;
  }

  public override function writeCell(header : Bool, data : Dynamic, name : String, index : Int) : Void {
    #if JS_BROWSER
      var oCell : Element = Document.createElement(header ? _info.HeaderCell()[0] : _info.Cell()[0]);
      _info.ColumnNumber(index, oCell);
      _info.ColumnName(name, oCell);
      _info.RowNumber(_row, oCell);
      _info.RowName(_rowName, oCell);
      _info.setData(data, oCell);

      oCell.setAttribute("RowNumber", _element.getAttribute("RowNumber"));
      oCell.setAttribute("RowName",  _element.getAttribute("RowName"));
      _element.appendChild(oCell);
    #end
  }  
}
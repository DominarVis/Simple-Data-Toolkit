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
  private var _writer : TableWriter;

  public function new(tdInfo : TableInfo, writer : TableWriter, sHeader : Array<String>) {
    super();
    reuse(tdInfo, writer, sHeader);
  }

  public function reuse(tdInfo : TableInfo, writer : TableWriter, sHeader : Array<String>) {
    _info = tdInfo;
    _writer = writer;
    _header = sHeader;
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    _header = null;
    _info = null;
    _writer = null;
  }
}
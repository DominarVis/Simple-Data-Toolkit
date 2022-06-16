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
  HTML table structure
**/
@:expose
@:nativeGen
class StandardTableInfo implements TableInfo {
  public static var instance : StandardTableInfo = new StandardTableInfo();

  private function new() {
  }

  public function Tag() : Array<String> {
    return [ "table" ];
  }

  public function HeaderRow() : Array<String> {
    return [ "tr" ];
  }

  public function HeaderCell() : Array<String> {
    return [ "th", "td" ];
  }

  public function Row() : Array<String> {
    return [ "tr" ];
  }

  public function Cell() : Array<String> {
    return [ "td" ];
  }

  public function RowNumber(i : Int, e : Dynamic) : Void {
    #if JS_BROWSER
      var e2 : Element = cast e;
      e2.setAttribute("RowNumber", Std.string(i));
    #end
  }

  public function RowName(i : String, e : Dynamic) : Void {
    #if JS_BROWSER
      var e2 : Element = cast e;
      e2.setAttribute("RowName", i);
    #end
  }

  public function ColumnNumber(i : Int, e : Dynamic) : Void {
    #if JS_BROWSER
      var e2 : Element = cast e;
      e2.setAttribute("ColumnNumber", Std.string(i));
    #end
  }

  public function ColumnName(i : String, e : Dynamic) : Void {
    #if JS_BROWSER
      var e2 : Element = cast e;
      e2.setAttribute("ColumnName", i);
    #end
  }

  public function setData(data : Dynamic, e : Dynamic) : Void {
    #if JS_BROWSER
      var e2 : Element = cast e;
      e2.innerText = data;
    #end
  }

  public function FormatTableStart(writer : Writer) : Void {
    writer.write("<");
    writer.write(Tag()[0]);
    writer.write(">");
  }

  public function FormatTableEnd(writer : Writer) : Void {
    writer.write("</");
    writer.write(Tag()[0]);
    writer.write(">");
  }

  public function FormatRowStart(writer : Writer, header : Bool, i : Int, n : String, rowCache : Map<String, Dynamic>, globalCache : Map<String, Dynamic>) : Void {
    writer.write("<");
    writer.write(header ? HeaderRow()[0] : Row()[0]);
    writer.write(" RowNumber=");
    writer.write(Std.string(i));
    writer.write(" RowName=\"");
    writer.write(replacementName(n, rowCache));
    writer.write("\">");
  }

  public function FormatRowEnd(writer : Writer, header : Bool) : Void {
    writer.write("</");
    writer.write(header ? HeaderRow()[0] : Row()[0]);
    writer.write(">");
  }

  public function FormatCell(writer : Writer, header : Bool, c : Int, cn : String, r : Int, rn : String, data : Dynamic, rowCache : Map<String, Dynamic>, globalCache : Map<String, Dynamic>) : Void {
    writer.write("<");
    writer.write(header ? HeaderCell()[0] : Cell()[0]);
    writer.write(" ColumnNumber=");
    writer.write(Std.string(c));
    writer.write(" ColumnName=\"");
    writer.write(replacementName(cn, globalCache));
    writer.write("\" RowNumber=");
    writer.write(Std.string(r));
    writer.write(" RowName=\"");
    writer.write(replacementName(rn, rowCache));
    writer.write("\">");
    writer.write(replacementData(Std.string(data)));
    writer.write("</");
    writer.write(header ? HeaderCell()[0] : Cell()[0]);
    writer.write(">");
  }

  public function replacementsName() : Array<String> {
    return ["&amp;", "&", "&lt;", "<", "&quot;", "\""];
  }

  public function replacementsData() : Array<String> {
    return ["&amp;", "&", "&lt;", "<"];
  }

  private function replacementName(data : String, cache : Map<String, Dynamic>) : String {
    if (data == null) {
      return null;
    }
    var result : String = cache.get(data);
    if (result == null) {
      result = data;
      var replacements : Array<String> = replacementsName();
      if (replacements != null && replacements.length > 0 && result != null) {
        var replaceI : Int = 1;
        while (replaceI < replacements.length) {
          result = StringTools.replace(result, replacements[replaceI], replacements[replaceI - 1]);
          replaceI += 2;
        }
      }
      cache.set(data, result);  
    }
    return result;
  }

  private function replacementData(data : String) : String {
    var replacements : Array<String> = replacementsData();
    if (replacements != null && replacements.length > 0 && data != null) {
      var replaceI : Int = 1;
      while (replaceI < replacements.length) {
        data = StringTools.replace(data, replacements[replaceI], replacements[replaceI - 1]);
        replaceI += 2;
      }
    }
    return data;
  }
}
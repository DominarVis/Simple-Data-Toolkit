/*
    Copyright (C) 2023 Vis LLC - All Rights Reserved

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
    ISTAR - Insanely Simple Transfer And Reporting
*/

package com.sdtk.api;

#if(!EXCLUDE_APIS && js)
@:expose
@:nativeGen
class JSPDFAutoTableAPI extends WriterAPI {
    private static var _instance : JSPDFAutoTableAPI;

    private function new() {
        super("PDF");
    }

    private override function startInit(callback : Void->Void) : Void {
        requireAPI(JSPDFAPI.instance(), function () : Void {
            load((js.Browser.document.location.protocol.toLowerCase().indexOf("file") == 0 ? "" : "/") + "jspdf.plugin.autotable.js", callback);
        });
    }

    public static function instance() : JSPDFAutoTableAPI {
        if (_instance == null) {
            _instance = new JSPDFAutoTableAPI();
        }
        return _instance;
    } 

    public function autoTable(header : Array<String>, body : Array<Array<Dynamic>>, callback : String->Void) : Void {
        requireInit(function () {
            var doc : Dynamic = js.Syntax.code("new jspdf.jsPDF()");
            js.Syntax.code("{0}.autoTable({head: [{1}], body: {2}})", doc, header, body);
            callback(cast js.Syntax.code("{0}.output()", doc));
        });
    }

    public override function createWriter(mapping : Map<String, String>, w : com.sdtk.std.Writer, finish : Void->Void, header : Array<String>) : com.sdtk.table.DataTableWriter {
        return new JSPDFAutoTableWriter(w, finish, header);
    }

    public override function isFormat() : Bool {
        return true;
    }
}

@:nativeGen
class JSPDFAutoTableWriter extends com.sdtk.table.DataTableWriter {
    private var _writer : com.sdtk.table.Array2DWriter<Dynamic>;
    private var _w : com.sdtk.std.Writer;
    private var _array : Array<Array<Dynamic>>;
    private var _header : Map<String, String> = new Map<String, String>();
    private var _headerRow : Array<String> = new Array<String>();
    private var _finish : Void->Void;

    public function new(w : com.sdtk.std.Writer, finish : Void->Void, header : Array<String>) {
        super();
        _w = w;
        _finish = finish;
        _writer = com.sdtk.table.Array2DWriter.writeToExpandableArray(null);
        _array = cast _writer.getArray();
        if (header == null) {
            _header = new Map<String, String>();
            _headerRow = new Array<String>();
        } else {
            _headerRow = header;
            _header = null;
        }
    }

    public override function start() : Void {
        _writer.start();
    }

    private function addName(name : String) : Void {
        if (_header != null) {
            if (_header[name] == null) {
                _header[name] = name;
                _headerRow.push(name);
            }
        }
    }

    public override function writeStart(name : String, index : Int) : com.sdtk.table.DataTableRowWriter {
        addName(name);
        return _writer.writeStart(name, index);
    }
  
    public override function writeStartReuse(name : String, index : Int, rowWriter : Null<com.sdtk.table.DataTableRowWriter>) : com.sdtk.table.DataTableRowWriter {
        addName(name);
        return _writer.writeStartReuse(name, index, rowWriter);
    }
    
    public override function writeHeaderFirst() : Bool {
        return _writer.writeHeaderFirst();
    }
    
    public override function writeRowNameFirst(): Bool {
        return _writer.writeRowNameFirst();
    }
    
    public override function oneRowPerFile() : Bool {
        return _writer.oneRowPerFile();
    }
    
    public override function canWrite() : Bool {
        return _writer.canWrite();
    }

    public override function dispose() : Void {
        if (_headerRow != null) {
            _writer.dispose();
            JSPDFAutoTableAPI.instance().autoTable(_headerRow, _array, function (data : String) {
                _w.write(data);
                _w.dispose();
                _header = null;
                _headerRow = null;
                _array = null;
                _w = null;
                _writer = null;
                _finish();
                _finish = null;
            });
        }
    }
}
#end
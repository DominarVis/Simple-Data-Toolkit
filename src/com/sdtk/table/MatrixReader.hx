/*
    Copyright (C) 2022 Vis LLC - All Rights Reserved

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

/*
    Simple Data Toolkit
    Simple Table Converter (STC) - Source code can be found in Converter.hx in Haxe on SourceForge.net
*/

package com.sdtk.table;

@:expose
@:nativeGen
class MatrixReader extends DataTableReaderDecorator {
    private var _info : MatrixInfo = new MatrixInfo();

    private function new(reader : DataTableReader, headerColumns : Int, headerRows : Int, columnList : Array<String>) {
        super(reader);
        _info._headerColumns = headerColumns;
        _info._headerRows = headerRows;
        _info._columnList = columnList;
        _info._headers  = new Array<Array<Dynamic>>();
        _info._headers.resize(headerColumns);
        reader.noHeaderIncluded(true);

        if (headerRows > 0) {
            var i : Int = 0;
            while (i < headerRows) {
                var rowBuffer = new Array<Dynamic>();
                _info._headers[i] = rowBuffer;
                var rowReader : DataTableRowReader = reader.next();
                rowReader.start();
                while (rowReader.hasNext()) {
                    rowBuffer.push(rowReader.next());
                }
                i++;
            }
    
            _info._headersFlatten = new Array<Dynamic>();
    
            i = 0;
    
            while (i < _info._headers[0].length) {
                var j = 0;
                while (j < headerRows) {
                    _info._headersFlatten.push(_info._headers[j][i]);
                    j++;
                }
                i++;
            }
        }
    }

    public static function createMatrixReader(reader : DataTableReader, headerColumns : Int, headerRows : Int, columnList : Array<String>) {
        return new MatrixReader(reader, headerColumns, headerRows, columnList);
    }  

    #if cs
    @:native('Dispose')
    #elseif java
    @:native('close')
    #end
    public override function dispose() : Void {
        _info = null;
        super.dispose();
    }
    
    public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
        var reader : DataTableRowReader;
        if (_info._currentI == 0) {
            reader = _reader.next();
        } else {
            reader = _reader.value();
        }
        if (rowReader == null) {
                rowReader = new MatrixRowReader(_info, reader);
        } else {
            var rr : MatrixRowReader = cast rowReader;
            rr.reuse(reader);
        }
        incrementTo(null, rowReader, _reader.rawIndex());
        return rowReader;
    }
      
    
    public override function next() : Dynamic {
        return nextReuse(null);
    }
    
    public function skipRows(rows : Int) : Void {
    // TODO
    }
}
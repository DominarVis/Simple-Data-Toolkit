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
class MatrixRowReader extends DataTableRowReaderDecorator {
    private var _info : MatrixInfo;

    public function new(info : MatrixInfo, reader : DataTableRowReader) {
        super(reader);
        _info = info;
        _started = false;
    }

    public override function reuse(reader : DataTableRowReader) : Void {
        super.reuse(reader);
        _started = false;
    }

    public override function next() : Dynamic {
        var current : Dynamic = null;
        var name : String;
        var i : Int = index() + 1;
        var j : Int = i - _info._currentRow.length;
        if (j < 0) {
            current = _info._currentRow[i];
        } else if (j < _info._headers.length) {
            current = _info._headers[j][_info._currentI];
        } else if (j == _info._headers.length) {
            current = _reader.next();
            _info._currentI++;
            if (!(_reader.hasNext())) {
                _info._currentI = 0;
            }
        }
        if (_info._columnList != null && i < _info._columnList.length) {
            name = _info._columnList[i];
        } else {
            name = null;
        }
        incrementTo(name, current, _reader.rawIndex());
        return current;
    }

    public override function hasNext() : Bool {
        var i : Int = index() + 1;
        var j : Int = i - _info._currentRow.length;

        return j <= _info._headers.length;
    }
    
    public override function start() : Void {
        if (!_started) {
            _started = true;
            if (_info._currentI == 0) {
                super.start();
                var i : Int = 0;
                if (_info._currentRow == null) {
                    _info._currentRow = new Array();
                    _info._currentRow.resize(_info._headerColumns);
                }
                while (i < _info._headerColumns) {
                    _info._currentRow[i] = _reader.next();
                    i++;
                }
            }
        }
    }

    public override function name() : String {
        return _name;
    }

    public override function value() : Dynamic {
        return _value;
    }

    public override function index() : Int {
        return this._index;
    }
}
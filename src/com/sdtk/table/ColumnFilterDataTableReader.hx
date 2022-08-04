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

import com.sdtk.std.*;

@:expose
@:nativeGen
class ColumnFilterDataTableReader extends DataTableReader {
    private var _reader : Null<DataTableReader>;
    private var _remove : Null<Array<Bool>>;
    private var _current : Dynamic;
    private var _columnHeaderFilter : Null<Filter>;
    private var _header : Array<String>;
    private var _sentHeader : Bool = false;
    private var _prev : Null<DataTableRowReader> = null;

    public function new(dtrReader : DataTableReader, fColumnHeaderFilter : Filter) {
        super();
        _reader = dtrReader;
        _columnHeaderFilter = fColumnHeaderFilter;
    }

    private override function startI() {
        _reader.start();
        super.startI();
        if (_reader.hasNext()) {
            _header = new Array<String>();
            _remove = new Array<Bool>();
            var dtrrHeader : DataTableRowReader = _reader.next();
            dtrrHeader.start();
            var i : Int = 0;

            while (dtrrHeader.hasNext()) {
                var sValue : String = dtrrHeader.next();
                if (_columnHeaderFilter.filter(sValue) == null) {
                    _remove.push(true);
                } else {
                    _remove.push(false);
                }

                _header.push(sValue);
                i++;
            }
        }
    }

    public override function hasNext() : Bool {
        if (_sentHeader) {
            return _reader.hasNext();
        } else {
            return _header != null;
        }
    }

    public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
    	var nextValue : Dynamic;
        if (rowReader == null || _index <= 0) {
            nextValue = nextI();
            nextValue = new ColumnFilterDataTableRowReader(nextValue, _remove);
        } else {
            var rr : ColumnFilterDataTableRowReader = cast rowReader;
            rr.reuse(nextI(), _remove);
            nextValue = rr;
        }
    	incrementTo(_reader.name(), nextValue, _reader.rawIndex());
        return value();
    }
      
    private function nextI() : Dynamic {
        if (_sentHeader) {
            _prev = _reader.nextReuse(_prev);
            return _prev;
        } else {
            _sentHeader = true;
            return ArrayRowReader.readWholeArray(_header);
        }
    }

    public override function next() : Dynamic {
        return nextReuse(null);
    }

    public override function isAutoNamed() : Bool {
  	    return _reader.isAutoNamed();
    }

    public override function isNameIndex() : Bool {
  	    return _reader.isNameIndex();
    }
    
    public override function headerRowNotIncluded() : Bool {
        return _reader.headerRowNotIncluded();
    }    
    
  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
    public override function dispose() {
        if (_reader != null) {
            super.dispose();
            _reader.dispose();
            _reader = null;
            _remove = null;
            _current = null;
            _columnHeaderFilter = null;
            _header = null;
            _prev = null;
        }
    }

    public override function reset() : Void {
        _reader.reset();
    }    
}
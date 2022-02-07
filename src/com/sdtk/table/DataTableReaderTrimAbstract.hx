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
    Simple Table Converter (STC) - Source code can be found in DataEntryReaderLeftTrim.hx in Haxe on SourceForge.net
*/

package com.sdtk.table;

@:nativeGen
class DataTableReaderTrimAbstract extends DataTableReaderDecorator {
    public function new(reader : DataTableReader) {
        super(reader);
    }

    private function rowReaderInstance(reader : DataTableRowReader) : DataTableRowReader {
        return null;
    }

    public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
        if(rowReader == null) {
            rowReader = rowReaderInstance(_reader.next());
        }
        else {
            var rr : DataTableRowReaderDecorator = cast rowReader;
            rr.reuse(rr.reader());
        }
        return rowReader;
    }

    public override function next() : Dynamic {
        return nextReuse(null);
    }

    public override function value() : Dynamic {
        return _value;
    }
}
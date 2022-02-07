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
class DataTableRowReaderTrimAbstract extends DataTableRowReaderDecorator {
    public function new(reader : DataTableRowReader) {
        super(reader);
    }

    private function trimI(value : String) : String {
        return null;
    }

    private function trim(value : Dynamic) : Dynamic {
        if (
          #if (haxe_ver < 3.2)
            Std.is(value, String)
          #else
            Std.isOfType(value, String)
          #end            
        ) {
            return trimI(Std.string(value));
        } else {
            return value;
        }
    }
    
    public override function next() : Dynamic {
        _value = trim(_reader.next());
        return _value;
    }

    public override function value() : Dynamic {
        return _value;
    }
}
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
    Simple Table Converter (STC) - Source code can be found in ConverterInputOptions.hx in Haxe on SourceForge.net
*/

package com.sdtk.table;
/*
@:expose
@:nativeGen
class ConverterInputOptions {
    private var _values : Map<String, Dynamic>;

    public function new(?values : Null<Map<String, Dynamic>>) {
        if (values == null) {
            values = new Map<String, Dynamic>();
        }
        _values = values;
    }

    public function readFile(file : String) : ConverterInputFormatOptions {
        return setSource(file, "file");
    }

    public function readString(value : String) : ConverterInputFormatOptions {
        return setSource(value, "string");
    }

    // TODO - Add additional
    /*
    public function reader() : ConverterInputFormatOptions {
        return setSource(reader, "reader");
    }/

    private function setSource(value : Dynamic, sourceType : String) : ConverterInputFormatOptions {
        _values.set("source", value);
        _values.set("sourceType", value);
        return new ConverterInputFormatOptions(_values);
    }
}
*/
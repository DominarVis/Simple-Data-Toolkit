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


@:expose
@:nativeGen
class ConverterOutputOptions {
    private var _values : Map<String, Dynamic>;

    public function new(?values : Null<Map<String, Dynamic>>) {
        if (values == null) {
            values = new Map<String, Dynamic>();
        }
        _values = values;
    }

    public function writeFile(file : String) : ConverterOutputFormatOptions {
        return setTarget(file, "file");
    }

    public function writeString() : ConverterOutputFormatOptions {
        return setTarget(new StringBuf(), "string");
    }    

    public function writeArrayOfArrays() : ConverterOutputOperationsOptions {
        _values.set("target", new Array());
        _values.set("targetType", "array");
        _values.set("targetFormat", Format.ARRAY);
        return new ConverterOutputOperationsOptions(_values);
    }

    private function setTarget(value : Dynamic, targetType : String) : ConverterOutputFormatOptions {
        _values.set("target", value);
        _values.set("targetType", targetType);
        return new ConverterOutputFormatOptions(_values);
    }    
}

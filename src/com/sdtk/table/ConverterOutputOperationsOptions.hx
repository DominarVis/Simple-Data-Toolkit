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
class ConverterOutputOperationsOptions {
    private var _values : Map<String, Dynamic>;

    public function new(?values : Null<Map<String, Dynamic>>) {
        if (values == null) {
            values = new Map<String, Dynamic>();
        }
        _values = values;
    }

    public function execute(?callback : Null<Dynamic->Void>) : Dynamic {
        // TODO - Add additional options
        var result : Dynamic = null;
        Converter.convertWithOptions(cast _values.get("source"), cast _values.get("sourceFormat"), cast _values.get("target"), cast _values.get("targetFormat"), null /*sFilterColumnsExclude : Null<String>*/, null /*sFilterColumnsInclude : Null<String>*/, null /*sFilterRowsExclude : Null<String>*/, null /*sFilterRowsInclude : Null<String>*/, null /*sSortRowsBy : Null<String>*/, false/*leftTrim : Bool*/, false/*rightTrim : Bool*/);
        switch (_values.get("targetType")) {
            case "string":
                result = _values.get("target").toString();
            case "array":
                result = _values.get("target");
        }
        if (callback == null) { 
            return result;
        } else {
            callback(result);
            return null;
        }
    }
}

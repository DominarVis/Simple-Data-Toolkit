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
class ConverterInputFormatOptions {
    private var _values : Map<String, Dynamic>;

    public function new(?values : Null<Map<String, Dynamic>>) {
        if (values == null) {
            values = new Map<String, Dynamic>();
        }
        _values = values;
    }

    public function csv() : ConverterInputOperationsOptions.ConverterInputOperationsOptionsDelimited {
        return setSourceFormatDelimited(CSV);
    }

    public function psv() : ConverterInputOperationsOptions.ConverterInputOperationsOptionsDelimited {
        return setSourceFormatDelimited(PSV);
    }

    public function tsv() : ConverterInputOperationsOptions.ConverterInputOperationsOptionsDelimited {
        return setSourceFormatDelimited(TSV);
    }

    public function htmlTable() : ConverterInputOperationsOptions {
        return setSourceFormat(HTMLTable);
    }

    public function dir() : ConverterInputOperationsOptions {
        return setSourceFormat(DIR);
    }

    public function ini() : ConverterInputOperationsOptions {
        return setSourceFormat(INI);
    }    

    public function json() : ConverterInputOperationsOptions {
        return setSourceFormat(JSON);
    }        

    public function properties() : ConverterInputOperationsOptions {
        return setSourceFormat(PROPERTIES);
    }            

    public function splunk() : ConverterInputOperationsOptions {
        return setSourceFormat(SPLUNK);
    }

    private function setSourceFormat(value : Format) : ConverterInputOperationsOptions {
        _values.set("sourceFormat", value);
        return new ConverterInputOperationsOptions(_values);
    }

    private function setSourceFormatDelimited(value : Format) : ConverterInputOperationsOptions.ConverterInputOperationsOptionsDelimited {
        _values.set("sourceFormat", value);
        return new ConverterInputOperationsOptions.ConverterInputOperationsOptionsDelimited(_values);
    }    
}

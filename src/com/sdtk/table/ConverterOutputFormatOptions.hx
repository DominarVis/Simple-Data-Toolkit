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
class ConverterOutputFormatOptions {
    private var _values : Map<String, Dynamic>;

    public function new(?values : Null<Map<String, Dynamic>>) {
        if (values == null) {
            values = new Map<String, Dynamic>();
        }
        _values = values;
    }

    public function csv() : ConverterOutputOperationsOptions.ConverterOutputOperationsOptionsDelimited {
        return setTargetFormatDelimited(CSV);
    }

    public function psv() : ConverterOutputOperationsOptions.ConverterOutputOperationsOptionsDelimited {
        return setTargetFormatDelimited(PSV);
    }

    public function tsv() : ConverterOutputOperationsOptions.ConverterOutputOperationsOptionsDelimited {
        return setTargetFormatDelimited(TSV);
    }

    public function htmlTable() : ConverterOutputOperationsOptions {
        return setTargetFormat(HTMLTable);
    }

    public function dir() : ConverterOutputOperationsOptions {
        return setTargetFormat(DIR);
    }

    public function ini() : ConverterOutputOperationsOptions {
        return setTargetFormat(INI);
    }    

    public function json() : ConverterOutputOperationsOptions {
        return setTargetFormat(JSON);
    }        

    public function properties() : ConverterOutputOperationsOptions {
        return setTargetFormat(PROPERTIES);
    }            

    public function splunk() : ConverterOutputOperationsOptions {
        return setTargetFormat(SPLUNK);
    }    

    public function sql() : ConverterOutputOperationsOptions.ConverterOutputOperationsOptionsSQL {
        _values.set("targetFormat", Format.SQL);
        return new ConverterOutputOperationsOptions.ConverterOutputOperationsOptionsSQL(_values);
    }

    public function csharp() : ConverterOutputOperationsOptions {
        return setTargetFormat(CSharp);
    }    

    public function java() : ConverterOutputOperationsOptions {
        return setTargetFormat(Java);
    }    

    public function haxe() : ConverterOutputOperationsOptions {
        return setTargetFormat(Haxe);
    }    

    public function python() : ConverterOutputOperationsOptions {
        return setTargetFormat(Python);
    }

    private function setTargetFormat(value : Format) : ConverterOutputOperationsOptions {
        _values.set("targetFormat", value);
        return new ConverterOutputOperationsOptions(_values);
    }

    private function setTargetFormatDelimited(value : Format) : ConverterOutputOperationsOptions.ConverterOutputOperationsOptionsDelimited {
        _values.set("targetFormat", value);
        return new ConverterOutputOperationsOptions.ConverterOutputOperationsOptionsDelimited(_values);
    }    
}

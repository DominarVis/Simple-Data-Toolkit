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
class ConverterQuickInputOptions {
    public function new() { }

    public function csv(value : String) : ConverterQuickOutputOptions {
        return next(read(value).csv());
    }

    public function psv(value : String) : ConverterQuickOutputOptions {
        return next(read(value).psv());
    }

    public function tsv(value : String) : ConverterQuickOutputOptions {
        return next(read(value).tsv());
    }

    public function htmlTable(value : String) : ConverterQuickOutputOptions {
        return next(read(value).htmlTable());
    }

    public function dir(value : String) : ConverterQuickOutputOptions {
        return next(read(value).dir());
    }

    public function ini(value : String) : ConverterQuickOutputOptions {
        return next(read(value).ini());
    }    

    public function json(value : String) : ConverterQuickOutputOptions {
        return next(read(value).json());
    }        

    public function properties(value : String) : ConverterQuickOutputOptions {
        return next(read(value).properties());
    }            

    public function splunk(value : String) : ConverterQuickOutputOptions {
        return next(read(value).splunk());
    }

    public function readDatabase(value : Dynamic) : ConverterQuickOutputOptions {
        return next(Converter.start().readDatabase(value));
    }

    public function readArrayOfArrays(value : Array<Array<Dynamic>>) : ConverterQuickOutputOptions {
        return next(Converter.start().readArrayOfArrays(value));
    }  
    
    private function read(value : String) : ConverterInputFormatOptions {
        return Converter.start().readString(value);
    }

    private function next(value : ConverterInputOperationsOptions) : ConverterQuickOutputOptions {
        return new ConverterQuickOutputOptions(value.output());
    }
}

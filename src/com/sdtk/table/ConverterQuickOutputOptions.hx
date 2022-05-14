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
class ConverterQuickOutputOptions {
    private var _values : ConverterOutputOptions;

    public function new(values : ConverterOutputOptions) {
        _values = values;
    }

    public function csv(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeString().csv().execute(callback);
    }

    public function psv(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeString().psv().execute(callback);
    }

    public function tsv(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeString().tsv().execute(callback);
    }

    public function htmlTable(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeString().htmlTable().execute(callback);
    }

    public function dir(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeString().dir().execute(callback);
    }

    public function ini(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeString().ini().execute(callback);
    }    

    public function json(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeString().json().execute(callback);
    }        

    public function properties(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeString().properties().execute(callback);
    }            

    public function splunk(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeString().splunk().execute(callback);
    }    

    public function sql(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeString().sql().execute(callback);
    }

    public function csharp(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeString().csharp().execute(callback);
    }    

    public function java(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeString().java().execute(callback);
    }    

    public function haxe(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeString().haxe().execute(callback);
    }    

    public function python(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeString().python().execute(callback);
    }  

    public function writeArrayOfArrays(?callback : Null<Dynamic->Void>) : Dynamic {
        return _values.writeArrayOfArrays().execute(callback);
    }
}

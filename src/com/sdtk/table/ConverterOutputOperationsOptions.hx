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

#if JS_BROWSER
    import com.sdtk.std.JS_BROWSER.Element;
#end

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

    public function sortRowsBy(value : String) : ConverterOutputOperationsOptions {
        return mergeSortBy("sortRowsBy", value);
    }

    private function mergeSortBy(key : String, value : String) : ConverterOutputOperationsOptions {
        var current : Array<String> = _values.get(key);

        if (current == null) {
            current = new Array<String>();
        }

        current.push(value);
        _values.set(key, current);

        return this;
    }

    public function execute(?callback : Null<Dynamic->Void>) : Dynamic {
        // TODO - Add additional options
        var result : Dynamic = null;
        var eTarget : Dynamic = null;
        if (_values.get("targetType") == "element" && _values.get("targetFormat") != Format.HTMLTable) {
            eTarget = _values.get("target");
            _values.set("target", new StringBuf());
            _values.set("targetType", "string");
        }
        Converter.convertWithOptions(cast _values.get("source"), cast _values.get("sourceFormat"), cast _values.get("target"), cast _values.get("targetFormat"), cast _values.get("filterColumnsExclude"), cast _values.get("filterColumnsInclude"), cast _values.get("filterRowsExclude"), cast _values.get("filterRowsInclude"), cast _values.get("sortRowsBy"), false/*leftTrim : Bool*/, false/*rightTrim : Bool*/, cast _values.get("inputOptions"), cast _values.get("outputOptions"));
        switch (_values.get("targetType")) {
            case "string":
                var sb : StringBuf =  _values.get("target");
                #if php
                    // Handle bug in Haxe to PHP conversion for StringBuf
                    result = php.Syntax.code("{0}->b", sb);
                #else
                    result = sb.toString();
                #end
            case "array":
                result = _values.get("target");
        }
        if (eTarget != null) {
            #if JS_BROWSER
                var e : Element = cast eTarget;
                e.innerText = result;
            #end
            result = null;
        }
        if (callback == null) { 
            return result;
        } else {
            callback(result);
            return null;
        }
    }
}

@:expose
@:nativeGen
class ConverterOutputOperationsOptionsSQL extends ConverterOutputOperationsOptions {
    public function new(?values : Null<Map<String, Dynamic>>) {
        super(values);
    }

    public function createTable(name : String) : ConverterOutputOperationsOptions {
        return setValue("Create", name);
    }
    
    public function createOrReplaceTable(name : String) : ConverterOutputOperationsOptions {
        return setValue("CreateOrReplace", name);
    }
    
    public function insertIntoTable(name : String) : ConverterOutputOperationsOptions {    
        return setValue("Insert", name);
    }

    private function setValue(sqlType : String, tableName : String) : ConverterOutputOperationsOptions {
        var options : Map<String, Dynamic> = cast _values.get("outputOptions");
        if (options == null) {
            options = new Map<String, Dynamic>();
            _values.set("outputOptions", options);
        }
        options.set("sqlType", sqlType);
        options.set("tableName", tableName);

        return new ConverterOutputOperationsOptions(_values);
    }
}

@:expose
@:nativeGen
class ConverterOutputOperationsOptionsDelimited extends ConverterOutputOperationsOptions {
    public function new(?values : Null<Map<String, Dynamic>>) {
        super(values);
    }

    public function excludeHeader(?value : Bool = true) : ConverterOutputOperationsOptionsDelimited {
        return setValue("header", !value);
    }

    public function textOnly(?value : Bool = true) : ConverterOutputOperationsOptionsDelimited {
        return setValue("textOnly", !value);
    }    

    private function setValue(key : String, value : Bool) : ConverterOutputOperationsOptionsDelimited {
        var options : Map<String, Dynamic> = cast _values.get("outputOptions");
        if (options == null) {
            options = new Map<String, Dynamic>();
            _values.set("outputOptions", options);
        }
        options.set(key, value);

        return this;
    }
}
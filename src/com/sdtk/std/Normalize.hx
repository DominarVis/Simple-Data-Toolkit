/*
    Copyright (C) 2023 Vis LLC - All Rights Reserved

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

/*
    Simple Data Toolkit
    Standard/Core Library - Source code can be found on SourceForge.net
*/

package com.sdtk.std;

@:expose
@:nativeGen
class Normalize {
    public static function parseJson(data : Dynamic) : Dynamic {
        #if python
            python.Syntax.code("import json");
        #end
        var jsonData : String = Std.string(data);
        if (jsonData.charAt(0) == "`" && jsonData.indexOf("```json\n") == 0) {
            jsonData = jsonData.substr(8, jsonData.length - 11);
        }
        return 
        #if python
            python.Syntax.code("json.loads({0})", jsonData);
        #elseif js
            js.Syntax.code("JSON.parse({0})", jsonData);
        #else
            haxe.Json.parse(jsonData);
        #end
    }

    public static function nativeToHaxe(mapping : Dynamic) : Map<Dynamic, Dynamic> {
        if (mapping is haxe.ds.StringMap || mapping is haxe.ds.IntMap || mapping is haxe.ds.WeakMap || mapping is haxe.ds.ObjectMap) {
            return mapping;
        }
        #if php
        else if (cast php.Syntax.code("is_array({0}) && array_keys({0}) === range(0, count({0}) - 1)", mapping)) {
            return php.Lib.hashOfAssociativeArray(cast mapping);
        }
        #elseif java
        // TODO - Confirm not needed
        /*
        else if (mapping is java.util.Hashtable) {
            //return java.Lib.hashOfList(cast mapping);
        }
        else if (mapping is java.util.Map) {
            //return
        }*/
        #elseif cs
        // TODO - Confirm not needed
        //else if
        #elseif python
        else if (mapping is python.Dict) {
            var map : Map<String, String> = new Map<String, String>();
            var m2 : python.Dict<Dynamic, Dynamic> = cast mapping;
            for (field in m2.keys()) {
                map.set(field, cast mapping.get(field));
            }
            return map;
        }
        #elseif lua
        // TODO - Confirm not needed
        //else if
        #end
        else {
            var map : Map<String, String> = new Map<String, String>();
            var size : Int = 0;
            for (field in Reflect.fields(mapping)) {
                map.set(field, cast Reflect.field(mapping, field));
                size++;
            }
            if (size == 1) {
                var k : String = map.keys().next();
                switch (k) {
                    case "h", "d":
                        return nativeToHaxe(cast map.get(k));
                }
            }
            return map;
        }
    }

    public static function haxeMapValuesToStrings(mapping : Map<String, Dynamic>) : Map<String, String> {
        var map : Map<String, String> = new Map<String, String>();
        for (field in mapping.keys()) {
            map.set(field, Std.string(mapping.get(field)));
        }
        return map;
    }

    public static function haxeToNative(mapping : Map<Dynamic, Dynamic>) : Dynamic {
        #if php
            return cast php.Syntax.code("{0}->data", mapping);
        #elseif js
            return cast js.Syntax.code("{0}.h", mapping);
        #elseif java
            // TODO - Confirm not needed
            return mapping;
        #elseif cs
            // TODO - Confirm not needed
            return mapping;
        #elseif python
            var map : python.Dict<Dynamic, Dynamic> = new python.Dict<Dynamic, Dynamic>();
            for (field in mapping.keys()) {
                map.set(field, cast mapping.get(field));
            }
            return map;
        #elseif lua
            // TODO - Confirm not needed
            return mapping;
        #else
            return mapping;
        #end
    }
}
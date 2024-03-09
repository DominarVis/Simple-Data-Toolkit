/*
    Copyright (C) 2023 Vis LLC - All Rights Reserved

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
    ISTAR - Insanely Simple Transfer And Reporting
*/

package com.sdtk.api;

#if !EXCLUDE_APIS
@:expose
@:nativeGen
class ExecutorAPI extends API {
    public function new(name : String) {
        super(name);
    }

    public function acceptedFormat() : String {
        return null;
    }

    public function execute(script : String, mapping : Map<String, String>, callback : Dynamic->Void) : Void {
        callback(null);
    }

    public function keywords() : Array<String> {
        return null;
    }

    public function keywordsAreCaseSensitive() : Bool {
        return true;
    }

    private static function isArray(o : Dynamic) : Bool {
        #if js
            return cast js.Syntax.code("Array.isArray({0})", o);
        #else
            return (o is Array);
        #end
    }

    private static function emptyObject() : Dynamic {
        #if js
            return js.Syntax.code("{ }");
        #else
            return { };
        #end
    }

    private function exportReader(o : Dynamic, raw : Dynamic, callback : Dynamic->Void) : Void {
        var isPrimitive : Bool = false;
        var isArrayOfArrays : Bool = false;

        if (o == null && raw != null) {
            isPrimitive = true;
            isArrayOfArrays = true;
            var arr : Array<Dynamic> = new Array<Dynamic>();
            arr.push(raw);
            o = arr;
        }
        var arr : Array<Dynamic> = null;
        var map : Map<String, Dynamic> = null;
        var size : Int;
        if (isArray(o)) {
            arr = new Array<Dynamic>();
            arr.resize(o.length);
            size = o.length;
        } else {
            map = new Map<String, Dynamic>();
            size = o.keys().length;
        }
        
        var i : Int = 0;
    
        while (i < size) {
            if (arr != null) {
                var o2 : Dynamic = o[i];
                if (!isPrimitive) {
                    if (isArray(o2)) {
                        arr[i] = o2;
                        isArrayOfArrays = true;
                    } else {
                        if (o2.keys == null) {
                            arr[i] = [o2];
                            isArrayOfArrays = true;
                        } else {
                            var v : Dynamic = emptyObject();
                            var iterator : Dynamic = o2.keys();
                            var cur : Dynamic = iterator.next();
                            while (cur != null && cur.value != null && cur.done == false) {
                                v[cur.value] = o2.get(cur.value);
                                cur = iterator.next();
                            }
                            arr[i] = v;
                        }
                    }
                } else {
                    arr[i] = o2;
                }
            } else {
                var o2 : Dynamic = o[o.keys()[i]];
                if (isArray(o2)) {
                    map[o.keys()[i]] = o2;
                    isArrayOfArrays = true;
                } else {
                    if (o2.keys == null) {
                        map[o.keys()[i]] = [o2];
                        isArrayOfArrays = true;
                    } else {
                        var v : Dynamic = emptyObject();
                        var iterator : Dynamic = o2.keys();
                        var cur : Dynamic = iterator.next();
                        while (cur != null && cur.value != null && cur.done == false) {
                            v[cur.value] = o2.get(cur.value);
                            cur = iterator.next();
                        }
                        map[o.keys()[i]] = v;
                    }
                }
            }
            i++;
        }
        if (arr != null) {
            if (!isArrayOfArrays) {
                callback(com.sdtk.table.ArrayOfObjectsReader.readWholeArray(cast arr));
            } else {
                #if java
                    var o : Array<Array<java.lang.Object>> = cast arr;
                    callback(com.sdtk.table.Array2DReader.readWholeArray(o));
                #else
                    callback(com.sdtk.table.Array2DReader.readWholeArray(cast arr));
                #end
            }
        } else {
            if (!isArrayOfArrays) {
                callback(com.sdtk.table.ObjectOfArraysReader.readWholeObject(cast map));
            } else {
                callback(com.sdtk.table.ObjectOfObjectsReader.readWholeObject(cast map));
            }
        }
    }
}
#end
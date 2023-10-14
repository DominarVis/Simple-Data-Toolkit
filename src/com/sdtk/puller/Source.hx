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
    Simple Puller (SP) - Source code can be found on SourceForge.net
*/

package com.sdtk.puller;

#if !EXCLUDE_PARAMETERS
@:expose
@:nativeGen
class Source {
    private function new() { }

    public static function fromInputAPI(api : com.sdtk.api.InputAPI) : Source {
        return new SourceInputAPI(api);
    }

    public static function fromDataTableReader(reader : com.sdtk.table.DataTableReader) : Source {
        return new Source();
    }

    public function pull(callback : Map<String, Dynamic> -> Void) { }
}

@:nativeGen
class SourceInputAPI extends Source {
    private var _api : com.sdtk.api.InputAPI;
    private var _key : String;
    private var _value : String;

    public function new(api : com.sdtk.api.InputAPI) {
        super();
        _api = api;
        _key = api.externalKey();
        _value = api.externalValue();
    }

    public override function pull(callback : Map<String, Dynamic> -> Void) : Void {
        _api.retrieveData(null, function (s : String, r : com.sdtk.table.DataTableReader) : Void {
            var result : Map<String, Dynamic> = new Map<String, Dynamic>();
            r.toHaxeMap(result, _key, _value);
            callback(result);
        });
    }
}
#end
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
@:nativeGen
class InputAPI extends API {
    public function new(name : String) {
        super(name);
    }

    public function isFormat() : Bool {
        return false;
    }

    public function getInputNames() : Array<String> {
        return null;
    }

    public function scriptable() : Bool {
        return false;
    }

    public function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        callback(null, null);
    } 

    public function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        callback(null, null);
    }

    public function externalKey() : String {
        return null;
    }

    public function externalValue() : String {
        return null;
    }

    public function wrapWithMapping(mapping : Map<String, String>) : InputAPI {
        return new InputAPIWrapper(this, mapping);
    }
}

@:nativeGen
class InputAPIWrapper extends InputAPI {
    private final _api : InputAPI;
    private final _mapping : Map<String, String>;

    public function new(api : InputAPI, mapping : Map<String, String>) {
        super(api.name());
        _api = api;
        _mapping = mapping;
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        _api.retrieveData(_mapping, callback);
    } 
}
#end
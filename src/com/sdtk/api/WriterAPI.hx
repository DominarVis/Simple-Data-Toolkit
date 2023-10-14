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
class WriterAPI extends API {
    public function new(name : String) {
        super(name);
    }

    public function isFormat() : Bool {
        return false;
    }

    public function createWriter(mapping : Map<String, String>, w : com.sdtk.std.Writer, finish : Void->Void, header : Array<String>) : com.sdtk.table.DataTableWriter {
        return null;
    }

    public function getInputNames() : Array<String> {
        return null;
    }    

    public function scriptable() : Bool {
        return false;
    }
}
#end
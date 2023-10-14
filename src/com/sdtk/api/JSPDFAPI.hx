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

#if(!EXCLUDE_APIS && js)
@:nativeGen
class JSPDFAPI extends API {
    private static var _instance : JSPDFAPI;

    private function new() {
        super("JSPDF");
    }

    private override function startInit(callback : Void->Void) : Void {
        load((js.Browser.document.location.protocol.toLowerCase().indexOf("file") == 0 ? "" : "/") + "jspdf.js", callback);
    }

    public static function instance() : JSPDFAPI {
        if (_instance == null) {
            _instance = new JSPDFAPI();
        }
        return _instance;
    }  
}
#end
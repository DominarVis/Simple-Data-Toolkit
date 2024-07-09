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

#if(!EXCLUDE_APIS && JS_BROWSER)
// TODO - Add options
@:expose
@:nativeGen
class SpeechSynthesisUtteranceAPI extends API {
    private static var _instance : SpeechSynthesisUtteranceAPI;

    private function new() {
        super("SpeechSynthesisUtteranceAPI");
    }

    public static function instance() : SpeechSynthesisUtteranceAPI {
        if (_instance == null) {
            _instance = new SpeechSynthesisUtteranceAPI();
        }
        return _instance;
    }

    public function convert(callback : String->String->Void, query : String) : Void {
        var msg : Dynamic = js.Syntax.code("new SpeechSynthesisUtterance()");
        msg.text = query;
        js.Syntax.code("window.speechSynthesis.speak({0})", msg);
    }
}
#end

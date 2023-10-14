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
class SVG2PDFAPI extends API {
    private static var _instance : SVG2PDFAPI;

    private function new() {
        super("SVG2PDFAPI");
    }

    private override function startInit(callback : Void->Void) : Void {
        requireAPI(JSPDFAPI.instance(), function () : Void {
            load("svg2pdf.js", callback);
        });
    }

    public static function instance() : SVG2PDFAPI {
        if (_instance == null) {
            _instance = new SVG2PDFAPI();
        }
        return _instance;
    }

    public function convert(data : String, callback : String->Void) {
        requireInit(function () {
            var doc : Dynamic = js.Syntax.code("new jspdf.jsPDF()");
            var element : Dynamic = js.Syntax.code("document.createElement(\"div\")");
            element.innerHTML = data;
            element = element.children[0];
            doc.svg(element);
            callback(cast js.Syntax.code("{0}.output()", doc));            
        });
    }
}
#end
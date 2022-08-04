/*
    Copyright (C) 2022 Vis LLC - All Rights Reserved

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
    Simple Table Converter (STC) - Source code can be found in Converter.hx in Haxe on SourceForge.net
*/

package com.sdtk.table;

@:expose
@:nativeGen
class MatrixInfo {
    public var _headerColumns : Int;
    public var _headerRows : Int;
    public var _columnList : Array<String>;
    public var _headers : Array<Array<Dynamic>>;
    public var _headersFlatten : Array<Dynamic>;
    public var _currentRow : Array<Dynamic>;
    public var _currentI : Int = 0;

    public function new() { }
}

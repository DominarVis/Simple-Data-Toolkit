/*
    Copyright (C) 2019 Vis LLC - All Rights Reserved

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

import com.sdtk.std.*;

@:nativeGen
interface KeyValueHandler {
  function favorReadAll() : Bool;
  function oneRowPerFile() : Bool;

  function read(rReader : Reader) : Map<String, Dynamic>;
  function write(wWriter : Writer, mMap : Map<String, Dynamic>) : Void;
  function readAll(rReader : Reader, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void;
  function writeAll(wWriter : Writer, aMaps : Array<Map<String, Dynamic>>, aNames : Array<Dynamic>) : Void;
}
/*
    Copyright (C) 2019 Vis LLC - All Rights Reserved

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
    Simple Data Toolkit
    Simple Table Converter (STC) - Source code can be found in DataEntryReaderDecorator.hx in Haxe on SourceForge.net
*/

package com.sdtk.table;

@:nativeGen
class DataEntryReaderDecorator extends DataEntryReader {
    private var _reader : DataEntryReader;

    public function new(reader : DataEntryReader) {
        super();
        _reader = reader;
    }

    public override function hasNext() : Bool {
        return _reader.hasNext();
    }

    public override function next() : Dynamic {
        return _reader.next();
    }

    public override function iterator() : Iterator<Dynamic> {
        return this;
    }

    public override function name() : String {
        return _reader.name();
    }

    public override function index() : Int {
        return _reader.index();
    }

    public override function value() : Dynamic {
        return _reader.value();
    }
    
    public override function isAutoNamed() : Bool {
        return _reader.isAutoNamed();
    }

    public override function isNameIndex() : Bool {
        return _reader.isNameIndex();
    }
    
    public override function start() : Void {
        _reader.start();
    }

    /**
    Closes/disposes of all data structures required to read the table.
    **/
    #if cs
    @:native('Dispose')
    #elseif java
    @:native('close')
    #end
    public override function dispose() : Void {
        _reader.dispose();
    }    
}
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
    Standard/Core Library - Source code can be found on SourceForge.net
*/

package com.sdtk.std;

@:nativeGen
class ReaderAsyncAbstract implements ReaderAsync {
    private var _handlers : Null<Array<ReaderHandler>> = new Array<ReaderHandler>();

    public function readTo(rhHandler : ReaderHandler) : ReaderAsync {
        _handlers.push(rhHandler);
        return this;
    }

    public function read(sValue : String) {
        for (rhHandler in _handlers) {
            rhHandler.read(sValue);
        }
    }

    public function start() : ReaderAsync {
        return this;
    }

    #if cs
        @:native('Dispose')
    #elseif java
        @:native('close') 
    #end
    public function dispose() {
        _handlers = null;
    }
}

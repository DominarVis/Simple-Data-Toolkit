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

@:expose
@:nativeGen
class ParametersReader extends Reader {
    private var _next : Null<String> = null;
    private var _index : Int = 0;
    private var _parameters : Null<Parameters>;

    public function new(pParameters : Null<Parameters>) {
        super();

        if (pParameters == null) {
            pParameters = new Parameters();
        }
        _parameters = pParameters;
        _next = "";
        moveToNext();
    }

    private function moveToNext() {
      try {
        _next = null;
        _next = _parameters.getParameter(_index);
        _index++;
      } catch (ex : Dynamic) {
      }
      if (_next == null) {
        dispose();
      }
    }

    public override function hasNext() : Bool {
        return (_next != null);
    }

    public override function next() : Null<String> {
        var sValue : Null<String> = _next;
        if (sValue != null) {
            moveToNext();
        }
        return sValue;
    }

    public override function peek() : Null<String> {
        return _next;
    }

    #if cs
        @:native('Dispose')
    #elseif java
        @:native('close')
    #end
    public override function dispose() {
        if (_parameters != null) {
            _parameters = null;
            _next = null;
            _index = -1;
        }
    }

    public override function iterator() : DataIterator<String> {
        return this;
    }
}

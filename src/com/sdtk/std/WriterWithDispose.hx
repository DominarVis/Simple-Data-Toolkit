/*
    Copyright (C) 2024 Vis LLC - All Rights Reserved

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
class WriterWithDispose extends Writer {
    private var _writer : Null<Writer> = null;
    private var _onDispose : Void->Void;

    public function new(writer : Writer, onDispose : Void->Void) {
      super();
      _writer = writer;
      _onDispose = onDispose;
    }

    public override function start() {
        _writer.start();
    }

    public function endWith(writer : Writer) : Void {
      _writer = writer;
    }

    #if java
        @:native('close') 
    #end
    public override function dispose() : Void {
      _writer.dispose();
      _onDispose();
    }

    public override function flush() : Void {
      _writer.flush();
    }


    public override function write(str : String) : Void {
      _writer.write(str);
    }

    public override function switchToLineWriter() : Writer {
      return new WriterWithDispose(_writer.switchToLineWriter(), _onDispose);
    }

    public override function unwrapOne() : Writer {
      return _writer;
    }

    public override function unwrapAll() : Writer {
      return _writer.unwrapAll();
    }
}

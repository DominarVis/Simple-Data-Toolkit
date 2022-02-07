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
class FilterWriter extends Writer {
  private var _writer : Null<Writer>;
  private var _filter : Null<Array<Filter>>;

  public function new(wWriter : Writer) {
    super();
    _writer = wWriter;
  }

  public function addFilter(fFilter : Filter) : Void {
    if (_filter == null) {
      _filter = new Array<Filter>();
    }
    _filter.push(fFilter);
  }

  public override function write(str : String) : Void {
    if (_filter == null) {
      _writer.write(str);
    } else {
      var sWrite : Null<String> = str;
      for (fFilter in _filter) {
        sWrite = fFilter.filter(sWrite);
      }
      if (sWrite != null) {
        _writer.write(sWrite);
      }
    }
  }

    public override function switchToLineWriter() : Writer {
      _writer = _writer.switchToLineWriter();
      return this;
    }

    public override function unwrapOne() : Writer {
        return _writer;
    }

    public override function unwrapAll() : Writer {
        return _writer.unwrapAll();
    }

  public override function flush() {
    _writer.flush();
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_writer != null) {
      _writer.dispose();
      _writer = null;
      _filter = null;
    }
  }
}

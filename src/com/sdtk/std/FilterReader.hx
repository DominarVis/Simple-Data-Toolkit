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
class FilterReader extends Reader {
  private var _reader : Null<Reader>;
  private var _filter : Null<Array<Filter>>;
  private var _current : Null<String>;
  private var _currentRawIndex : Null<Int>;

  public function new(rReader : Reader) {
    super();
    _reader = rReader;
  }

  public override function rawIndex() : Int {
    return _currentRawIndex;
  }

  public override function jumpTo(index : Int) : Void {
      _reader.jumpTo(index);
      _current = null;
      check();
  }

  public function addFilter(fFilter : Filter) : Void {
    if (_filter == null) {
      _filter = new Array<Filter>();
    }
    _filter.push(fFilter);
  }

  private function check() : Void {
     if (_current == null) {
         if (_filter == null) {
             _current = _reader.next();
         } else {
             while (_current == null) {
                var iNext : Int = _reader.rawIndex();
                var sNext = _reader.next();
                if (sNext == null) {
                    break;
                }
                for (fFilter in _filter) {
                     sNext = fFilter.filter(sNext);
                }
                if (sNext != null) {
                    _current = sNext;
                    _currentRawIndex = iNext;
                }
             }
         }
     }
  }

  public override function hasNext() : Bool {
    check();
    return _current != null;
  }

  public override function next() : Null<String> {
    check();
    var sCurrent : String = _current;
    _current = null;
    return sCurrent;
  }

  public override function peek() : Null<String> {
    check();
    return _current;
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_reader != null) {
      _reader.dispose();
      _reader = null;
      _current = null;
      _filter = null;
    }
  }

  public override function switchToLineReader() : Reader {
    _reader = _reader.switchToLineReader();
    return this;
  }

  public override function unwrapOne() : Reader {
      return _reader;
  }

  public override function unwrapAll() : Reader {
      return _reader.unwrapAll();
  }
}

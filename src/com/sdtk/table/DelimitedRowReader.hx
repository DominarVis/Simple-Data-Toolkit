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
    Simple Table Converter (STC) - Source code can be found in Converter.hx in Haxe on SourceForge.net
*/

package com.sdtk.table;

import com.sdtk.std.*;

/**
  Adapts delimited files (like CSV, PSV, etc) to STC table row reader interface.
**/
@:expose
@:nativeGen
class DelimitedRowReader extends DataTableRowReader {
  private var _info : Null<DelimitedInfo> = null;
  private var _reader : Reader;
  private var _current : Null<String>;
  private var _currentRawIndex : Null<Int>;
  private var _done : Bool = false;
  private var _header : Null<Array<String>> = null;
  private var _initHeader : Bool;
  private static var _watch : Stopwatch = Stopwatch.getStopwatch("DelimitedRowReader");

  public function new(diInfo : DelimitedInfo, rReader : Reader, sHeader : Null<Array<String>>, bInitHeader : Bool) {
    super();
    reuse(diInfo, rReader, sHeader, bInitHeader);
  }

  public function reuse(diInfo : DelimitedInfo, rReader : Reader, sHeader : Null<Array<String>>, bInitHeader : Bool) {
    _info = diInfo;
    _reader = rReader;
    _header = sHeader;
    _initHeader = bInitHeader;
    _done = false;
    _index = -1;
    _rawIndex = -1;
    _started = false;
    _value = null;
  }

  private function check() : Void {
    if (_reader != null && _done != true) {
      _watch.start();
      var sChar : String = "";
      var iGettingValue : Int = -1;
      var iGot : Int = -1;
      var iCount : Int = 0;
      var sValue : StringBuf = new StringBuf();

      _currentRawIndex = _reader.rawIndex();
      if (!_reader.hasNext()) {
        _current = null;
        _done = true;
        return;
      }

      var rowDelimiter : String = _info.rowDelimiter();
      var delimiter : String = _info.delimiter();
      var hasNext : Bool = _reader.hasNext();
      var minimum : Int = _info.widthMinimum();
      var maximum : Int = _info.widthMaximum();
      var replacementIndicator : Null<String> = _info.replacementIndicator();
      var replacements : Array<String> = _info.replacements();

      while (hasNext && (iGettingValue >= 0 || sChar != rowDelimiter && sChar != delimiter) && !_done) {
        var bSkip : Bool = false;
        var bNoNext : Bool = false;
        var bEndValue : Bool = false;
        sChar = _reader.peek();
        if (iGettingValue >= 0) {
          if (iGettingValue == isEnd(sChar)) {
            bEndValue = true;
            bSkip = true;
          }
        } else {
          if (sChar == delimiter) {
            bSkip = true;
          } else if (sChar == rowDelimiter) {
            bSkip = true;
            _done = true;
          } else if (sChar == "\r") {
            bSkip = true;
          } else if (iCount == 0) {
            iGettingValue = isStart(sChar);
            if (iGettingValue >= 0) {
              iGot = iGettingValue;
              bSkip = true;
            }
          } else if (iCount >= maximum && maximum > 0) {
            bSkip = true;
            bNoNext = true;
          }
        }
        iCount++;
        if (!bNoNext) {
          _reader.next();
        }
        {
          if (replacementIndicator == null || replacementIndicator == sChar) {
            if (replacements != null && replacements.length > 0) {
              var checkReplace : String = sChar + _reader.peek();
              var replaceI : Int = replacements.length - 2;
              while (replaceI >= 0) {
                if (replacements[replaceI] == checkReplace) {
                  sChar = replacements[replaceI + 1];
                  bSkip = false;
                  bEndValue = false;
                  _reader.next();
                  break;
                }
                replaceI -= 2;
              }
            }
          }
        }
        hasNext = _reader.hasNext();
        if (!bSkip) {
          sValue.add(sChar);
        }
        if (bEndValue) {
          iGettingValue = -1;
        }
      }
      _watch.end();
      if (sValue.length <= 0) {
        _current = null;
      } else {
        _current = fromStringToType(sValue.toString());
      }
    } else {
      _current = null;
    }
  }

  public override function hasNext() : Bool {
    return _current != null || !_done;
  }

  private function isStart(sChar : String) : Int {
    if (_info.boolStart() == sChar) {
      return 0;
    } else if (_info.floatStart() == sChar) {
      return 1;
    } else if (_info.intStart() == sChar) {
      return 2;
    } else if (_info.stringStart() == sChar) {
      return 3;
    } else {
      return -1;
    }
  }

  private function isEnd(sChar : String) : Int {
    if (_info.boolEnd() == sChar) {
      return 0;
    } else if (_info.floatEnd() == sChar) {
      return 1;
    } else if (_info.intEnd() == sChar) {
      return 2;
    } else if (_info.stringEnd() == sChar) {
      return 3;
    } else {
      return -1;
    }
  }

  private override function startI() : Void {
    check();
  }

  public override function next() : Dynamic {
    var sCurrent = _current;
    var iRawIndex = _currentRawIndex;
    check();
    if (_header == null) {
      incrementTo(null, sCurrent, iRawIndex);
    } else {
      if (_initHeader) {
        _header.push(sCurrent);
      }
      incrementTo(_header[index() + 1], sCurrent, iRawIndex);
    }
    return sCurrent;
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    _current = null;
    _info = null;
    _reader = null;
    _header = null;
  }
}
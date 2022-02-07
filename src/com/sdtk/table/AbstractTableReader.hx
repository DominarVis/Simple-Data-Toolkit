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

#if JS_BROWSER
  import com.sdtk.std.JS_BROWSER.Document;
  import com.sdtk.std.JS_BROWSER.Element;
#end

/**
  Handles reading a typical table structure based on StandardTableInfo.
**/
@:nativeGen
class AbstractTableReader {
  private var _info : TableInfo;
  private var _element : Dynamic;
  private var _accessor : Dynamic;
  private var _next : Dynamic;

  public function new(tdInfo : TableInfo, oElement : Dynamic) {
    _info = tdInfo;
    _element = oElement;
    _accessor = null;
    findNext();
  }

  /**
    Checks if it should read a given element.
  **/
  private function elementCheck(oElement : Dynamic) : Bool {
    return false;
  }

  /**
    Gets the value contained in a given element.
  **/
  private function getValue(oElement : Dynamic) : Dynamic {
    return null;
  }

  /**
    Find the next readable element.
  **/
  private function findNext() : Void {
    #if JS_BROWSER
      var eNext : Element;

      if (_next == null) {
        eNext = cast(_element, Element).firstElementChild;
        if (eNext.tagName.toUpperCase() == "TBODY") {
          eNext = eNext.firstElementChild;
        }
      } else {
        eNext = cast(_next, Element).nextElementSibling;
      }

      while (eNext != null && !elementCheck(eNext)) {
        eNext = eNext.nextElementSibling;
      }

      _next = eNext;
    #end
  }

  /**
    Is there another readable element.
  **/
  public function hasNext() : Bool {
    return (_next != null);
  }

  /**
    Check next readable element, but don't consume/move to next.
  **/
  public function peek() : Dynamic {
    if (_next == null) {
      return null;
    } else {
      return getValue(_next);
    }
  }

  /**
    Get next readable element and move on to the following.
  **/
  public function next() : Dynamic {
    _accessor = _next;
    findNext();

    if (_accessor == null) {
      return null;
    } else {
      return getValue(_accessor);
    }
  }
}

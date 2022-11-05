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
class ConverterStageSort implements ConverterStage implements Disposable {
  private var _array : Null<Array<Array<Dynamic>>>;
  private var _columns : Null<Array<Int>>;
  private var _foundColumns : Null<Array<String>>;
  private var _reverse : Null<Array<Bool>>;
  private var _names : Null<Array<String>>;
  private var _firstRowIsHeader : Bool = true;
  private static var _watch : Stopwatch = Stopwatch.getStopwatch("ConverterStageSort");

  private function new() {
  }
  
  public static function createWithArrayAndColumns(aArray : Array<Array<Dynamic>>, sColumns : Array<String>) {
    var stage : ConverterStageSort = new ConverterStageSort();
    stage.setArray(aArray);
    for (sColumn in sColumns) {
      stage.addColumnName(sColumn, false);
    }
    return stage;
  }
  
  public static function createWithArrayAndColumnsString(aArray : Array<Array<Dynamic>>, sColumns : String) {
    return createWithArrayAndColumns(aArray, sColumns.split(","));
  }

  public function setArray(aArray : Null<Array<Array<Dynamic>>>) : Void {
    _array = aArray;
  }

  public function addColumn(iColumn : Int, bReverse : Bool) {
    if (_columns == null) {
      _columns = new Array<Int>();
      _reverse = new Array<Bool>();
    }

    _columns.push(iColumn);
    _reverse.push(bReverse);
  }
  
  public function addColumnName(sColumn : String, bReverse : Bool) {
    if (_names == null) {
      _names = new Array<String>();
      _reverse = new Array<Bool>();
    }
    
    _names.push(sColumn);
    _reverse.push(bReverse);
  }

  private function findNames() : Void {
  	var oFirstRow : Array<Dynamic> = _array[0];
  	_columns = new Array<Int>();
  	if (_names.length == 1) {
      for (sName in _names) {
        _columns.push(_foundColumns.indexOf(sName));
      }
    } else {
      _firstRowIsHeader = true;
      var i : Int = 0;
      var foundColumns : Map<String, Int> = new Map<String, Int>();
      for (o in _foundColumns) {
        if (o != oFirstRow[i]) {
          _firstRowIsHeader = false;
        }
        foundColumns.set(o, i++);
      }
      for (sName in _names) {
        _columns.push(foundColumns[sName]);
      }
    }
  }
  
  public function convert() : Void {
    _watch.start();
  	var oFirstRow : Null<Array<Dynamic>> = null;
    if (_columns == null && _names != null) {
      findNames();
  	  oFirstRow = _array[0];
    }
    _array.sort(function (a, b) {
      if (_firstRowIsHeader) {
        if (a == oFirstRow) {
          return -1;
        } else if (b == oFirstRow) {
          return 1;
        }
      }

      var i : Int = 0;
      for (iColumn in _columns) {
        var bReverse : Bool = _reverse[i];
        var columnA : String = Std.string(a[iColumn]);
        var columnB : String = Std.string(b[iColumn]);
        switch (columnA < columnB ? -1 : columnA > columnB ? 1 : 0) {
          case -1:
            return bReverse ? 1 : -1;
          case 1:
            return bReverse ? -1 : 1;
        }
        i++;
      }
      return 0;
    });
    _watch.end();
  }

  public function setColumns(columns : Array<String>) : Void {
    _foundColumns = columns;
  }

  public function getColumns() : Array<String> {
    return _foundColumns;
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public function dispose() : Void {
    if (_array != null) {
      _array = null;
      _columns = null;
      _foundColumns = null;
      _reverse = null;
      _names = null;
    }
  }
}

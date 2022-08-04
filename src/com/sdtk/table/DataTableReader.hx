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

import com.sdtk.std.DataIterable;

/**
  Defines defaults and interface for reading a whole table.
**/
@:expose
@:nativeGen
class DataTableReader extends DataEntryReader {
  private var ROW_NAME : String = "__name__";
  private var ROW_NAME_INDEX : Int = -1;
  private var HEADER_ROW_NAME : String = null;
  private var HEADER_ROW_INDEX : Int = -1;
  private var _alwaysString : Bool = false;

  public function new() {
    super();
  }
  
  private function writeRowNameHeader(writers : Iterable<DataTableWriter>, rowWriters : Array<DataTableRowWriter>, sName : String) : Bool {
  	var bWritingRowNames : Bool = false;
  	if (sName != null && sName.length > 0) {
  	  var i : Int = 0;
      for (writer in writers) {
        if (writer.writeRowNameFirst()) {
          rowWriters[i].write(ROW_NAME, ROW_NAME, ROW_NAME_INDEX);
          bWritingRowNames = true;
        }
        i++;
      }
    }
    return bWritingRowNames;
  }

  // TODO - Need a generic writer wrapper to also write rowNames.
  // TODO - Need a generic writer wrapper to also write header columns.
  // TODO - Need a generic reader wrapper to skip rowNames.
  // TODO - Need a generic reader wrapper to skip header columns.
  private function writeRowName(writers : Iterable<DataTableWriter>, rowWriters : Array<DataTableRowWriter>, sName : String, bWritingRowNames : Bool) : Bool {
  	if (bWritingRowNames) {
      bWritingRowNames = false;
  	  if (sName != null && sName.length > 0) {
  	    var i : Int = 0;
        for (writer in writers) {
          if (writer.writeRowNameFirst()) {
            rowWriters[i].write(sName, ROW_NAME, ROW_NAME_INDEX);
            bWritingRowNames = true;
          }
          i++;
        }
      }
    }
    return bWritingRowNames;
  }

  public function nextReuse(reader : Null<DataTableRowReader>) : Dynamic {
    return null;
  }
  
  private function writeFirstRow(writers : Iterable<DataTableWriter>, rowWriters : Array<DataTableRowWriter>) : Bool {
  	var bBufferFirstRow : Bool = false;
    var rowReader : DataTableRowReader = next();
    rowReader.alwaysString(_alwaysString);
  	var bWritingRowNames : Bool = !isAutoNamed() && !isNameIndex();
    var sName : String = name();
    var iIndex : Int = index();
  	    
  	if (headerRowNotIncluded()) {
  	  for (writer in writers) {
  	    bBufferFirstRow = bBufferFirstRow || writer.writeHeaderFirst();
  	  }
  	}
    	
  	if (!bBufferFirstRow) {
  	  if (!headerRowNotIncluded()) {
        var i : Int = 0;
        var iNulls : Int = 0;
  	    for (writer in writers) {
  	      if (!writer.writeHeaderFirst()) {
            rowWriters[i++] = NullRowWriter.instance;
  	        iNulls++;
  	      } else {
  	      	rowWriters[i++] = writer.writeStart(sName, iIndex);
  	      }
  	    }
  	  
  	    if (iNulls == i) {
  	  	  rowReader.convertTo(NullRowWriter.instance);
  	    } else {
          bWritingRowNames = writeRowName(writers, rowWriters, sName, bWritingRowNames);
  	      rowReader.convertToAll(rowWriters);
  	    }
        i = 0;
        for (rowWriter in rowWriters) {
          if (rowWriter != null) {
            if (rowWriter == NullRowWriter.instance) {
              rowWriters[i] = null;
            } else {
              rowWriter.dispose();
            }
          }
          i++;
        }
  	  } else {
        var i : Int = 0;
  	    for (writer in writers) {
  	      rowWriters[i++] = writer.writeStart(sName, iIndex);
  	    }
        bWritingRowNames = writeRowName(writers, rowWriters, sName, bWritingRowNames);
  	  	rowReader.convertToAll(rowWriters);
        for (rowWriter in rowWriters) {
          if (rowWriter != null) {
            rowWriter.dispose();
          }
        }
  	  }
  	} else {
      var i : Int = 0;
      var aData : Array<Dynamic> = new Array<Dynamic>();
      var aName : Array<String> = new Array<String>();
      var aIndex : Array<Int> = new Array<Int>();
  		
  	  for (writer in writers) {
  	    if (writer.writeHeaderFirst()) {
  	      rowWriters[i++] = writer.writeStart(HEADER_ROW_NAME, HEADER_ROW_INDEX);
  	    } else {
  	      rowWriters[i++] = null;
  	    }
  	  }
  	  rowReader.start();
      for (rowWriter in rowWriters) {
        if (rowWriter != null) {
          rowWriter.start();
        }
      }
      if (bWritingRowNames) {
        bWritingRowNames = writeRowNameHeader(writers, rowWriters, sName);
      }
      while (rowReader.hasNext()) {
  	    try {
          var data : Dynamic = rowReader.next();
          var sName : String = rowReader.name();
          var iIndex : Int = rowReader.index();
          
          for (rowWriter in rowWriters) {
            if (rowWriter != null) {
              rowWriter.write(sName, sName, iIndex);
            }
          }
          aData.push(data);
          aName.push(sName);
          aIndex.push(iIndex);
        } catch (msg : Dynamic) { break; }
      }

      rowReader.dispose();
      
      for (rowWriter in rowWriters) {
        if (rowWriter != null) {
          rowWriter.dispose();
        }
      }

  	  i = 0;
  	  for (writer in writers) {
  	  	rowWriters[i++] = writer.writeStart(sName, iIndex);
  	  }

      for (rowWriter in rowWriters) {
  	    rowWriter.start();
  	  }
  	  
      bWritingRowNames = writeRowName(writers, rowWriters, sName, bWritingRowNames);
  	  i = 0;
  	  for (o in aData) {
  	    for (rowWriter in rowWriters) {
  	      rowWriter.write(o, aName[i], aIndex[i]);  
  	    }
  	    i++;
  	  }
  	  
      for (rowWriter in rowWriters) {
  	    rowWriter.dispose();
  	  }
  	}
  	
  	return bWritingRowNames;
  }
	
  /**
    Convert a table from one data structure to another.
  **/
  public function convertTo(writer : DataTableWriter) {
    var aSingle : Array<DataTableWriter> = new Array<DataTableWriter>();
    aSingle.push(writer);
    convertToAll(aSingle);
  }

  /**
    Convert a table from one data structure to multiple target data structures.
  **/
  public function convertToAll(writers : Iterable<DataTableWriter>) {
  	var bWritingRowNames : Bool = true;
  	var bFirst : Bool = true;
  	var bCanWrite : Bool = true;
    start();
    for (writer in writers) {
      writer.start();
    }
    try {
      var rowReader : Null<DataTableRowReader> = null;
      var rowWriters : Array<DataTableRowWriter> = [];
      for (writer in writers) {
        rowWriters.push(null);
      }
      while (hasNext() && bCanWrite) {
        if (bFirst) {
          bWritingRowNames = writeFirstRow(writers, rowWriters);
          bFirst = false;
        } else {
          rowReader = nextReuse(rowReader);
          if (rowReader == null) {
            break;
          }
          rowReader.alwaysString(_alwaysString);
          rowReader.start();
          try {
            var i : Int = 0;
            var sName : String = name();
            var iIndex : Int = index();
            for (writer in writers) {
              rowWriters[i] = writer.writeStartReuse(sName, iIndex, rowWriters[i]);
              i++;
            }
            bWritingRowNames = writeRowName(writers, rowWriters, sName, bWritingRowNames);
            rowReader.convertToAll(rowWriters);
          }
          catch (msg : Dynamic) { }
        }
        bCanWrite = false;
        for (writer in writers) {
          bCanWrite = bCanWrite || writer.canWrite();
        }
      }
      for (rowWriter in rowWriters) {
        if (rowWriter != null) {
          rowWriter.dispose();
        }
      }
      if (rowReader != null) {
        rowReader.dispose();
      }
    }
    catch (msg : Dynamic) { }
    dispose();
    for (writer in writers) {
      writer.dispose();
    }
  }
  
  public function headerRowNotIncluded() : Bool {
    return true;
  }
  
  public function oneRowPerFile() : Bool {
    return false;
  }

  public function alwaysString(?value : Null<Bool>) : Bool {
    if (value == null) {
      return _alwaysString;
    } else {
      _alwaysString = value;
      return _alwaysString;
    }
  }

  public function reset() : Void { }

  public function moveTo(row : Int) : Void {
    if (row < _index) {
      reset();
    }
    while (_index < row) {
      //TODO
      //skip();
    }
  }

  public function noHeaderIncluded(noHeader : Bool) : Void { }

  public function allowNoHeaderInclude() : Bool {
    return false;
  }

  public function indexer() : com.sdtk.std.DataIterable<Dynamic> {
    if (_iteratorData == null) {
      _iteratorData = new DataTableReaderSharedIterator(this);
    }
    return new DataTableReaderIterable<Dynamic>(_iteratorData, function () : Dynamic { 
      return _iteratorData._row;
    });
  }

  public function readColumnIndex(i : Int) : com.sdtk.std.DataIterable<Dynamic> {
    if (_iteratorData == null) {
      _iteratorData = new DataTableReaderSharedIterator(this);
    }
    return new DataTableReaderIterable<Dynamic>(_iteratorData, function () : Dynamic {
      return _iteratorData._dataByIndex[i];
    });
  }  

  public function readColumnName(s : String) : com.sdtk.std.DataIterable<Dynamic> {
    if (_iteratorData == null) {
      _iteratorData = new DataTableReaderSharedIterator(this);
    }
    return new DataTableReaderIterable<Dynamic>(_iteratorData, function () : Dynamic {
      return _iteratorData._dataByName[s];
    });
  }

  /* TODO
  public function flipColumnRows() : DataTableReader {

  }

  public function reverse() : DataTableReader {

  }
  
  //  ,1,2,3,4
  // A,0,0,0,0
  // B,0,0,0,0
  //
  // A,1,0
  // A,2,0
  // A,3,0
  public function pivot() : DataTableReader {

  }
*/
  
  private var _iteratorData : DataTableReaderSharedIterator;
}

@:nativeGen
class DataTableReaderIterable<T> implements com.sdtk.std.DataIterable<T> {
  private var _shared : DataTableReaderSharedIterator;
  private var _f : Void -> Dynamic;

  public function new(shared : DataTableReaderSharedIterator, f : Void->Dynamic) {
    _shared = shared;
    _f = f;
  }

  public function iterator() : DataTableReaderIterator<T> {
    return new DataTableReaderIterator<T>(_shared, _f);
  }
}

@:nativeGen
class DataTableReaderIterator<T> implements com.sdtk.std.DataIterator<T> {
  private var _shared : DataTableReaderSharedIterator;
  private var _f : Void -> Dynamic;
  private var _row : Int = 0;
  
  public function new(shared : DataTableReaderSharedIterator, f : Void->Dynamic) {
    _shared = shared;
    _f = f;
  }

  public function hasNext() : Bool {
    // TODO
    return false;
  }

  public function next() : T {
    _shared.moveTo(_row + 1);
    _row++;
    return _f();
  }
}

@:nativeGen
class DataTableReaderSharedIterator {
  public var _reader : DataTableReader;
  public var _row : Int = 0;
  public var _dataByIndex : Array<Dynamic>;
  public var _dataByName : Map<String, Dynamic>;

  public function new(reader : DataTableReader) {
    _reader = reader;
  }
  
  public function moveTo(?row : Int) {
    if (row != _row) {
      _reader.moveTo(row);
    }
  }
}
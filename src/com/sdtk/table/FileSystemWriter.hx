package com.sdtk.table;

import com.sdtk.std.*;

@:expose
@:nativeGen
class FileSystemWriter extends DataTableWriter {
  private var _handler : Null<FileSystemHandler> = null;
  private var _writer : Null<Writer> = null;
  private var _previous : Null<FileSystemRowWriter> = null;

  private function new(fshHandler : FileSystemHandler, wWriter : Writer) {
    super();
    _handler = fshHandler;
    _writer = wWriter;
  }

  public static function createCMDDirWriter(wWriter : Writer) {
    return new FileSystemWriter(CMDDirHandler.instance, wWriter);
  }

  /**
    Indicates the beginning of writing.
  **/
  public override function start() : Void {
    _writer.start();
  }

  private override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    if (rowWriter == null) {
      _previous = new FileSystemRowWriter(_handler, _writer, _previous, 0);
    } else {
      _previous = cast rowWriter;
      _previous.reuse(_handler, _writer, _previous, 0);
    }
    
    return _previous;
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
      _handler = null;
      _previous = null;
      super.dispose();
    }
  }
}

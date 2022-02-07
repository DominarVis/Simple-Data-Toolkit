package com.sdtk.table;

import com.sdtk.std.*;

@:expose
@:nativeGen
class FileSystemReader extends DataTableReader {
  private var _handler : Null<FileSystemHandler> = null;
  private var _reader : Null<Reader> = null;
  private var _previous : Null<FileSystemRowReader> = null;
  private var _current : Null<FileSystemRowReader> = null;

  private function new(fshHandler : FileSystemHandler, rReader : Reader) {
    super();
    _handler = fshHandler;
    _reader = rReader;
  }

  public static function createCMDDirReader(rReader : Reader) {
    return new FileSystemReader(CMDDirHandler.instance, rReader);
  }

  private function check(reuse : Bool) : Void {
    if (reuse == false) {
      _current = new FileSystemRowReader(_handler, _reader, _current);
    } else {
      if (_previous == null) {
        check(false);
      } else {
        _previous.reuse(_handler, _reader, _current);
        _current = _previous;
      }
    }
  }

  private override function startI() : Void {
    _reader.start();
    check(false);
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
      _handler = null;
      _previous = null;
      _current = null;
    }
  }

  public override function hasNext() : Bool {
    return _current != null;
  }

  private function nextI(reuse : Bool) : Dynamic {
    if (_current != null) {
      var fsrrCurrent : Null<FileSystemRowReader> = _current;
      check(reuse);
      _previous = fsrrCurrent;
      return fsrrCurrent;
    } else {
      return null;
    }
  }

  public override function nextReuse(rowReader : Null<DataTableRowReader>) : Dynamic {
    return nextI(true);
  }

  public override function next() : Dynamic {
    return nextI(false);
  }
}

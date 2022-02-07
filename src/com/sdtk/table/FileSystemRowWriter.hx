package com.sdtk.table;

import com.sdtk.std.*;

@:nativeGen
class FileSystemRowWriter extends DataTableRowWriter {
  private var _handler : Null<FileSystemHandler> = null;
  private var _writer : Null<Writer> = null;
  private var _previous : Null<FileInfo> = null;
  private var _current : Null<FileInfo> = null;
  private var _tally : Null<TallyInfo> = null;
  private var _options : Int;

  public function new(fshHandler : FileSystemHandler, wWriter : Writer, fsrwPrevious : Null<FileSystemRowWriter>, iOptions : Int) {
    super();
    reuse(fshHandler, wWriter, fsrwPrevious, iOptions);
  }

  public function reuse(fshHandler : FileSystemHandler, wWriter : Writer, fsrwPrevious : Null<FileSystemRowWriter>, iOptions : Int) {
    _current = new FileInfo();
    _handler = fshHandler;
    _writer = wWriter;
    if (fsrwPrevious != null && fsrwPrevious != this) {
      _previous = fsrwPrevious._current;
      _tally = fsrwPrevious._tally;
      fsrwPrevious._current = null;
      fsrwPrevious._tally = null;
    } else {
      _tally = new TallyInfo();
    }
    _options = iOptions;
  }

  public override function write(data : Dynamic, name : String, index : Int) : Void {
    switch (StringTools.trim(name).toLowerCase()) {
      case "file":
        _current.setName(data);
      case "directory":
        _current.setDirectory(data);
      case "size":
        _current.setSize(data);
      case "drive":
        _current.setDrive(data);
      case "label":
        _current.setLabel(data);
      case "serial":
        _current.setSerial(data);
      case "owner":
        _current.setOwner(data);
      case "short":
        _current.setShortName(data);
      case "type":
        switch (StringTools.trim(Std.string(data)).substr(0, 3).toLowerCase()) {
          case "dir":
            _current.setIsDirectory(true);
          case "jun":
            _current.setIsJunction(true);
        }
      case "true":
        _current.setTrueName(data);
      case "modified":
        _current.setDate(data);
    }
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_writer != null) {
      _writer = null;
      _handler = null;
      _previous = null;
      // Don't set _current to null
      // Don't set _tally to null
      super.dispose();
    }
  }
}

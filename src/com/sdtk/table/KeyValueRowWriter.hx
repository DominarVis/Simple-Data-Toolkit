package com.sdtk.table;

import com.sdtk.std.*;

@:nativeGen
class KeyValueRowWriter extends DataTableRowWriter {
  private var _handler : Null<KeyValueHandler> = null;
  private var _writer : Null<Writer> = null;
  private var _name : Null<String> = null;
  private var _rowIndex : Int;
  private var _map : Null<Map<String, Dynamic>> = new Map<String, Dynamic>();

  public function new(fshHandler : KeyValueHandler, wWriter : Writer, name : String, index : Int) {
    super();
    reuse(fshHandler, wWriter, name, index);
  }

  public function reuse(fshHandler : KeyValueHandler, wWriter : Writer, name : String, index : Int) : Void {
    _handler = fshHandler;
    _writer = wWriter;
    _name = name;
    _rowIndex = index;
  }  

  public override function start() : Void {
    _writer.start();
  }

  public override function write(data : Dynamic, name : String, index : Int) : Void {
    if (data != null) {
      _map.set(name, data);
    }
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_writer != null) {
      _handler.write(_writer, _map);
      _writer = null;
      _handler = null;
      _name = null;
      _map = null;
      super.dispose();
    }
  }
}

package com.sdtk.table;

import com.sdtk.std.*;

@:expose
@:nativeGen
class KeyValueWriter extends DataTableWriter {
  private var _handler : Null<KeyValueHandler> = null;
  private var _writer : Null<Writer> = null;

  private function new(fshHandler : KeyValueHandler, wWriter : Writer) {
    super();
    _handler = fshHandler;
    _writer = wWriter;
  }

  public static function createINIWriter(wWriter : Writer) {
    return new KeyValueWriter(INIHandler.instance, wWriter);
  }

  public static function createJSONWriter(wWriter : Writer) {
    return new KeyValueWriter(JSONHandler.instance, wWriter);
  }

  public static function createPropertiesWriter(wWriter : Writer) {
    return new KeyValueWriter(PropertiesHandler.instance, wWriter);
  }

  public static function createSplunkWriter(wWriter : Writer) {
    return new KeyValueWriter(SplunkHandler.instance, wWriter);
  }

  public override function start() : Void {
    _writer.start();
  }

  private override function writeStartI(name : String, index : Int, rowWriter : Null<DataTableRowWriter>) : DataTableRowWriter {
    if (rowWriter == null) {
      rowWriter = new KeyValueRowWriter(_handler, _writer, name, index);
    } else {
      var rw : KeyValueRowWriter = cast rowWriter;
      rw.reuse(_handler, _writer, name, index);
    }
    return rowWriter;
  }
  
  public override function oneRowPerFile() : Bool {
    return _handler.oneRowPerFile();
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
      super.dispose();
    }
  }
}

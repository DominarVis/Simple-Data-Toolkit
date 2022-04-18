package com.sdtk.table;

import com.sdtk.std.*;

@:expose
@:nativeGen
class KeyValueRowReader extends DataTableRowReader {
  private var _map : Null<Map<String, Dynamic>> = null;
  private var _columns : Null<Array<Dynamic>> = null;

  public function new(mMap : Map<String, Dynamic>, cColumns : Null<Array<Dynamic>>) {
    super();
    reuse(mMap, cColumns);
  }

  public function reuse(mMap : Map<String, Dynamic>, cColumns : Null<Array<Dynamic>>) {
    _map = mMap;
    _columns = cColumns;
    _index = -1;
    _rawIndex = -1;
    _started = false;
    _value = null;
  }

  private override function startI() : Void {
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    _map = null;
    _columns = null;
  }

  public override function hasNext() : Bool {
    return index() < _columns.length - 1;
  }

  public override function next() : Dynamic {
    var sColumn : String = _columns[index() + 1];
    incrementTo(sColumn, _map.get(sColumn), index() + 1);
    return value();
  }
}

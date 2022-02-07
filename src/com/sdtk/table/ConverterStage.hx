package com.sdtk.table;

import com.sdtk.std.*;

@:nativeGen
interface ConverterStage extends Disposable {
  function convert() : Void;
  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  function dispose() : Void;
}
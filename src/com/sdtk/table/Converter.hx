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
  Handles converting from one data format to another.
**/
@:expose
@:nativeGen
class Converter {
  /*
  public function convert(dtrReader : DataTableReader, drwWriter : DataTableWriter) {
    dtrReader.convertTo(drwWriter);
  }*/

  /**
    Converts from one data format to another.  Takes controls or names of controls.
  **/

  private static var _watch : Stopwatch = Stopwatch.getStopwatch("Converter");


  public static function convert(oSource : Dynamic, oTarget : Dynamic) : Void {
    convertWithOptions(oSource, null, oTarget, null, null, null, null, null, null, false, false, null, null);
  }

  private static function length(o : Dynamic) : Int {
    if (isString(o)) {
      var s : String = cast o;
      return o.length;
    } else if (
        #if (haxe_ver < 3.2)
          Std.is(o, Array)
        #else
          Std.isOfType(o, Array)
        #end     
      ) {
      var a : Array<Dynamic> = cast o;
      return a.length;
    } else {
      return -1;
    }
  }

  private static function isString(o : Dynamic) : Bool {
    #if (haxe_ver < 3.2)
      return Std.is(o, String);
    #else
      return Std.isOfType(o, String);
    #end     
  }  

  public static function convertWithOptions(oSource : Dynamic, fSource : Null<Format>, oTarget : Dynamic, fTarget : Null<Format>, sFilterColumnsExclude : Dynamic, sFilterColumnsInclude : Dynamic, sFilterRowsExclude : Dynamic, sFilterRowsInclude : Dynamic, sSortRowsBy : Dynamic, leftTrim : Bool, rightTrim : Bool, inputOptions : Map<String, Dynamic>, outputOptions : Map<String, Dynamic>) : Void {
    _watch.start();

    var aStages : Array<ConverterStage> = new Array<ConverterStage>();
    var error : Dynamic = null;

    try {
      // When sorting, we first filter the input
      // Store the data in a temporary location
      // Sort the temporary location
      // Then output to the final output
      if (sSortRowsBy != null && length(sSortRowsBy) > 0) {
        var awWriter = Array2DWriter.writeToExpandableArray(null);
        aStages.push(new ConverterStageStandard(oSource, fSource, awWriter, Format.ARRAY, sFilterColumnsExclude, sFilterColumnsInclude, sFilterRowsExclude, sFilterRowsInclude, leftTrim, rightTrim, inputOptions, null));
        if (isString(sSortRowsBy)) {
          aStages.push(ConverterStageSort.createWithArrayAndColumnsString(awWriter.getArray(), cast sSortRowsBy));
        } else {
          aStages.push(ConverterStageSort.createWithArrayAndColumns(awWriter.getArray(), cast sSortRowsBy));
        }
        var arReader : Array2DReader<Dynamic> = awWriter.flip();
        aStages.push(new ConverterStageStandard(arReader, Format.ARRAY, oTarget, fTarget, null, null, null, null, false, false, null, outputOptions));
      } else {
        aStages.push(new ConverterStageStandard(oSource, fSource, oTarget, fTarget, sFilterColumnsExclude, sFilterColumnsInclude, sFilterRowsExclude, sFilterRowsInclude, leftTrim, rightTrim, inputOptions, outputOptions));
      }

      for (csStage in aStages) {
        csStage.convert();
      }
    } catch (message : Dynamic) {
      error = message;
    }

    for (csStage in aStages) {
      try {
        csStage.dispose();
      } catch (message : Dynamic) { }
    }

    _watch.end();
    if (error != null) {
      throw error;
    }
  }

  #if !EXCLUDE_PARAMETERS
  public static function main() : Void {
    var pParameters = new Parameters();
    if (pParameters.getRunInTestMode()) {
      #if JS_BROWSER
        com.sdtk.std.JS_BROWSER.Console.log
      #elseif JS_SNOWFLAKE
        com.sdtk.std.JS_SNOWFLAKE.Logger.log
      #elseif JS_WSH
        com.sdtk.std.JS_WSH.WScript.Echo
      #elseif JS_NODE
        com.sdtk.std.JS_NODE.Console.log
      #else
        Sys.println
      #end
      (
        Tests.runTests(pParameters.getRecordPass(), pParameters.getVerbose())
      );
    } else if (pParameters.getInput() == null || pParameters.getOutput() == null) {
      pParameters.fullPrint();
    } else {
      convertWithOptions(pParameters.getInput(), pParameters.getInputFormat(), pParameters.getOutput(), pParameters.getOutputFormat(), pParameters.getFilterColumnsExclude(), pParameters.getFilterColumnsInclude(), pParameters.getFilterRowsExclude(), pParameters.getFilterRowsInclude(), pParameters.getSortRowsBy(), pParameters.getLeftTrim(), pParameters.getRightTrim(), pParameters.getInputOptions(), pParameters.getOutputOptions());
    }
    Stopwatch.printResults();
  }
  #end

  public static function start() : ConverterInputOptions {
    return new ConverterInputOptions();
  }

  public static function quick() : ConverterQuickInputOptions {
    return new ConverterQuickInputOptions();
  }  
}
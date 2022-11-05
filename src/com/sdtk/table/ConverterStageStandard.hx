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

//import Assertion.*;

import com.sdtk.std.*;

@:nativeGen
class ConverterStageStandard implements ConverterStage {
  private var _writer : Null<DataTableWriter> = null;
  private var _reader : Null<DataTableReader> = null;
  private var _columns : Array<String> = null;

  private static function isString(o : Dynamic) : Bool {
    #if (haxe_ver < 3.2)
      return Std.is(o, String);
    #else
      return Std.isOfType(o, String);
    #end     
  }  

  private static function isInt(o : Dynamic) : Bool {
    #if (haxe_ver < 3.2)
      return Std.is(o, Int);
    #else
      return Std.isOfType(o, Int);
    #end     
  }    

  private static function mergeFilters(a : Null<Array<com.sdtk.std.Filter>>, b : Null<Array<com.sdtk.std.Filter>>) : com.sdtk.std.Filter {
    if ((a == null || a.length <= 0)&& (b == null || b.length <= 0)) {
      return null;
    } else {
      var mergedA : Null<com.sdtk.std.Filter>;
      var mergedB : Null<com.sdtk.std.Filter>;
      if (a == null || a.length <= 0) {
        mergedA = null;
      } else {
        var filter : Null<com.sdtk.std.Filter> = null;
        for (f in a) {
          if (filter == null) {
            filter = f;
          } else {
            filter = filter.or(f);
          }
        }
        mergedA = filter;
      }

      if (b == null || b.length <= 0) {
        mergedB = null;
      } else {
        var filter : Null<com.sdtk.std.Filter> = null;
        for (f in a) {
          if (filter == null) {
            filter = f;
          } else {
            filter = filter.and(f);
          }
        }
        mergedB = filter;
      }

      if (mergedA != null && mergedB != null) {
        return mergedA.and(mergedB);
      } else if (mergedA != null) {
        return mergedA;
      } else {
        return mergedB;
      }
    }
  }

  private static function getOption(options : Map<String, Dynamic>, key : String, ?def : Dynamic = null) : Dynamic {
    if (options == null) {
      return def;
    } else {
      var value : Dynamic = options.get(key);
      if (value == null) {
        return def;
      } else {
        return value;
      }
    }
  }

  public static function createWriter(oTarget : Dynamic, fTarget : Null<Format>, outputOptions : Map<String, Dynamic>) : Null<DataTableWriter> {
    var writer : Null<DataTableWriter> = null;
    if (oTarget != null) {
      if (
        #if (haxe_ver < 3.2)
          Std.is(oTarget, DataTableWriter)
        #else
          Std.isOfType(oTarget, DataTableWriter)
        #end
      ) {
        writer = cast oTarget;
      }
      if (writer == null) {
        var sTarget;

        if (oTarget == Std.string(oTarget)) {
          sTarget = "STRING";
        } else {
          sTarget = Type.getClassName(Type.getClass(oTarget)).toUpperCase();
        }

        switch (sTarget) {
          case "STRING":
            var sString : String = cast(oTarget, String);
            switch (sString.charAt(0)) {
              #if !EXCLUDE_CONTROLS
              case ".", "#":
                oTarget = getControl(oTarget);
              #end
              #if !EXCLUDE_FILES
              default:
                oTarget = (new FileWriter(sString, false)).convertToStringWriter().switchToDroppingCharacters();
              #end
            }
          case "STRINGBUF":
            oTarget = new StringWriter(oTarget);
          case "ARRAY":
            if (fTarget == null) {
              fTarget = ARRAY;
            }
        }

        if (fTarget == null) {
          switch (getControlType(oTarget)) {
            case 1:
              fTarget = CSV;
          }
        }

        var diTarget : Null<DelimitedInfo> = null;
        var ciTarget : Null<CodeInfo> = null;
        var tiTarget : Null<TableInfo> = null;
        var fshTarget : Null<FileSystemHandler> = null;
        var kvhTarget : Null<KeyValueHandler> = null;

        switch (fTarget) {
          case TEX:
            diTarget = TeXInfo.instance;
          case RAW:
            diTarget = RAWInfo.instance;
          case CSV:
            diTarget = CSVInfo.instance;
          case PSV:
            diTarget = PSVInfo.instance;
          case TSV:
            diTarget = TSVInfo.instance;
          case HTMLTable:
            tiTarget = StandardTableInfo.instance;
            if (
              #if (haxe_ver < 3.2)
                Std.is(oTarget, Writer)
              #else
                Std.isOfType(oTarget, Writer)
              #end              
            ) {
              writer = TableWriter.createStandardTableWriterForWriter(oTarget);
            } else {
              writer = TableWriter.createStandardTableWriterForElement(oTarget);
            }
          case DIR:
            fshTarget = CMDDirHandler.instance;
            writer = FileSystemWriter.createCMDDirWriter(oTarget);
          case INI:
            kvhTarget = INIHandler.instance;
            writer = KeyValueWriter.createINIWriter(oTarget);
          case JSON:
            kvhTarget = JSONHandler.instance;
            writer = KeyValueWriter.createJSONWriter(oTarget);
          case PROPERTIES:
            kvhTarget = PropertiesHandler.instance;
            writer = KeyValueWriter.createPropertiesWriter(oTarget);
          case SPLUNK:
            kvhTarget = SplunkHandler.instance;
            writer = KeyValueWriter.createSplunkWriter(oTarget);
          case SQL:
            var sqlType : String = cast getOption(outputOptions, "sqlType");
            if (sqlType != null) {
              var tableName : String = cast getOption(outputOptions, "tableName");
              switch (sqlType) {
                case "Create":
                  ciTarget = SQLSelectInfo.createTable(tableName);
                case "CreateOrReplace":
                  ciTarget = SQLSelectInfo.createOrReplaceTable(tableName);
                case "Insert":
                  ciTarget = SQLSelectInfo.insertIntoTable(tableName);
                default:
                  ciTarget = SQLSelectInfo.instance;
              }
            } else {
              ciTarget = SQLSelectInfo.instance;
            }
          case Haxe:
            ciTarget = HaxeInfoArrayOfMaps.instance;
          case Python:
            ciTarget = PythonInfoArrayOfMaps.instance;
          case Java:
            ciTarget = JavaInfoArrayOfMaps.instance;
          case CSharp:
            ciTarget = CSharpInfoArrayOfMaps.instance;  
          case ARRAY:
            {
              writer = Array2DWriter.writeToExpandableArrayI(cast oTarget);
            }
          case DB:
            // TODO         
          default:
            // Intentionally left empty
        }

        if (diTarget != null) {
          var dwWriter = new DelimitedWriter(diTarget, oTarget);
          writer = dwWriter;
          if (cast getOption(outputOptions, "header", true)) {
            dwWriter.noHeaderIncluded(false);
          } else {
            dwWriter.noHeaderIncluded(true);
          }
          /* TODO
          if (cast getOption(outputOptions, "textOnly", false)) {
            dwWriter.alwaysString(true);
          } else {
            dwWriter.alwaysString(false);
          }
          */
        } else if (ciTarget != null) {
          writer = new CodeWriter(ciTarget, oTarget);
        }
      }
    } else {
      // TODO
      #if JS_BROWSER

      #elseif JS_SNOWFLAKE

      #end
    }

    return writer;
  }

  public static function createReader(oSource : Dynamic, fSource : Null<Format>, sFilterColumnsExclude : Dynamic, sFilterColumnsInclude : Dynamic, sFilterRowsExclude : Dynamic, sFilterRowsInclude : Dynamic, leftTrim : Bool, rightTrim : Bool, inputOptions : Map<String, Dynamic>) : Null<DataTableReader> {
    var reader : Null<DataTableReader> = null;
    if (oSource != null) {
      if (
        #if (haxe_ver < 3.2)
          Std.is(oSource, DataTableReader)
        #else
          Std.isOfType(oSource, DataTableReader)
        #end
      ) {
        reader = cast oSource;
      }
      if (reader == null) {
        var sSource;

        if (oSource == Std.string(oSource)) {
          sSource = "STRING";
        } else {
          sSource = Type.getClassName(Type.getClass(oSource)).toUpperCase();
        }

        if (sSource == "STRINGBUF") {
          var sb : StringBuf = cast oSource;
          oSource = sb.toString();
          sSource = "STRING";
        }

        switch (sSource) {
          case "STRING":
            var sString : String = cast(oSource, String);
            switch (sString.charAt(0)) {
              #if !EXCLUDE_CONTROLS
              case ".", "#":
                oSource = getControl(oSource);
              #end
              #if !EXCLUDE_FILES
              default:
                if (sString.indexOf("\n") >= 0 || sString.indexOf("\t") >= 0 || sString.indexOf(",") >= 0 || sString.indexOf("|") >= 0) {
                  oSource = new StringReader(sString);
                } else if (fSource != DB) {
                  oSource = (new FileReader(sString)).convertToStringReader().switchToDroppingCharacters();
                }
              #end
            }
          case "ARRAY":
            if (fSource == null) {
              fSource = ARRAY;
            }
        }

        if (fSource == null) {
          switch (getControlType(oSource)) {
            case 0:
              fSource = HTMLTable;
          }
        }

        var diSource : Null<DelimitedInfo> = null;
        var ciSource : Null<CodeInfo> = null;
        var tiSource : Null<TableInfo> = null;
        var fshSource : Null<FileSystemHandler> = null;
        var kvhSource : Null<KeyValueHandler> = null;

        switch (fSource) {
          case RAW:
            diSource = RAWInfo.instance;          
          case CSV:
            diSource = CSVInfo.instance;
          case PSV:
            diSource = PSVInfo.instance;
          case TSV:
            diSource = TSVInfo.instance;
          case HTMLTable:
            tiSource = StandardTableInfo.instance;
            reader = TableReader.createStandardTableReader(oSource);
          case DIR:
            fshSource = CMDDirHandler.instance;
            reader = FileSystemReader.createCMDDirReader(oSource);
          case INI:
            kvhSource = INIHandler.instance;
            reader = KeyValueReader.createINIReader(oSource);
          case JSON:
            kvhSource = JSONHandler.instance;
            reader = KeyValueReader.createJSONReader(oSource);
          case PROPERTIES:
            kvhSource = PropertiesHandler.instance;
            reader = KeyValueReader.createPropertiesReader(oSource);
          case SPLUNK:
            kvhSource = SplunkHandler.instance;
            reader = KeyValueReader.createSplunkReader(oSource);
          case SQL:
            ciSource = SQLSelectInfo.instance;
          case Haxe:
            ciSource = HaxeInfoArrayOfMaps.instance;
          case Python:
            ciSource = PythonInfoArrayOfMaps.instance;
          case Java:
            ciSource = JavaInfoArrayOfMaps.instance;
          case CSharp:
            ciSource = CSharpInfoArrayOfMaps.instance;    
          case DB:
            #if(!JS_BROWSER)
              if (Std.isOfType(oSource, String)) {
                var sb : StringBuf = new StringBuf();
                reader = DatabaseReaderOptions.parse(cast oSource, sb).queryForReader(sb.toString());
              } else {
                reader = DatabaseReader.read(oSource);
              }
            #end
          case ARRAY:
            {
              reader = Array2DReader.readWholeArrayI(cast oSource);
            }
          default:
            // Intentionally left empty
        }
        if (diSource != null) {
          var drReader = new DelimitedReader(diSource, oSource);
          reader = drReader;
          if (cast getOption(inputOptions, "header", true)) {
            drReader.noHeaderIncluded(false);
          } else {
            drReader.noHeaderIncluded(true);
          }
          if (cast getOption(inputOptions, "textOnly", false)) {
            drReader.alwaysString(true);
          } else {
            drReader.alwaysString(false);
          }
        } else if (ciSource != null) {
          // TODO
          //reader = new CodeReader(ciSource, oSource);
        }
        if (leftTrim && rightTrim) {
          reader = new DataTableReaderTrim(reader);
        } else if (leftTrim) {
          reader = new DataTableReaderLeftTrim(reader);
        } else if (rightTrim) {
          reader = new DataTableReaderRightTrim(reader);
        }
        if (sFilterRowsInclude != null || sFilterRowsExclude != null) {
          var fFilter : Filter;
          if (isString(sFilterRowsInclude) || isString(sFilterRowsExclude)) {
            if (sFilterRowsInclude != null && sFilterRowsExclude != null) {
              fFilter = Filter.parse(sFilterRowsInclude, false);
              fFilter.and(Filter.parse(sFilterRowsExclude, true));
            } else if (sFilterRowsInclude != null) {
              fFilter = Filter.parse(sFilterRowsInclude, false);
            } else {
              fFilter = Filter.parse(sFilterRowsExclude, true);
            }
          } else {
            fFilter = mergeFilters(cast sFilterRowsInclude, cast sFilterRowsExclude);
          }
          reader = new RowFilterDataTableReader(reader, fFilter);
        }
      }
      if (sFilterColumnsInclude != null || sFilterColumnsExclude != null) {
        var fFilter : Filter;
        if (isString(sFilterColumnsInclude) || isString(sFilterColumnsExclude)) {
          if (sFilterColumnsInclude != null && sFilterColumnsExclude != null) {
            fFilter = Filter.parse(sFilterColumnsInclude, false);
            fFilter.and(Filter.parse(sFilterColumnsExclude, true));
          } else if (sFilterColumnsInclude != null) {
            fFilter = Filter.parse(sFilterColumnsInclude, false);
          } else {
            fFilter = Filter.parse(sFilterColumnsExclude, true);
          }
        } else {
          if (sFilterColumnsInclude != null && sFilterColumnsInclude.length > 0) {
            if (isString(sFilterColumnsInclude[0]) || isInt(sFilterColumnsInclude[0])) {
              var fFilters : Array<Filter> = new Array<Filter>();
              var sFilters : Array<String> = cast sFilterColumnsInclude;
              for (sFilter in sFilters) {
                var fFilter : Filter = Filter.parse(sFilter, false);
                fFilters.push(fFilter);
              }
              sFilterColumnsInclude = fFilters;
            }
          }
          if (sFilterColumnsExclude != null && sFilterColumnsExclude.length > 0) {
            if (isString(sFilterColumnsExclude[0]) || isInt(sFilterColumnsExclude[0])) {
              var fFilters : Array<Filter> = new Array<Filter>();
              var sFilters : Array<String> = cast sFilterColumnsExclude;
              for (sFilter in sFilters) {
                var fFilter : Filter = Filter.parse(sFilter, true);
                fFilters.push(fFilter);
              }              
            }
          }
          fFilter = mergeFilters(cast sFilterColumnsInclude, cast sFilterColumnsExclude);
        }
        reader = new ColumnFilterDataTableReader(reader, fFilter);
      }
    } else {
      // TODO
    }

    return reader;
  }

  public function new(oSource : Dynamic, fSource : Null<Format>, oTarget : Dynamic, fTarget : Null<Format>, sFilterColumnsExclude : Dynamic, sFilterColumnsInclude : Dynamic, sFilterRowsExclude : Dynamic, sFilterRowsInclude : Dynamic, leftTrim : Bool, rightTrim : Bool, inputOptions : Map<String, Dynamic>, outputOptions : Map<String, Dynamic>) {
    _writer = createWriter(oTarget, fTarget, outputOptions);
    _reader = createReader(oSource, fSource, sFilterColumnsExclude, sFilterColumnsInclude, sFilterRowsExclude, sFilterRowsInclude, leftTrim, rightTrim, inputOptions);

    
    //TODO
    //assert(_writer != null, "_writer should not be null for " + Type.getClassName(Type.getClass(this)));
    //assert(_reader != null, "_reader should not be null for " + Type.getClassName(Type.getClass(this)));
  }

  private static function getControl(sName : String) : Dynamic {
    #if sys
      // TODO
      return null;
    #elseif JS_WSH
      // TODO
      return null;
    #elseif JS_NODE
      // TODO
      return null;
    #elseif JS_SNOWFLAKE
      // TODO
      return null;      
    #elseif JS_BROWSER
      // TODO - Add support for jQuery, Angular, etc.
      return com.sdtk.std.JS_BROWSER.Document.getElementById(sName);
    #else
      return null;
    #end
  }

  private static function getControlType(oControl : Dynamic) : Int {
    var sTag : Null<String> = null;
    #if sys
      // TODO
    #elseif JS_WSH
      // TODO
    #elseif JS_NODE
      // TODO
    #elseif JS_SNOWFLAKE
      // TODO      
    #elseif JS_BROWSER
      sTag = StringTools.trim(cast(oControl, com.sdtk.std.JS_BROWSER.Element).tagName).toUpperCase();
    #else
      return null;
    #end

    switch (sTag) {
      case "TABLE":
        return 0;
      case "DIV", "DOCUMENT", "BODY", "HTML", "HEAD":
        return 1;
      default:
        return -1;
    }
  }
  
  public function convert() : Void {
    _reader.convertTo(_writer);
    _columns = _reader.getColumns();
  }

  public function setColumns(columns : Array<String>) : Void { }
  public function getColumns() : Array<String> {
    return _columns;
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public function dispose() : Void {
    if (_writer != null) {
      _writer.dispose();
      _writer = null;
      _reader.dispose();
      _reader = null;
      _columns = null;
    }
  }
}
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

@:expose
@:nativeGen
class Tests {
  private static var sCSV : String = "A,B,C\n5,6,7\n1,2,3\n8,1,5";
  private static var sPASSED : String = "Passed";
  private static var sFAILED : String = "Failed";
  private static var sEXPECTED : String = "Expected";
  private static var sGOT : String = "Got";
  private static var sEXCEPTION : String = "Exception";
  
  public static function runTests(recordPass: Bool, verbose : Bool) : String {
    var results : String = "";
    
    results = addResult(results, testCSVToPSV(recordPass, verbose));
    results = addResult(results, testExcludeColumns(recordPass, verbose));
    results = addResult(results, testExcludeRows(recordPass, verbose));
    results = addResult(results, testIncludeColumns(recordPass, verbose));
    results = addResult(results, testIncludeRows(recordPass, verbose));
    results = addResult(results, testOrderBy(recordPass, verbose));
    
    return results;
  }
  
  private static function addResult(sum : String, test : Null<String>) : String {
    if (test == null) {
      return sum;
    } else {
      return sum + test + "\n";
    }
  }
  
  private static function compareResults(recordPass: Bool, verbose : Bool, sTest : String, sExpected : String, sGot : String) : String {
  	sGot = StringTools.trim(sGot);
  	sExpected = StringTools.trim(sExpected);
    if (sGot != sExpected) {
      if (verbose) {
      	return sTest + ": " + sFAILED + "\n" + sEXPECTED + ":\n" + sExpected + "\n" + sGOT +":\n" + sGot;
      } else {
        return sTest + ": " + sFAILED;
      }
    } else if (recordPass) {
      if (verbose) {
        return sTest + ": " + sPASSED + "\n" + sEXPECTED + ":\n" + sExpected + "\n" + sGOT + ":\n" + sGot;
      } else {
        return sTest + ": " + sPASSED;
      }
    } else {
      return null;
    }
  }
  
  public static function testCSVToPSV(recordPass: Bool, verbose : Bool) : String {
  	var sTest : String = "testCSVToPSV";
    var sPSV : String = StringTools.replace(sCSV, ",", "|");
    var sbBuffer : StringBuf = new StringBuf();
    try {
      Converter.convertWithOptions(sCSV, Format.CSV, sbBuffer, Format.PSV, null, null, null, null, null, false, false);
      return compareResults(recordPass, verbose, sTest, sPSV, StringTools.replace(sbBuffer.toString(), "\"", ""));
    } catch (msg : Dynamic) {
      if (verbose) {
      	return sTest + ": " + sFAILED + "\n" + sEXCEPTION + ":\n" + msg;
      } else {
        return sTest + ": " + sFAILED;
      }
    }
  }
  
  public static function testExcludeColumns(recordPass: Bool, verbose : Bool) : String {
  	var sTest : String = "testExcludeColumns";
  	var sExcluded : String = "A,C\n5,7\n1,3\n8,5";
    var sbBuffer : StringBuf = new StringBuf();
    try {
      Converter.convertWithOptions(sCSV, Format.CSV, sbBuffer, Format.CSV, "B", null, null, null, null, false, false);
      return compareResults(recordPass, verbose, sTest, sExcluded, StringTools.replace(sbBuffer.toString(), "\"", ""));
    } catch (msg : Dynamic) {
      if (verbose) {
      	return sTest + ": " + sFAILED + "\n" + sEXCEPTION + ":\n" + msg;
      } else {
        return sTest + ": " + sFAILED;
      }
    }    
  }
  
  public static function testExcludeRows(recordPass: Bool, verbose : Bool) : String {
  	var sTest : String = "testExcludeRows";
  	var sExcluded : String = "A,B,C\n1,2,3\n8,1,5";
    var sbBuffer : StringBuf = new StringBuf();
    try {
      Converter.convertWithOptions(sCSV, Format.CSV, sbBuffer, Format.CSV, null, null, "#2", null, null, false, false);
      return compareResults(recordPass, verbose, sTest, sExcluded, StringTools.replace(sbBuffer.toString(), "\"", ""));
    } catch (msg : Dynamic) {
      if (verbose) {
      	return sTest + ": " + sFAILED + "\n" + sEXCEPTION + ":\n" + msg;
      } else {
        return sTest + ": " + sFAILED;
      }
    }    
  }
  
  public static function testIncludeColumns(recordPass: Bool, verbose : Bool) : String {
  	var sTest : String = "testIncludeColumns";
    var sIncluded : String = "B\n6\n2\n1";
    var sbBuffer : StringBuf = new StringBuf();
    try {
      Converter.convertWithOptions(sCSV, Format.CSV, sbBuffer, Format.CSV, null, "B", null, null, null, false, false);
      return compareResults(recordPass, verbose, sTest, sIncluded, StringTools.replace(sbBuffer.toString(), "\"", ""));
    } catch (msg : Dynamic) {
      if (verbose) {
      	return sTest + ": " + sFAILED + "\n" + sEXCEPTION + ":\n" + msg;
      } else {
        return sTest + ": " + sFAILED;
      }
    }    
  }
  
  public static function testIncludeRows(recordPass: Bool, verbose : Bool) : String {
  	var sTest : String = "testIncludeRows";
  	var sExcluded : String = "5,6,7";
    var sbBuffer : StringBuf = new StringBuf();
    try {
      Converter.convertWithOptions(sCSV, Format.CSV, sbBuffer, Format.CSV, null, null, null, "#2", null, false, false);
      return compareResults(recordPass, verbose, sTest, sExcluded, StringTools.replace(sbBuffer.toString(), "\"", ""));
    } catch (msg : Dynamic) {
      if (verbose) {
      	return sTest + ": " + sFAILED + "\n" + sEXCEPTION + ":\n" + msg;
      } else {
        return sTest + ": " + sFAILED;
      }
    }    
  }
  
  public static function testOrderBy(recordPass: Bool, verbose : Bool) : String {
  	var sTest : String = "testOrderBy";
    var sOrdered : String = "A,B,C\n1,2,3\n8,1,5\n5,6,7";
    var sbBuffer : StringBuf = new StringBuf();
    try {
      Converter.convertWithOptions(sCSV, Format.CSV, sbBuffer, Format.CSV, null, null, null, null, "C", false, false);
      return compareResults(recordPass, verbose, sTest, sOrdered, StringTools.replace(sbBuffer.toString(), "\"", ""));
    } catch (msg : Dynamic) {
      if (verbose) {
      	return sTest + ": " + sFAILED + "\n" + sEXCEPTION + ":\n" + msg;
      } else {
        return sTest + ": " + sFAILED;
      }
    }    
  }
}
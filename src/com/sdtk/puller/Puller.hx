/*
    Copyright (C) 2023 Vis LLC - All Rights Reserved

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
    Simple Puller (SP) - Source code can be found on SourceForge.net
*/

package com.sdtk.puller;

/**
  Defines process of pulling a file(s) from source and putting it somewhere.
  This also serves as the starting point when running the program as a standalone application.
**/
#if !EXCLUDE_PARAMETERS
@:expose
@:nativeGen
class Puller {
  /**
    Serves as entry point when running as a standalone application.
	**/
  static public function main() : Void {
    #if python
      python.Syntax.code("import ssl");
      python.Syntax.code("orig_sslsocket_init = ssl.SSLSocket.__init__");
      python.Syntax.code("ssl.SSLSocket.__init__ = lambda *args, cert_reqs=ssl.CERT_NONE, **kwargs: orig_sslsocket_init(*args, cert_reqs=ssl.CERT_NONE, **kwargs)");
    #end
    var pParameters = new Parameters();
    var pPuller = new Puller();
    while (pParameters.next()) {
      var source : Source = pParameters.getSource();
      var output : Source = pParameters.getOutput();
      if (source != null) {
        #if sys
          Sys.println("Add source");
        #end
        pPuller.addSource(source);
      }
      if (output != null) {
        #if sys
          Sys.println("Add output");
        #end
        pPuller.addOutput(output);
      }
    }
    pPuller.pull();
  }

  public function new() { }

  private var _sources : Array<Source> = new Array<Source>();
  private var _outputs : Array<Source> = new Array<Source>();

  public function addSource(source : Source) {
    _sources.push(source);
  }

  public function addOutput(output : Source) {
    _sources.push(output);
  }  

  public function pull() : Void {
    nextPull(0);
  }

  public static function validSource(source : String) : Bool {
    return Parameters.typeOfAccess(source) >= 0;
  }

  public static function pullAsString(source : String, callback : String -> Void) : Void {
    return Parameters.getSourceFrom(source).pullAsString(callback);
  }

  public static function pullAsMap(source : String, callback : Map<String, Dynamic> -> Void) : Void {
    return Parameters.getSourceFrom(source).pullAsMap(callback);
  }

  private function nextPull(i : Int) : Void {
    #if sys
      Sys.println("Start");
    #end
    _sources[i].pullAsMap(function (result : Map<String, Dynamic>) {
      #if sys
        Sys.println("Done");
        Sys.println(haxe.Json.stringify(result));
      #end
      if ((i+1) < _sources.length) {
        nextPull(i+1);
      } else {
        nextPut(0);
      }
    });
  }

  private function nextPut(i : Int) : Void {
    /*
    _outputs[i].put(function (result : Map<String, Dynamic>) {
      if ((i+1) < _outputs.length) {
        nextPut(i+1);
      }
    });
    */
  }
}
#end
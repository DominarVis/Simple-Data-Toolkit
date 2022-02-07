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
    Simple Calendar - Source code can be found on SourceForge.net
*/

package com.sdtk.calendar;

import com.sdtk.std.*;

/**
  Handles command-line parameters.
**/
@:nativeGen
class Parameters extends com.sdtk.std.Parameters {
    private var _invite : Null<CalendarInvite>;
    private var _format : Null<String>;
    private var _input : Null<String>;
    private var _output : Null<String>;
    private var _nothing : Bool;
    private var _invalid : Bool;

  public function new() {
    super();
    var ciInvite : CalendarInvite = new CalendarInvite();
    var iDates : Int = 0;
    var iText : Int = 0;
    var sFiles : Array<String> = new Array<String>();
    // Check extensions
    var regexp : EReg = ~/[.]ics$/i;

    #if JS_BROWSER
      getArguments();
    #end
    var i : Int = 0;
    var sParameter : Null<String>;

    do {
      sParameter = getParameter(i);
      if (sParameter != null) {
          var dDate : Null<Date> = null;
          try {
              dDate = Date.fromString(sParameter);
              if (StringTools.startsWith(dDate.toString(), "NaN") || sParameter.indexOf("" + dDate.getFullYear()) < 0) {
                  dDate = null;
              }
          } catch (message : Dynamic) {
          }
          if (dDate != null) {
              switch (iDates) {
                  case 0:
                    ciInvite.start = dDate;
                    _invite = ciInvite;
                  case 1:
                    ciInvite.end = dDate;
                    _invite = ciInvite;
              }
              iDates++;
          } else {
              if (regexp.match(sParameter)) {
                  sFiles.push(sParameter);
              } else {
                  switch (iText) {
                      case 0:
                          ciInvite.summary = sParameter;
                          _invite = ciInvite;
                  }
                  iText++;
              }
          }
      }
      i++;
    } while (sParameter != null);

    if (sFiles.length == 0 && iText > 0 && iDates > 0) {
        _nothing = true;
        _invalid = false;
    } else if (sFiles.length == 1 && iText > 0 && iDates > 0) {
        _output = sFiles[0];
        _nothing = false;
        _invalid = false;
    } else if (sFiles.length == 1 && iText == 0 && iDates == 0) {
        _input = sFiles[0];
        _nothing = false;
        _invalid = false;
    } else if (sFiles.length == 2) {
        _input = sFiles[0];
        _output = sFiles[1];
        _nothing = false;
        _invalid = false;
    } else {
        _invalid = true;
        _nothing = false;
    }

    #if JS_BROWSER
      _arguments = null;
    #end
  }

  public function getInvite() : CalendarInvite {
      return _invite;
  }

  public function getOutput() : String {
      return _output;
  }

  public function getInput() : String {
      return _input;
  }
  
  public function getNothing() : Bool {
      return _nothing;
  }

  public function getInvalid() : Bool {
      return _invalid;
  }
}
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
    Simple Log Grabber (SLG) - Source code can be found on SourceForge.net
*/

package com.sdtk.log;

#if !EXCLUDE_TIMESTAMPSENDER
/**
  Defines interface for sending log entries, which adds a timestamp and formatting for each line.
**/
@:expose
@:nativeGen
class TimeStampWriter extends com.sdtk.std.Writer {
  private var _wrapped : com.sdtk.std.Writer;
  private var _dateFormat : String;
  private var _entryFormat : String;

  private var _indicateStartEnd : Bool;

  public function new(sWrapped : com.sdtk.std.Writer, sDateFormat : String, sEntryFormat : String, bIndicateStartAndEnd : Bool) {
    super();
    _wrapped = sWrapped;
    _dateFormat = (sDateFormat == null ? "%Y-%m-%d_%H:%M:%S" : sDateFormat);
    _entryFormat = (sEntryFormat == null ? "%timestamp% - %entry%" : sEntryFormat);
    if (_entryFormat.indexOf("%timestamp%") < 0) {
      _entryFormat = "%timestamp%" + _entryFormat;
    }
    if (_entryFormat.indexOf("%entry%") < 0) {
      _entryFormat += "%entry%";
    }
    _indicateStartEnd = bIndicateStartAndEnd;
    if (_indicateStartEnd) {
      write("Started");
    }
  }

  public override function write(sLine : String) : Void {
    _wrapped.write(StringTools.replace(StringTools.replace(_entryFormat, "%timestamp%", DateTools.format(Date.now(), _dateFormat)), "%entry%", sLine));
  }

  #if cs
    @:native('Dispose')
  #elseif java
    @:native('close')
  #end
  public override function dispose() : Void {
    if (_indicateStartEnd) {
      write("Ended");
    }
    _wrapped.dispose();
  }
}
#end

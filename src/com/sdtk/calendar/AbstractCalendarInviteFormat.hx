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

#if JS_BROWSER
    import com.sdtk.std.JS_BROWSER.Document;
    import com.sdtk.std.JS_BROWSER.Element;
#end

/**
    Implements standard routines for processing calendar events.
**/
@:expose
@:nativeGen
class AbstractCalendarInviteFormat implements CalendarInviteFormat<Reader, Writer> {
    public var sDateTimeFormat : String;

    private var _startOfFile : Null<String>;
    private var _endOfFile : Null<String>;
    private var _uid : Null<String>;
    private var _created : Null<String>;
    private var _start : Null<String>;
    private var _end : Null<String>;
    private var _summary : Null<String>;
    private var _separator : Null<String>;
    private var _lineEnd : Null<String>;
    private var _limit : Int;

    public function new(sDateTimeFormat : String, sStartOfFile : Null<String>, sEndOfFile : Null<String>, sUID : Null<String>, sCreated : Null<String>, sStart : Null<String>, sEnd : Null<String>, sSummary : Null<String>, sSeparator : Null<String>, sLineEnd : Null<String>, iLimit : Int) {
        this.sDateTimeFormat = sDateTimeFormat;
        _startOfFile = sStartOfFile;
        _endOfFile = sEndOfFile;
        _uid = sUID;
        _created = sCreated;
        _start = sStart;
        _end = sEnd;
        _summary = sSummary;
        _separator = sSeparator;
        _lineEnd = sLineEnd;
        _limit = iLimit;
    }

    public function convertDateTime(dDateTime : Date) : String {
        return DateTools.format(dDateTime, sDateTimeFormat);
    }

    public function toDateTime(sValue : String) : Null<Date> {
        try {
            return new Date(Std.parseInt(sValue.substring(0, 4)), Std.parseInt(sValue.substr(4, 2)), Std.parseInt(sValue.substr(6, 2)), Std.parseInt(sValue.substr(9, 2)), Std.parseInt(sValue.substr(11, 2)), Std.parseInt(sValue.substr(13, 2)));
        }
        catch (message : Dynamic) {
            return null;
        }
    }

    public function convert(ciInvite : CalendarInvite, wWriter : Writer) : Void {
        wWriter.start();

        if (_startOfFile != null) {
            wWriter.write(_startOfFile);
        }
        if (_uid != null && ciInvite.uid != null) {
            wWriter.write(_uid);
            wWriter.write(_separator);
            wWriter.write(ciInvite.uid);
            wWriter.write(_lineEnd);
        }
        if (_created != null && ciInvite.created != null) {
            wWriter.write(_created);
            wWriter.write(_separator);
            wWriter.write(convertDateTime(ciInvite.created));
            wWriter.write(_lineEnd);
        }
        if (_start != null && ciInvite.start != null) {
            wWriter.write(_start);
            wWriter.write(_separator);
            wWriter.write(convertDateTime(ciInvite.start));
            wWriter.write(_lineEnd);
        }
        if (_end != null && ciInvite.end != null) {
            wWriter.write(_end);
            wWriter.write(_separator);
            wWriter.write(convertDateTime(ciInvite.end));
            wWriter.write(_lineEnd);
        }
        if (_summary != null && ciInvite.summary != null) {
            wWriter.write(_summary);
            wWriter.write(_separator);
            wWriter.write(ciInvite.summary);
            wWriter.write(_lineEnd);
        }

        if (_endOfFile != null) {
            wWriter.write(_endOfFile);
        }

        wWriter.dispose();
    }

    public function convertToString(ciInvite : CalendarInvite) : String {
        var wWriter : StringWriter = new StringWriter(null);

        convert(ciInvite, wWriter);

        return wWriter.toString();
    }

    public function read(rReader : Reader) : CalendarInvite {
        var ciInvite : CalendarInvite = new CalendarInvite();
        var sbBuffer : StringBuf = new StringBuf();
        var sCurrentLabel : String = "";

        rReader.start();

        while (rReader.hasNext()) {
            var c : String = rReader.next();
            if (c == _lineEnd) {
                if (sbBuffer.length > 0) {
                    var sValue : String = sbBuffer.toString();
                    if (sCurrentLabel == _uid) {
                        ciInvite.uid = sValue;
                    } else if (sCurrentLabel == _created) {
                        ciInvite.created = toDateTime(sValue);
                    } else if (sCurrentLabel == _start) {
                        ciInvite.start = toDateTime(sValue);
                    } else if (sCurrentLabel == _end) {
                        ciInvite.end = toDateTime(sValue);
                    } else if (sCurrentLabel == _summary) {
                        ciInvite.summary = sValue;
                    }
                    sbBuffer = new StringBuf();
                }
            } else if (c == _separator) {
                var sLabel = sbBuffer.toString();
                sbBuffer = new StringBuf();
            } else {
                if (sbBuffer.length < _limit) {
                    sbBuffer.add(c);
                }
            }
        }

        return ciInvite;
    }
}
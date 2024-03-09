/*
    Copyright (C) 2022 Vis LLC - All Rights Reserved

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
    Simple Grapher (SG) - Source code can be found in Converter.hx in Haxe on SourceForge.net
*/

package com.sdtk.graphs;

@:expose
@:nativeGen
interface GrapherInterface {
    public function export(options : GraphExportTypeOptionsFinish, ?callback : String->Void) : String;
    public function updateLocations() : Void;
}

@:expose
@:nativeGen
class Grapher implements GrapherInterface {
    private var _tileWidth : Float;
    private var _tileHeight : Float;
    private var _colors : Array<String>;
    private var _plotFunctions : Array<Float->Float>;
    private var _plotType : Int;
    private var _locationsY : Array<Float>;
    private var _locationsX : Array<Float>;
    private var _coordinates : Array<String>;
    private var _groups : Array<String>;
    private var _changed : Bool;
    private var _shiftX : Int;
    private var _shiftY : Int;
    private var _originX : Int;
    private var _originY : Int;
    private var _convertedData : Array<Array<Dynamic>>;
    private var _lastX : Float;
    private var _lastI : Int;
    private var _dataByIndex : Bool;
    private var _fillGap : Bool;
    private var _reader : com.sdtk.table.DataTableReader;
    private var _dataX : Dynamic;
    private var _dataY : Dynamic;
    private var _dataGroup : Dynamic;
    private static var _defaultGraphColor : String = "black";
    private static var _validGraphColors : Array<String> = ["Aquamarine","Black","Blue","BlueViolet","Brown","CadetBlue","CornflowerBlue","Cyan","DarkOrchid","ForestGreen","Fuchsia","Goldenrod","Gray","Green","GreenYellow","Lavender","LimeGreen","Magenta","Maroon","MidnightBlue","Orange","OrangeRed","Orchid","Plum","Purple","Red","RoyalBlue","RoyalPurple","Salmon","SeaGreen","SkyBlue","SpringGreen","Tan","Thistle","Turquoise","Violet","White","Yellow","YellowGreen"];
    private static var _defaultGraphColors : Array<String>  = ["Red","Green","Blue","Orange","Purple","Cyan","Pink"];

    public static function getValidGraphColors() : Array<String> {
        return _validGraphColors;
    }

    private function new(options : GrapherOptions) {
        var fo : Map<String, Dynamic> = options.toMap();
        var width : Int = cast fo.get("tileWidth");
        var height : Int = cast fo.get("tileHeight");
        var shiftX : Null<Int> = cast fo.get("shiftX");
        var shiftY : Null<Int> = cast fo.get("shiftY");
        var plotFunction : Float->Float = cast fo.get("plotFunction");
        _colors = cast fo.get("colors");
        _plotFunctions = cast fo.get("plotFunctions");
        if (_plotFunctions == null) {
            _plotFunctions = new Array<Float->Float>();
            _plotFunctions.resize(1);
            _plotFunctions[0] = plotFunction;
        }
        _plotType = cast fo.get("plotType");
        if (shiftX == null) {
            shiftX = 0;
        }
        if (shiftY == null) {
            shiftY = 0;
        }
        _shiftX = shiftX;
        _shiftY = shiftY;
        _reader = cast fo.get("reader");
        _dataX = cast fo.get("dataX");
        _dataY = cast fo.get("dataY");
        _dataGroup = cast fo.get("dataGroup");
        _dataByIndex = cast fo.get("dataByIndex");
        _fillGap = false;
        if (_plotFunctions[0] == null && _reader != null) {
            _plotFunctions[0] = plotForData;
        }
    }

    public static function create(options : GrapherOptions) : Grapher {
        return new Grapher(options);
    }

    public static function options() : GrapherOptions {
        return new GrapherOptions();
    }

    public function updateLocations() : Void {
        _convertedData = _updateData(_convertedData, _reader, _plotType, _dataByIndex, _dataX, _dataY, _dataGroup);
        var results : GrapherUpdateLocationsResults = _updateLocations(_originX, _originY, 1, 1, _tileWidth, _tileHeight, _shiftX, _shiftY, _plotFunctions, _plotType, _locationsX, _locationsY, _coordinates, _groups, _convertedData);
        _changed = results._changed;
        _locationsX = results._locationsX;
        _locationsY = results._locationsY;
        _coordinates = results._coordinates;
        _groups = results._groups;
    }

    public static function _updateData(convertedData : Array<Array<Dynamic>>, reader : com.sdtk.table.DataTableReader, plotType : Int, dataByIndex : Bool, dataX : Dynamic, dataY : Dynamic, dataGroup : Dynamic) : Array<Array<Dynamic>> {
        if (reader != null && convertedData == null) {
            if (dataByIndex) {
                convertedData = convertDataForPlotByColumnIndex(reader, plotType, cast dataX, cast dataY, cast dataGroup);
            } else {
                convertedData = convertDataForPlotByColumnName(reader, plotType, cast dataX, cast dataY, cast dataGroup);
            }
        }
        return convertedData;
    }

    public static function _updateLocations(originX : Float, originY : Float, rectWidth : Float, rectHeight : Float, tileWidth : Float, tileHeight : Float, shiftX : Int, shiftY : Int, plotFunctions : Array<Float->Float>, plotType : Int, _locationsX : Array<Float>,  _locationsY : Array<Float>, _coordinates : Array<String>, _groups : Array<String>, convertedData : Array<Array<Dynamic>>) : GrapherUpdateLocationsResults {
        var results : GrapherUpdateLocationsResults = new GrapherUpdateLocationsResults();
        var start : Float = -1;
        var end : Float = -1;
        var increment : Float = -1;
        var size : Int;

        switch (plotType) {
            case 1:
                start = originY - shiftY;
                end = start + tileHeight;
                increment = 1/rectHeight;
            case 2:
                start = originX - shiftX;
                end = start + tileWidth;
                increment = 1/rectWidth;
        }

        if (convertedData == null) {
            size = Math.round((end - start)/increment);        
        } else {
            size = convertedData.length;
            increment = 1;
        }
        

        var locationsY : Array<Float> = new Array<Float>();
        locationsY.resize(size);
        var locationsX : Array<Float> = new Array<Float>();
        locationsX.resize(size);
        var coordinates : Array<String> = new Array<String>();
        coordinates.resize(size);
        var groups : Array<String> = new Array<String>();
        groups.resize(size);
        var locationUse : Array<Float> = null;
        var locationResult : Array<Float> = null;
        var locationCompare : Array<Float> = null;
        var shiftUse : Float = -1;
        var shiftResult : Float = -1;
        var getCoordinates : Null<Float->Float->String> = null;

        switch (plotType) {
            case 1:
                locationUse = locationsY;
                locationResult = locationsX;
                locationCompare = _locationsX;
                shiftUse = shiftY;
                shiftResult = shiftX;
                getCoordinates = function (y : Float, x : Float) {
                    return "" + x + "," + y;
                }
            case 2:
                locationUse = locationsX;
                locationResult = locationsY;
                locationCompare = _locationsY;
                shiftUse = shiftX;
                shiftResult = shiftY;                
                getCoordinates = function (x : Float, y : Float) {
                    return "" + x + "," + y;
                }                
        }        

        var group : Int = 0;
        var changed : Bool = (_locationsX == null);
        var groupSize : Int = size;
        if (convertedData != null) {
            groupSize = getSizeOfGroups(convertedData);
        }
        
        //var locations : Map<String, Float> = new Map<String, Float>();

        for (plotFunction in plotFunctions) {
            var i : Float = start;
            var j : Int = 0;
            while (j < size) {
                var result : Float = plotFunction(i);
                locationUse[j] = i % groupSize + shiftUse;
                locationResult[j] = result + shiftResult;
                if (convertedData == null) {
                    coordinates[j] = getCoordinates(i % groupSize, result);
                    groups[j] = Std.string(group);
                } else {
                    coordinates[j] = convertedData[j][0] + " - " + convertedData[j][1];
                    if (convertedData[j].length == 3) {
                        groups[j] = convertedData[j][2];
                    } else {
                        groups[j] = '';
                    }
                }
                if (!changed && locationCompare[j] != locationResult[j]) {
                    changed = true;
                }
                i += increment;
                j++;
            }
            group++;
        }

        {
            results._changed = changed;
            if (changed) {
                results._locationsX = locationsX;
                results._locationsY = locationsY;
                results._coordinates = coordinates;
                results._groups = groups;
            } else {
                results._locationsX = _locationsX;
                results._locationsY = _locationsY;                
                results._coordinates = _coordinates;
                results._groups = _groups;
            }
            return results;
        }
    }

    public function exportOptions() : GraphExportTypeOptions {
        return new GraphExportTypeOptions(this);
    }

    public static function _exportOptions() : GraphExportTypeOptions {
        return new GraphExportTypeOptions(null);
    }

    public function export(options : GraphExportTypeOptionsFinish, ?callback : String->Void) {
        return _export(null, options, callback, _originX, _originY, 1, 1, _tileWidth, _tileHeight, _shiftX, _shiftY, _plotType, _locationsX, _locationsY, _coordinates, _groups, _convertedData, _colors);
    }

    public static function _export(exporter : GrapherExporter<Dynamic>, options : GraphExportTypeOptionsFinish, ?callback : String->Void, originX : Float, originY : Float, rectWidth : Float, rectHeight : Float, tileWidth : Float, tileHeight : Float, shiftX : Int, shiftY : Int, plotType : Int, locationsX : Array<Float>, locationsY : Array<Float>, coordinates : Array<String>, groups : Array<String>, convertedData : Array<Array<Dynamic>>, ?colors : Array<String> = null) : String {
        if (colors == null) {
            colors = _defaultGraphColors;
        }
        var width : Null<Int> = null;
        var height : Null<Int> = null;   
        if (options != null) {
            var fo : Map<String, Any> = options.toMap();
            if (exporter == null) {
                exporter = cast fo.get("type");
            }
            width = fo.get("width");
            height = fo.get("height");   
        }
        var sb : Dynamic = exporter.getTarget();

        if (width == null) {
            width = Math.round(tileWidth * rectWidth);
        }

        if (height == null) {
            height = Math.round(tileHeight * rectHeight);
        }

        if (width == -1) {
            switch (plotType) {
                case 1:
                    width = cast convertedData[0][1];
                    for (v in convertedData) {
                        if (cast v[1] > width) {
                            width = cast v[1];
                        }
                    }
                    width = cast Math.pow(10, Math.round(Math.log(width / tileWidth) / Math.log(10))) * tileWidth;
                case 2:
                    width = getSizeOfGroups(convertedData);
            }
        }

        if (height == -1) {
            switch (plotType) {
                case 1:
                    height = getSizeOfGroups(convertedData);
                case 2:
                    height = cast convertedData[0][1];
                    for (v in convertedData) {
                        if (cast v[1] > height) {
                            height = cast v[1];
                        }
                    }
                    height = cast Math.pow(10, Math.round(Math.log(height / tileHeight) / Math.log(10))) * tileHeight;
            }
        }

        var scaleX : Float = -1;
        var scaleY : Float = -1;

        scaleY = height / tileHeight;
        scaleX = width / tileWidth;

        width = cast width * rectWidth;
        height = cast height * rectHeight;

        var start : Float = -1;
        var end : Float = -1;
        var increment : Float = -1;

        switch (plotType) {
            case 1:
                start = originY;
                end = start + tileHeight;
                increment = 1/rectHeight;
            case 2:
                start = originX;
                end = start + tileWidth;
                increment = 1/rectWidth;
        }

        var size : Int;

        if (convertedData == null) {
            size = Math.round((end - start)/increment);        
        } else {
            size = convertedData.length;
        }

        exporter.start(sb, width, height, scaleX, scaleY);
        var j : Int = 0;
        var multiX : Float = rectWidth / scaleX;
        var multiY : Float = rectHeight / scaleY;
        var prevGroup : String = null;
        var prevX : Int = Math.round(locationsX[j - 1] * multiX);
        var prevY : Int = Math.round(locationsY[j - 1] * multiY);
        var groupI : Int = -1;
        var groupCount : Int = 0;
        while (j < size) {
            var curGroup : String = groups[j];
            if (curGroup != prevGroup) {
                prevGroup = curGroup;
                groupCount++;
            }
            j++;
        }
        prevGroup = null;
        j = 0;
        while (j < size) {
            var curGroup : String = groups[j];
            if (curGroup != prevGroup) {
                prevX = Math.round(locationsX[j] * multiX);
                prevY = Math.round(locationsY[j] * multiY);
                prevGroup = curGroup;
                groupI++;
            } else {
                var newX : Int = Math.round(locationsX[j] * multiX);
                var newY : Int = Math.round(locationsY[j] * multiY);
                exporter.drawLine(sb, prevX, prevY, newX, newY);
                if (groupCount > 1) {
                    exporter.setColor(sb, colors[groupI % colors.length]);
                }
                prevX = newX;
                prevY = newY;
            }
            j++;
        }

        var startX : Float = originX;
        var startY : Float = originY;
        var endX : Float = startX + tileWidth;
        var endY : Float = startY + tileHeight;
        var tickHeight : Float = rectHeight / 10;
        var tickWidth : Float = rectWidth / 10;
        var i : Float = startX;
        j = 0;
        while (j < tileWidth) {
            var caption : String;
            exporter.drawLine(sb, cast (j + startX) * rectWidth, cast -tickHeight/2 + (originY + shiftY) * rectHeight, cast (j + startX) * rectWidth, cast tickHeight/2 + (originY + shiftY) * rectHeight);
            exporter.setColor(sb, "black");
            if (convertedData != null && plotType == 2) {
                caption = convertedData[j][0];
            } else {
                caption = Std.string((j - shiftX) * scaleX);
            }
            exporter.setCaption(sb, caption);
            if (plotType == 2 || j > 0) {
                exporter.drawText(sb, cast (j + startX) * rectWidth, 0, 0, caption);
            }
            j++;
        }

        j = 0;
        while (j < tileHeight) {
            var caption : String;
            exporter.drawLine(sb, cast -tickWidth/2 + (originX + shiftX) * rectWidth, cast (j + startY) * rectHeight, cast tickWidth/2 + (originX + shiftX) * rectWidth, cast (j + startY) * rectHeight);
            exporter.setColor(sb, "black");
            if (convertedData != null && plotType == 1) {
                caption = convertedData[j][1];
            } else {
                caption = Std.string((j - shiftY) * scaleY);
            }
            exporter.setCaption(sb, caption);
            if (plotType == 1 || j > 0) {
                exporter.drawText(sb, 0, cast (j + startY) * rectHeight, 3, caption);
            }
            j++;
        }

        exporter.drawLine(sb, cast startX * rectWidth, cast (originY + shiftY) * rectHeight, cast endX * rectWidth, cast (originY + shiftY) * rectHeight);
        exporter.setColor(sb, "black");
        exporter.drawLine(sb, cast (originX + shiftX) * rectWidth, cast startY * rectHeight, cast (originX + shiftX) * rectWidth, cast endY * rectHeight);
        exporter.setColor(sb, "black");

        var s : String = exporter.end(sb);

        if (callback != null) {
            callback(s);
            return null;
        } else {
            return s;
        }
    }

    private static function convertData(columns : Array<Dynamic>, r : com.sdtk.table.DataTableReader) : Array<Array<Dynamic>> {
        var awWriter : com.sdtk.table.Array2DWriter<Dynamic> = com.sdtk.table.Array2DWriter.writeToExpandableArray(null);
        var arr : Array<Array<Dynamic>> = awWriter.getArray();
        com.sdtk.table.Converter.convertWithOptions(r, null, awWriter, com.sdtk.table.Formats.ARRAY(), null, columns, null, null, columns, false, false, null, null);
        var possibleIMap : Map<Dynamic, Bool> = new Map<Dynamic, Bool>();
        var possibleIArray : Array<Dynamic> = new Array<Dynamic>();
        if (arr.length == 0 || arr[0].length == 2) {
            return arr;
        } else {
            var convertedData : Array<Array<Dynamic>> = new Array<Array<Dynamic>>();
            for (row in arr) {
                possibleIMap[row[0]] = true;
            }
            for (i in possibleIMap.keys()) {
                possibleIArray.push(i);
            }
            possibleIArray.sort(Reflect.compare);
            var i : Int = 0;
            var j : Int = 0;
            var curGroup : String = null;
            while (j < arr.length || (i % possibleIArray.length) != 0) {
                if (i % possibleIArray.length == 0) {
                    curGroup = arr[j][2];
                }
                var x : Dynamic = possibleIArray[i % possibleIArray.length];
                if (x == arr[j][0]) {
                    convertedData.push(arr[j]);
                    j++;
                } else {
                    var dummyRow = new Array<Dynamic>();
                    dummyRow.resize(3);
                    dummyRow[0] = x;
                    dummyRow[1] = null;
                    dummyRow[2] = curGroup;
                    convertedData.push(dummyRow);
                }
                i++;
            }
    
            return convertedData;
        }
    }

    private static function convertDataForPlotByColumnName(r : com.sdtk.table.DataTableReader, plotType : Int, x : String, y : String, group : String) : Array<Array<Dynamic>> {
        var columns : Array<String> = new Array<String>();

        if (group == null) {
            switch (plotType) {
                case 1:
                    columns.push(y);
                    columns.push(x);
                case 2:
                    columns.push(x);
                    columns.push(y);
                default:
                    throw "Invalid direction";
            }
        } else {
            switch (plotType) {
                case 1:
                    columns.push(group);
                    columns.push(y);
                    columns.push(x);
                case 2:
                    columns.push(group);
                    columns.push(x);
                    columns.push(y);
                default:
                    throw "Invalid direction";
            }
        }

        return convertData(columns, r);
    }

    private static function convertDataForPlotByColumnIndex(r : com.sdtk.table.DataTableReader, plotType : Int, x : Int, y : Int, group : Null<Int>) : Array<Array<Dynamic>> {
        var columns : Array<Int> = new Array<Int>();

        if (group == null) {
            switch (plotType) {
                case 1:
                    columns.push(y);
                    columns.push(x);
                case 2:
                    columns.push(x);
                    columns.push(y);
                default:
                    throw "Invalid direction";
            }
        } else {
            switch (plotType) {
                case 1:
                    columns.push(group);
                    columns.push(y);
                    columns.push(x);
                case 2:
                    columns.push(group);
                    columns.push(x);
                    columns.push(y);
                default:
                    throw "Invalid direction";
            }
        }

        return convertData(columns, r);
    }

    public static function _plotForData(x : Float, convertedData : Array<Array<Dynamic>>) : Float {
        return cast convertedData[cast x][1];
    }

    private function plotForData(x : Float) {
        return _plotForData(x, _convertedData);
    }

    private static function getSizeOfGroups(convertedData : Array<Array<Dynamic>>) {
        if (convertedData.length == 0) {
            return 0;
        } else if (convertedData[0].length < 3) {
            return convertedData.length;
        } else {
            var maxSize : Int = -1;
            var curSize : Int = 0;
            var prevGroup : String = null;
            var j : Int = 0;
            while (j < convertedData.length) {
                var curGroup : String = convertedData[j][2];
                if (curGroup != prevGroup) {
                    if (curSize > maxSize) {
                        maxSize = curSize;
                    }
                    curSize = 0;
                    prevGroup = curGroup;
                }
                curSize++;
                j++;
            }
            if (curSize > maxSize) {
                maxSize = curSize;
            }
            return maxSize;
        }
    }

    public function getGroups() : Iterable<String> {
        return _getGroups(_groups);
    }

    public static function _getGroups(groups : Iterable<String>) : Iterable<String> {
        var mGroups : Map<String, Bool> = new Map<String, Bool>();
        for (group in groups) {
            mGroups[group] = true;
        }
        var aGroups : Array<String> = new Array<String>();
        for (group in mGroups.keys()) {
            aGroups.push(group);
        }
        return aGroups;
    }
}

@:expose
@:nativeGen
class GrapherUpdateLocationsResults {
    public function new() { }

    public var _changed : Bool;
    public var _locationsX : Array<Float>;
    public var _locationsY : Array<Float>;
    public var _coordinates : Array<String>;
    public var _groups : Array<String>;
}

@:expose
@:nativeGen
class GraphExportTypeOptions {
    private var _values : Map<String, Any> = new Map<String, Any>();
    private var _view : GrapherInterface;

    public function new(view : GrapherInterface) {
        _view = view;
    }

    public function html() : GraphExportTypeOptionsFinish {
        return setType(GrapherHTMLExporter.getInstance());
    }

    public function svg() : GraphExportTypeOptionsFinish {
        return setType(GrapherSVGExporter.getInstance());
    }

    public function tex() : GraphExportTypeOptionsFinish {
        return setType(GrapherTEXExporter.getInstance());
    }    

    private function setType(t : GrapherExporter<Dynamic>) : GraphExportTypeOptionsFinish {
        _values.set("type", t);
        return new GraphExportTypeOptionsFinish(_view, _values);
    }
}

@:expose
@:nativeGen
class GraphExportTypeOptionsFinish {
    private var _values : Map<String, Any>;
    private var _view : GrapherInterface;

    public function new(view : GrapherInterface, values : Map<String, Any>) {
        _view = view;
        _values = values;
    }

    public function width(width : Int) : GraphExportTypeOptionsFinish {
        _values.set("width", width);
        return this;
    }

    public function height(height : Int) : GraphExportTypeOptionsFinish {
        _values.set("height", height);
        return this;
    }

    /**
        Set width to match the data
    **/
    public function matchWidth() : GraphExportTypeOptionsFinish {
        _values.set("width", -1);
        return this;
    }

    /**
        Set height to match the data
    **/
    public function matchHeight() : GraphExportTypeOptionsFinish {
        _values.set("height", -1);
        return this;
    }

    public function toMap() : Map<String, Any> {
        return _values;
    }

    public function execute(?callback : String->Void) : String {
        return _view.export(this, callback);
    }
}

@:expose
@:nativeGen
interface GrapherExporter<T> {
    function start(sb : T, width : Int, height : Int, scaleX : Float, scaleY : Float) : Void;
    function end(sb : T) : String;
    function drawLine(sb : T, x1 : Int, y1 : Int, x2 : Int, y2 : Int) : Void;
    function drawRect(sb : T, x1 : Int, y1 : Int, x2 : Int, y2 : Int) : Void;
    function drawCircle(sb : T, x : Int, y : Int, radius : Float) : Void;
    function drawText(sb : T, x : Int, y : Int, p : Float, s : String) : Void;
    function getTarget() : T;
    function setCaption(sb : T, caption : String) : Void;
    function setColor(sb : T, color : String) : Void;
}

@:expose
@:nativeGen
class GrapherHTMLExporter implements GrapherExporter<StringBufRef> {
    private function new() { }

    private static var _instance : GrapherExporter<StringBufRef> = new GrapherHTMLExporter();
    
    public static function getInstance() : GrapherExporter<StringBufRef> {
        return _instance;
    }

    public function getTarget() : StringBufRef {
        return new StringBufRef();
    }

    public function start(sb : StringBufRef, width : Int, height : Int, scaleX : Float, scaleY : Float) : Void {
        sb.add("<html><head><style>.line-segment { transform: rotate(calc(var(--angle) * 1deg)); transform-origin: left bottom; bottom: calc(var(--y1) * 1px); left: calc(var(--x1) * 1px); height: 1px; position: absolute; background-color: black; width: calc(var(--length) * 1px); }</style></head><body><div style=\"width:");
        sb.add(width / scaleX);
        sb.add("px; height: ");
        sb.add(height / scaleY);
        sb.add("px;\">");
    }

    public function setCaption(sb : StringBufRef, caption : String) : Void { }

    public function setColor(sb : StringBufRef, color : String) : Void {
        var s : String = sb.toString();
        var update : String = "style=\"";
        var i : Int = s.lastIndexOf(update) + update.length;
        sb.reset();
        sb.add(s.substring(0,i));
        sb.add("color: ");
        sb.add(color);
        sb.add("; background-color: ");
        sb.add(color);
        sb.add("; ");
        sb.add(s.substring(i));
    }

    public function end(sb : StringBufRef) : String {
        sb.add("</div></body></html>");
        return sb.toString();
    }    

    public function drawLine(sb : StringBufRef, x1 : Int, y1 : Int, x2 : Int, y2 : Int) : Void {
        var angle : Float = -Math.atan2(y2 - y1, x2 - x1) / Math.PI * 180;
        var length : Float = Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
        sb.add("<div ");
        sb.add("class=\"line-segment\" ");
        sb.add("style=\"--x1: ");
        sb.add(x1);
        sb.add("; --y1: ");
        sb.add(y1);
        sb.add("; --x2: ");
        sb.add(x2);
        sb.add("; --y2: ");
        sb.add(y2);
        sb.add("; --angle: ");
        sb.add(angle);
        sb.add("; --length: ");
        sb.add(length);
        sb.add("; \"> </div>\n");
    }    

    public function drawRect(sb : StringBufRef, x1 : Int, y1 : Int, x2 : Int, y2 : Int) : Void {
        var width : String = "" + (x2 - x1) + "px";
        var height : String = "" + (y2 - y1) + "px";
        sb.add("<div ");
        sb.add("class=\"graph-box\" ");
        sb.add("style=\"");
        sb.add("left: ");
        sb.add(x1);
        sb.add("; bottom: ");
        sb.add(y1);
        sb.add("; height: ");
        sb.add(height);
        sb.add("; min-height: ");
        sb.add(height);
        sb.add("; max-height: ");
        sb.add(height);
        sb.add("; width: ");
        sb.add(width);
        sb.add("; min-width: ");
        sb.add(width);
        sb.add("; max-width: ");
        sb.add(width);
        sb.add("; \">");
        sb.add("</div>\n");
    }

    public function drawCircle(sb : StringBufRef, x : Int, y : Int, radius : Float) : Void {
        var size : String = "" + (radius * 2) + "px";
        sb.add("<div ");
        sb.add("class=\"graph-circle\" ");
        sb.add("style=\"");
        sb.add("left: ");
        sb.add(x);
        sb.add("; bottom: ");
        sb.add(y);
        sb.add("; height: ");
        sb.add(size);
        sb.add("; min-height: ");
        sb.add(size);
        sb.add("; max-height: ");
        sb.add(size);
        sb.add("; width: ");
        sb.add(size);
        sb.add("; min-width: ");
        sb.add(size);
        sb.add("; max-width: ");
        sb.add(size);
        sb.add("; \">");
        sb.add("</div>\n");
    }

    public function drawText(sb : StringBufRef, x : Int, y : Int, p : Float, s : String) : Void {
        sb.add("<div ");
        sb.add("class=\"graph-text\" ");
        sb.add("style=\"");
        sb.add("left: ");
        sb.add(x);
        sb.add("; bottom: ");
        sb.add(y);
        sb.add("; position: absolute; \">");
        sb.add(s);
        sb.add("</div>\n");
    }
}

@:expose
@:nativeGen
class GrapherSVGExporter implements GrapherExporter<StringBufRef> {
    private function new() { }

    private static var _instance : GrapherExporter<StringBufRef> = new GrapherSVGExporter();
    
    public static function getInstance() : GrapherExporter<StringBufRef> {
        return _instance;
    }

    public function getTarget() : StringBufRef {
        return new StringBufRef();
    }

    public function start(sb : StringBufRef, width : Int, height : Int, scaleX : Float, scaleY : Float) : Void {
        sb.add("<svg viewBox=\"0 0 ");
        sb.add(width / scaleX);
        sb.add(" ");
        sb.add(height / scaleY);
        sb.add("\" transform=\"scale(1,-1)\" xmlns=\"http://www.w3.org/2000/svg\">");
    }

    public function setCaption(sb : StringBufRef, caption : String) : Void { }

    public function setColor(sb : StringBufRef, color : String) : Void {
        var s : String = sb.toString();
        var update : String = "stroke=\"";
        var i : Int = s.lastIndexOf(update) + update.length;
        var j : Int = s.indexOf("\"", i);
        sb.reset();
        sb.add(s.substring(0,i));
        sb.add(color);
        sb.add(s.substring(j));
        s = sb.toString();

        update = "fill=\"";
        i = s.indexOf(update, i);
        if (i >= 0) {
            i += update.length;
            j = s.indexOf("\"", i);
            sb.reset();
            sb.add(s.substring(0,i));
            sb.add(color);
            sb.add(s.substring(j));
        }
    }

    public function end(sb : StringBufRef) : String {
        sb.add("</svg>");
        return sb.toString();
    }

    public function drawLine(sb : StringBufRef, x1 : Int, y1 : Int, x2 : Int, y2 : Int) : Void {
        sb.add("<line x1=\"");
        sb.add(x1);
        sb.add("\" y1=\"");
        sb.add(y1);
        sb.add("\" x2=\"");
        sb.add(x2);
        sb.add("\" y2=\"");
        sb.add(y2);
        sb.add("\" stroke=\"black\" />\n");
    }

    public function drawRect(sb : StringBufRef, x1 : Int, y1 : Int, x2 : Int, y2 : Int) : Void {
        sb.add("<rect x=\"");
        sb.add(x1);
        sb.add("\" y=\"");
        sb.add(y1);
        sb.add("\" width=\"");
        sb.add(x2 - x1);
        sb.add("\" y2=\"");
        sb.add(y2 - y1);
        sb.add("\" stroke=\"black\" fill=\"black\" />\n");
    }

    public function drawCircle(sb : StringBufRef, x : Int, y : Int, radius : Float) : Void {
        sb.add("<circle cx=\"");
        sb.add(x);
        sb.add("\" cy=\"");
        sb.add(y);
        sb.add("\" r=\"");
        sb.add(radius);
        sb.add("\" stroke=\"black\" fill=\"black\" />");
    }

    public function drawText(sb : StringBufRef, x : Int, y : Int, p : Float, s : String) : Void {
        sb.add("<text x=\"");
        sb.add(x);
        sb.add("\" y=\"");
        sb.add(-y);
        sb.add("\" font-family=\"arial\" font-size=\"10\" stroke=\"black\" transform=\"scale(1,-1)\">");
        sb.add(s);
        sb.add("</text>");
    }
}

@:expose
@:nativeGen
class GrapherTEXExporter implements GrapherExporter<StringBufRef> {
    private function new() { }

    private static var _instance : GrapherExporter<StringBufRef> = new GrapherTEXExporter();
    
    public static function getInstance() : GrapherExporter<StringBufRef> {
        return _instance;
    }

    public function getTarget() : StringBufRef {
        return new StringBufRef();
    }

    public function start(sb : StringBufRef, width : Int, height : Int, scaleX : Float, scaleY : Float) : Void {
        width = cast width / scaleX;
        height = cast height / scaleY;
        var pageHeight : Float = 254;
        var pageWidth : Float = 190.5;
        var adjustHeight : Float = pageHeight / height;
        var adjustWidth : Float = pageWidth / width;
        sb.add("\\documentclass{article}\n");
        sb.add("\\usepackage[left=0cm, right=0cm]{geometry}\n");
        sb.add("\\usepackage{xcolor}");
        sb.add("\\setlength{\\unitlength}{");
        sb.add(adjustHeight < adjustWidth ? adjustHeight : adjustWidth);
        sb.add("mm}\n");
        sb.add("\\begin{document}\n");
        sb.add("\\begin{picture}(");
        sb.add(width);
        sb.add(",");
        sb.add(height);
        sb.add(")\n");
    }

    public function setCaption(sb : StringBufRef, caption : String) : Void { }    

    public function setColor(sb : StringBufRef, color : String) : Void {
        var s : String = sb.toString();
        var update : String = "\\";
        var i : Int = s.lastIndexOf(update);
        sb.reset();
        sb.add(s.substring(0,i));
        sb.add("\\color{");
        sb.add(color);
        sb.add("}\n");
        sb.add(s.substring(i));
    }

    public function end(sb : StringBufRef) : String {
        sb.add("\\end{picture}\n");
        sb.add("\\end{document}\n");
        return sb.toString();
    }        

    // TODO - pstricks, tikz, xpicture

    public function drawLine(sb : StringBufRef, x1 : Int, y1 : Int, x2 : Int, y2 : Int) : Void {
        sb.add("\\qbezier(");
        sb.add(x1);
        sb.add(",");
        sb.add(y1);
        sb.add(")(");
        sb.add((x1+x2)/2);
        sb.add(",");
        sb.add((y1+y2)/2);
        sb.add(")(");
        sb.add(x2);
        sb.add(",");
        sb.add(y2);
        sb.add(")\n");
    }

    public function drawRect(sb : StringBufRef, x1 : Int, y1 : Int, x2 : Int, y2 : Int) : Void {
        
    }

    public function drawCircle(sb : StringBufRef, x : Int, y : Int, radius : Float) : Void {

    }

    public function drawText(sb : StringBufRef, x : Int, y : Int, p : Float, s : String) : Void {
        sb.add("\\put(");
        sb.add(x);
        sb.add(",");
        sb.add(y);
        sb.add("){");
        sb.add(s);
        sb.add("}\n");
    }
}

@:expose
@:nativeGen
class StringBufRef {
    private var sb : StringBuf;

    public function new() {
        reset();
    }

    public function add(s : Dynamic) {
        sb.add(s);
    }

    public function toString() : String {
        return sb.toString();
    }

    public function reset() : Void {
        sb = new StringBuf();
    }
}
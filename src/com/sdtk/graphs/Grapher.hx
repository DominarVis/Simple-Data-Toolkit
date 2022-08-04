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
    private var _plotFunction : Float->Float;
    private var _plotType : Int;
    private var _locationsY : Array<Float>;
    private var _locationsX : Array<Float>;
    private var _coordinates : Array<String>;
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

    private function new(options : GrapherOptions) {
        var fo : Map<String, Dynamic> = options.toMap();
        var width : Int = cast fo.get("tileWidth");
        var height : Int = cast fo.get("tileHeight");
        var shiftX : Null<Int> = cast fo.get("shiftX");
        var shiftY : Null<Int> = cast fo.get("shiftY");
        _plotFunction = cast fo.get("plotFunction");
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
        _dataByIndex = cast fo.get("dataByIndex");
        _fillGap = false;
        if (_plotFunction == null && _reader != null) {
            _plotFunction = plotForData;
        }
    }

    public static function create(options : GrapherOptions) : Grapher {
        return new Grapher(options);
    }

    public static function options() : GrapherOptions {
        return new GrapherOptions();
    }

    public function updateLocations() : Void {
        _convertedData = _updateData(_convertedData, _reader, _plotType, _dataByIndex, _dataX, _dataY);
        var results : GrapherUpdateLocationsResults = _updateLocations(_originX, _originY, 1, 1, _tileWidth, _tileHeight, _shiftX, _shiftY, _plotFunction, _plotType, _locationsX, _locationsY, _coordinates, _convertedData);
        _changed = results._changed;
        _locationsX = results._locationsX;
        _locationsY = results._locationsY;
        _coordinates = results._coordinates;
    }

    public static function _updateData(convertedData : Array<Array<Dynamic>>, reader : com.sdtk.table.DataTableReader, plotType : Int, dataByIndex : Bool, dataX : Dynamic, dataY : Dynamic) : Array<Array<Dynamic>> {
        if (reader != null && convertedData == null) {
            if (dataByIndex) {
                convertedData = convertDataForPlotByColumnIndex(reader, plotType, cast dataX, cast dataY);
            } else {
                convertedData = convertDataForPlotByColumnName(reader, plotType, cast dataX, cast dataY);
            }
        }
        return convertedData;
    }

    public static function _updateLocations(originX : Float, originY : Float, rectWidth : Float, rectHeight : Float, tileWidth : Float, tileHeight : Float, shiftX : Int, shiftY : Int, plotFunction : Float->Float, plotType : Int, _locationsX : Array<Float>,  _locationsY : Array<Float>, _coordinates : Array<String>, convertedData : Array<Array<Dynamic>>) : GrapherUpdateLocationsResults {
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

        var changed : Bool = (_locationsX == null);
        //var locations : Map<String, Float> = new Map<String, Float>();

        {
            var i : Float = start;
            var j : Int = 0;
            while (j < size) {
                var result : Float = plotFunction(i);
                locationUse[j] = i + shiftUse;
                locationResult[j] = result + shiftResult;
                if (convertedData == null) {
                    coordinates[j] = getCoordinates(i, result);
                } else {
                    coordinates[j] = convertedData[j][0] + " - " + convertedData[j][1];
                }
                if (!changed && locationCompare[j] != locationResult[j]) {
                    changed = true;
                }
                i += increment;
                j++;
            }
        }

        {
            results._changed = changed;
            if (changed) {
                results._locationsX = locationsX;
                results._locationsY = locationsY;
                results._coordinates = coordinates;
            } else {
                results._locationsX = _locationsX;
                results._locationsY = _locationsY;                
                results._coordinates = _coordinates;
            }
            return results;
        }
    }

    public function exportOptions() : GraphExportTypeOptions {
        return new GraphExportTypeOptions(this);
    }

    public function export(options : GraphExportTypeOptionsFinish, ?callback : String->Void) {
        return _export(null, options, callback, _originX, _originY, 1, 1, _tileWidth, _tileHeight, _shiftX, _shiftY, _plotType, _locationsX, _locationsY, _coordinates, _convertedData);
    }

    public static function _export(exporter : GrapherExporter<Dynamic>, options : GraphExportTypeOptionsFinish, ?callback : String->Void, originX : Float, originY : Float, rectWidth : Float, rectHeight : Float, tileWidth : Float, tileHeight : Float, shiftX : Int, shiftY : Int, plotType : Int, locationsX : Array<Float>, locationsY : Array<Float>, coordinates : Array<String>, convertedData : Array<Array<Dynamic>>) : String {
        var width : Null<Int> = null;
        var height : Null<Int> = null;   
        if (options != null) {
            var fo : Map<String, Any> = options.toMap();
            exporter = cast fo.get("type");
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

        var start : Float = -1;
        var end : Float = -1;
        var increment : Float = -1;
        var scale : Float = -1;

        switch (plotType) {
            case 1:
                start = originY;
                end = start + tileHeight;
                increment = 1/rectHeight;
                scale = height / (tileHeight * rectHeight);
            case 2:
                start = originX;
                end = start + tileWidth;
                increment = 1/rectWidth;
                scale = width / (tileWidth * rectWidth);                
        }

        var size : Int;

        if (convertedData == null) {
            size = Math.round((end - start)/increment);        
        } else {
            size = convertedData.length;
        }

        exporter.start(sb, width, height);
        var j : Int = 1;
        var multiX : Float = rectWidth * scale;
        var multiY : Float = rectHeight * scale;
        var prevX : Int = Math.round(locationsX[j - 1] * multiX);
        var prevY : Int = Math.round(locationsY[j - 1] * multiY);
        while (j < size) {
            var newX : Int = Math.round(locationsX[j] * multiX);
            var newY : Int = Math.round(locationsY[j] * multiY);
            exporter.drawLine(sb, prevX, prevY, newX, newY);
            prevX = newX;
            prevY = newY;
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
            exporter.drawLine(sb, cast (j + startX) * rectWidth, cast -tickHeight/2 + (originY + shiftY) * rectHeight, cast (j + startX) * rectWidth, cast tickHeight/2 + (originY + shiftY) * rectHeight);
            if (convertedData != null && plotType == 2) {
                exporter.setCaption(sb, convertedData[j][0]);
            } else {
                exporter.setCaption(sb, Std.string(j - shiftX));
            }
            j++;
        }

        j = 0;
        while (j < tileHeight) {
            exporter.drawLine(sb, cast -tickWidth/2 + (originX + shiftX) * rectWidth, cast (j + startY) * rectHeight, cast tickWidth/2 + (originX + shiftX) * rectWidth, cast (j + startY) * rectHeight);
            if (convertedData != null && plotType == 1) {
                exporter.setCaption(sb, convertedData[j][1]);
            } else {
                exporter.setCaption(sb, Std.string(j - shiftY));
            }
            j++;
        }

        exporter.drawLine(sb, cast startX * rectWidth, cast (originY + shiftY) * rectHeight, cast endX * rectWidth, cast (originY + shiftY) * rectHeight);
        exporter.drawLine(sb, cast (originX + shiftX) * rectWidth, cast startY * rectHeight, cast (originX + shiftX) * rectWidth, cast endY * rectHeight);

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
        com.sdtk.table.Converter.convertWithOptions(r, null, awWriter, com.sdtk.table.Format.Formats.ARRAY(), null, columns, null, null, columns, false, false, null, null);
        return arr;
    }

    private static function convertDataForPlotByColumnName(r : com.sdtk.table.DataTableReader, plotType : Int, x : String, y : String) : Array<Array<Dynamic>> {
        var columns : Array<String> = new Array<String>();

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

        return convertData(columns, r);
    }

    private static function convertDataForPlotByColumnIndex(r : com.sdtk.table.DataTableReader, plotType : Int, x : Int, y : Int) : Array<Array<Dynamic>> {
        var columns : Array<Int> = new Array<Int>();

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

        return convertData(columns, r);
    }

    public static function _plotForData(x : Float, convertedData : Array<Array<Dynamic>>) : Float {
        return cast convertedData[cast x][1];
    }

    private function plotForData(x : Float) {
        return _plotForData(x, _convertedData);
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
    function start(sb : T, width : Int, height : Int) : Void;
    function end(sb : T) : String;
    function drawLine(sb : T, x1 : Int, y1 : Int, x2 : Int, y2 : Int) : Void;
    function getTarget() : T;
    function setCaption(sb : T, caption : String) : Void;
}

@:expose
@:nativeGen
class GrapherHTMLExporter implements GrapherExporter<StringBuf> {
    private function new() { }

    private static var _instance : GrapherExporter<StringBuf> = new GrapherHTMLExporter();
    
    public static function getInstance() : GrapherExporter<StringBuf> {
        return _instance;
    }

    public function getTarget() : StringBuf {
        return new StringBuf();
    }

    public function start(sb : StringBuf, width : Int, height : Int) : Void {
        sb.add("<html><head><style>.line-segment { transform: rotate(calc(var(--angle) * 1deg)); transform-origin: left bottom; bottom: calc(var(--y1) * 1px); left: calc(var(--x1) * 1px); height: 1px; position: absolute; background-color: black; width: calc(var(--length) * 1px); }</style></head><body><div style=\"width:");
        sb.add(width);
        sb.add("px; height: ");
        sb.add(height);
        sb.add("px;\">");
    }

    public function setCaption(sb : StringBuf, caption : String) : Void { }

    public function end(sb : StringBuf) : String {
        sb.add("</div></body></html>");
        return sb.toString();
    }    

    public function drawLine(sb : StringBuf, x1 : Int, y1 : Int, x2 : Int, y2 : Int) : Void {
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
}

@:expose
@:nativeGen
class GrapherSVGExporter implements GrapherExporter<StringBuf> {
    private function new() { }

    private static var _instance : GrapherExporter<StringBuf> = new GrapherSVGExporter();
    
    public static function getInstance() : GrapherExporter<StringBuf> {
        return _instance;
    }

    public function getTarget() : StringBuf {
        return new StringBuf();
    }

    public function start(sb : StringBuf, width : Int, height : Int) : Void {
        sb.add("<svg viewBox=\"0 0 ");
        sb.add(width);
        sb.add(" ");
        sb.add(height);
        sb.add("\" transform=\"scale(1,-1)\" xmlns=\"http://www.w3.org/2000/svg\">");
    }

    public function setCaption(sb : StringBuf, caption : String) : Void { }

    public function end(sb : StringBuf) : String {
        sb.add("</svg>");
        return sb.toString();
    }

    public function drawLine(sb : StringBuf, x1 : Int, y1 : Int, x2 : Int, y2 : Int) : Void {
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
}

@:expose
@:nativeGen
class GrapherTEXExporter implements GrapherExporter<StringBuf> {
    private function new() { }

    private static var _instance : GrapherExporter<StringBuf> = new GrapherTEXExporter();
    
    public static function getInstance() : GrapherExporter<StringBuf> {
        return _instance;
    }

    public function getTarget() : StringBuf {
        return new StringBuf();
    }

    public function start(sb : StringBuf, width : Int, height : Int) : Void {
        var pageHeight : Float = 254;
        var pageWidth : Float = 190.5;
        var adjustHeight : Float = pageHeight / height;
        var adjustWidth : Float = pageWidth / width;
        sb.add("\\documentclass{article}\n");
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

    public function setCaption(sb : StringBuf, caption : String) : Void { }    

    public function end(sb : StringBuf) : String {
        sb.add("\\end{picture}\n");
        sb.add("\\end{document}\n");
        return sb.toString();
    }        

    // TODO - pstricks, tikz, xpicture

    public function drawLine(sb : StringBuf, x1 : Int, y1 : Int, x2 : Int, y2 : Int) : Void {
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
}

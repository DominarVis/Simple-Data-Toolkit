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
/**
    Specifies options for creating GraphViews.
**/
class GrapherOptions {
    /**
        All the values that are wrapped by OptionsAbstract.
    **/
    private var _values : Map<String, Any> = new Map<String, Any>();

    public inline function new() {  }

    /**
        Plots a function that defines X for a given Y.
    **/
    public function plotFunctionForX(f : Float->Float) : GrapherOptions {
        return cast _plotFunctionForX(setOnceI, this, f);
    }

    /**
        Plots a function that defines X for a given Y.
    **/
    public static function _plotFunctionForX(setOnce : Dynamic->String->Any->Dynamic, options : Dynamic, f : Float->Float) : Dynamic{
        setOnce(options, "plotFunction", f);
        return cast setOnce(options, "plotType", 1);
    }

    /**
        Plots a function that defines Y for a given X.
    **/
    public function plotFunctionForY(f : Float->Float) : GrapherOptions {
        return cast _plotFunctionForY(setOnceI, this, f);
    }

    /**
        Plots a function that defines Y for a given X.
    **/
    public static function _plotFunctionForY(setOnce : Dynamic->String->Any->Dynamic, options : Dynamic, f : Float->Float) : Dynamic {
        setOnce(options, "plotFunction", f);
        return cast setOnce(options, "plotType", 2);
    }

    /**
        Plots data on a graph.
    **/    
    public function plotDataByColumnNameForY(r : com.sdtk.table.DataTableRowReader, x : String, y : String) : GrapherOptions {
        return cast _plotDataByColumnNameForY(setOnceI, this, r, x, y);
    }

    /**
        Plots data on a graph.
    **/    
    public static function _plotDataByColumnNameForY(setOnce : Dynamic->String->Any->Dynamic, options : Dynamic, r : com.sdtk.table.DataTableRowReader, x : String, y : String) : Dynamic {
        setOnce(options, "plotType", 2);
        setOnce(options, "reader", r);
        setOnce(options, "dataX", x);
        setOnce(options, "dataY", y);
        return cast setOnce(options, "dataByIndex", false);
    }

    /**
        Plots data on a graph.
    **/    
    public function plotDataByColumnNameForX(r : com.sdtk.table.DataTableRowReader, x : String, y : String) : GrapherOptions {
        return cast _plotDataByColumnNameForX(setOnceI, this, r, x, y);
    }

    /**
        Plots data on a graph.
    **/    
    public static function _plotDataByColumnNameForX(setOnce : Dynamic->String->Any->Dynamic, options : Dynamic, r : com.sdtk.table.DataTableRowReader, x : String, y : String) : Dynamic {
        setOnce(options, "plotType", 1);
        setOnce(options, "reader", r);
        setOnce(options, "dataX", x);
        setOnce(options, "dataY", y);
        return cast setOnce(options, "dataByIndex", false);
    }    

    /**
        Plots data on a graph.
    **/    
    public function plotDataByColumnIndexForY(r : com.sdtk.table.DataTableRowReader, x : String, y : String) : GrapherOptions {
        return cast _plotDataByColumnIndexForY(setOnceI, this, r, x, y);
    }

    /**
        Plots data on a graph.
    **/    
    public static function _plotDataByColumnIndexForY(setOnce : Dynamic->String->Any->Dynamic, options : Dynamic, r : com.sdtk.table.DataTableRowReader, x : String, y : String) : Dynamic {
        setOnce(options, "plotType", 2);
        setOnce(options, "reader", r);
        setOnce(options, "dataX", x);
        setOnce(options, "dataY", y);
        return cast setOnce(options, "dataByIndex", true);
    }

    /**
        Plots data on a graph.
    **/    
    public function plotDataByColumnIndexForX(r : com.sdtk.table.DataTableRowReader, x : String, y : String) : GrapherOptions {
        return cast _plotDataByColumnIndexForX(setOnceI, this, r, x, y);
    }

    /**
        Plots data on a graph.
    **/    
    public static function _plotDataByColumnIndexForX(setOnce : Dynamic->String->Any->Dynamic, options : Dynamic, r : com.sdtk.table.DataTableRowReader, x : String, y : String) : Dynamic {
        setOnce(options, "plotType", 1);
        setOnce(options, "reader", r);
        setOnce(options, "dataX", x);
        setOnce(options, "dataY", y);
        return cast setOnce(options, "dataByIndex", true);
    }    

    /**
        Only plot values that have a positive Y.
    **/
    public function positiveOnlyY() : GrapherOptions {
        return cast _positiveOnlyY(setOnceI, this);
    }

    /**
        Only plot values that have a positive Y.
    **/
    public static function _positiveOnlyY(setOnce : Dynamic->String->Any->Dynamic, options : Dynamic) : Dynamic {
        return cast setOnce(options, "centerOfY", 1);
    }    

    /**
        Only plot values that have a negative Y.
    **/
    public function negativeOnlyY() : GrapherOptions {
        return cast _negativeOnlyY(setOnceI, this);
    }

    /**
        Only plot values that have a negative Y.
    **/
    public static function _negativeOnlyY(setOnce : Dynamic->String->Any->Dynamic, options : Dynamic) : Dynamic {
        return cast setOnce(options, "centerOfY", -1);
    }    

    /**
        Plot values for both negative and positive Y.
    **/
    public function positiveAndNegativeY() : GrapherOptions {
        return cast _positiveAndNegativeY(setOnceI, this);
    }

    /**
        Plot values for both negative and positive Y.
    **/
    public static function _positiveAndNegativeY(setOnce : Dynamic->String->Any->Dynamic, options : Dynamic) : Dynamic {
        return cast setOnce(options, "centerOfY", 0);
    }    

    /**
        Only plot values that have a positive X.
    **/
    public function positiveOnlyX() : GrapherOptions {
        return cast _positiveOnlyX(setOnceI, this);
    }

    /**
        Only plot values that have a positive X.
    **/
    public static function _positiveOnlyX(setOnce : Dynamic->String->Any->Dynamic, options : Dynamic) : Dynamic {
        return cast setOnce(options, "centerOfX", 1);
    }

    /**
        Only plot values that have a negative X.
    **/
    public function negativeOnlyX() : GrapherOptions {
        return cast _negativeOnlyX(setOnceI, this);
    }

    /**
        Only plot values that have a negative X.
    **/
    public static function _negativeOnlyX(setOnce : Dynamic->String->Any->Dynamic, options : Dynamic) : Dynamic {
        return cast setOnce(options, "centerOfX", -1);
    }    

    /**
        Plot values for both negative and positive X.
    **/
    public function positiveAndNegativeX() : GrapherOptions {
        return cast _positiveAndNegativeX(setOnceI, this);
    }

    /**
        Plot values for both negative and positive X.
    **/
    public static function _positiveAndNegativeX(setOnce : Dynamic->String->Any->Dynamic, options : Dynamic) : Dynamic  {
        return cast setOnce(options, "centerOfX", 0);
    }

    /**
        Set a value exactly once.
    **/
    private function setOnce(key : String, value : Any) : GrapherOptions {
        if (_values[key] == null) {
            return _values[key] = value;
        } else {
            throw "Can only set once.";
        }
    }

    public function toMap() : Map<String, Dynamic> {
        return _values;
    }

    private static function setOnceI(o : Dynamic, key : String, value : Any) : Dynamic {
        var o2 : GrapherOptions = cast o;
        o2.setOnce(key, value);
        return o;
    }

    public function execute() : Grapher {
        return Grapher.create(this);
    }
}
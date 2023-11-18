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
    Standard/Core Library - Source code can be found on SourceForge.net
*/

package com.sdtk.std;

@:expose
@:nativeGen
class Filter {
    public function new() { }

    public function filter(sValue : Null<String>) : Null<String> {
        return sValue;
    }

    public static function list(sValue : Array<String>, bBlock : Bool) : Null<Filter> {
        if (bBlock) {
            var fFilter : Filter = null;
            for (s in sValue) {
                if (fFilter == null) {
                    fFilter = new FilterBlockWithString(s);
                } else {
                    fFilter = fFilter.and(new FilterBlockWithString(s));
                }
            }
            return fFilter;            
        } else {
            var fFilter : Filter = null;
            for (s in sValue) {
                if (fFilter == null) {
                    fFilter = new FilterAllowEqualString(s);
                } else {
                    fFilter = fFilter.or(new FilterAllowEqualString(s));
                }
            }
            return fFilter;
        }
    }

    public static function parse(sValue : Null<String>, bBlock : Bool) : Null<Filter> {
        if (sValue == null) {
            return null;
        } else {
            if (bBlock) {
                switch (sValue.charAt(0)) {
                    case "=":
                        return new FilterBlockEqualString(sValue.substring(1));
                    case "/":
                        return new FilterBlockRegularExpression(sValue);
                    case "#":
                    {
                        sValue = sValue.substring(1);
                        if (sValue.indexOf("-") > 0) {
                            var iRange : Array<Int> = parseRange(sValue);
                            return new FilterBlockCountingRange(iRange[0], iRange[1]);
                        } else if (sValue.indexOf(",") > 0) {
                            return new FilterBlockCountingList(parseList(sValue));
                        } else {
                            return new FilterBlockCountingSingle(Std.parseInt(StringTools.trim(sValue)));
                        }
                    }
                    default:
                        return new FilterBlockWithString(sValue);
                }
            } else {
                switch (sValue.charAt(0)) {
                    case "=":
                        return new FilterAllowEqualString(sValue.substring(1));
                    case "/":
                        return new FilterAllowRegularExpression(sValue);
                    case "#":
                    {
                        sValue = sValue.substring(1);
                        if (sValue.indexOf("-") > 0) {
                            var iRange : Array<Int> = parseRange(sValue);
                            return new FilterAllowCountingRange(iRange[0], iRange[1]);
                        } else if (sValue.indexOf(",") > 0) {
                            return new FilterAllowCountingList(parseList(sValue));
                        } else {
                            return new FilterAllowCountingSingle(Std.parseInt(StringTools.trim(sValue)));
                        }
                    }
                    default:
                        return new FilterAllowWithString(sValue);
                }
            }
        }
    }

    private static function parseList(sList : String) : Array<Int> {
        var iList : Array<Int> = new Array<Int>();
        for (s in sList.split(",")) {
            iList.push(Std.parseInt(StringTools.trim(s)));
        }
        return iList;
    }

    private static function parseRange(sRange : String) : Array<Int> {
        var iRange : Array<Int> = new Array<Int>();
        for (s in sRange.split("-")) {
            iRange.push(Std.parseInt(StringTools.trim(s)));
        }
        return iRange;
    }

    public function and(fFilter : Filter) : Filter {
        var cfAnd = new FilterCompositeAnd();
        cfAnd.and(this);
        cfAnd.and(fFilter);
        return cfAnd;
    }

    public function or(fFilter : Filter) : Filter {
        var cfAnd = new FilterCompositeOr();
        cfAnd.or(this);
        cfAnd.or(fFilter);
        return cfAnd;
    }    
}

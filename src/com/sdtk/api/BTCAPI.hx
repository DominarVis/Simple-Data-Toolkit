/*
    Copyright (C) 2023 Vis LLC - All Rights Reserved

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
    ISTAR - Insanely Simple Transfer And Reporting
*/

package com.sdtk.api;

#if !EXCLUDE_APIS
@:expose
@:nativeGen
class BTCAPI extends API {
    private static var _btcRoot : String = "chain.api.btc.com/v3/";
    private static var _blockAPI : String = "block/";
    private static var _addressAPI : String = "address/";
    private static var _latest : String = "latest/";
    private static var _transactions : String = "/tx";
    private static var _pagesize : String = "?pagesize=50";
    //TODO
    //private static var _transfersAPI : String = "token_trc20/transfers";
    //private static var _priceAPI : String = "price";
    private static var _maxLimit : Int = 50;
    private static var _maxMultiple : Int = 20;

    private static var _instance : BTCAPI;

    private function new() {
        super("BTC");
    }

    public static function instance() : BTCAPI {
        if (_instance == null) {
            _instance = new BTCAPI();
        }
        return _instance;
    }

    public static function transactions(callback : Dynamic->Void, block : String, address : String, page : Null<Int>) : Void {
        var api : String;
        var value : String;
        if ((address == null || address.length <= 0)) {
            api = _blockAPI;
            if (block == null) {
                block = _latest;
            }
            value = block;
        } else {
            api = _addressAPI;
            value = address;
        }
        if (page == null) {
            page = 1;
            var arr : Array<Dynamic> = new Array<Dynamic>();
            var progress : Dynamic->Void = null;
            progress = function (r : Dynamic) : Void {
                r = com.sdtk.std.Normalize.parseJson(r);
                arr.push(r);
                if (r.data.page < r.data.page_total) {
                    transactions(progress, block, address, r.data.page + 1);
                } else {
                    r = arr[0];
                    var i : Int = 1;
                    while (i < arr.length) {
                        r.data.list = r.data.list.concat(arr[i].data.list);
                        i++;
                    }
                    callback(haxe.Json.stringify(r));
                }
            };
            transactions(progress, block, address, page);
        } else {
            instance().fetch("GET", _btcRoot, api, null, null, value + _transactions + _pagesize + "&page=" + page, null, function (r) {
                var o : Dynamic = com.sdtk.std.Normalize.parseJson(r);
                callback(r);
            });
        }
    }

    public static function transactionsAPI() : InputAPI {
        return BTCAPITransactions.instance();
    }
}

@:nativeGen
class BTCAPITransactions extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Blockchain - Bitcoin - BTC - Transactions");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new BTCAPITransactions();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["address", "block"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        BTCAPI.transactions(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, cast mapping["block"], cast mapping["address"], null);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        callback(data, com.sdtk.table.ArrayOfObjectsReader.readWholeArray(com.sdtk.std.Normalize.parseJson(data).data.list));
    }    
}
#end
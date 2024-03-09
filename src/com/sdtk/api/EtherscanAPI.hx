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
class EtherscanAPI extends API {
    private static var _etherscanRoot : String = "api.etherscan.io/api";
    private static var _transactionAPI : String = "?module=account&action=txlist";
    //private static var _priceAPI : String = "price";
    //private static var _transfersAPI : String = "token_trc20/transfers";
    private static var _maxLimit : Int = 50;
    private static var _maxMultiple : Int = 20;

    private static var _instance : EtherscanAPI;

    private function new() {
        super("Etherscan");
    }

    public static function instance() : EtherscanAPI {
        if (_instance == null) {
            _instance = new EtherscanAPI();
        }
        return _instance;
    }

    public static function transactions(callback : Dynamic->Void, limit : Null<Int>, start : Null<Int>, address : String, apikey : String) : Void {
        if (limit == null) {
            limit = _maxLimit;
        }
        if (start == null) {
            start = 0;
        }
        if (apikey == null) {
            apikey = "YourApiKeyToken";
        }
        // TODO
        //if (limit <= _maxLimit) {
        if (true) {
            instance().fetch("GET", _etherscanRoot, _transactionAPI, null, null, "&sort=asc&startblock=" + start + "endblock=" + (limit + start) + "&address=" + address + "&apikey=" + apikey, null, function (r) {
                var o : Dynamic = haxe.Json.parse(r);
                // TODO
                //if (o.data.length == limit) {
                if (true) {
                    callback(r);
                } else {
                    transactions(function (r) {
                        var o2 : Dynamic = haxe.Json.parse(r);
                        o.data = o.data.concat(o2.data);
                        callback(haxe.Json.stringify(o));
                    }, cast limit - o.data.length, cast start + o.data.length, address, apikey);
                }
            });
        } else {
            var i : Int = start;
            var j : Int = _maxLimit;
            var arr : Array<String> = new Array<String>();
            var cnt : Int = 0;
            var loaded : Int = 0;
            while (i < limit) {
                (function (k) {
                    transactions(function (r) {
                        arr[k] = cast r;
                        loaded++;
                        if (loaded == cnt) {
                            r = haxe.Json.parse(arr[0]);
                            r.data = [];
                            for (s in arr) {
                                var o : Dynamic = haxe.Json.parse(s);
                                r.data = r.data.concat(o.data);
                            }
                            callback(haxe.Json.stringify(r));
                        }
                    }, j, i, address, apikey);
                })(cnt);
                i += j;
                j = ((limit - i) > _maxLimit) ? _maxLimit : (limit - i);
                cnt++;
            }
        }
        
        // {"total":,"rangeTotal":,"data":[{"block":,"hash":,"timestamp":,"ownerAddress":,"toAddress":,"contractType":,"confirmed":,"revert":,"SmartCalls":,"Events":,"id":,"data":,"fee":,"contractRet":,"result":,"amount":,"cost":}],"wholeChainTxCount":,"contractMap":{"0x":false,},"contractInfo":{}}
    }

    public static function transactionsAPI() : InputAPI {
        return EtherscanAPITransactions.instance();
    }
}

@:nativeGen
class EtherscanAPITransactions extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Blockchain - Ethereum - Etherscan - Transactions");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new EtherscanAPITransactions();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["address", "start", "limit", "apikey"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        EtherscanAPI.transactions(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, Std.parseInt(mapping["limit"]), Std.parseInt(mapping["start"]), cast mapping["address"], cast mapping["apikey"]);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        callback(data, com.sdtk.table.ArrayOfObjectsReader.readWholeArray(haxe.Json.parse(data).result));
    }    
}
#end
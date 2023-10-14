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
@:nativeGen
class BitTorrentAPI extends API {
    private static var _bttRoot : String = "scanapi.bt.io/api";
    private static var _statusAPI : String = "system/status";
    private static var _transactionAPI : String = "transaction";
    private static var _transfersAPI : String = "token_trc20/transfers";
    private static var _priceAPI : String = "price";
    private static var _maxLimit : Int = 50;
    private static var _maxMultiple : Int = 20;

    private static var _instance : BitTorrentAPI;

    private function new() {
        super("BitTorrent");
    }

    public static function instance() : BitTorrentAPI {
        if (_instance == null) {
            _instance = new BitTorrentAPI();
        }
        return _instance;
    }

    public static function status(callback : Dynamic->Void) : Void {
        instance().fetch("GET", _bttRoot, _statusAPI, null, null, null, null, callback);
        //{"database":{"confirmedBlock":16588904},"sync":{"progress":100.0},"network":{"type":"mainnet"},"solidity":{"block":16588904}}
    }

    private static function getDefaultStart() : Dynamic {
        #if js
            return cast js.Syntax.code("1529906400000");
        #elseif php
            return php.Syntax.code("1529906400000");
        #elseif python
            return python.Syntax.code("1529906400000");
        #elseif java
            return java.lang.Long.parseLong("1529906400000");
        #elseif cs
            return cs.Syntax.code("1529906400000");
        #else
            return "1529906400000";
        #end
    }

    private static function getDefaultEnd() : Dynamic {
        #if js
            return cast js.Syntax.code("Date.now()");
        #elseif php
            return php.Syntax.code("microtime(true) * 1000");
        #elseif python
            python.Syntax.code("import time");
            return python.Syntax.code("int(time.time()*1000.0)");
        #elseif java
            return java.lang.System.currentTimeMillis();
        #elseif cs
            return cs.Syntax.code("System.DateTime.Now.Ticks / System.TimeSpan.TicksPerMillisecond");
        #else
            return Date.now();
        #end
    }    

    public static function transactions(callback : Dynamic->Void, sort : String, limit : Null<Int>, start : Null<Int>, startTimestamp : Null<Int>, endTimestamp : Null<Int>, address : String) : Void {
        if (sort == null) {
            sort = "-timestamp";
        }
        if (limit == null) {
            limit = _maxLimit;
        }
        if (start == null) {
            start = 0;
        }
        if (startTimestamp == null) {
            startTimestamp = cast getDefaultStart();
        }
        if (endTimestamp == null) {
            endTimestamp = cast getDefaultEnd();
        }
        if (limit > (_maxLimit * _maxMultiple)) {
            limit = (_maxLimit * _maxMultiple);
        }
        if (limit <= _maxLimit) {
            instance().fetch("GET", _bttRoot, _transactionAPI, null, null, "?sort=" + sort + "&count=true&limit=" + limit + "&start=" + start + "&start_timestamp=" + startTimestamp + "&end_timestamp=" + endTimestamp + (address != null ? "&address=" + address : ""), null, function (r) {
                var o : Dynamic = haxe.Json.parse(r);
                if (o.data.length == limit) {
                    callback(r);
                } else {
                    transactions(function (r) {
                        var o2 : Dynamic = haxe.Json.parse(r);
                        o.data = o.data.concat(o2.data);
                        callback(haxe.Json.stringify(o));
                    }, sort, cast limit - o.data.length, cast start + o.data.length, startTimestamp, endTimestamp, address);
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
                    }, sort, j, i, startTimestamp, endTimestamp, address);
                })(cnt);
                i += j;
                j = ((limit - i) > _maxLimit) ? _maxLimit : (limit - i);
                cnt++;
            }
        }
        
        // {"total":,"rangeTotal":,"data":[{"block":,"hash":,"timestamp":,"ownerAddress":,"toAddress":,"contractType":,"confirmed":,"revert":,"SmartCalls":,"Events":,"id":,"data":,"fee":,"contractRet":,"result":,"amount":,"cost":}],"wholeChainTxCount":,"contractMap":{"0x":false,},"contractInfo":{}}
    }

    public function transactionsAPI() : InputAPI {
        return BitTorrentAPITransactions.instance();
    }

    public static function transfers(callback : Dynamic->Void, sort : String, limit : Null<Int>, start : Null<Int>, startTimestamp : Null<Int>, endTimestamp : Null<Int>, address : String) : Void {
        if (sort == null) {
            sort = "-timestamp";
        }
        if (limit == null) {
            limit = _maxLimit;
        }
        if (start == null) {
            start = 0;
        }
        if (startTimestamp == null) {
            startTimestamp = cast getDefaultStart();
        }
        if (endTimestamp == null) {
            endTimestamp = cast getDefaultEnd();
        }
        if (limit > (_maxLimit * _maxMultiple)) {
            limit = (_maxLimit * _maxMultiple);
        }
        if (limit <= _maxLimit) {
            instance().fetch("GET", _bttRoot, _transfersAPI, null, null, "?sort=" + sort + "&count=true&limit=" + limit + "&start=" + start + "&start_timestamp=" + startTimestamp + "&end_timestamp=" + endTimestamp + (address != null ? "relatedAddress=" + address : ""), null, function (r) {
                var o : Dynamic = haxe.Json.parse(r);
                if (o.token_transfers.length == limit) {
                    callback(r);
                } else {
                    transfers(function (r) {
                        var o2 : Dynamic = haxe.Json.parse(r);
                        o.token_transfers = o.token_transfers.concat(o2.token_transfers);
                        callback(haxe.Json.stringify(o));
                    }, sort, cast limit - o.token_transfers.length, cast start + o.token_transfers.length, startTimestamp, endTimestamp, address);
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
                    transfers(function (r) {
                        arr[k] = cast r;
                        loaded++;
                        if (loaded == cnt) {
                            r = haxe.Json.parse(arr[0]);
                            r.token_transfers = [];
                            for (s in arr) {
                                var o : Dynamic = haxe.Json.parse(s);
                                r.token_transfers = r.token_transfers.concat(o.token_transfers);
                            }
                            callback(haxe.Json.stringify(r));
                        }
                    }, sort, j, i, startTimestamp, endTimestamp, address);
                })(cnt);
                i += j;
                j = ((limit - i) > _maxLimit) ? _maxLimit : (limit - i);
                cnt++;
            }
        }
        // {"total":,"rangeTotal":,"contractInfo":{},"token_transfers":[{"transaction_id":,"block_ts":,"from_address":,"to_address":,"block":,"contract_address":,"amount_str":,"event_type":,"eventType":,"confirmed":,"contractRet":,"status":,"quant":,"approval_amount":,"contract_type":,"finalResult":,"tokenInfo":{"tokenId":,"tokenAbbr":,"tokenName":,"tokenDecimal":,"tokenCanShow":,"tokenType":,"tokenLogo":,"tokenLevel":,"vip":},"fromAddressIsContract":,"toAddressIsContract":,"revert":},]}
    }

    public function transfersAPI() : InputAPI {
        return BitTorrentAPITransfers.instance();
    }

    public static function price(callback : Dynamic->Void) {
        instance().fetch("GET", _bttRoot, _priceAPI, null, null, null, null, callback);
    }
}

@:nativeGen
class BitTorrentAPITransactions extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Blockchain - BitTorrent - Transactions");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new BitTorrentAPITransactions();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["address", "startTimestamp", "endTimestamp", "start", "limit"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        BitTorrentAPI.transactions(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, null, Std.parseInt(mapping["limit"]), Std.parseInt(mapping["start"]), Std.parseInt(mapping["startTimestamp"]), Std.parseInt(mapping["endTimestamp"]), cast mapping["address"]);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        callback(data, com.sdtk.table.ArrayOfObjectsReader.readWholeArray(haxe.Json.parse(data).data));
    }    
}

@:nativeGen
class BitTorrentAPITransfers extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Blockchain - BitTorrent - Transfers");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new BitTorrentAPITransfers();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["address", "startTimestamp", "endTimestamp", "start", "limit"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        BitTorrentAPI.transfers(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, null, Std.parseInt(mapping["limit"]), Std.parseInt(mapping["start"]), Std.parseInt(mapping["startTimestamp"]), Std.parseInt(mapping["endTimestamp"]), cast mapping["address"]);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        callback(data, com.sdtk.table.ArrayOfObjectsReader.readWholeArray(haxe.Json.parse(data).token_transfers));
    }    
}
#end
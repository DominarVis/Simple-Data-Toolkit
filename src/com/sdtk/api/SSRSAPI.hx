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
class SSRSAPI extends API {
    private static var _ssrsRoot1 : String = "https://";
    private static var _ssrsRoot2 : String = "/ReportServer/";
    private static var _viewAPI : String = "ReportExecution2005.asmx";

    private static var _instance : SSRSAPI;

    private var _token : String;
    private var _executionId : String;
    private var _user : String;
    private var _site : String;

    private function new() {
        super("SSRS");
    }

    public static function instance() : SSRSAPI {
        if (_instance == null) {
            _instance = new SSRSAPI();
        }
        return _instance;
    }

    // TODO - public static function list

    public static function pull(callback : Dynamic->Void, user : String, password : String, site : String, view : String, ?format : String = "CSV") : Void {
        var instance : SSRSAPI = instance();
        login(function (response : Dynamic) {
            instance.fetch("POST", _ssrsRoot1 + site + _ssrsRoot2, _viewAPI, null, null, null, getSoapEnvelope("LoadReport", ["report" => view]), function (response : Dynamic) {
                instance.fetch("POST", _ssrsRoot1 + site + _ssrsRoot2, _viewAPI, null, null, null, getSoapEnvelope("Render", ["report" => view, "format" => format, "parameters" => null, "executionId" => instance._executionId]), function (response : Dynamic) {
                    callback(response);
                });
            });
        }, user, password, site);
    }

    public function pullAPI() : InputAPI {
        return SSRSAPIPull.instance();
    }

    public static function login(callback : Dynamic->Void, user : String, password : String, site : String) {
        var instance : SSRSAPI = instance();
        if (user == instance._user && site == instance._site && instance._token != null) {
            callback(true);
        } else {
            instance.fetch("POST", _ssrsRoot1 + site + _ssrsRoot2, _viewAPI, null, null, null, getSoapEnvelope("LogonUser", ["username" => user, "password" => password]), function (response : Dynamic) {
                instance._executionId = getSessionId(response);
                instance._token = response.cookie;
                instance._user = user;
                instance._site = site;
                callback(response);
            });
        }
    }

    private static function getSoapEnvelope(method : String, args : Map<String, String>) : String {
        var soapNs = "http://schemas.xmlsoap.org/soap/envelope/";
        var soapEnv = Xml.createElement("soapenv:Envelope");
        soapEnv.set("xmlns:soapenv", soapNs);
        soapEnv.set("xmlns:ser", "http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices");
        var soapHeader = Xml.createElement("soapenv:Header");
        var soapBody = Xml.createElement("soapenv:Body");
        var soapMethod = Xml.createElement("ser:" + method);
        // NS = "http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices"
  
        for (key in args.keys()) {
            Xml.createElement(key).nodeValue = args.get(key);
        }
  
        soapEnv.addChild(soapHeader);
        soapEnv.addChild(soapBody);
  
        return soapEnv.toString();
    }   
    
    private static function getSessionId(response : String) : String {
        var doc = Xml.parse(response);
        return doc.firstElement().firstElement().elementsNamed("ExecutionID").next().nodeValue;
    }    

    private override function getAuthorizationHeader() : String {
        return "Cookie";
    }

    private override function getAuthorizationHeaderBearer() : String {
        return "";
    }

    private override function getAccessToken() : String {
        return _token;
    }
}

@:nativeGen
class SSRSAPIPull extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Reporting - SQL Server Reporting Services - View");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new SSRSAPIPull();
        }
        return _instance;
    }

    public override function getInputNames() : Array<String> {
        return ["user", "password", "site", "view"];
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        SSRSAPI.pull(function (r : Dynamic) {
            parseData(r, mapping, callback);
        }, cast mapping["user"], cast mapping["password"], cast mapping["site"], cast mapping["view"]);
    } 

    public override function parseData(data : String, mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        callback(data, com.sdtk.table.ArrayOfObjectsReader.readWholeArray(haxe.Json.parse(data).token_transfers));
    }    
}
#end
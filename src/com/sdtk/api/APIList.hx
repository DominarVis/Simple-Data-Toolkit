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
class APIList {
    private static var _executors : Array<ExecutorAPI> = null;
    private static var _executorsByName : Map<String, ExecutorAPI> = null;
    private static var _apis : Array<API> = null;
    private static var _inputs : Array<InputAPI> = null;
    private static var _apisByName : Map<String, API> = null;
    private static var _inputsByName : Map<String, InputAPI> = null;
    private static var _writers : Array<WriterAPI> = null;
    private static var _writersByName : Map<String, WriterAPI> = null;

    public static function apis() : Array<API> {
        if (_apis == null) {
            _apis = [
                GitAPI.instance(),
                BitTorrentAPI.instance(),
                BTCAPI.instance(),
                EtherscanAPI.instance(),
                #if JS_BROWSER
                    WebTorrentAPI.instance(),
                    SpeechSynthesisUtteranceAPI.instance(),
                #end
                #if python
                    TortoiseTTSAPI.instance(),
                #end
                ChatGPTAPI.instance(),
                TableauAPI.instance(),
            ];
        }
        return _apis;
    }

    public static function executors() : Array<ExecutorAPI> {
        if (_executors == null) {
            _executors =  [
                #if js
                    JSAPI.instance(),
                    PythonAPI.instance(),
                    SQLAPI.instance(),
                    CobolAPI.instance(),
                    BasicAPI.instance(),
                #end
                ChatGPTAPI.queryAsReaderWithDataAPI()
            ];
        }
        return _executors;
    }

    public static function inputs() : Array<InputAPI> {
        if (_inputs == null) {
            _inputs = [
                GitAPI.filesAPI(), GitAPI.reposAPI(), GitAPI.branchesAPI(), GitAPI.commitsAPI(), GitAPI.retrieveAPI(),
                #if(!JS_BROWSER)
                    OrtingoAPI.postsAPI(), OrtingoAPI.suggestionsAPI(), OrtingoAPI.commentsAPI(),
                #end
                BitTorrentAPI.transactionsAPI(), BitTorrentAPI.transfersAPI(),
                BTCAPI.transactionsAPI(),
                ChatGPTAPI.queryAsReaderAPI(),
                EtherscanAPI.transactionsAPI(),
                ACMAPI.eventsAPI(),
                IEEEAPI.eventsAPI(),
                #if JS_BROWSER
                    WebTorrentAPI.filesAPI(), WebTorrentAPI.retrieveAPI(),
                #end
                TableauAPI.pullAPI(), SSRSAPI.pullAPI(),
            ];
        }
        return _inputs;
    }

    public static function writers() : Array<WriterAPI> {
        if (_writers == null) {
            _writers = [
                #if js
                    JSPDFAutoTableAPI.instance()
                #end
            ];
        }
        return _writers;
    }

    public static function apisByName() : Map<String, API> {
        if (_apisByName == null) {
            _apisByName = cast byName(apis());
        }
        return _apisByName;
    }

    public static function executorsByName() : Map<String, ExecutorAPI> {
        if (_executorsByName == null) {
            _executorsByName = cast byName(executors());
        }
        return _executorsByName;
    }

    public static function inputsByName() : Map<String, InputAPI>{
        if (_inputsByName == null) {
            _inputsByName = cast byName(inputs());
        }
        return _inputsByName;
    }

    public static function writersByName() : Map<String, WriterAPI> {
        if (_writersByName == null) {
            _writersByName = cast byName(writers());
        }
        return _writersByName;
    }    

    private static function byName(arr : Array<Dynamic>) : Map<String, Dynamic> {
        var map : Map<String, Dynamic> = new Map<String, Dynamic>();
        for (o in arr) {
            map[o.name()] = o;
        }
        return map;
    }
}
#end
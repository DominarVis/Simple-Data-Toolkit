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
class ChatGPTAPI extends API {
    private static var _apiKey : String = "<CHATGPT_API_KEY>";
    private static var _instance : ChatGPTAPI;
    private static var _chatGPTRoot : String = "api.openai.com";
    private static var _completions : String = "v1/chat/completions";
    private static var _model : String = "<CHATGPT_MODEL>";

    private function new() {
        super("ChatGPT");
    }

    public static function instance() : ChatGPTAPI {
        if (_instance == null) {
            _instance = new ChatGPTAPI();
        }
        return _instance;
    }

    private override function getAccessToken() : String {
        return processIfNeeded(_apiKey);
    }

    public function query(callback : Dynamic->Void, query : String) : Void {
        var model : String = _model;
        if (model == null || model == "<CHATGPT_MODEL>") {
            model = "gpt-4o";
        }
        var data : Map<String, Dynamic> = [
            "model" => model,
            "messages" => [["role" => "user", "content" => query]]
        ];
        fetch("POST", _chatGPTRoot, _completions, null, true, null, haxe.Json.stringify(data),
            function (response : Dynamic) : Void {
                var responseData : Map<String, Dynamic> = cast com.sdtk.std.Normalize.nativeToHaxe(com.sdtk.std.Normalize.parseJson(Std.string(response)));
                var choices : Array<Dynamic> = cast responseData.get("choices");
                responseData = cast com.sdtk.std.Normalize.nativeToHaxe(choices[0]);
                responseData = cast com.sdtk.std.Normalize.nativeToHaxe(responseData.get("message"));
                callback(responseData.get("content"));
            },
            ["Content-Type" => "application/json"]
        );
    }

    public function queryAsTable(callback : Dynamic->Void, query : String, format : com.sdtk.table.Format) : Void {
        var details : String = "";
        switch (format) {
            case JSON:
                details = "  Like an array of objects.";
            default:
        }
        instance().query(function(response : Dynamic) {
            callback(response);
        }, query + "\n\nGive the result as only " + Std.string(format) + " content file in the chat like a table of values, as simple as possible." + details);  
    }

    public function queryAsReader(callback : String->com.sdtk.table.DataTableReader->Void, query : String) : Void {
        queryAsTable(function(response : Dynamic) {
            callback(response, com.sdtk.table.KeyValueReader.createJSONReader(new com.sdtk.std.StringReader(response)));
        }, query, com.sdtk.table.Format.JSON);
    }

    public function queryAsReaderWithData(callback : String->com.sdtk.table.DataTableReader->Void, query : String, reader : com.sdtk.table.DataTableReader) : Void {
        var data : String;
        var writer : com.sdtk.std.StringWriter = new com.sdtk.std.StringWriter(null);
        reader.convertTo(com.sdtk.table.KeyValueWriter.createJSONWriter(writer));
        data = writer.toString();
        queryAsReader(callback, "Given the following data in JSON format.\n\n" + data + "\n\n" + query);
    }

    public static function queryAsReaderAPI() : InputAPI {
        return ChatGPTQueryAsReaderAPI.instance();   
    }

    public static function queryAsReaderWithDataAPI() : ExecutorAPI {
        return ChatGPTQueryAsReaderWithDataAPI.instance();
    }

    public static function queryWithDataAPI() : ChatGPTQueryWithDataAPI {
        return ChatGPTQueryWithDataAPI.instance();
    }
}

@:nativeGen
class ChatGPTQueryAsReaderAPI extends InputAPI {
    private static var _instance : InputAPI;

    private function new() {
        super("Large Language Model - ChatGPT - Table");
    }

    public static function instance() : InputAPI {
        if (_instance == null) {
            _instance = new ChatGPTQueryAsReaderAPI();
        }
        return _instance;
    }

    public override function retrieveData(mapping : Map<String, String>, callback : String->com.sdtk.table.DataTableReader->Void) : Void {
        mapping = normalizeMapping(mapping);
        ChatGPTAPI.instance().queryAsReader(callback, cast mapping["query"]);
    } 
}

@:nativeGen
class ChatGPTQueryAsReaderWithDataAPI extends ExecutorAPI {
    private static var _instance : ExecutorAPI;

    private function new() {
        super("Large Language Model - ChatGPT - Process");
    }

    public static function instance() : ExecutorAPI {
        if (_instance == null) {
            _instance = new ChatGPTQueryAsReaderWithDataAPI();
        }
        return _instance;
    }

    public override function acceptedFormat() : String {
        return "plain/text";
    }

    public override function keywords() : Array<String> {
        return null;
    }     

    public override function execute(script : String, mapping : Map<String, String>, readers : Map<String, com.sdtk.table.DataTableReader>, callback : Dynamic->Void) : Void {
        mapping = cast com.sdtk.std.Normalize.nativeToHaxe(mapping);
        readers = cast com.sdtk.std.Normalize.nativeToHaxe(readers);
        var init : String = "";
        if (mapping != null) {
            for (i in mapping.keys()) {
                init += "Given the following data, referred to as \"" + i + "\", in JSON format.\n\n" + haxe.Json.stringify(mappingValueToType(mapping[i])) + "\n\n";
            }
        }
        if (readers != null) {
            for (i in readers.keys()) {
                var writer : com.sdtk.std.StringWriter = new com.sdtk.std.StringWriter(null);
                readers[i].convertTo(com.sdtk.table.KeyValueWriter.createJSONWriter(writer));
                init += "Given the following data, referred to as \"" + i + "\", in JSON format.\n\n" + writer.toString() + "\n\n";
            }
        }
        ChatGPTAPI.instance().queryAsReader(function (data : String, reader : com.sdtk.table.DataTableReader) : Void {
            callback(reader);
        }, init + script);
    }

    private override function startInit(callback : Void->Void) : Void {
        callback();
    }
}

@:nativeGen
class ChatGPTQueryWithDataAPI extends API {
    private static var _instance : ChatGPTQueryWithDataAPI;

    private function new() {
        super("Large Language Model - ChatGPT - Narrative");
    }

    public static function instance() : ChatGPTQueryWithDataAPI {
        if (_instance == null) {
            _instance = new ChatGPTQueryWithDataAPI();
        }
        return _instance;
    }

    public function acceptedFormat() : String {
        return "plain/text";
    }

    public function keywords() : Array<String> {
        return null;
    }     

    public function execute(script : String, mapping : Map<String, String>, readers : Map<String, com.sdtk.table.DataTableReader>, callback : String->Void) : Void {
        mapping = cast com.sdtk.std.Normalize.nativeToHaxe(mapping);
        readers = cast com.sdtk.std.Normalize.nativeToHaxe(readers);
        var init : String = "";
        if (mapping != null) {
            for (i in mapping.keys()) {
                init += "Given the following data, referred to as \"" + i + "\", in JSON format.\n\n" + haxe.Json.stringify(mappingValueToType(mapping[i])) + "\n\n";
            }
        }
        if (readers != null) {
            for (i in readers.keys()) {
                var writer : com.sdtk.std.StringWriter = new com.sdtk.std.StringWriter(null);
                readers[i].convertTo(com.sdtk.table.KeyValueWriter.createJSONWriter(writer));
                init += "Given the following data, referred to as \"" + i + "\", in JSON format.\n\n" + writer.toString() + "\n\n";
            }
        }
        ChatGPTAPI.instance().query(function (data : String) : Void {
            callback(data);
        }, init + script);
    }

    private override function startInit(callback : Void->Void) : Void {
        callback();
    }
}
#end

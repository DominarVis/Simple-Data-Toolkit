/*
    Copyright (C) 2019 Vis LLC - All Rights Reserved

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
    Simple Table Converter (STC) - Source code can be found in Converter.hx in Haxe on SourceForge.net
*/

package com.sdtk.proxy;

#if(!LUA_TI && !EXCLUDE_PROXY)
import com.sdtk.std.StdinReader;
import com.sdtk.std.StdinReader;
import com.sdtk.table.DataTableReader;
import com.sdtk.std.StdoutWriter;
import com.sdtk.table.KeyValueWriter;
import com.sdtk.table.DatabaseReaderOptions;
import com.sdtk.table.DatabaseReaderLoginOptions;


@:expose
@:nativeGen
class Proxy {
  public static function proxy(obj : Dynamic) {
    var db : DatabaseReaderLoginOptions = (new DatabaseReaderOptions()).database(obj.connector);
    if (obj.user != null) {
        db.user(obj.user);
    }
    if (obj.password != null) {
        db.password(obj.password);
    }
    if (obj.account != null) {
        db.account(obj.account);
    }
    if (obj.warehouse != null) {
        db.warehouse(obj.warehouse);
    }
    if (obj.role != null) {
        db.role(obj.role);
    }
    if (obj.database != null) {
        db.database(obj.database);
    }
    if (obj.schema != null) {
        db.schema(obj.schema);
    }
    if (obj.host != null) {
        db.host(obj.host);
    }
    if (obj.file != null) {
        db.file(obj.file);
    }
    if (obj.driver != null) {
        db.driver(obj.driver);
    }    
    if (obj.size != null) {
        db.size(obj.size);
    }   
    db.queryForReader(obj.query, obj.params, function (reader : DataTableReader) : Void {
        reader.convertTo(KeyValueWriter.createJSONWriter(new StdoutWriter()));
    });
  }

  private static function getURL(url : String) : String {
    #if php
        var data : Dynamic = cast php.Syntax.code("file_get_contents({0}, false)", url);
        if (data == false) {
            return null;
        } else {
            return cast data;
        }
    #else
        return null;
    #end
  }

  private static function getGoogleEmail(token : String) : String {
    return getURL("http://www.googleapis.com/oauth2/v1/userinfo?access_token=" + token);
  }

  private static function requestVariable(v : String) : String {
    #if php
        var get : String = null;
        var cookie : String = null;
        var post : String = null;
        var put : String = null;
        try {
            get = cast php.Syntax.code("$_GET[{0}]", v);
        } catch (ex) { }
        try {
            cookie = cast php.Syntax.code("$_COOKIE[{0}]", v);
        } catch (ex) { }
        try {
            post = cast php.Syntax.code("$_POST[{0}]", v);
        } catch (ex) { }
        try {
            put = cast php.Syntax.code("$_PUT[{0}]", v);
        } catch (ex) { }

        if (get != null && get != "") {
            return get;
        } else if (post != null && post != "") {
            return post;
        } else if (put != null && put != "") {
            return put;
        } else if (cookie != null && cookie != "") {
            return cookie;
        } else {
            return null;
        }
    #else
        return null;
    #end
  }

  private static var checkForLogin : Bool = true;
  private static var verifyLogin : Bool = true;

  public static function main() : Void {
    var data : String = "";

    if (checkForLogin) {
        var accessToken : String = requestVariable("access_token");
        var email : String = null;
        if (verifyLogin) {
            switch (requestVariable("access_token_type")) {
                case "google":
                    email = getGoogleEmail(accessToken);
            }
        } else {
            email = requestVariable("access_email");
        }
        if (email == null) {
            return;
        }
    }

    try {
        var reader : StdinReader = new StdinReader();
        while (reader.hasNext()) {
            data += reader.next();
        }
    } catch (ex : Any) {
    } 

    data = StringTools.trim(data);
    if (data.length > 0) {
        var obj : Dynamic = com.sdtk.std.Normalize.parseJson(data);
        data = null;
        proxy(obj);
    }
  }
}
#end
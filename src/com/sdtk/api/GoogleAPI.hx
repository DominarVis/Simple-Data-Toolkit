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
class GoogleAPI extends API {
    private static var _clientId : String = "<GOOGLE_CLIENT_ID>";
    private static var _apiKey : String = "<GOOGLE_API_KEY>";
    private static var _appScope : String = "https://www.googleapis.com/auth/userinfo.email";
    private static var _dataScope : String = "https://www.googleapis.com/auth/drive";
    private static var _idScope : String = "https://www.googleapis.com/auth/userinfo.email";
    private static var _sendEmailScope : String = "https://www.googleapis.com/auth/gmail.compose"; //https://www.googleapis.com/auth/gmail.send";
    private static var _readEmailScope : String = "https://www.googleapis.com/auth/gmail.readonly";
    private static var _pickerScope : String = "";
    private static var _discovery : String = "https://www.googleapis.com/discovery/v1/apis/drive/v3/rest";
    private static var _fileAPI : String = "drive/v3/files";
    private static var _uploadAPI : String = "upload/drive/v3/files";
    //https://developers.google.com/drive/api/v3/reference/changes/list
    private static var _changesAPI : String = "drive/v3/changes";
    //https://developers.google.com/drive/api/v3/reference
    private static var _permissionsAPI : String = "drive/v3/files/{fileId}/permissions";
    private static var _gmailSendAPI : String = "v1/users/me/messages/send";
    private static var _gmailListAPI : String = "v1/users/me/messages";
    private static var _gmailGetAPI : String = "v1/users/me/messages";
    private static var _gmailAttachmentAPI : String = "gmail/v1/users/me";
    private static var _mainRoot : String = "www.googleapis.com";
    private static var _contentRoot : String = "content.googleapis.com";
    private static var _gmailRoot : String = "gmail.googleapis.com";
    private static var _instance : GoogleAPI;

    private var _currentScope : String = null;
    private var _loggedIn : Bool = false;
    private var _token : String = null;
    private var _email : String = null;

    private function new() {
        super("Google");
    }

    private static function instance() : GoogleAPI {
        if (_instance == null) {
            _instance = new GoogleAPI();
        }
        return _instance;
    }    

    public static function isWorking() : Bool {
        return instance()._token != null;
    }

    public static function hasScope(scope : String) : Bool {
        return instance()._currentScope.indexOf(scope) >= 0;
    }

    public static function dataScope() : String {
        return _dataScope;
    }

    private override function getKey() : String {
        return _apiKey;
    }

    private override function getAccessToken() : String {
        return _token;
    }

    public static function setAccessToken(token : String) : Void {
        instance()._token = token;
    }
    
    public static function setEmail(email : String) : Void {
        instance()._email = email;
    }

    public static function createAppFile(name : String, data : String, callback : Dynamic->Void) : Void {
        var metadata : Dynamic = { name: name, 'parents': ['appDataFolder'] };
        #if JS_BROWSER
            var form : js.html.FormData = new js.html.FormData();
            form.append('metadata', new js.html.Blob([haxe.Json.stringify(metadata)], { type: 'application/json' }));
            form.append('file', data);
        #else // TODO - Confirm more than if(php || python)
            var form : Dynamic = "--divider--sdtk--\nContent-Type: application/json; charset=UTF-8\n\n" + haxe.Json.stringify(metadata) + "\n\n--divider--sdtk--\n\nContent-Type: application/octet\n\n" + data + "\n\n--divider--sdtk--\n";
            "Content-Type: multipart/related; boundary=--divider--sdtk--";
        #end

        instance().fetch("POST", GoogleAPI._mainRoot, GoogleAPI._uploadAPI, false, true, "?uploadType=multipart", cast form, callback);
    }

    public static function createFile(name : String, data : String, callback : Dynamic->Void) : Void {
        var metadata : Dynamic = { name: name };
        #if js
            var form = new js.html.FormData();
            form.append('metadata', new js.html.Blob([haxe.Json.stringify(metadata)], { type: 'application/json' }));
            form.append('file', data);
            #else // TODO - Confirm more than if(php || python)
            var form : Dynamic = "--divider--sdtk--\nContent-Type: application/json; charset=UTF-8\n\n" + haxe.Json.stringify(metadata) + "\n\n--divider--sdtk--\n\nContent-Type: application/octet\n\n" + data + "\n\n--divider--sdtk--\n";
        #end

        instance().fetch("POST", GoogleAPI._mainRoot, GoogleAPI._uploadAPI, false, true, "?uploadType=multipart", cast form, callback);
    }

    public static function updateAppFile(id : String, data : String, callback : Dynamic->Void) : Void {
        instance().fetch("PATCH", GoogleAPI._mainRoot, GoogleAPI._uploadAPI, false, true, "/" + id + "?uploadType=media", data, callback);
    }
    
    public static function getAppFileId(name : String, callback : Dynamic->Void) : Void {
        var path : Array<String> = name.split("/");
        name = path[path.length - 1];
        instance().fetch("GET", GoogleAPI._contentRoot, GoogleAPI._fileAPI, true, true, "?q=name%20%3D%20%27" + name + "%27&spaces=appDataFolder&fields=files(id%2C%20name)", null, callback);
    }

    public static function readAppFileI(id : String, callback : Dynamic->Void) : Void {
        instance().fetch("GET", GoogleAPI._contentRoot, GoogleAPI._fileAPI, true, true, "/" + id + "?alt=media", null, callback);
    }

    public static function readAppFile(name : String, callback : Dynamic->Void) : Void {
        GoogleAPI.getAppFileId(name, function (id : Dynamic) {
            GoogleAPI.readAppFileI(cast id, callback);
        });
    }

    public static function listAppFiles(callback : Dynamic->Void) : Void {
        instance().fetch("GET", GoogleAPI._mainRoot, GoogleAPI._fileAPI, true, true, "?spaces=appDataFolder&fields=files(name)", null, callback);
    }
    
    public static function listFiles(callback : Dynamic->Void) : Void {
        instance().fetch("GET", GoogleAPI._mainRoot, GoogleAPI._fileAPI, true, true, "?fields=files(name)", null, callback);
    }
    
    private static function deleteAppFileI(id : String, callback : Dynamic->Void) : Void {
        instance().fetch("DELETE", GoogleAPI._contentRoot, GoogleAPI._fileAPI, true, true, "/" + id, null, callback);
    }
    
    public static function deleteAppFile(name : String, callback : Dynamic->Void) : Void {
        GoogleAPI.getAppFileId(name, function (id : Dynamic) {
            GoogleAPI.deleteAppFileI(cast id, callback);
        });
    }

    private static function renameAppFileI(id : String, newName : String, callback : Dynamic->Void) : Void {
        instance().fetch("PATCH", GoogleAPI._mainRoot, GoogleAPI._fileAPI, true, true, "/" + id, haxe.Json.stringify({title: newName}), callback);
    }

    public static function renameAppFile(oldName : String, newName : String, callback : Dynamic->Void) : Void {
        GoogleAPI.getAppFileId(oldName, function (id : Dynamic) {
            GoogleAPI.renameAppFileI(cast id, newName, callback);
        });
    }

    private static function encode(s : String) : Dynamic {
        #if js
            return js.Browser.window.btoa(s);
        #elseif php
            return php.Syntax.code("base64_encode({0})", s);
        #elseif python
            python.Syntax.code("import base64");
            return python.Syntax.code("base64.b64encode({0})", s);
        #elseif java
            var s2 : java.NativeString = cast s;
            return java.util.Base64.getEncoder().encodeToString(s2.getBytes());
        #elseif cs
            return cs.Syntax.code("System.Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes({0}))", s);
        #else
            return haxe.crypto.Base64.encode(haxe.io.Bytes.ofString(s));
        #end
    }

    public static function emailFile(to : String, subject : String, body : String, name : String, file : Dynamic, contentType : String, callback : Dynamic->Void) : Void {
        if (contentType == null) {
            contentType = "text-plain";
        }
        var encodedEmail : Dynamic;
        if (file == null) {
            encodedEmail = encode("To: " + to + "\r\nSubject: " + subject + "\r\nContent-Type: multipart/mixed; boundary=message\r\n--message\r\nContent-Type: text/plain; charset=UTF-8\r\n" + body + "\r\n--message");
        } else {
            encodedEmail = encode("To: " + to + "\r\nSubject: " + subject + "\r\nContent-Type: multipart/mixed; boundary=message\r\n--message\r\nContent-Type: text/plain; charset=UTF-8\r\n" + body + "\r\n--message\r\nContent-Type: " + contentType + "\r\nContent-Disposition: attachment; filename=" + name + "\r\nContent-Transfer-Encoding: base64\r\n" + encode(file) + "\r\n--message--");
        }
        instance().fetch("POST", GoogleAPI._gmailRoot, GoogleAPI._gmailSendAPI, true, true, "", haxe.Json.stringify({raw: encodedEmail}), callback);
    }

    public static function listEmails(query : String, callback : Dynamic->Void) : Void {
        instance().fetch("GET", GoogleAPI._gmailRoot, GoogleAPI._gmailListAPI, true, true, "?q=" + query, null, callback);
    }

    public static function getEmail(id : String, callback : Dynamic->Void) : Void {
        instance().fetch("GET", GoogleAPI._gmailRoot, GoogleAPI._gmailGetAPI, true, true, "/" + id, null, callback);
    }

    public static function getAttachment(id : String, attachmentId : String, callback : Dynamic->Void) : Void {
        instance().fetch("GET", GoogleAPI._gmailRoot, GoogleAPI._gmailAttachmentAPI, true, true, "/" + id + "/attachments/" + attachmentId, null, callback);
    }
}
#end
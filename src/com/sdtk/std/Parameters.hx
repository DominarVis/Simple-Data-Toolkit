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

#if !EXCLUDE_PARAMETERS
@:expose
@:nativeGen
class Parameters {
    private var _arguments : Array<String>;
    private static var _enableLogin : Bool = false;
    private static var _ldapHost : String = null;
    private static var _ldapPort : Int = 389;
    private static var _ldapBaseDN : String = null;
    private static var _ldapUsersDN : String = null;
    private static var _builtInUsers : Map<String, String> = null;
    private static var _loginPageTemplate : String = "<html><body><form method=\"post\"><table><tr><td><label for=\"user\">User: </label></td><td><input type=\"text\" id=\"user\" name=\"user\"></td></tr><tr><td><label for=\"password\">Password: </label></td><td><input type=\"password\" id=\"password\" name=\"password\"></td></tr><tr><td colspan=\"2\"><input type=\"submit\" value=\"Login\"></td></tr></table></form></body></html>";
    private static var _loginCommandLineTemplate : Array<String> = ["Enter user name: ", "Enter password: ", "Invalid login"];
    private static var _loginVariable : String = "REMOTE_USER"; // PHP_AUTH_USER, AUTH_USER
    private static var _loginPath : String = "/";

    private function getArguments() : Void {
      #if JS_BROWSER
        var eScripts : Array<com.sdtk.std.JS_BROWSER.Element> = com.sdtk.std.JS_BROWSER.Document.getElementsByTagName("script");
        var eScript : com.sdtk.std.JS_BROWSER.Element = eScripts[eScripts.length - 1];
        var sScript : String = eScript.src;
        var regexp : EReg = ~/&|#/ig;
        sScript = regexp.replace(sScript, "?");
        var sArguments : Array<String> = sScript.split("?");
        if (sArguments.length <= 1) {
          return;
        }
        sArguments.shift();
        _arguments = sArguments;
      #elseif JS_WSH
        var sArguments : Array<String> = new Array<String>();
        var iArgument : Int = 0;
        while (true) {
            var sArgument : Null<String> = null;
            try {
              sArgument = JS_WSH.WScript.Arguments(iArgument);
            } catch (msg : Dynamic) {
            }
            if (sArgument != null) {
              sArguments.push(sArgument);
              iArgument++;
            } else {
              break;
            }
        }
        _arguments = sArguments;
      #else
        _arguments = Sys.args();
      #end
    }

    public function getParameter(i : Int) : Null<String> {
      try {
        return _arguments[i];
      } catch (msg : Dynamic) {
        return null;
      }
    }

    public function length() : Int {
      return _arguments.length;
    }

    public function isCGI() : Bool {
      #if(JS_BROWSER || JS_SNOWFLAKE)
        return false;
      #elseif JS_NODE
        return js.Syntax.code("process.env.GATEWAY_INTERFACE") != null;
      #elseif JS_WSH
        var sh : Dynamic = js.Syntax.code("WScript.CreateObject(\"WScript.Shell\")");
        var v : Dynamic = js.Syntax.code("{0}.ExpandEnvironmentStrings(\"%GATEWAY_INTERFACE%\")", sh);
        return v != null;
      #else
        return Sys.environment().get("GATEWAY_INTERFACE") != null;
      #end
    }

    public function isWindows() : Bool {
      #if JS_BROWSER
        return js.Browser.window.navigator.userAgent.toUpperCase().indexOf("WIN") >= 0;
      #elseif JS_SNOWFLAKE
        return false;
      #elseif JS_NODE
        return cast js.Syntax.code("process.platform.toUpperCase().indexOf(\"WIN\") >= 0");
      #elseif JS_WSH
        return true;
      #else
        return Sys.systemName().toUpperCase().indexOf("WIN") >= 0;
      #end
    }

    private function checkLoginLDAP(user : String, password : String) : Bool {
      var un : String;
      if (_ldapBaseDN != null && _ldapUsersDN != null) {
        un = "uid=" + user + "," + _ldapUsersDN + "," + _ldapBaseDN;
      } else {
        un = user;
      }
      #if cs
        var pc : PrincipalContext = new PrincipalContext(ContextType.Machine, _ldapHost + ":" + _ldapPort);
        var r : Bool = pc.ValidateCredentials(un, password);
        pc.Dispose();
        return r;
      #elseif php
        var connect : Dynamic = php.Syntax.code("ldap_connect({0}, {1})", _ldapHost, _ldapPort);
        return cast php.Syntax.code("ldap_bind({0}, {1}, {2})", connect, un, password);
      #elseif python
        python.Syntax.code("import ldap");
        var connect : Dynamic = python.Syntax.code("ldap.initialize({0})", "ldap://" + _ldapHost + ":" + _ldapPort);
        python.Syntax.code("{0}.simple_bind_s({1}, {2})", connect, un, password);
        return false;
      #elseif JS_NODE
        // TODO
        return false;
      #elseif JS_WSH
        // TODO - Double check
        var connect = js.Syntax.code("WScript.CreateObject(\"ADODB.Connection\")");
        js.Syntax.code("{0}.Provider = \"ADsDSOObject\"", connect);
        js.Syntax.code("{0}.Properties(\"User ID\") = {1}", connect, un);
        js.Syntax.code("{0}.Properties(\"Password\") = {1}", connect, password);
        js.Syntax.code("{0}.Properties(\"Encrypt Password\") = true", connect);
        js.Syntax.code("{0}.Open(\"Active Directory Provider\")", connect);
        var rs = js.Syntax.code("{0}.Execute(\"SELECT * FROM 'LDAP://{1}'\")", connect, (_ldapHost + ":" + _ldapPort));
        var r = js.Syntax.code("{0}.EOF", rs);
        js.Syntax.code("{0}.Close()", rs);
        js.Syntax.code("{0}.Close()", connect);
        return r;
      #else
        return false;
      #end
  }

    private function checkLogin(user : String, password : String) : Bool {
      if (_ldapHost != null) {
        return checkLoginLDAP(user, password);
      } else if (_builtInUsers != null) {
        var p : String = _builtInUsers.get(user);
        if (p == null) {
          return false;
        } else {
          return p == password;
        }
      } else {
        return false;
      }
    }

    private function checkLoginVariable() : Bool {
      #if sys
        return Sys.environment().get(_loginVariable) != null;
      #else
        return false;
      #end
    }

    private function redirectToLogin() : Void {
      #if JS_BROWSER
        js.Browser.window.location.href = _loginPath;
      #elseif php
        php.Syntax.code("header(\"Location: \" + {0})", _loginPath);
      #else
        var w : Writer = new StdoutWriter();
        w.write("Location: " + _loginPath);
        w.write("\n\n");
        w.dispose();
      #end
    }

    private function checkLoginPost() : Bool {
      #if JS_BROWSER
        return false;
      #elseif php
        return checkLogin(php.Syntax.code("$_POST[\"user\"]"), php.Syntax.code("$_POST[\"password\"]"));
      #else
        var r : Reader = new StdinReader();
        var value : StringBuf = new StringBuf();
        while(true) {
          var s : String = r.next();
          if (s == null) {
            break;
          }
          value.add(s);
        }
        r.dispose();
        r = null;
        var arr : Array<String> = value.toString().split("&");
        arr[0] = arr[0].split("=")[1];
        arr[1] = arr[1].split("=")[1];
        return checkLogin(StringTools.urlDecode(arr[0]), StringTools.urlDecode(arr[1]));
      #end
    }

    public function validLogin() : Bool {
      if (!_enableLogin) {
        return true;
      }
      if (isCGI()) {
        if (checkLoginVariable()) {
          return true;
        } else if (_loginPath != null) {
          redirectToLogin();
          return false;
        } else if (checkLoginPost()) {
          return true;
        } else {
          var w : Writer = new StdoutWriter();
          w.write(_loginPageTemplate);
          w.dispose();
          return false;
        }
      } else {
        var w : Writer = new StdoutWriter();
        w.write(_loginCommandLineTemplate[0]);
        w.flush();
        var r : Reader = (new StdinReader()).switchToLineReader();
        var user : String = r.next();
        w.write(_loginCommandLineTemplate[1]);
        w.flush();
        var password : String = r.next();
        var valid : Bool = checkLogin(user, password);
        if (!valid) {
          w.write(_loginCommandLineTemplate[2]);
        }
        w.dispose();
        r.dispose();
        return valid;
      }
      return false;
    }

    public function new() {
        getArguments();
    }
}
#end

#if cs
@:native('System.DirectoryServices.AccountManagement.ContextType') extern enum ContextType {
  Machine;
  Domain;
  ApplicationDirectory;
}

@:native('System.DirectoryServices.AccountManagement.PrincipalContext') extern class PrincipalContext {
  public function new(contextType : ContextType, name : String);
  public function ValidateCredentials(userName : String, password : String) : Bool;
  public function Dispose() : Void;
}
#end
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

// Add Sync Reader
// Add Sync Writer
// Add Async Reader
// Add Async Writer
// TODO Read resources
// TODO Read user files
// TODO STDOUT

#if JS_BROWSER
@:native('HTMLElement') extern class Element {
  public function appendChild(eChild : Element) : Void;
  public function getAttribute(sName : String) : String;
  public function setAttribute(sName : String, sValue : String) : Void;
  public var firstElementChild : Element;
  public var innerHTML : String;
  public var innerText : String;
  public var nextElementSibling : Element;
  public var src : String;
  public var tagName : String;
  public var value : String;
}

@native('document') extern class Document {
  public static function createElement(sTag : String) : Element;
  public static function getElementById(sId : String) : Element;
  public static function getElementsByTagName(sTag : String) : Array<Element>;
  public static function getElementsByClassName(sClassName : String) : Array<Element>;
}

@native('console') extern class Console {
  public static function log(s : String) : Void;
}

@native('console') extern class MutableConsole {
  public static var log : Dynamic;
}

@native('window') extern class Window {
  public static function alert(s : String) : Void;
}

@:nativeGen
extern class XMLHttpRequest {
  public function new();
  public var onerror : Dynamic;
  public var onreadystatechange : Dynamic;
  public var onload : Dynamic;
  public var readyState : Int;
  public var responseText : String;
  public var status : Int;
  public function open(sMethod : String, sURL : String, bAsync : Bool) : Void;
  public function send(oParam : Dynamic) : Void;
}
#end
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

package com.sdtk.table;

@:nativeGen
class DirectoryInfo {
  private var _drive : Null<String> = null;
  private var _label : String;
  private var _serial : String;
  private var _path : String;
  private var _name : String;
  private var _size : Int = 0;
  private var _count : Int = 0;

  public function new () {}

  public function setDrive(sDrive : String) : Void {
    _drive = sDrive;
  }

  public function setLabel(sLabel : String) : Void {
    _label = sLabel;
  }

  public function setSerial(sSerial : String) : Void {
    _serial = sSerial;
  }

  public function setFullPath(sPath : String) : Void {
    _path = sPath;
  }

  public function setName(sName : String) : Void {
    _name = sName;
  }

  public function addFile(fiInfo : FileInfo) : Void {
    _size += fiInfo.getSize();
    _count++;
  }

  public function getDrive() : String {
    return _drive;
  }

  public function getLabel() : String {
    return _label;
  }

  public function getSerial() : String {
    return _serial;
  }

  public function getFullPath() : String {
    return _path;
  }

  public function getName() : String {
    return _name;
  }

  public function getCount() : Int {
    return _count;
  }

  public function getSize() : Int {
    return _size;
  }
}
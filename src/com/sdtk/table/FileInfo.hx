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

import com.sdtk.std.*;

@:nativeGen
class FileInfo {
  private var _parent : Null<DirectoryInfo> = null;
  private var _name : Null<String> = null;
  private var _trueName : Null<String> = null;
  private var _shortName : Null<String> = null;
  private var _owner : Null<String> = null;
  private var _size : Int = 0;
  private var _type : Int = 0;
  private var _time : Int = 0;
  private var _date : Date;

  private static var IS_DIRECTORY = 1;
  private static var IS_JUNCTION = 2;

  public function new () {}

  public function getDirectoryInfo() : Null<DirectoryInfo> {
    return _parent;
  }

  public function getDirectory() : String {
    return _parent.getFullPath();
  }

  public function setDirectory(sDirectory : String) : Void {
    _parent.setFullPath(sDirectory);
  }

  public function setDirectoryInfo(diParent : Null<DirectoryInfo>) {
      _parent = diParent;
  }

  public function setDrive(sDrive : String) : Void {
    _parent.setDrive(sDrive);
  }

  public function setLabel(sLabel : String) : Void {
    _parent.setLabel(sLabel);
  }

  public function setSerial(sSerial : String) : Void {
    _parent.setSerial(sSerial);
  }

  public function setFullPath(sPath : String) : Void {
    var iEnd : Int = sPath.lastIndexOf("\\");
    _parent.setName(sPath.substr(iEnd));
    _name = sPath.substr(iEnd + 1);
  }

  public function setName(sName : String) : Void {
    _name = sName;
  }

  public function addFile(fiInfo : FileInfo) : Void {
    _parent.addFile(fiInfo);
  }

  public function getDrive() : String {
    return getDirectoryInfo().getDrive();
  }

  public function getLabel() : String {
    return getDirectoryInfo().getLabel();
  }

  public function getSerial() : String {
    return getDirectoryInfo().getSerial();
  }

  public function getFullPath() : String {
    return getDirectoryInfo().getFullPath + "\\" + getName();
  }

  public function getName() : String {
    return _name;
  }

  public function getCount() : Int {
    return getDirectoryInfo().getCount();
  }

  public function getDate() : Date {
    return _date;
  }

  public function getTime() : Int {
    return _time;
  }

  public function getIsDirectory() : Bool {
    return (_type & IS_DIRECTORY == IS_DIRECTORY);
  }

  public function getIsJunction() : Bool {
    return (_type & IS_JUNCTION == IS_JUNCTION);
  }

  private function MergeDateTime() : Void {

  }

  public function setTrueName(sTrueName : String) : Void {
    _trueName = sTrueName;
  }

  public function getTrueName() : String {
    return _trueName;
  }

  public function setShortName(sShortName : String) : Void {
    _shortName = sShortName;
  }

  public function getShortName() : String {
    return _shortName;
  }

  public function setOwner(sOwner : String) : Void {
    _owner = sOwner;
  }

  public function getOwner() : String {
    return _owner;
  }

  public function setDate(dDate : Date) : Void {
    _date = dDate;
    MergeDateTime();
  }

  public function setTime(iTime : Int) : Void {
    _time = iTime;
    MergeDateTime();
  }

  public function setSize(iSize : Int) : Void {
    _size = iSize;
  }

  public function getSize() : Int {
    return _size;
  }

  public function setIsDirectory(bIsDirectory : Bool) : Void {
    _type = bIsDirectory ? (_type | IS_DIRECTORY) : (_type & (-1 ^ IS_DIRECTORY));
  }

  public function setIsJunction(bIsJunction : Bool) : Void {
    _type = bIsJunction ? (_type | IS_JUNCTION) : (_type & (-1 ^ IS_JUNCTION));
  }
}

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
class CMDDirHandler implements FileSystemHandler {
  private var _volumeInDrive : String = " Volume in drive ";
  private var _is : String = " is ";
  private var _serial : String = " Volume Serial Number is ";
  private var _directoryOf : String = " Directory of ";
  private var _firstEntry : String = " .";
  private var _secondEntry : String = " ..";
  private var _timeSeparator : String = "  ";
  private var _dtSeparator : String = "    ";
  private var _dirIndicator : String = "<DIR>";
  private var _dirIndicator2 : String = "         ";
  private var _junctionIndicator : String = "<JUNCTION>";
  private var _junctionIndicator2 : String = "    ";
  private var _noDirIndicator : String = "     ";
  private var _directorySeparator : String = "\\";
  private var _endOfEntry : String = "\n";
  private var _endOfSection : String = "\n\n";
  private var _startOfSection : String = " ";
  private var _driveIndicator : String = ":";
  private var _timeIndicator : String = ":";
  private var _dateIndicator : String = "/";
  private var _numberSeparator : String = ",";
  private var _space : String = " ";
  private var _trueNameStart : String = "[";
  private var _trueNameEnd : String = "]";
  private var _footerFiles : String = " File(s) ";
  private var _footerDirs : String = " Dir(s)  ";
  private var _footerSize : String = "  bytes";
  private var _total : String = "     Total Files Listed:";
  private var _footerFreeSpace : String = " bytes free";
  private var _zero : String = "0";
  private var _tilde : String = "~";
  private var _extension : String = ".";

  public static var OPTION_BARE : Int = 1;
  public static var OPTION_FULL_PATH : Int = 2;
  public static var OPTION_SHORT_NAME : Int = 4;
  public static var OPTION_OWNER_NAME : Int = 8;
  public static var OPTION_TRUE_NAME : Int = 16;
  public static var OPTION_COMMAS : Int = 32;
  public static var OPTION_LOWER_CASE_NAMES : Int = 64;

  public var _NAME : Int = 2;

  private function new() {
  }

  private static var _instance : FileSystemHandler;

  public static function instance() : FileSystemHandler {
    if (_instance == null) {
        _instance = new CMDDirHandler();
    }
    return _instance;
  }  

  private function convertFromDateTime(dDate : Date) : String {
    var iHours : Int = dDate.getHours();
    return Std.string(dDate.getMonth() - 1) + "/" + Std.string(dDate.getDate()) + "/" + Std.string(dDate.getFullYear()) + " " + (iHours == 0 || iHours == 12 ? 12 : iHours % 12)  + ":" + Std.string(dDate.getMinutes()) + " " + (iHours < 12 ? "AM" : "PM");
  }

  private function convertToDate(sDate : String) : Date {
    var iMonth : Int = Std.parseInt(sDate.substr(0, 2));
    var iDay : Int  = Std.parseInt(sDate.substr(2, 2));
    var iYear : Int  = Std.parseInt(sDate.substr(4, 4));
    return new Date(iYear, iMonth - 1, iDay, 0, 0, 0);
  }

  private function convertToTime(sTime : String) : Int {
    var iHours : Int = Std.parseInt(sTime.substr(0, 2));
    if (sTime.substr(4, 2).toLowerCase() == "pm") {
      if (iHours < 12) {
        iHours += 12;
      }
    } else if (iHours == 12) {
      iHours = 0;
    }
    var iMinutes : Int =  iHours * 60 + Std.parseInt(sTime.substr(2, 2));
    return iMinutes * 60 * 1000;
  }

  private function convertToSize(sSize : String) : Int {
    return Std.parseInt(StringTools.replace(StringTools.replace(sSize, _numberSeparator, ""), _space, ""));
  }

  private function convertFromSize(iSize : Int, iOptions : Int) : String {
    if (iSize <= 0) {
      return _zero;
    } else if (iSize < 1000) {
      return Std.string(iSize);
    } else if (iOptions & OPTION_COMMAS != 0) {
      var sParts : Array<String> = new Array<String>();
      while (iSize > 0) {
        var iPart : Int = iSize % 1000;
        iSize = Std.int(iSize / 1000);
        sParts.push(Std.string(iPart));
      }
      sParts.reverse();
      return sParts.join(_numberSeparator);
    } else {
      return Std.string(iSize);
    }
  }

  private function convertFromCount(iCount : Int) : String {
    return Std.string(iCount);
  }

  private function displayFooter(wWriter : Writer, diInfo : DirectoryInfo, iOptions : Int, tiTally : TallyInfo) : Void {
    var iCount : Int = diInfo.getCount();
    var iSize : Int = diInfo.getSize();
    wWriter.write(convertFromCount(iCount));
    wWriter.write(_footerFiles);
    wWriter.write(convertFromSize(iSize, iOptions));
    wWriter.write(_footerSize);
    wWriter.write(_endOfSection);
    tiTally.add(iCount, iSize);
  }

  public function write(wWriter : Writer, fiPrevious : Null<FileInfo>, fiCurrent : Null<FileInfo>, iOptions : Int, tiTally : TallyInfo) : Void {
    if (iOptions & OPTION_BARE == OPTION_BARE) {
      wWriter.write(fiCurrent.getName());
      wWriter.write(_endOfEntry);
    } else if (iOptions & OPTION_FULL_PATH == OPTION_FULL_PATH) {
      wWriter.write(fiCurrent.getFullPath());
      wWriter.write(_endOfEntry);
    } else {
      if (fiCurrent == null) {
        displayFooter(wWriter, fiPrevious.getDirectoryInfo(), iOptions, tiTally);
        if (tiTally.getNumberOfEntries() > 1) {
          wWriter.write(_total);
          wWriter.write(_endOfEntry);
          wWriter.write(convertFromCount(tiTally.getFileCount()));
          wWriter.write(_footerFiles);
          wWriter.write(convertFromSize(tiTally.getFileSize(), iOptions));
          wWriter.write(_footerSize);
          wWriter.write(_endOfEntry);
          wWriter.write(convertFromCount(tiTally.getNumberOfEntries()));
          wWriter.write(_footerDirs);
          try {
            wWriter.write(convertFromSize(tiTally.getFreeSpace(), iOptions));
            wWriter.write(_footerFreeSpace);
          } catch (ex : Dynamic) {
          }
          wWriter.write(_endOfSection);
        }
      } else if (fiPrevious == null || fiPrevious.getDrive() != fiCurrent.getDrive()) {
        if (fiPrevious != null) {
          displayFooter(wWriter, fiPrevious.getDirectoryInfo(), iOptions, tiTally);
        }
        wWriter.write(_volumeInDrive);
        wWriter.write(fiCurrent.getDrive());
        wWriter.write(_is);
        wWriter.write(fiCurrent.getLabel());
        wWriter.write(_endOfEntry);
        wWriter.write(_serial);
        wWriter.write(fiCurrent.getSerial());
        wWriter.write(_endOfSection);
        wWriter.write(_directoryOf);
        wWriter.write(fiCurrent.getDirectory());
        wWriter.write(_endOfSection);
      } else if (fiPrevious.getDirectory() != fiCurrent.getDirectory()) {
        wWriter.write(_directoryOf);
        wWriter.write(fiCurrent.getDirectory());
        wWriter.write(_endOfSection);
      }
      wWriter.write(convertFromDateTime(fiCurrent.getDate()));
      wWriter.write(_dtSeparator);
      if (fiCurrent.getIsDirectory()) {
        wWriter.write(_dirIndicator);
        wWriter.write(_dirIndicator2);
      } else if (fiCurrent.getIsJunction()) {
        wWriter.write(_junctionIndicator);
        wWriter.write(_junctionIndicator2);
      } else {
        wWriter.write(convertFromSize(fiCurrent.getSize(), iOptions));
        if (iOptions & OPTION_SHORT_NAME == OPTION_SHORT_NAME) {
          if (iOptions & OPTION_LOWER_CASE_NAMES == OPTION_LOWER_CASE_NAMES) {
            wWriter.write(fiCurrent.getShortName().toLowerCase());
          } else {
            wWriter.write(fiCurrent.getShortName());
          }
        }
        if (iOptions & OPTION_OWNER_NAME == OPTION_OWNER_NAME) {
          wWriter.write(fiCurrent.getOwner());
        }
        if (iOptions & OPTION_LOWER_CASE_NAMES == OPTION_LOWER_CASE_NAMES) {
          wWriter.write(fiCurrent.getName().toLowerCase());
        } else {
          wWriter.write(fiCurrent.getName());
        }
        if (iOptions & OPTION_TRUE_NAME == OPTION_TRUE_NAME) {
          var sTrueName : Null<String> = fiCurrent.getTrueName();
          if (sTrueName != null && sTrueName.length > 0) {
            wWriter.write(_trueNameStart);
            wWriter.write(sTrueName);
            wWriter.write(_trueNameEnd);
          }
        }
        wWriter.write(_endOfEntry);
      }
    }
  }

  public function next(rReader : Reader, fiPrevious : Null<FileInfo>) : Null<FileInfo> {
    rReader = rReader.switchToLineReader();
    var sLine : Null<String> = rReader.next();
    if (sLine != null) {
      var sCurrentDrive : Null<String> = null;
      var sCurrentLabel : Null<String> = null;
      var sCurrentSerial : Null<String> = null;
      var sCurrentDirectory : Null<String> = null;
      var bChanged : Bool = false;

      if (fiPrevious != null) {
        sCurrentDrive = fiPrevious.getDrive();
        sCurrentLabel = fiPrevious.getLabel();
        sCurrentSerial = fiPrevious.getSerial();
        sCurrentDirectory = fiPrevious.getDirectory();
      }

      while (!StringTools.startsWith(sLine, _startOfSection)) {
        if (StringTools.startsWith(sLine, _volumeInDrive)) {
          sLine = sLine.substr(0, _volumeInDrive.length);
          var iIs : Int = sLine.lastIndexOf(_is);
          sCurrentDrive = sLine.substr(0, iIs);
          sCurrentLabel = sLine.substr(iIs + _is.length);
          bChanged = true;
        } else if (StringTools.startsWith(sLine, _serial)) {
          sCurrentSerial = sLine.substr(_serial.length);
          bChanged = true;
        } else if (StringTools.startsWith(sLine, _directoryOf)) {
          sCurrentDirectory = sLine.substr(_directoryOf.length);
          bChanged = true;
        }
        sLine = rReader.next();
        if (sLine == null) {
          return null;
        }
      }

      while (StringTools.endsWith(sLine, _firstEntry) || StringTools.endsWith(sLine, _secondEntry)) {
        sLine = rReader.next();
        if (sLine == null) {
          return null;
        }
      }

      var fiNew : FileInfo = new FileInfo();

      // Starts with drive letter
      if (sLine.charAt(1) == _driveIndicator) {
        var iSeparator : Int = sLine.lastIndexOf(_directorySeparator);
        var sNewDrive = sLine.substr(0, 1);
        var sNewDirectory : String = sLine.substr(0, iSeparator);
        var diNew : DirectoryInfo;
        if (sCurrentDirectory != sNewDirectory || sCurrentDrive != sNewDrive) {
          diNew = new DirectoryInfo();
          diNew.setDrive(sNewDrive);
          diNew.setFullPath(sNewDirectory);
        } else {
          diNew = fiPrevious.getDirectoryInfo();
        }
        fiNew.setDirectoryInfo(diNew);
        fiNew.setName(sLine.substr(iSeparator + 1));
      }
      // Starts with filename
      else if (sLine.length < 27 || sLine.charAt(2) != _dateIndicator || sLine.charAt(5) != _dateIndicator || sLine.charAt(14) != _timeIndicator) {
        fiNew.setName(sLine);
      }
      // Full format
      else {
        var diNew : DirectoryInfo;
        if (bChanged) {
          diNew = new DirectoryInfo();
          diNew.setDrive(sCurrentDrive);
          diNew.setLabel(sCurrentLabel);
          diNew.setSerial(sCurrentSerial);
          diNew.setFullPath(sCurrentDirectory);
        } else if (fiPrevious != null) {
          diNew = fiPrevious.getDirectoryInfo();
        } else {
          diNew = new DirectoryInfo();
        }
        fiNew.setDirectoryInfo(diNew);
        var iSeparator : Int = sLine.indexOf(_timeSeparator);
        fiNew.setDate(convertToDate(sLine.substr(0, iSeparator)));
        sLine = sLine.substr(iSeparator + _timeSeparator.length);
        iSeparator = sLine.indexOf(_dtSeparator);
        fiNew.setTime(convertToTime(sLine.substr(0, iSeparator)));
        sLine = sLine.substr(iSeparator + _dtSeparator.length);
        if (StringTools.startsWith(sLine, _dirIndicator)) {
          fiNew.setIsDirectory(true);
          sLine = sLine.substr(_dirIndicator.length);
        } else if (StringTools.startsWith(sLine, _junctionIndicator)) {
          fiNew.setIsJunction(true);
          sLine = sLine.substr(_junctionIndicator.length);
        } else {
          sLine = StringTools.ltrim(sLine);
          iSeparator = sLine.indexOf(" ");
          fiNew.setSize(convertToSize(sLine.substring(0, iSeparator)));
          sLine = sLine.substring(iSeparator + 1);
          // True Path
          {
            var iTruePathLocation : Int = sLine.lastIndexOf(_driveIndicator);
            if (iTruePathLocation > 0) {
              iTruePathLocation -= 1;
              var iTruePathEnd = sLine.lastIndexOf(_trueNameEnd);
              if (iTruePathEnd < iTruePathLocation) {
                iTruePathEnd = sLine.length;
              }
              fiNew.setTrueName(sLine.substr(iTruePathLocation, iTruePathEnd - iTruePathLocation));
              sLine = sLine.substr(0, iTruePathLocation);
              if (StringTools.endsWith(sLine, _trueNameStart)) {
                sLine = sLine.substr(0, iTruePathLocation - 1);
              }
              sLine = StringTools.rtrim(sLine);
            }
          }
          // Short Name
          {
            var iEndOfFirstColumn = sLine.indexOf(_startOfSection);
            var iTilde = sLine.indexOf(_tilde);
            var iNameLength = sLine.indexOf(_extension);
            var iDirectory = sLine.indexOf(_directorySeparator);

            if (iEndOfFirstColumn > iTilde && iEndOfFirstColumn > iNameLength && iNameLength >= iTilde && (iDirectory < 0 || iDirectory > iEndOfFirstColumn)) {
              fiNew.setShortName(sLine.substr(0, iEndOfFirstColumn));
              sLine = sLine.substr(iEndOfFirstColumn + 1);
            }
          }
          // Owner
          {
            var sOwner = sLine.substr(0, 23);
            if (sOwner.indexOf(_directorySeparator) > 0) {
              sOwner = StringTools.rtrim(sOwner);
              fiNew.setOwner(sOwner);
              sLine = sLine.substr(23);
            }
          }
          // Standard File Name
          fiNew.setName(sLine);
        }
      }

      return fiNew;
    } else {
      return null;
    }
  }
}

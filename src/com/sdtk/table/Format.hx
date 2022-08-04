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

@:expose
@:nativeGen
enum Format {
  CSV;
  PSV;
  TSV;
  DIR;
  INI;
  JSON;
  PROPERTIES;
  SQL;
  Haxe;
  Python;
  Java;
  CSharp;
  SPLUNK;
  HTMLTable;
  ARRAY;
  MAP;
  ARRAYMAP;
  MAPARRAY;
  DB;
  RAW;
  TEX;
}

@:expose
@:nativeGen
class Formats {
  private function new() { }

  public static function CSV() : Format {
    return Format.CSV;
  }

  public static function PSV() : Format {
    return Format.PSV;
  }  

  public static function TSV() : Format {
    return Format.TSV;
  }

  public static function DIR() : Format {
    return Format.DIR;
  }  

  public static function INI() : Format {
    return Format.INI;
  }

  public static function JSON() : Format {
    return Format.JSON;
  }  

  public static function PROPERTIES() : Format {
    return Format.PROPERTIES;
  }

  public static function SQL() : Format {
    return Format.SQL;
  }

  public static function Haxe() : Format {
    return Format.Haxe;
  }

  public static function Python() : Format {
    return Format.Python;
  }

  public static function Java() : Format {
    return Format.Java;
  }

  public static function CSharp() : Format {
    return Format.CSharp;
  }

  public static function SPLUNK() : Format {
    return Format.SPLUNK;
  }

  public static function HTMLTable() : Format {
    return Format.HTMLTable;
  }

  public static function ARRAY() : Format {
    return Format.ARRAY;
  }

  public static function MAP() : Format {
    return Format.MAP;
  }  

  public static function ARRAYMAP() : Format {
    return Format.ARRAYMAP;
  }  

  public static function MAPARRAY() : Format {
    return Format.MAPARRAY;
  }  

  public static function DB() : Format {
    return Format.DB;
  }  

  public static function RAW() : Format {
    return Format.RAW;
  }  

  public static function TEX() : Format {
    return Format.TEX;
  }  
}
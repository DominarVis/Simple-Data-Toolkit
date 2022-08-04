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
    
*/

package com.sdtk.plugin;

public class GenericPlugin
#if java
    extends JEditPlugin
#end
{
    #if java
        public static var NAME : String = "quicknotepad";
        public static var OPTION_PREFIX : String = "options.quicknotepad.";    

        public override function createBrowserMenuItems() : JEditMenuItem {

        }

        public override function createMenuItems() : JEditMenuItem {

        }
    #end

    private function getMenuItems() : Map<String, Void->Void> {
        
    }
}
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

#if java
@:native('org.gjt.sp.jedit.EditPlugin') extern class JEditPlugin {
    public function createBrowserMenuItems() : JEditMenuItem;
    public function createMenuItems() : JEditMenuItem;
    public function getClassName() : String;
    public function	getPluginHome() : java.io.File;
    public static function getPluginHome(clazz : java.lang.Class<? extends EditPlugin>) : java.io.File;
    public static function getPluginHome(plugin : JEditPlugin) : java.io.File;
    public static function getPluginJAR() : PluginJAR;
    public static function getResourceAsOutputStream(clazz : java.lang.Class<? extends EditPlugin>, path : String) : java.io.OutputStream;
    public static function getResourceAsOutputStream(plugin : JEditPlugin, path : String) : java.io.OutputStream;
    public static function getResourceAsStream(clazz : java.lang.Class<? extends EditPlugin>, path : String) : java.io.InputStream;
    public static function getResourceAsStream(plugin : JEditPlugin, path : String) : java.io.InputStream;
    public static function getResourcePath(clazz : java.lang.Class<? extends EditPlugin>, path : String) : java.io.File;
    public static function getResourcePath(plugin : JEditPlugin, path : String) : java.io.File;
    public function start() : Void;
    public function stop() : Void;

    public function new();
}

@:native('org.gjt.sp.jedit.PluginJAR') extern class PluginJAR {
    // Intentionally left empty
}

@:native('java.awt.Component') extern class JEditComponent {

}

@:native('java.awt.event.ActionEvent') extern class JEditEvent {
    public actionPerformed(e : JEditEvent) : Void;
}


@:native('java.awt.event.ActionListener') extern interface JEditListener {
    public actionPerformed(e : JEditEvent) : Void;
}

@:native('javax.swing.JMenuItem') extern class JEditMenuItem extends JEditComponent {
    public function new(text : String);

    public add(comp : JEditComponent) : JEditComponent;
    public addActionListener(l : ) : Void;
}
#end
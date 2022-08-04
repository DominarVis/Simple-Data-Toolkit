/*
    Copyright (C) 2022 Vis LLC - All Rights Reserved

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
    JEdit Plugin
*/

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Font;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import javax.swing.JFileChooser;
import javax.swing.JPanel;
import javax.swing.JScrollPane;

import org.gjt.sp.jedit.EBComponent;
import org.gjt.sp.jedit.EBMessage;
import org.gjt.sp.jedit.EditBus;
import org.gjt.sp.jedit.GUIUtilities;
import org.gjt.sp.jedit.View;
import org.gjt.sp.jedit.jEdit;
import org.gjt.sp.jedit.gui.DefaultFocusComponent;
import org.gjt.sp.jedit.gui.DockableWindowManager;
import org.gjt.sp.jedit.msg.PropertiesChanged;
import org.gjt.sp.util.Log;
import org.gjt.sp.util.StandardUtilities;

public class SDTKJEdit extends JPanel
    implements EBComponent, SDTKJEditActions, DefaultFocusComponent {

	private String filename;

	private String defaultFilename;

	private View view;

	private boolean floating;


	public SDTKJEdit(View view, String position) {
		super(new BorderLayout());
		this.view = view;
		this.floating = position.equals(DockableWindowManager.FLOATING);

		if (jEdit.getSettingsDirectory() != null) {
			this.filename = jEdit.getProperty(SDTKJEditPlugin.OPTION_PREFIX
					+ "filepath");
			if (this.filename == null || this.filename.length() == 0) {
				this.filename = new String(jEdit.getSettingsDirectory()
						+ File.separator + "qn.txt");
				jEdit.setProperty(
						SDTKJEditPlugin.OPTION_PREFIX + "filepath",
						this.filename);
			}
			this.defaultFilename = this.filename;
		}


		if (floating)
			this.setPreferredSize(new Dimension(500, 250));
	}

	public void focusOnDefaultComponent() {
	}

	public String getFilename() {
		return filename;
	}

	public void handleMessage(EBMessage message) {
		if (message instanceof PropertiesChanged) {
			propertiesChanged();
		}
	}

	private void propertiesChanged() {
		String propertyFilename = jEdit
				.getProperty(SDTKJEditPlugin.OPTION_PREFIX + "filepath");
	}

	public void addNotify() {
		super.addNotify();
		EditBus.addToBus(this);
	}

	public void removeNotify() {
		super.removeNotify();
		EditBus.removeFromBus(this);
	}

	private String getText() {
		if (view.getEditPane().getTextArea().getSelectionCount() > 0) {
			return view.getTextArea().getSelectedText(view.getTextArea().getSelection()[0]);
		} else {
			return view.getEditPane().getTextArea().getText();
		}
	}

	private void setText(Object text) {
		if (view.getEditPane().getTextArea().getSelectionCount() > 0) {
			view.getTextArea().setSelectedText(view.getTextArea().getSelection()[0], text.toString());
		} else {
			view.getEditPane().getTextArea().setText(text.toString());
		}
	}

	private static com.sdtk.table.ConverterQuickInputOptions quick() {
		return com.sdtk.table.Converter.quick();
	}

	public void csvToPython() {
		setText(
			quick().csv(
				getText()
			).python(null)
		);
	}	

	public void csvToHaxe() {
		setText(
			quick().csv(
				getText()
			).haxe(null)
		);
	}

	public void csvToJava() {
		setText(
			quick().csv(
				getText()
			).java(null)
		);
	}

	public void csvToCSharp() {
		setText(
			quick().csv(
				getText()
			).csharp(null)
		);
	}

	public void csvToSql() {
		setText(
			quick().csv(
				getText()
			).sql(null)
		);
	}

	public void csvToJson() {
		setText(
			quick().csv(
				getText()
			).json(null)
		);
	}

	public void csvToHtmlTable() {
		setText(
			quick().csv(
				getText()
			).htmlTable(null)
		);
	}

	public void csvToTex() {
		setText(
			quick().csv(
				getText()
			).tex(null)
		);
	}

	public void csvToPsv() {
		setText(
			quick().csv(
				getText()
			).psv(null)
		);
	}

	public void csvToTsv() {
		setText(
			quick().csv(
				getText()
			).tsv(null)
		);
	}

	public void tsvToPython() {
		setText(
			quick().tsv(
				getText()
			).python(null)
		);
	}	

	public void tsvToHaxe() {
		setText(
			quick().tsv(
				getText()
			).haxe(null)
		);
	}

	public void tsvToJava() {
		setText(
			quick().tsv(
				getText()
			).java(null)
		);
	}

	public void tsvToCSharp() {
		setText(
			quick().tsv(
				getText()
			).csharp(null)
		);
	}

	public void tsvToSql() {
		setText(
			quick().tsv(
				getText()
			).sql(null)
		);
	}

	public void tsvToJson() {
		setText(
			quick().tsv(
				getText()
			).json(null)
		);
	}

	public void tsvToHtmlTable() {
		setText(
			quick().tsv(
				getText()
			).htmlTable(null)
		);
	}

	public void tsvToTex() {
		setText(
			quick().tsv(
				getText()
			).tex(null)
		);
	}

	public void tsvToPsv() {
		setText(
			quick().tsv(
				getText()
			).psv(null)
		);
	}

	public void tsvToCsv() {
		setText(
			quick().tsv(
				getText()
			).csv(null)
		);
	}

	public void psvToPython() {
		setText(
			quick().psv(
				getText()
			).python(null)
		);
	}	

	public void psvToHaxe() {
		setText(
			quick().psv(
				getText()
			).haxe(null)
		);
	}

	public void psvToJava() {
		setText(
			quick().psv(
				getText()
			).java(null)
		);
	}

	public void psvToCSharp() {
		setText(
			quick().psv(
				getText()
			).csharp(null)
		);
	}

	public void psvToSql() {
		setText(
			quick().psv(
				getText()
			).sql(null)
		);
	}

	public void psvToJson() {
		setText(
			quick().psv(
				getText()
			).json(null)
		);
	}

	public void psvToHtmlTable() {
		setText(
			quick().psv(
				getText()
			).htmlTable(null)
		);
	}

	public void psvToTex() {
		setText(
			quick().psv(
				getText()
			).tex(null)
		);
	}

	public void psvToTsv() {
		setText(
			quick().psv(
				getText()
			).tsv(null)
		);
	}

	public void psvToCsv() {
		setText(
			quick().psv(
				getText()
			).csv(null)
		);
	}
}

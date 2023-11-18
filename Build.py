def getBuildPlatform():
	from sys import platform
	match platform:
		case "aix":
			return "unix"
		case "linux":
			return "unix"
		case "windows":
			return "windows"
		case "win32":
			return "windows"
		case "cygwin":
			return "unix"
		case "darwin":
			return "unix"

def getLanguageSwitch():
	import sys
	return sys.argv[1]

def getPlatformSwitch():
	import sys
	return "-D " + sys.argv[2]

buildPlatform = getBuildPlatform()
languageSwitch = getLanguageSwitch()
platformSwitch = getPlatformSwitch()

def buildPath(arr):
	global buildPlatform
	match buildPlatform:
		case "unix":
			return "/".join(arr)
		case "windows":
			return "\\".join(arr)

def mkdir(path):
	import os
	try:
		os.mkdir(buildPath(path))
	except:
		pass

def rm(path):
	import shutil
	try:
		shutil.rmtree(buildPath(path))
	except:
		pass
	import os
	try:
		os.remove(buildPath(path))
	except:
		pass
	try:
		os.unlink(buildPath(path))
	except:
		pass

def move(src, to):
	import os
	rm(to)
	os.rename(buildPath(src), buildPath(to))

def append(src, to, appending):
	with open(buildPath(to), "a" if appending else "w+") as fo:
		with open(buildPath(src), "r") as fi:
			fo.write(fi.read())
def run(program, parameters):
	import os
	print(" ".join([program] + parameters))
	os.system(" ".join([program] + parameters))

def haxe(name, out, src, package, defines):
	global languageSwitch
	global platformSwitch
	if defines == None:
		defines = [ ]
	if languageSwitch == "--python" and "Library" not in name:
		defines = defines + ["--main " + package]
	elif languageSwitch == "-cs" and "Library" not in name:
		defines = defines + ["--main " + package]
		out = out.replace(".dll", ".exe")
	for i in range(len(src)):
		src[i] = "-cp " + src[i]
	run("haxe", [languageSwitch, buildPath(["out", out])] + src + [ package, platformSwitch] + defines)
	if languageSwitch == "-java":
		move(["out", out, out + ".jar"], ["out", "build.tmp"])
		rm(["out", out])
	elif languageSwitch == "-cs":
		if ".dll" in out:
			move(["out", out, "bin", out + ".dll"], ["out", "build.tmp"])
		else:
			move(["out", out, "bin", package.split(".")[-1] + ".exe"], ["out", "build.tmp"])
		rm(["out", out])
	else:
		move(["out", out], ["out", "build.tmp"])
	if appendFile != None:
		append([appendFile], ["out", out], False)
	if appendFile == None:
		move(["out", "build.tmp"], ["out", out])
	else:
		append(["out", "build.tmp"], ["out", out], True)
	rm(["out", "build.tmp"])

def build(name, out, src, package, defines):
	global languageSwitch
	global platformSwitch
	mkdir(["out"])
	rm(["out", "build.tmp"])
	rm(["out", out])

	print(name)
	if languageSwitch == "--js":
		if defines == None:
			defines = [ ]
		defines = defines + ["-lib jsasync"]
	haxe(name, out, src, package, defines)


if languageSwitch != "CLEAN":
	if languageSwitch == "--python":
		out2 = ".py"
		appendFile = "Append_To_Beginning.py"
	elif languageSwitch == "-cs":
		out2 = ".dll"
		appendFile = None
	elif languageSwitch == "-hl":
		out2 = "-lib.hl"
		appendFile = None
	elif languageSwitch == "-java":
		out2 = ".jar"
		appendFile = None
	elif languageSwitch == "-lua":
		out2 = ".lua"
		appendFile = "Append_To_Beginning.lua"
	elif platformSwitch == "-D JS_BROWSER":
		out2 = "-browser.js"
		appendFile = "Append_To_Beginning.txt"
	elif platformSwitch == "-D JS_WSH":
		out2 = "-wsh.js"
		appendFile = "Append_To_Beginning.txt"	

	# TODO - Add Lua TI
	# TODO - Add PHP
	# TODO - Add Docs
	# TODO - Add UML

	build("Building Library", "sdtk" + out2, ["src"], "com.sdtk", None)
	build("Building Simple Log Grabber", "slg" + out2, ["src"], "com.sdtk.log.Transfer", None)
	build("Building Simple Table Converter", "stc" + out2, ["src"], "com.sdtk.table.Converter", None)
	build("Building Simple Calendar", "calendar" + out2, ["src"], "com.sdtk.calendar.Create", None)
	build("Building Simple Calendar Executor", "executor" + out2, ["src"], "com.sdtk.calendar.Executor", None)
	build("Building Simple Puller", "puller" + out2, ["src"], "com.sdtk.puller.Puller", None)

else:
	rm(["out"])
	rm([".ionide"])
	rm(["pages"])
	rm(["plugin-jedit-src-actual"])
	rm(["tmp"])
	rm(["tmp_choco"])
	rm(["texput.log"])
	rm(["doc.xml"])

#pushd plugin-jedit-src
#REM haxe -java ..\out -main SDTKJEditPlugIn --java-lib "C:\Program Files\jEdit\jedit.jar"
#javac *.java -cp "C:\Program Files\jEdit\jedit.jar;..\out\sdtk.jar"
#mkdir out
#move *.class out
#copy *.html out
#copy *.xml out
#copy *.prop* out
#cd out
#jar cvf sdtk-plugin-jedit.jar *.class *.html *.props *.xml
#REM    --resource index.html --resource SDTKJEdit.props --resource actions.xml
#REM move *.jar ..\..\out
#cd ..
#REM rmdir /s /q out
#popd

#REM move out\out.jar out\sdtk-plugin-jedit.jar > NUL 2> NUL

#popd


#ECHO Building Library
#DEL out\sdtk-snowflake.js
#haxe com.sdtk -js out\sdtk-snowflake.js -cp src -D JS_SNOWFLAKE -D EXCLUDE_PARAMETERS -D EXCLUDE_CONTROLS -D EXCLUDE_FILES -D EXCLUDE_APIS -D EXCLUDE_PROXY -D %* $*
#MOVE out\sdtk-snowflake.js out\sdtk-snowflake.tmp
#TYPE Append_To_Beginning.txt > out\sdtk-snowflake.js
#TYPE Append_To_Beginning_SF.txt >> out\sdtk-snowflake.js
#TYPE out\sdtk-snowflake.tmp >> out\sdtk-snowflake.js
#TYPE Append_To_End_SF.txt >> out\sdtk-snowflake.js
#DEL out\sdtk-snowflake.tmp

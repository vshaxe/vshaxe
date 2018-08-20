package vshaxe.view.dependencies;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import vshaxe.helper.PathHelper;
import vshaxe.helper.HxmlParser;

class DependencyExtractor {
	public static function extractDependencies(args:Array<String>, cwd:String):DependencyList {
		var result:DependencyList = {
			libs: [],
			classPaths: [],
			hxmls: []
		}

		if (args == null) {
			return result;
		}

		function processHxml(hxmlFile:String, cwd:String) {
			hxmlFile = PathHelper.absolutize(hxmlFile, cwd);
			result.hxmls.push(hxmlFile);
			if (hxmlFile == null || !FileSystem.exists(hxmlFile)) {
				return [];
			}

			return HxmlParser.parseFile(File.getContent(hxmlFile));
		}

		function processLines(lines:Array<HxmlLine>) {
			for (line in lines) {
				switch (line) {
					case Param("-lib" | "-L" | "--library", lib):
						result.libs.push(lib);
					case Param("-cp" | "-p" | "--class-path", cp):
						result.classPaths.push(cp);
					case Param("--cwd" | "-C", newCwd):
						if (Path.isAbsolute(newCwd)) {
							cwd = newCwd;
						} else {
							cwd = Path.join([cwd, newCwd]);
						}
					case Simple(name) if (name.endsWith(".hxml")):
						processLines(processHxml(name, cwd));
					case _:
				}
			}
		}

		processLines(HxmlParser.parseArray(args));
		return result;
	}
}

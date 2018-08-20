package vshaxe.helper;

import haxe.io.Path;

class PathHelper {
	public static function absolutize(path:String, cwd:String) {
		return Path.normalize(if (Path.isAbsolute(path)) {
			path;
		} else {
			Path.join([cwd, path]);
		});
	}

	public static function relativize(path:String, cwd:String) {
		path = Path.normalize(path);
		cwd = Path.normalize(cwd) + "/";

		var segments = path.split(cwd);
		segments.shift();
		return segments.join(cwd);
	}

	public static function containsFile(directory:String, file:String):Bool {
		directory = Path.normalize(directory) + "/";
		var fileDirectory = Path.normalize(Path.directory(file)) + "/";

		if (Sys.systemName() == "Windows") {
			directory = directory.toLowerCase();
			fileDirectory = fileDirectory.toLowerCase();
		}

		return fileDirectory.startsWith(directory);
	}

	public static function areEqual(path1:String, path2:String):Bool {
		if (Sys.systemName() == "Windows") {
			path1 = path1.toLowerCase();
			path2 = path2.toLowerCase();
		}
		return Path.normalize(path1) == Path.normalize(path2);
	}

	public static function capitalizeDriveLetter(path:String):String {
		if (Sys.systemName() == "Windows" && Path.isAbsolute(path)) {
			path = path.charAt(0).toUpperCase() + path.substr(1);
		}
		return path;
	}
}

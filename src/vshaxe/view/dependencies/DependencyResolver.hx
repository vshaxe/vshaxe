package vshaxe.view.dependencies;

import haxe.Json;
import haxe.io.Path;
import js.node.Buffer;
import js.node.ChildProcess;
import sys.FileSystem;
import sys.io.File;
import vshaxe.helper.PathHelper;
import vshaxe.helper.HaxeExecutable;

using Lambda;

typedef DependencyInfo = {
	name:String,
	version:String,
	path:String
}

class DependencyResolver {
	static var _haxelibRepo:Null<String>;
	static var haxelibRepo(get, never):Null<String>;

	public static function resolveDependencies(dependencies:DependencyList, haxeExecutable:HaxeExecutable):Array<DependencyInfo> {
		var paths = [];
		for (lib in dependencies.libs) {
			paths = paths.concat(resolveHaxelib(lib));
		}
		paths = paths.concat(dependencies.classPaths);
		paths = pruneSubdirectories(paths);

		var infos = [];
		if (haxelibRepo != null) {
			infos = paths.map(getDependencyInfo).filter(info -> info != null);
		}
		var stdLibPath = getStandardLibraryPath(haxeExecutable.configuration);
		if (stdLibPath != null && FileSystem.exists(stdLibPath)) {
			infos.push(getStandardLibraryInfo(stdLibPath, haxeExecutable.configuration.executable));
		}
		return infos;
	}

	static function get_haxelibRepo():String {
		if (_haxelibRepo == null) {
			var output = getProcessOutput("haxelib config")[0];
			if (output == null) {
				trace("`haxelib config` call failed, Haxe Dependencies won't be populated.");
			} else {
				_haxelibRepo = Path.normalize(output);
			}
		}
		return _haxelibRepo;
	}

	static function resolveHaxelib(lib:String):Array<String> {
		var paths = [];
		for (line in getProcessOutput('haxelib path $lib')) {
			var potentialPath = Path.normalize(line);
			if (FileSystem.exists(potentialPath)) {
				paths.push(potentialPath);
			}
		}
		return paths;
	}

	static function getProcessOutput(command:String):Array<String> {
		try {
			var oldCwd = Sys.getCwd();
			if (workspace.workspaceFolders != null) {
				Sys.setCwd(workspace.workspaceFolders[0].uri.fsPath);
			}
			var result:Buffer = ChildProcess.execSync(command);
			Sys.setCwd(oldCwd);
			var lines = result.toString().split("\n");
			return [for (line in lines) line.trim()];
		} catch (e:Any) {
			return [];
		}
	}

	// ignore directories that are subdirectories of others (#156)
	static function pruneSubdirectories(paths:Array<String>):Array<String> {
		paths = paths.map(Path.addTrailingSlash); // needed to make the startsWith() check safe
		return paths.filter(path -> {
			return !paths.exists(p -> p != path && path.startsWith(p));
		});
	}

	static function getDependencyInfo(path:String) {
		var rootPath = workspace.workspaceFolders[0].uri.fsPath;
		var absPath = PathHelper.absolutize(path, rootPath);
		if (!FileSystem.exists(absPath)) {
			return null;
		}

		if (absPath.indexOf(haxelibRepo) == -1) {
			// dependencies outside of the haxelib repo (installed via "haxelib dev" or just classpaths)
			// - only bother to show these if they're outside of the current workspace
			if (absPath.indexOf(Path.normalize(rootPath)) == -1) {
				// could be a "haxelib dev" haxelib
				var haxelibInfo = searchHaxelibJson(absPath);
				if (haxelibInfo == null) {
					return {name: path, version: null, path: absPath};
				}
				return haxelibInfo;
			}
			return null;
		}

		// regular haxelibs inside the haxelib repo location
		path = absPath.replace(haxelibRepo + "/", "");
		var segments = path.split("/");
		var name = segments[0];
		var version = segments[1];

		path = '$haxelibRepo/$name';

		if (name != null) {
			name = name.replace(",", ".");
		}

		if (version != null) {
			path += '/$version';
			version = version.replace(",", ".");
		} else {
			version = path;
		}

		if (!FileSystem.exists(path)) {
			return null;
		}
		return {name: name, version: version, path: path};
	}

	static function searchHaxelibJson(path:String, levels:Int = 3) {
		if (levels <= 0) {
			return null;
		}

		var haxelibFile = Path.join([path, "haxelib.json"]);
		if (FileSystem.exists(haxelibFile)) {
			var content:{?name:String} = Json.parse(File.getContent(haxelibFile));
			if (content.name == null) {
				return null;
			}
			path = Path.normalize(path);
			return {name: content.name, version: "dev", path: path};
		}
		return searchHaxelibJson(Path.join([path, ".."]), levels - 1);
	}

	static function getStandardLibraryPath(haxeExecutable:HaxeExecutableConfiguration):String {
		// more or less a port of main.ml's get_std_class_paths()
		var path = Sys.getEnv("HAXE_STD_PATH");
		if (path != null) {
			return path;
		}

		if (Sys.systemName() == "Windows") {
			var path = if (haxeExecutable.isCommand) {
				var exectuable = getProcessOutput("where " + haxeExecutable.executable)[0];
				if (exectuable == null) {
					return null;
				}
				exectuable;
			} else {
				haxeExecutable.executable;
			}
			return Path.join([Path.directory(path), "std"]);
		} else {
			for (path in [
				"/usr/local/share/haxe/std/",
				"/usr/local/lib/haxe/std/",
				"/usr/share/haxe/std/",
				"/usr/lib/haxe/std/"
			]) {
				if (FileSystem.exists(path)) {
					return path;
				}
			}
		}
		return null;
	}

	static function getStandardLibraryInfo(path:String, haxeExecutable:String) {
		var version = "?";
		var result = ChildProcess.spawnSync(haxeExecutable, ["-version"]);

		if (result != null && result.stderr != null) {
			var output = (result.stderr : Buffer).toString().trim();
			if (output == "") {
				output = (result.stdout : Buffer).toString().trim(); // haxe 4.0 prints -version output to stdout instead
			}

			if (output != null) {
				version = output.split(" ")[0].trim();
			}
		}

		return {name: "haxe", path: path, version: version};
	}
}

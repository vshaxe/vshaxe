package vshaxe.view.dependencies;

import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import vshaxe.configuration.HaxeInstallation;
import vshaxe.helper.PathHelper;
import vshaxe.helper.ProcessHelper;

using Lambda;

typedef DependencyInfo = {
	name:String,
	version:String,
	path:String
}

class DependencyResolver {
	public static function resolveDependencies(dependencies:DependencyList, haxeInstallation:HaxeInstallation):Array<DependencyInfo> {
		var haxe = haxeInstallation.haxe.configuration;
		var haxelib = haxeInstallation.haxelib.configuration;

		var paths = [];
		for (lib in dependencies.libs) {
			paths = paths.concat(resolveHaxelib(lib, haxelib));
		}
		paths = paths.concat(dependencies.classPaths);
		paths = pruneSubdirectories(paths);

		var infos:Array<DependencyInfo> = [];
		var libraryBasePath = haxeInstallation.libraryBasePath;
		if (libraryBasePath != null) {
			for (info in paths.map(getDependencyInfo.bind(_, libraryBasePath))) {
				if (info != null) {
					infos.push(info);
				}
			}
		}

		var stdLibPath = haxeInstallation.standardLibraryPath;
		if (stdLibPath != null && FileSystem.exists(stdLibPath)) {
			@:nullSafety(Off) infos.push({
				name: "haxe",
				version: if (haxe.version == null) "?" else haxe.version,
				path: stdLibPath
			});
		}

		return infos;
	}

	static function resolveHaxelib(lib:String, haxelib:String):Array<String> {
		var paths = [];
		for (line in ProcessHelper.getOutput('$haxelib path $lib')) {
			var potentialPath = Path.normalize(line);
			if (FileSystem.exists(potentialPath)) {
				paths.push(potentialPath);
			}
		}
		return paths;
	}

	// ignore directories that are subdirectories of others (#156)
	static function pruneSubdirectories(paths:Array<String>):Array<String> {
		paths = paths.map(Path.addTrailingSlash); // needed to make the startsWith() check safe
		return paths.filter(path -> {
			return !paths.exists(p -> p != path && path.startsWith(p));
		});
	}

	static function getDependencyInfo(path:String, libraryBasePath:String):Null<DependencyInfo> {
		if (workspace.workspaceFolders == null) {
			return null;
		}
		var rootPath = workspace.workspaceFolders[0].uri.fsPath;
		var absPath = PathHelper.absolutize(path, rootPath);
		if (libraryBasePath == null || !FileSystem.exists(absPath)) {
			return null;
		}

		libraryBasePath = Path.normalize(libraryBasePath);
		if (absPath.indexOf(libraryBasePath) == -1) {
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
		path = absPath.replace(libraryBasePath + "/", "");
		var segments = path.split("/");
		var name = segments[0];
		var version = segments[1];

		path = '$libraryBasePath/$name';

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

	static function searchHaxelibJson(path:String, levels:Int = 3):Null<DependencyInfo> {
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
}

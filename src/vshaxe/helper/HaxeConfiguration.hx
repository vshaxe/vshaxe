package vshaxe.helper;

import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import vshaxe.configuration.HaxeInstallation;
import vshaxe.display.DisplayArguments;
import vshaxe.helper.HxmlParser.HxmlLine;
import vshaxe.helper.PathHelper;
import vshaxe.helper.ProcessHelper;

using Lambda;

/** "extracted" compiler arguments without resolved libraries **/
typedef ExtractedConfiguration = {
	var libs:Array<String>;
	var classPaths:Array<String>;
	var hxmls:Array<String>;
}

/** compiler arguments with resolved libraries **/
typedef ResolvedConfiguration = {
	var dependencies:Array<DependencyInfo>;
}

typedef DependencyInfo = {
	var name(default, never):String;
	var version(default, never):String;
	var path(default, never):String;
}

class HaxeConfiguration {
	public var onDidChange(get, never):Event<ResolvedConfiguration>;
	public var resolvedConfiguration(default, null):Null<ResolvedConfiguration>;

	final folder:WorkspaceFolder;
	final haxeInstallation:HaxeInstallation;
	final didChangeEmitter:EventEmitter<ResolvedConfiguration>;

	var rawArguments:Null<Array<String>>;
	var extractedConfiguration:Null<ExtractedConfiguration>;

	var providerWaitTimedOut = false;

	inline function get_onDidChange()
		return didChangeEmitter.event;

	public function new(context:ExtensionContext, folder:WorkspaceFolder, displayArguments:DisplayArguments, haxeInstallation:HaxeInstallation) {
		this.folder = folder;
		this.haxeInstallation = haxeInstallation;
		didChangeEmitter = new EventEmitter();

		rawArguments = displayArguments.arguments;

		var hxmlFileWatcher = workspace.createFileSystemWatcher("**/*.hxml");
		context.subscriptions.push(hxmlFileWatcher.onDidCreate(onDidChangeHxml));
		context.subscriptions.push(hxmlFileWatcher.onDidChange(onDidChangeHxml));
		context.subscriptions.push(hxmlFileWatcher.onDidDelete(onDidChangeHxml));
		context.subscriptions.push(hxmlFileWatcher);

		context.subscriptions.push(haxeInstallation.onDidChange(_ -> update()));
		context.subscriptions.push(displayArguments.onDidChangeArguments(onDidChangeDisplayArguments));

		if (haxeInstallation.isWaitingForProvider()) {
			// fallback in case the provider is not there anymore
			haxe.Timer.delay(() -> {
				providerWaitTimedOut = true;
				if (extractedConfiguration == null) {
					update();
				}
			}, 2000);
		}
	}

	function onDidChangeHxml(uri:Uri) {
		if (extractedConfiguration != null) {
			for (hxml in extractedConfiguration.hxmls) {
				if (PathHelper.areEqual(uri.fsPath, hxml)) {
					update();
					break;
				}
			}
		}
	}

	function onDidChangeDisplayArguments(displayArguments:Array<String>) {
		rawArguments = displayArguments;
		update();
	}

	function update() {
		if (haxeInstallation.isWaitingForProvider() && !providerWaitTimedOut) {
			return;
		}
		var newExtractedConfiguration = extract(rawArguments);
		// avoid FS access / creating processes unless there were _actually_ changes
		if (extractedConfiguration != null
			&& extractedConfiguration.libs.equals(newExtractedConfiguration.libs)
			&& extractedConfiguration.classPaths.equals(newExtractedConfiguration.classPaths)) {
			return;
		}
		extractedConfiguration = newExtractedConfiguration;

		resolvedConfiguration = resolve(extractedConfiguration);
		didChangeEmitter.fire(resolvedConfiguration);
	}

	public function dispose() {
		didChangeEmitter.dispose();
	}

	public function invalidate() {
		extractedConfiguration = null;
		resolvedConfiguration = null;
		update();
	}

	function extract(args:Null<Array<String>>):ExtractedConfiguration {
		var cwd = folder.uri.fsPath;
		var result:ExtractedConfiguration = {
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
				switch line {
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

	function resolve(extractedConfiguration:ExtractedConfiguration):ResolvedConfiguration {
		var haxe = haxeInstallation.haxe.configuration;
		var haxelib = haxeInstallation.haxelib.configuration;

		var paths = [];
		for (lib in extractedConfiguration.libs) {
			paths = paths.concat(resolveHaxelib(lib, haxelib));
		}
		paths = paths.concat(extractedConfiguration.classPaths);
		paths = pruneSubdirectories(paths);

		var dependencies:Array<DependencyInfo> = [];
		var libraryBasePath = haxeInstallation.libraryBasePath;
		if (libraryBasePath != null) {
			for (path in paths) {
				var info = haxeInstallation.resolveLibrary(path);
				if (info == null) {
					info = getDependencyInfo(path, libraryBasePath);
				}
				if (info != null) {
					dependencies.push(info);
				}
			}
		}

		var stdLibPath = haxeInstallation.standardLibraryPath;
		if (stdLibPath != null && FileSystem.exists(stdLibPath)) {
			@:nullSafety(Off) dependencies.push({
				name: "haxe",
				version: if (haxe.version == null) "?" else haxe.version,
				path: stdLibPath
			});
		}

		return {
			dependencies: dependencies
		};
	}

	function resolveHaxelib(lib:String, haxelib:String):Array<String> {
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
	function pruneSubdirectories(paths:Array<String>):Array<String> {
		paths = paths.map(Path.addTrailingSlash); // needed to make the startsWith() check safe
		return paths.filter(path -> {
			return !paths.exists(p -> p != path && path.startsWith(p));
		});
	}

	function getDependencyInfo(path:String, libraryBasePath:String):Null<DependencyInfo> {
		if (workspace.workspaceFolders == null) {
			return null;
		}
		var rootPath = workspace.workspaceFolders[0].uri.fsPath;
		var absPath = PathHelper.absolutize(path, rootPath);
		if (libraryBasePath == null || !FileSystem.exists(absPath)) {
			return null;
		}

		libraryBasePath = Path.normalize(libraryBasePath);
		if (!absPath.contains(libraryBasePath)) {
			// dependencies outside of the haxelib repo (installed via "haxelib dev" or just classpaths)
			// - only bother to show these if they're outside of the current workspace
			if (!absPath.contains(Path.normalize(rootPath))) {
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

	function searchHaxelibJson(path:String, levels:Int = 3):Null<DependencyInfo> {
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

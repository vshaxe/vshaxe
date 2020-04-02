package vshaxe.helper;

import haxe.Json;
import haxe.ds.ReadOnlyArray;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import vshaxe.HaxeConfiguration.ClassPath;
import vshaxe.HaxeConfiguration.Target;
import vshaxe.configuration.HaxeInstallation;
import vshaxe.display.DisplayArguments;
import vshaxe.helper.HxmlParser.HxmlLine;
import vshaxe.helper.PathHelper;
import vshaxe.helper.ProcessHelper;

using Lambda;

/** "extracted" compiler arguments without resolved libraries **/
typedef ExtractedConfiguration = vshaxe.HaxeConfiguration & {
	final libs:ReadOnlyArray<String>;
	final hxmls:ReadOnlyArray<String>;
}

/** compiler arguments with resolved libraries **/
typedef ResolvedConfiguration = vshaxe.HaxeConfiguration & {
	final dependencies:ReadOnlyArray<DependencyInfo>;
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

	var rawArguments:Array<String>;
	var extractedConfiguration:Null<ExtractedConfiguration>;

	inline function get_onDidChange()
		return didChangeEmitter.event;

	public function new(context:ExtensionContext, folder:WorkspaceFolder, displayArguments:DisplayArguments, haxeInstallation:HaxeInstallation) {
		this.folder = folder;
		this.haxeInstallation = haxeInstallation;
		didChangeEmitter = new EventEmitter();

		var args = displayArguments.arguments;
		rawArguments = if (args == null) [] else args;

		var hxmlFileWatcher = workspace.createFileSystemWatcher("**/*.hxml");
		context.subscriptions.push(hxmlFileWatcher.onDidCreate(onDidChangeHxml));
		context.subscriptions.push(hxmlFileWatcher.onDidChange(onDidChangeHxml));
		context.subscriptions.push(hxmlFileWatcher.onDidDelete(onDidChangeHxml));
		context.subscriptions.push(hxmlFileWatcher);

		context.subscriptions.push(haxeInstallation.onDidChange(_ -> invalidate()));
		context.subscriptions.push(displayArguments.onDidChangeArguments(onDidChangeDisplayArguments));
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
		if (haxeInstallation.isWaitingForProvider()) {
			return;
		}
		var newExtractedConfiguration = extract(HxmlParser.parseArray(rawArguments));
		// avoid FS access / creating processes unless there were _actually_ changes
		@:nullSafety(Off) {
			if (Json.stringify(extractedConfiguration) == Json.stringify(newExtractedConfiguration)) {
				return;
			}
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

	function extract(lines:Array<HxmlLine>):ExtractedConfiguration {
		var cwd = folder.uri.fsPath;

		var libs = [];
		var hxmls = [];
		var classPaths = [];
		var defines = new Map<String, String>();
		var target = None;
		var main:Null<String> = null;

		function processHxml(hxmlFile:String, cwd:String) {
			hxmlFile = PathHelper.absolutize(hxmlFile, cwd);
			hxmls.push(hxmlFile);
			if (hxmlFile == null || !FileSystem.exists(hxmlFile)) {
				return [];
			}

			return HxmlParser.parseFile(File.getContent(hxmlFile));
		}

		function processLines(lines:Array<HxmlLine>) {
			for (line in lines) {
				switch line {
					case Param("-lib" | "-L" | "--library", lib):
						libs.push(lib);
					case Param("-cp" | "-p" | "--class-path", cp):
						classPaths.push({path: cp});
					case Param("--cwd" | "-C", newCwd):
						if (Path.isAbsolute(newCwd)) {
							cwd = newCwd;
						} else {
							cwd = Path.join([cwd, newCwd]);
						}
					case Param("-D" | "--define", arg):
						var parts = arg.split("=");
						var name = parts[0];
						var value = if (parts.length == 1) "1" else parts[1];
						defines[name] = value;

					case Param("-js" | "--js", file):
						target = Js(file);
					case Param("-lua" | "--lua", file):
						target = Lua(file);
					case Param("-swf" | "--swf", file):
						target = Swf(file);
					case Param("-as3" | "--as3", directory):
						target = As3(directory);
					case Param("-neko" | "--neko", file):
						target = Neko(file);
					case Param("-php" | "--php", directory):
						target = Php(directory);
					case Param("-cpp" | "--cpp", directory):
						target = Cpp(directory);
					case Param("-cppia" | "--cppia", file):
						target = Cppia(file);
					case Param("-cs" | "--cs", directory):
						target = Cs(directory);
					case Param("-java" | "--java", directory):
						target = Java(directory);
					case Param("-python" | "--python", file):
						target = Python(file);
					case Param("-hl" | "--hl", file):
						target = Hl(file);
					case Simple("-interp" | "--interp"):
						target = Interp;

					case Param("-m" | "-main" | "--main", mainClass):
						main = mainClass;
					case Param("--run", mainClass):
						main = mainClass;
						target = Interp;

					case Simple(name) if (name.endsWith(".hxml")):
						processLines(processHxml(name, cwd));
					case _:
				}
			}
		}

		processLines(lines);
		return {
			libs: libs,
			hxmls: hxmls,
			classPaths: classPaths,
			defines: defines,
			target: target,
			main: main
		};
	}

	function resolve(extractedConfiguration:ExtractedConfiguration):ResolvedConfiguration {
		var classPaths = extractedConfiguration.classPaths.copy();
		var defines = extractedConfiguration.defines.copy();

		var result = resolveHaxelibs(extractedConfiguration.libs);
		var extracted = extract(HxmlParser.parseFile(result.hxml.join("\n")));
		// assume extracted has no libs or hxmls
		classPaths = classPaths.concat(result.classPaths);
		classPaths = classPaths.concat(cast extracted.classPaths);
		for (name => value in extracted.defines) {
			defines[name] = value;
		}

		var dependencies = resolveDependencies(classPaths.map(cp -> cp.path));

		var stdLibPath = haxeInstallation.standardLibraryPath;
		if (stdLibPath != null) {
			classPaths.push({
				path: (stdLibPath : String)
			});
		}
		return {
			dependencies: dependencies,
			defines: defines,
			classPaths: classPaths,
			target: extractedConfiguration.target,
			main: extractedConfiguration.main
		};
	}

	function resolveHaxelibs(libs:ReadOnlyArray<String>):{classPaths:Array<ClassPath>, hxml:Array<String>} {
		var result = {
			classPaths: [],
			hxml: []
		};
		var haxelib = haxeInstallation.haxelib.configuration;
		var output = ProcessHelper.getOutput('$haxelib path ${libs.join(" ")}');
		for (line in output) {
			line = line.trim();
			if (line.length == 0) {
				continue;
			}
			if (line.charCodeAt(0) == "-".code) {
				result.hxml.push(line);
			} else {
				result.classPaths.push({path: Path.normalize(line)});
			}
		}
		return result;
	}

	function resolveDependencies(paths:Array<String>):Array<DependencyInfo> {
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

		var haxe = haxeInstallation.haxe.configuration;
		var stdLibPath = haxeInstallation.standardLibraryPath;
		if (stdLibPath != null && FileSystem.exists(stdLibPath)) {
			@:nullSafety(Off) dependencies.push({
				name: "haxe",
				version: if (haxe.version == null) "?" else haxe.version,
				path: stdLibPath
			});
		}
		return dependencies;
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

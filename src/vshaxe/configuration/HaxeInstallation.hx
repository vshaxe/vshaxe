package vshaxe.configuration;

import sys.FileSystem;
import haxe.io.Path;
import vshaxe.helper.ProcessHelper;

class HaxeInstallation {
	public final haxe:HaxeExecutable;
	public final haxelib:HaxelibExecutable;
	public var standardLibraryPath(default, null):Null<String>;
	public var libraryBasePath(default, null):Null<String>;
	public var onDidChange(get, never):Event<Void>;

	final providers = new Map<String, HaxeInstallationProvider>();
	var currentProvider:Null<String>;
	var ignoreEvents:Bool = false;
	final _onDidChange = new EventEmitter<Void>();

	inline function get_onDidChange()
		return _onDidChange.event;

	public function new(folder:WorkspaceFolder) {
		haxe = new HaxeExecutable(folder);
		haxelib = new HaxelibExecutable(folder);
		haxe.onDidChangeConfiguration(_ -> onDidChangeConfiguration());
		haxelib.onDidChangeConfiguration(_ -> onDidChangeConfiguration());
		standardLibraryPath = getStandardLibraryPath();
		libraryBasePath = getLibraryBasePath();
	}

	function onDidChangeConfiguration() {
		if (!ignoreEvents) {
			_onDidChange.fire();
		}
	}

	public function dispose() {
		haxe.dispose();
		haxelib.dispose();
	}

	public function registerProvider(name:String, provider:HaxeInstallationProvider):Disposable {
		if (providers.exists(name)) {
			throw new js.lib.Error('Haxe installation provider `$name` is already registered.');
		}

		providers[name] = provider;
		if (currentProvider == null) {
			setCurrentProvider(name);
		}

		return new Disposable(function() {
			if (name == currentProvider)
				setCurrentProvider(null);
			providers.remove(name);
		});
	}

	function setCurrentProvider(name:Null<String>) {
		if (currentProvider != null) {
			var provider = providers[currentProvider];
			if (provider != null)
				provider.deactivate();
		}

		currentProvider = name;

		if (name != null) {
			var provider = providers[name];
			if (provider != null)
				provider.activate(provideInstallation);
		} else {
			provideInstallation({});
		}
	}

	function provideInstallation(installation:vshaxe.HaxeInstallation) {
		ignoreEvents = true;
		haxe.setAutoResolveValue(currentProvider, installation.haxeExecutable);
		haxelib.setAutoResolveValue(installation.haxelibExecutable);
		ignoreEvents = false;

		standardLibraryPath = installation.standardLibraryPath;
		if (standardLibraryPath == null) {
			standardLibraryPath = getStandardLibraryPath();
		}

		libraryBasePath = installation.libraryBasePath;
		if (libraryBasePath == null) {
			libraryBasePath = getLibraryBasePath();
		}

		_onDidChange.fire();
	}

	function getStandardLibraryPath():Null<String> {
		// more or less a port of main.ml's get_std_class_paths()
		var path = Sys.getEnv("HAXE_STD_PATH");
		if (path != null) {
			return path;
		}

		if (Sys.systemName() == "Windows") {
			var path = if (haxe.configuration.isCommand) {
				var exectuable = ProcessHelper.getOutput("where " + haxe.configuration.executable)[0];
				if (exectuable == null) {
					return null;
				}
				exectuable;
			} else {
				haxe.configuration.executable;
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

	function getLibraryBasePath():Null<String> {
		var output = ProcessHelper.getOutput('${haxelib.configuration} config')[0];
		return if (output == null) {
			trace("`haxelib config` call failed, Haxe Dependencies won't be populated.");
			null;
		} else {
			Path.normalize(output);
		}
	}
}

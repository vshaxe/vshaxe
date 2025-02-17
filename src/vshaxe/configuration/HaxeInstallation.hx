package vshaxe.configuration;

import haxe.DynamicAccess;
import haxe.Timer;
import haxe.io.Path;
import haxeLanguageServer.ProcessUtil.shellEscapeCommand;
import sys.FileSystem;
import vshaxe.helper.PathHelper;
import vshaxe.helper.ProcessHelper;

class HaxeInstallation {
	public static final PreviousHaxeInstallationProviderKey = new HaxeMementoKey<String>("previousHaxeInstallationProvider");

	public final haxe:HaxeExecutable;
	public final haxelib:HaxelibExecutable;
	public var standardLibraryPath(default, null):Null<String>;
	public var libraryBasePath(default, null):Null<String>;
	public var onDidChange(get, never):Event<Void>;
	public var env(default, null):DynamicAccess<String>;

	final folder:WorkspaceFolder;
	final mementos:WorkspaceMementos;
	final providers = new Map<String, HaxeInstallationProvider>();
	var currentProvider:Null<String>;
	var ignoreEvents:Bool = false;
	final _onDidChange = new EventEmitter<Void>();

	inline function get_onDidChange()
		return _onDidChange.event;

	public function new(folder:WorkspaceFolder, mementos:WorkspaceMementos) {
		this.folder = folder;
		this.mementos = mementos;
		haxe = new HaxeExecutable(folder);
		haxelib = new HaxelibExecutable(folder);
		env = updateEnv();

		haxe.onDidChangeConfiguration(_ -> onDidChangeConfiguration());
		haxelib.onDidChangeConfiguration(_ -> onDidChangeConfiguration());
		standardLibraryPath = getStandardLibraryPath();
		libraryBasePath = getLibraryBasePath();

		if (isWaitingForProvider()) {
			// fallback in case the provider is not there anymore
			Timer.delay(() -> {
				if (isWaitingForProvider()) {
					setCurrentProvider(null);
				}
			}, 2000);
		}
	}

	function onDidChangeConfiguration() {
		if (!ignoreEvents) {
			env = updateEnv();
			_onDidChange.fire();
		}
	}

	function updateEnv():DynamicAccess<String> {
		@:nullSafety(Off) final env = haxe.configuration.env.copy();
		// if we have a custom haxelib executable, we need to make sure it's in the PATH of Haxe
		// - otherwise `haxelib run hxcpp/hxjava/hxcs` that Haxe runs on those targets will fail
		var haxelib = haxelib.configuration.executable;
		if (!Path.isAbsolute(haxelib)) {
			haxelib = PathHelper.absolutize(haxelib, folder.uri.fsPath);
		}
		if (FileSystem.exists(haxelib) && !FileSystem.isDirectory(haxelib)) {
			final separator = if (Sys.systemName() == "Windows") ";" else ":";
			env["PATH"] = Path.directory(haxelib) + separator + Sys.getEnv("PATH");
		}
		return env;
	}

	public function dispose() {
		haxe.dispose();
		haxelib.dispose();
	}

	function getCurrentProvider():Null<HaxeInstallationProvider> {
		return if (currentProvider != null) providers[currentProvider] else null;
	}

	public function resolveLibrary(classpath:String):Null<Library> {
		final provider = getCurrentProvider();
		if (provider != null && provider.resolveLibrary != null) {
			return provider.resolveLibrary(classpath);
		}
		return null;
	}

	public function listLibraries():Array<{name:String}> {
		final provider = getCurrentProvider();
		if (provider != null && provider.listLibraries != null) {
			return provider.listLibraries();
		}
		if (libraryBasePath == null || !FileSystem.exists(libraryBasePath) || !FileSystem.isDirectory(libraryBasePath)) {
			return [];
		}
		return FileSystem.readDirectory(libraryBasePath).filter(file -> !file.startsWith(".")).map(file -> {name: file.replace(',', '.')});
	}

	public function isWaitingForProvider():Bool {
		final previousProvider = mementos.get(folder, PreviousHaxeInstallationProviderKey);
		return previousProvider != null && currentProvider == null;
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
			final provider = providers[currentProvider];
			if (provider != null)
				provider.deactivate();
		}

		currentProvider = name;
		mementos.set(folder, PreviousHaxeInstallationProviderKey, name);

		if (name != null) {
			final provider = providers[name];
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

		env = updateEnv();
		_onDidChange.fire();
	}

	function getStandardLibraryPath():Null<String> {
		// more or less a port of main.ml's get_std_class_paths()
		final path = Sys.getEnv("HAXE_STD_PATH");
		if (path != null) {
			return path;
		}

		if (Sys.systemName() == "Windows") {
			final path = if (haxe.configuration.isCommand) {
				final exectuable = getProcessOutput("where " + haxe.configuration.executable)[0];
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
		final haxelibExe = shellEscapeCommand(haxelib.configuration.executable);
		final output = getProcessOutput('$haxelibExe config')[0];
		return if (output == null) {
			trace("`haxelib config` call failed, Haxe Dependencies won't be populated.");
			null;
		} else {
			Path.normalize(output);
		}
	}
}

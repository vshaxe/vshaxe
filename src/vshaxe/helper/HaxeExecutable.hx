package vshaxe.helper;

import haxe.DynamicAccess;
import haxe.io.Path;
import haxe.extern.EitherType;
import sys.FileSystem;
import vshaxe.HaxeExecutableConfiguration;
import vshaxe.helper.PathHelper;

/** unprocessed config **/
private typedef RawHaxeExecutableConfig = {
	var path:String;
	var env:DynamicAccess<String>;
}

private typedef HaxeExecutablePathOrConfigBase = EitherType<String, RawHaxeExecutableConfig>;

typedef HaxeExecutablePathOrConfig = EitherType<String, RawHaxeExecutableConfig &
	{
		var ?windows:RawHaxeExecutableConfig;
		var ?linux:RawHaxeExecutableConfig;
		var ?osx:RawHaxeExecutableConfig;
	}>;

class HaxeExecutable {
	public static final SYSTEM_KEY = switch Sys.systemName() {
		case "Windows": "windows";
		case "Mac": "osx";
		default: "linux";
	};

	public var configuration(default, null):HaxeExecutableConfiguration;
	public var onDidChangeConfiguration(get, never):Event<HaxeExecutableConfiguration>;

	final _onDidChangeConfiguration:EventEmitter<HaxeExecutableConfiguration>;
	final folder:WorkspaceFolder;
	final changeConfigurationListener:Disposable;
	var rawConfig:RawHaxeExecutableConfig;

	function get_onDidChangeConfiguration()
		return _onDidChangeConfiguration.event;

	public function new(folder) {
		this.folder = folder;
		_onDidChangeConfiguration = new EventEmitter();
		updateConfig();
		changeConfigurationListener = workspace.onDidChangeConfiguration(onWorkspaceConfigurationChanged);
	}

	public function dispose() {
		changeConfigurationListener.dispose();
	}

	/** Returns true if haxe.executable setting was configured by user **/
	public function isConfigured() {
		var executableSetting = workspace.getConfiguration("haxe", folder.uri).inspect("executable");
		return executableSetting.globalValue != null || executableSetting.workspaceValue != null || executableSetting.workspaceFolderValue != null;
	}

	function onWorkspaceConfigurationChanged(change:ConfigurationChangeEvent) {
		if (change.affectsConfiguration("haxe.executable", folder.uri)) {
			var oldConfig = rawConfig;
			updateConfig();
			if (!isSame(oldConfig, rawConfig))
				_onDidChangeConfiguration.fire(configuration);
		}
	}

	static function isSame(oldConfig:RawHaxeExecutableConfig, newConfig:RawHaxeExecutableConfig):Bool {
		// ouch...
		if ((oldConfig is String) || (newConfig is String)) {
			if (oldConfig != newConfig)
				return false;
		}

		if (oldConfig.path != newConfig.path)
			return false;

		var oldKeys = oldConfig.env.keys();
		var newKeys = newConfig.env.keys();
		if (oldKeys.length != newKeys.length)
			return false;

		for (key in newKeys) {
			var oldValue = oldConfig.env[key];
			var newValue = newConfig.env[key];
			if (oldValue != newValue)
				return false;
			oldKeys.remove(key);
		}

		if (oldKeys.length > 0)
			return false;

		return true;
	}

	function updateConfig() {
		var input:Null<HaxeExecutablePathOrConfig> = workspace.getConfiguration("haxe", folder.uri).get("executable");

		var executable = "haxe";
		var env = new DynamicAccess<String>();

		function merge(conf:HaxeExecutablePathOrConfigBase) {
			if ((conf is String)) {
				executable = conf;
			} else {
				var conf:RawHaxeExecutableConfig = conf;
				if (conf.path != null)
					executable = conf.path;
				if (conf.env != null)
					env = conf.env;
			}
		}

		if (input != null) {
			merge(input);
			var systemConfig = Reflect.field(input, SYSTEM_KEY);
			if (systemConfig != null)
				merge(systemConfig);
		}

		var isCommand = false;
		if (!Path.isAbsolute(executable)) {
			var absolutePath = PathHelper.absolutize(executable, folder.uri.fsPath);
			if (FileSystem.exists(absolutePath) && !FileSystem.isDirectory(absolutePath)) {
				executable = absolutePath;
			} else {
				isCommand = true;
			}
		}

		rawConfig = input;
		configuration = {
			executable: executable,
			isCommand: isCommand,
			env: env
		}
	}
}

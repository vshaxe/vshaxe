package vshaxe.configuration;

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

typedef HaxeExecutablePathOrConfig = EitherType<String, RawHaxeExecutableConfig & {
	var ?windows:RawHaxeExecutableConfig;
	var ?linux:RawHaxeExecutableConfig;
	var ?osx:RawHaxeExecutableConfig;
}>;

class HaxeExecutable extends ConfigurationWrapper<HaxeExecutableConfiguration, RawHaxeExecutableConfig> {
	public static final SYSTEM_KEY = switch Sys.systemName() {
			case "Windows": "windows";
			case "Mac": "osx";
			default: "linux";
		};

	public function new(folder) {
		super("haxe.executable", folder);
	}

	override function isSame(oldConfig:RawHaxeExecutableConfig, newConfig:RawHaxeExecutableConfig):Bool {
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

	override function updateConfig() {
		var input:HaxeExecutablePathOrConfig = workspace.getConfiguration("haxe", folder.uri).get("executable", "haxe");

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

		merge(input);
		var systemConfig = Reflect.field(input, SYSTEM_KEY);
		if (systemConfig != null)
			merge(systemConfig);

		var isCommand = false;
		if (!Path.isAbsolute(executable)) {
			var absolutePath = PathHelper.absolutize(executable, folder.uri.fsPath);
			if (FileSystem.exists(absolutePath) && !FileSystem.isDirectory(absolutePath)) {
				executable = absolutePath;
			} else {
				isCommand = true;
				if (Sys.systemName() == "Windows" && Path.extension(executable) == "") {
					executable += ".exe";
				}
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

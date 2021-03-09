package vshaxe.configuration;

import haxe.DynamicAccess;
import haxe.extern.EitherType;

/** unprocessed config **/
private typedef RawHaxeExecutableConfig = {
	final path:String;
	final env:DynamicAccess<String>;
}

private typedef HaxeExecutablePathOrConfigBase = EitherType<String, RawHaxeExecutableConfig>;

typedef HaxeExecutablePathOrConfig = EitherType<String, RawHaxeExecutableConfig & {
	final ?windows:RawHaxeExecutableConfig;
	final ?linux:RawHaxeExecutableConfig;
	final ?osx:RawHaxeExecutableConfig;
}>;

private typedef HaxeExecutableConfiguration = vshaxe.HaxeExecutableConfiguration & {
	final ?version:String;
}

class HaxeExecutable extends BaseExecutable<HaxeExecutableConfiguration> {
	public function new(folder) {
		super("haxe", folder);
	}

	override function copyConfig():HaxeExecutableConfiguration {
		return {
			executable: configuration.executable,
			source: configuration.source,
			isCommand: configuration.isCommand,
			version: configuration.version,
			env: configuration.env
		}
	}

	override function updateConfig() {
		final input:HaxeExecutablePathOrConfig = workspace.getConfiguration("haxe", folder.uri).get("executable", "haxe");

		var executable = "auto";
		var env = new DynamicAccess<String>();
		isDefault = false;

		function merge(conf:HaxeExecutablePathOrConfigBase) {
			if (conf is String) {
				executable = conf;
			} else {
				final conf:RawHaxeExecutableConfig = conf;
				if (conf.path != null) {
					executable = conf.path;
				}
				if (conf.env != null) {
					env = conf.env;
				}
			}
		}

		merge(input);
		final systemConfig = getSystemConfig(input);
		if (systemConfig != null)
			merge(systemConfig);

		final executable = processExecutable(executable);

		configuration = {
			executable: executable.executable,
			source: executable.source,
			isCommand: executable.isCommand,
			version: getVersion(executable.executable),
			env: env
		}
	}

	function getVersion(haxeExecutable:String):Null<String> {
		final result = readCommand(haxeExecutable, ["-version"]);
		return if (result != null) {
			result.split(" ")[0].trim();
		} else {
			null;
		}
	}
}

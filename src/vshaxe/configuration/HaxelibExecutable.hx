package vshaxe.configuration;

import haxe.extern.EitherType;

private typedef RawHaxelibExecutableConfig = {
	final path:String;
}

private typedef HaxelibExecutablePathOrConfigBase = EitherType<String, RawHaxelibExecutableConfig>;

typedef HaxelibExecutablePathOrConfig = EitherType<String, RawHaxelibExecutableConfig & {
	final ?windows:RawHaxelibExecutableConfig;
	final ?linux:RawHaxelibExecutableConfig;
	final ?osx:RawHaxelibExecutableConfig;
}>;

private typedef HaxelibExecutableConfiguration = vshaxe.HaxelibExecutableConfiguration & {
	final ?version:String;
}

class HaxelibExecutable extends BaseExecutable<HaxelibExecutableConfiguration> {
	public function new(folder) {
		super("haxelib", folder);
	}

	override function updateConfig() {
		final input:HaxelibExecutablePathOrConfig = workspace.getConfiguration("haxelib", folder.uri).get("executable", "haxelib");

		var executable = "auto";
		isDefault = false;

		function merge(conf:HaxelibExecutablePathOrConfigBase) {
			if (conf is String) {
				executable = conf;
			} else {
				final conf:RawHaxelibExecutableConfig = conf;
				if (conf.path != null) {
					executable = conf.path;
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
			version: getVersion(executable.isCommand ? executable.executable : '"' + executable.executable + '"')
		}
	}

	function getVersion(haxelibExecutable:String):Null<String> {
		return readCommand(haxelibExecutable, ["version"]);
	}
}

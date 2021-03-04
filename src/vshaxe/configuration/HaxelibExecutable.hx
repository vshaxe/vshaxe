package vshaxe.configuration;

import haxe.extern.EitherType;
import haxe.io.Path;
import js.node.Buffer;
import js.node.ChildProcess;
import sys.FileSystem;
import vshaxe.HaxelibExecutableSource;
import vshaxe.helper.PathHelper;

private typedef RawHaxelibExecutableConfig = {
	final path:String;
}

private typedef HaxelibExecutablePathOrConfigBase = EitherType<String, RawHaxelibExecutableConfig>;

typedef HaxelibExecutablePathOrConfig = EitherType<String, RawHaxelibExecutableConfig & {
	final ?windows:RawHaxelibExecutableConfig;
	final ?linux:RawHaxelibExecutableConfig;
	final ?osx:RawHaxelibExecutableConfig;
}>;

private typedef HaxeExecutableConfiguration = vshaxe.HaxelibExecutableConfiguration & {
	final ?version:String;
}

class HaxelibExecutable extends ConfigurationWrapper<HaxeExecutableConfiguration> {
	public static final SYSTEM_KEY = switch Sys.systemName() {
			case "Windows": "windows";
			case "Mac": "osx";
			default: "linux";
		};

	public var isDefault(default, null):Bool = false;

	var autoResolveProvider:Null<String>;
	var autoResolveValue:Null<String>;

	public function new(folder) {
		super("haxelib.executable", folder);
	}

	public function setAutoResolveValue(provider:Null<String>, value:Null<String>) {
		autoResolveProvider = provider;
		autoResolveValue = value;
		update();
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
		final systemConfig = Reflect.field(input, SYSTEM_KEY);
		if (systemConfig != null)
			merge(systemConfig);

		var source = Settings;
		if (executable == "auto") {
			if (autoResolveProvider == null || autoResolveValue == null) {
				executable = "haxelib";
				isDefault = true;
			} else {
				executable = autoResolveValue;
				source = Provider(autoResolveProvider);
			}
		}

		var isCommand = false;
		if (!Path.isAbsolute(executable)) {
			final absolutePath = PathHelper.absolutize(executable, folder.uri.fsPath);
			if (FileSystem.exists(absolutePath) && !FileSystem.isDirectory(absolutePath)) {
				executable = absolutePath;
			} else {
				isCommand = true;
				// Fix tasks not working on Windows with a `haxelib` folder next to `haxelib.exe`
				if (Sys.systemName() == "Windows" && Path.extension(executable) == "") {
					executable += ".exe";
				}
			}
		}

		configuration = {
			executable: executable,
			source: source,
			isCommand: isCommand,
			version: getVersion(isCommand ? executable : '"' + executable + '"')
		}
	}

	function getVersion(haxelibExecutable:String):Null<String> {
		final result = ChildProcess.spawnSync(haxelibExecutable, ["version"], {cwd: folder.uri.fsPath});
		if (result != null && result.stderr != null) {
			var output = (result.stderr : Buffer).toString().trim();
			if (output == "") {
				output = (result.stdout : Buffer).toString().trim();
			}

			return output;
		}
		return null;
	}
}

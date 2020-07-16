package vshaxe.configuration;

import haxe.DynamicAccess;
import haxe.extern.EitherType;
import haxe.io.Path;
import js.node.Buffer;
import js.node.ChildProcess;
import sys.FileSystem;
import vshaxe.HaxeExecutableSource;
import vshaxe.helper.PathHelper;

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

class HaxeExecutable extends ConfigurationWrapper<HaxeExecutableConfiguration> {
	public static final SYSTEM_KEY = switch Sys.systemName() {
			case "Windows": "windows";
			case "Mac": "osx";
			default: "linux";
		};

	public var isDefault(default, null):Bool = false;

	var autoResolveProvider:Null<String>;
	var autoResolveValue:Null<String>;

	public function new(folder) {
		super("haxe.executable", folder);
	}

	public function setAutoResolveValue(provider:Null<String>, value:Null<String>) {
		autoResolveProvider = provider;
		autoResolveValue = value;
		update();
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
		final systemConfig = Reflect.field(input, SYSTEM_KEY);
		if (systemConfig != null)
			merge(systemConfig);

		var source = Settings;
		if (executable == "auto") {
			if (autoResolveProvider == null || autoResolveValue == null) {
				executable = "haxe";
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
				if (Sys.systemName() == "Windows" && Path.extension(executable) == "") {
					executable += ".exe";
				}
			}
		}

		configuration = {
			executable: executable,
			source: source,
			isCommand: isCommand,
			env: env,
			version: getVersion(executable)
		}
	}

	function getVersion(haxeExecutable:String):Null<String> {
		final result = ChildProcess.spawnSync(haxeExecutable, ["-version"], {cwd: folder.uri.fsPath});
		if (result != null && result.stderr != null) {
			var output = (result.stderr : Buffer).toString().trim();
			if (output == "") {
				output = (result.stdout : Buffer).toString().trim(); // haxe 4.0 prints -version output to stdout instead
			}

			if (output != null) {
				return output.split(" ")[0].trim();
			}
		}
		return null;
	}
}

package vshaxe.configuration;

import haxe.io.Path;
import js.node.Buffer;
import js.node.ChildProcess;
import sys.FileSystem;
import vshaxe.ExecutableSource;
import vshaxe.helper.PathHelper;

typedef ExecutableConfiguration = {
	var executable(default, never):String;
	var source(default, never):ExecutableSource;
	var isCommand(default, never):Bool;
}

class BaseExecutable<Config> extends ConfigurationWrapper<Config> {
	public static final SYSTEM_KEY = switch Sys.systemName() {
			case "Windows": "windows";
			case "Mac": "osx";
			default: "linux";
		};

	public var isDefault(default, null):Bool = false;

	var autoResolveProvider:Null<String>;
	var autoResolveValue:Null<String>;
	final name:String;

	public function new(name, folder) {
		this.name = name;
		super('$name.executable', folder);
	}

	public function setAutoResolveValue(provider:Null<String>, value:Null<String>) {
		autoResolveProvider = provider;
		autoResolveValue = value;
		update();
	}

	inline function getSystemConfig(input:Any) {
		return Reflect.field(input, SYSTEM_KEY);
	}

	inline function processExecutable(executable:String):ExecutableConfiguration {
		var source = Settings;
		if (executable == "auto") {
			if (autoResolveProvider == null || autoResolveValue == null) {
				executable = name;
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
				// Fix tasks not working on Windows with a `haxe` folder next to `haxe.exe`
				if (Sys.systemName() == "Windows" && Path.extension(executable) == "") {
					executable += ".exe";
				}
			}
		}

		return {
			executable: executable,
			source: source,
			isCommand: isCommand,
		}
	}

	function readCommand(executable:String, args:Array<String>):Null<String> {
		final result = ChildProcess.spawnSync(executable, args, {cwd: folder.uri.fsPath});
		if (result != null && result.stderr != null) {
			var output = (result.stderr : Buffer).toString().trim();
			if (output == "") {
				output = (result.stdout : Buffer).toString().trim(); // haxe 4.0 prints -version output to stdout instead
			}
			return output.trim();
		}
		return null;
	}
}

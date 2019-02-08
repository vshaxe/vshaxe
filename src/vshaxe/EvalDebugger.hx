package vshaxe;

import vshaxe.HaxeExecutableConfiguration;
import vshaxe.display.DisplayArguments;

typedef EvalLaunchDebugConfiguration = DebugConfiguration & {
	var ?cwd:String;
	var ?args:Array<String>;
	var stopOnEntry:Bool;
	var haxeExecutable:HaxeExecutableConfiguration;
}

class EvalDebugger {
	static inline final DEBUG_TYPE = "haxe-eval";

	final displayArguments:DisplayArguments;
	final haxeExecutable:HaxeExecutable;

	public function new(displayArguments:DisplayArguments, haxeExecutable:HaxeExecutable) {
		this.displayArguments = displayArguments;
		this.haxeExecutable = haxeExecutable;
		debug.registerDebugConfigurationProvider(DEBUG_TYPE, {resolveDebugConfiguration: resolveDebugConfiguration});
	}

	public function resolveDebugConfiguration(folder:Null<WorkspaceFolder>, config:DebugConfiguration,
			?token:CancellationToken):ProviderResult<DebugConfiguration> {
		var config:EvalLaunchDebugConfiguration = cast config;
		if (config.type == null) {
			config.type = DEBUG_TYPE;
			config.name = "Haxe Interpreter";
			config.request = "launch";
		}
		if (config.cwd == null) {
			config.cwd = folder.uri.fsPath;
		}
		if (config.args == null) {
			config.args = displayArguments.arguments;
		}
		config.haxeExecutable = haxeExecutable.configuration;
		return config;
	}
}

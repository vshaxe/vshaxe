package vshaxe;

import vshaxe.display.DisplayArguments;

typedef EvalLaunchDebugConfiguration = DebugConfiguration & {
	var cwd:String;
	var args:Array<String>;
	var stopOnEntry:Bool;
}

class EvalDebugger {
	static inline final DEBUG_TYPE = "haxe-eval";

	final displayArguments:DisplayArguments;

	public function new(displayArguments:DisplayArguments) {
		this.displayArguments = displayArguments;
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
		return config;
	}
}

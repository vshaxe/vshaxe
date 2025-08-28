package vshaxe;

import haxe.io.Path;
import vshaxe.HaxeExecutableConfiguration;
import vshaxe.display.DisplayArguments;

typedef EvalLaunchDebugConfiguration = DebugConfiguration & {
	var ?cwd:String;
	var ?args:Array<String>;
	var stopOnEntry:Bool;
	var haxeExecutable:HaxeExecutableConfiguration;
	var mergeScopes:Bool;
	var showGeneratedVariables:Bool;
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
		final config:EvalLaunchDebugConfiguration = cast config;
		if (config.type == null) {
			config.type = DEBUG_TYPE;
			config.name = "Haxe Interpreter";
			config.request = "launch";
		}
		if (config.cwd == null && folder != null) {
			config.cwd = folder.uri.fsPath;
		}
		if (config.args == null) {
			if (displayArguments.arguments == null) {
				if (window.activeTextEditor != null) {
					var document = window.activeTextEditor.document;
					var baseFileName = Path.withoutDirectory(document.fileName);
					if (baseFileName.endsWith(".hx")) {
						var dirPath = Path.directory(document.fileName);
						var mainClassName = baseFileName.substr(0, baseFileName.length - 3);
						config.args = ["--interp", "-cp", dirPath, "--main", mainClassName];
					}
				}
				if (config.args == null) {
					window.showErrorMessage('No Haxe configuration exists. '
						+ 'Please create a HXML file, use the "haxe.configurations" setting or set `args` in the launch configuration.');
					return js.Lib.undefined;
				}
			} else {
				config.args = displayArguments.arguments;
			}
		}
		config.haxeExecutable = haxeExecutable.configuration;
		config.mergeScopes = workspace.getConfiguration("haxe.debug").get("mergeScopes", true);
		config.showGeneratedVariables = workspace.getConfiguration("haxe.debug").get("showGeneratedVariables", false);
		return config;
	}
}

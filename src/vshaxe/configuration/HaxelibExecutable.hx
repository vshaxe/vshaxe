package vshaxe.configuration;

class HaxelibExecutable extends ConfigurationWrapper<HaxelibExecutableConfiguration> {
	var autoResolveValue:Null<String>;

	public function new(folder) {
		super("haxelib.executable", folder);
	}

	public function setAutoResolveValue(value:Null<String>) {
		autoResolveValue = value;
		update();
	}

	function copyConfig():HaxelibExecutableConfiguration {
		return {
			executable: configuration.executable
		}
	}

	function updateConfig() {
		var executable = workspace.getConfiguration("haxelib", folder.uri).get("executable", "haxelib");
		if (executable == "auto") {
			executable = if (autoResolveValue == null) "haxelib" else autoResolveValue;
		}
		configuration = {
			executable: executable
		}
	}
}

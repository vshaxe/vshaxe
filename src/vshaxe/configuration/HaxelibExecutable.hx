package vshaxe.configuration;

class HaxelibExecutable extends ConfigurationWrapper<String> {
	var autoResolveValue:Null<String>;

	public function new(folder) {
		super("haxelib.executable", folder);
	}

	public function setAutoResolveValue(value:Null<String>) {
		autoResolveValue = value;
		update();
	}

	override function updateConfig() {
		configuration = workspace.getConfiguration("haxelib", folder.uri).get("executable", "haxelib");
		if (configuration == "auto") {
			configuration = if (autoResolveValue == null) "haxelib" else autoResolveValue;
		}
	}
}

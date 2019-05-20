package vshaxe.configuration;

class HaxelibExecutable extends ConfigurationWrapper<String, String> {
	public function new(folder) {
		super("haxelib.executable", folder);
	}

	override function updateConfig() {
		var input = workspace.getConfiguration("haxelib", folder.uri).get("executable", "haxelib");
		rawConfig = configuration = input;
	}
}

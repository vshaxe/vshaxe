package vshaxe.configuration;

class HaxelibExecutable extends ConfigurationWrapper<String, String> {
	public function new(folder) {
		super("haxelib.executable", folder);
	}

	override function updateConfig() {
		var path = workspace.getConfiguration("haxelib", folder.uri).get("executable", "haxelib");
		rawConfig = path;
		configuration = ExecutableHelper.resolve(folder.uri, path, "haxelib");
	}
}

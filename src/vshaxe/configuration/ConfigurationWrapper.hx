package vshaxe.configuration;

import haxe.Json;

abstract class ConfigurationWrapper<Config> {
	public final accessor:ConfigurationAccessor<Config>;
	@:nullSafety(Off) public var configuration(default, null):Config;
	public var onDidChangeConfiguration(get, never):Event<Config>;

	final section:String;
	final folder:WorkspaceFolder;
	final changeConfigurationListener:Disposable;

	final function get_onDidChangeConfiguration()
		return accessor.onDidChangeConfiguration;

	public function new(section, folder) {
		this.section = section;
		this.folder = folder;
		accessor = new ConfigurationAccessor();
		@:nullSafety(Off) updateConfig();
		accessor.set(@:nullSafety(Off) copyConfig());
		changeConfigurationListener = workspace.onDidChangeConfiguration(onWorkspaceConfigurationChanged);
	}

	public function dispose() {
		changeConfigurationListener.dispose();
	}

	final function onWorkspaceConfigurationChanged(change:ConfigurationChangeEvent) {
		if (change.affectsConfiguration(section, folder.uri)) {
			update();
		}
	}

	function update() {
		final oldConfig = configuration;
		updateConfig();
		if (!isSame(configuration, oldConfig))
			accessor.set(copyConfig());
	}

	function isSame(oldConfig:Config, newConfig:Config):Bool {
		return Json.stringify(oldConfig) == Json.stringify(newConfig);
	}

	abstract function updateConfig():Void;

	abstract function copyConfig():Config;
}

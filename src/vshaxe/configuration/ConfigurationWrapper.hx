package vshaxe.configuration;

import haxe.Json;

class ConfigurationWrapper<Config> {
	@:nullSafety(Off) public var configuration(default, null):Config;
	public var onDidChangeConfiguration(get, never):Event<Config>;

	final _onDidChangeConfiguration:EventEmitter<Config>;
	final section:String;
	final folder:WorkspaceFolder;
	final changeConfigurationListener:Disposable;

	final function get_onDidChangeConfiguration()
		return _onDidChangeConfiguration.event;

	public function new(section, folder) {
		this.section = section;
		this.folder = folder;
		_onDidChangeConfiguration = new EventEmitter();
		@:nullSafety(Off) updateConfig();
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
			_onDidChangeConfiguration.fire(configuration);
	}

	function isSame(oldConfig:Config, newConfig:Config):Bool {
		return Json.stringify(oldConfig) == Json.stringify(newConfig);
	}

	function updateConfig() {
		throw "to be implemented";
	}
}

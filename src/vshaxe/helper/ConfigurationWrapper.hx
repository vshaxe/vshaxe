package vshaxe.helper;

class ConfigurationWrapper<Config, RawConfig> {
	@:nullSafety(Off) public var configuration(default, null):Config;
	public var onDidChangeConfiguration(get, never):Event<Config>;

	final _onDidChangeConfiguration:EventEmitter<Config>;
	final section:String;
	final folder:WorkspaceFolder;
	final changeConfigurationListener:Disposable;
	@:nullSafety(Off) var rawConfig:RawConfig;

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
			var oldConfig = rawConfig;
			updateConfig();
			if (!isSame(oldConfig, rawConfig))
				_onDidChangeConfiguration.fire(configuration);
		}
	}

	function isSame(oldConfig:RawConfig, newConfig:RawConfig):Bool {
		return oldConfig != newConfig;
	}

	function updateConfig() {
		throw "to be implemented";
	}
}

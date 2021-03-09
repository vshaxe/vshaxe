package vshaxe.configuration;

class ConfigurationAccessor<Config> {
	@:nullSafety(Off) public var configuration(default, null):Config;
	public var onDidChangeConfiguration(get, never):Event<Config>;

	final _onDidChangeConfiguration:EventEmitter<Config>;

	final function get_onDidChangeConfiguration()
		return _onDidChangeConfiguration.event;

	public function new() {
		_onDidChangeConfiguration = new EventEmitter();
	}

	@:allow(vshaxe.configuration.ConfigurationWrapper)
	inline function set(value:Config):Void {
		configuration = value;
		_onDidChangeConfiguration.fire(value);
	}
}

package vshaxe.display;

class DisplayArguments {
	public static inline final ProviderNameKey = new MementoKey<String>("haxe.displayArgumentsProviderName");

	public final providers = new Map<String, DisplayArgumentsProvider>();
	public var currentProvider(default, null):Null<String>;
	public var onDidChangeCurrentProvider(get, never):Event<Null<String>>;
	public var arguments(default, null):Array<String>;
	public var onDidChangeArguments(get, never):Event<Array<String>>;

	final folder:WorkspaceFolder;
	final mementos:WorkspaceMementos;
	final _onDidChangeArguments = new EventEmitter<Array<String>>();
	final _onDidChangeCurrentProvider = new EventEmitter<Null<String>>();

	inline function get_onDidChangeCurrentProvider()
		return _onDidChangeCurrentProvider.event;

	inline function get_onDidChangeArguments()
		return _onDidChangeArguments.event;

	public function new(folder, mementos) {
		this.folder = folder;
		this.mementos = mementos;
	}

	public function dispose() {
		_onDidChangeArguments.dispose();
		_onDidChangeCurrentProvider.dispose();
	}

	public function registerProvider(name:String, provider:DisplayArgumentsProvider):Disposable {
		if (isProviderRegistered(name)) {
			throw new js.Error('Display arguments provider `$name` is already registered.');
		}

		providers[name] = provider;

		var savedProvider = mementos.get(folder, ProviderNameKey);
		if (currentProvider == null || savedProvider == null || savedProvider == name) {
			setCurrentProvider(name, false);
		}

		return new Disposable(function() {
			providers.remove(name);
			if (name == currentProvider)
				setCurrentProvider(null, false);
		});
	}

	public inline function isProviderRegistered(name:String):Bool {
		return providers.exists(name);
	}

	public inline function selectProvider(name:String) {
		setCurrentProvider(name, true);
	}

	function setCurrentProvider(name:Null<String>, persist:Bool) {
		if (currentProvider != null) {
			var provider = providers[currentProvider];
			if (provider != null)
				provider.deactivate();
		}

		currentProvider = name;
		commands.executeCommand("setContext", "haxeCompletionProvider", name);

		if (name != null) {
			var provider = providers[name];
			if (provider != null)
				provider.activate(provideArguments);
		}

		if (persist) {
			mementos.set(folder, ProviderNameKey, name);
		}

		_onDidChangeCurrentProvider.fire(currentProvider);
	}

	function provideArguments(newArguments:Array<String>) {
		if (!newArguments.equals(arguments)) {
			arguments = newArguments;
			_onDidChangeArguments.fire(newArguments);
		}
	}
}

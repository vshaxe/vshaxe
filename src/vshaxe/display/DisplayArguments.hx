package vshaxe.display;

class DisplayArguments {
    final context:ExtensionContext;
    final _onDidChangeArguments = new EventEmitter<Array<String>>();
    final _onDidChangeCurrentProvider = new EventEmitter<Null<String>>();

    public final providers = new Map<String, DisplayArgumentsProvider>();

    public var currentProvider(default,null):Null<String>;
    public var onDidChangeCurrentProvider(get,never):Event<Null<String>>;
    inline function get_onDidChangeCurrentProvider() return _onDidChangeCurrentProvider.event;

    public var arguments(default,null):Array<String>;
    public var onDidChangeArguments(get,never):Event<Array<String>>;
    inline function get_onDidChangeArguments() return _onDidChangeArguments.event;

    public static final ProviderNameKey = new HaxeMementoKey<String>("displayArgumentsProviderName");

    public function new(context:ExtensionContext) {
        this.context = context;
        context.subscriptions.push(_onDidChangeArguments);
        context.subscriptions.push(_onDidChangeCurrentProvider);
    }

    public function registerProvider(name:String, provider:DisplayArgumentsProvider):Disposable {
        if (isProviderRegistered(name)) {
            throw new js.Error('Display arguments provider `$name` is already registered.');
        }

        providers[name] = provider;

        var savedProvider = context.getWorkspaceState().get(ProviderNameKey);
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
            if (provider != null) provider.deactivate();
        }

        currentProvider = name;

        if (name != null) {
            var provider = providers[name];
            if (provider != null)
                provider.activate(provideArguments);
        }

        if (persist) {
            context.getWorkspaceState().update(ProviderNameKey, name);
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

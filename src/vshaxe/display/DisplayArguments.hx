package vshaxe.display;

class DisplayArguments {
    static var statusBarWarningThemeColor = new ThemeColor("errorForeground");

    var context:ExtensionContext;
    var statusBarItem:StatusBarItem;
    var providers:Map<String, DisplayArgumentsProvider>;
    var currentProvider:Null<String>;
    var _onDidChangeArguments:EventEmitter<Array<String>>;

    public var arguments(default,null):Array<String>;

    public var onDidChangeArguments(get,never):Event<Array<String>>;
    inline function get_onDidChangeArguments() return _onDidChangeArguments.event;

    public function new(context:ExtensionContext) {
        this.context = context;
        providers = new Map();
        _onDidChangeArguments = new EventEmitter();
        context.subscriptions.push(_onDidChangeArguments);

        statusBarItem = window.createStatusBarItem(Left, 11);
        statusBarItem.tooltip = "Select Haxe Completion Provider";
        statusBarItem.command = SelectDisplayArgumentsProvider;
        context.subscriptions.push(statusBarItem);

        context.registerHaxeCommand(SelectDisplayArgumentsProvider, selectProvider);
        updateStatusBarItem();
    }

    public function registerProvider(name:String, provider:DisplayArgumentsProvider):Disposable {
        if (providers.exists(name)) {
            throw new js.Error('Display arguments provider `$name` is already registered.');
        }

        providers[name] = provider;

        var current = getCurrentProviderName();
        if (current == null || current == name)
            setCurrentProvider(name, false);
        else
            updateStatusBarItem();

        return new Disposable(function() {
            providers.remove(name);
            if (name == currentProvider)
                setCurrentProvider(null, false);
            updateStatusBarItem();
        });
    }

    function selectProvider() {
        var items:Array<QuickPickItem> = [for (name in providers.keys()) {
            {label: name, description: providers[name].description};
        }];

        if (items.length == 0) {
            window.showErrorMessage("No Haxe completion providers registered.");
            return;
        }

        items.moveToStart(item -> item.label == currentProvider);
        window.showQuickPick(items, {placeHolder: "Select Haxe Completion Provider"}).then(item -> if (item != null) setCurrentProvider(item.label, true));
    }

    inline function getCurrentProviderName():Null<String> {
        return context.workspaceState.get(HaxeMemento.DisplayArgumentsProviderName);
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
            context.workspaceState.update(HaxeMemento.DisplayArgumentsProviderName, name);
        }
        updateStatusBarItem();
    }

    function provideArguments(newArguments:Array<String>) {
        if (!newArguments.equals(arguments)) {
            arguments = newArguments;
            _onDidChangeArguments.fire(newArguments);
        }
    }

    function updateStatusBarItem() {
        if (currentProvider == null) {
            statusBarItem.hide();
            return;
        }

        var label = currentProvider;
        var color = null;
        var provider = providers[currentProvider];
        if (provider == null) {
            label = '$currentProvider (not available)'; // selected but not (yet?) loaded
            color = statusBarWarningThemeColor;
        }

        statusBarItem.color = color;
        statusBarItem.text = '$(gear) $label';
        statusBarItem.show();
    }
}

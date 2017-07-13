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
        statusBarItem.tooltip = "Haxe: Select Completion Provider...";
        statusBarItem.command = SelectDisplayArgumentsProvider;
        context.subscriptions.push(statusBarItem);

        context.registerHaxeCommand(SelectDisplayArgumentsProvider, selectProvider);

        context.subscriptions.push(window.onDidChangeActiveTextEditor(_ -> updateStatusBarItem()));

        updateStatusBarItem();
    }

    public function registerProvider(name:String, provider:DisplayArgumentsProvider):Disposable {
        if (providers.exists(name)) {
            throw new js.Error('Display arguments provider `$name` is already registered.');
        }

        providers[name] = provider;

        if (getCurrentProviderName() == name)
            setCurrentProvider(name);
        else
            updateStatusBarItem();

        return new Disposable(function() {
            providers.remove(name);
            if (name == currentProvider)
                setCurrentProvider(null);
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

        window.showQuickPick(items, {placeHolder: "Select Haxe completion provider"}).then(item -> if (item != null) setCurrentProvider(item.label));
    }

    inline function getCurrentProviderName():Null<String> {
        var providerName = context.workspaceState.get(HaxeMemento.DisplayArgumentsProviderName);
        if (providerName == null && providers.count() == 1) {
            providerName = providers.keys().next();
        }
        return providerName;
    }

    function setCurrentProvider(name:Null<String>) {
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

        context.workspaceState.update(HaxeMemento.DisplayArgumentsProviderName, name);
        updateStatusBarItem();
    }

    function provideArguments(newArguments:Array<String>) {
        if (!newArguments.equals(arguments)) {
            arguments = newArguments;
            _onDidChangeArguments.fire(newArguments);
        }
    }

    function updateStatusBarItem() {
        if (providers.count() <= 1) {
            statusBarItem.hide();
            return;
        }

        var label, color;
        if (currentProvider == null) {
            label = "Select Haxe completion provider...";
            color = statusBarWarningThemeColor; // TODO: different color?
        } else {
            var provider = providers[currentProvider];
            if (provider == null) {
                label = '$currentProvider (not available)'; // selected but not (yet?) loaded
                color = statusBarWarningThemeColor;
            } else {
                label = currentProvider;
                color = null;
            }
        }
        statusBarItem.color = color;
        statusBarItem.text = '$(gear) $label';
        statusBarItem.show();
    }
}

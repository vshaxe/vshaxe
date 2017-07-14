package vshaxe.display;

class HaxeDisplayArgumentsProvider {
    var context:ExtensionContext;
    var api:Vshaxe;
    var hxmlDiscovery:HxmlDiscovery;
    var statusBarItem:StatusBarItem;
    var provideArguments:Array<String>->Void;
    var providerDisposable:Disposable;

    public var description(default,never):String = "Project using haxe.displayConfigurations or HXML files (built-in)";

    public function new(context:ExtensionContext, api:Vshaxe, hxmlDiscovery:HxmlDiscovery) {
        this.context = context;
        this.api = api;
        this.hxmlDiscovery = hxmlDiscovery;

        statusBarItem = window.createStatusBarItem(Left, 10);
        statusBarItem.tooltip = "Select Haxe Configuration";
        statusBarItem.command = SelectDisplayConfiguration;
        context.subscriptions.push(statusBarItem);

        context.registerHaxeCommand(SelectDisplayConfiguration, selectConfiguration);

        context.subscriptions.push(workspace.onDidChangeConfiguration(_ -> refresh()));
        hxmlDiscovery.onDidChangeHxmlFiles(_ -> refresh());

        fixIndex();
        updateStatusBarItem();
        updateDisplayArgumentsProviderRegistration();
    }

    public function activate(provideArguments) {
        this.provideArguments = provideArguments;
        provideArguments(getConfiguration());
        updateStatusBarItem();
    }

    public function deactivate() {
        this.provideArguments = null;
        updateStatusBarItem();
    }

    function fixIndex() {
        var index = getIndex();
        var configs = getConfigurations();
        if (configs == null || index >= configs.length)
            setIndex(0);
    }

    function selectConfiguration() {
        var configs = getConfigurations();
        if (configs == null || configs.length == 0) {
            window.showErrorMessage("No Haxe display configurations are available. Please provide the haxe.displayConfigurations setting.", ({title: "Edit settings"} : vscode.MessageItem)).then(function(button) {
                if (button == null)
                    return;
                workspace.getConfiguration("haxe").update("displayConfigurations", [], false).then(_ ->
                    workspace.openTextDocument(workspace.rootPath + "/.vscode/settings.json").then(
                        document -> window.showTextDocument(document)
                ));
            });
            return;
        }

        var items:Array<DisplayConfigurationPickItem> = [];
        for (index in 0...configs.length) {
            var args = configs[index];
            var label = args.join(" ");
            items.push({
                label: "" + index,
                description: label,
                index: index,
            });
        }

        items.moveToStart(item -> item.index == getIndex());
        window.showQuickPick(items, {matchOnDescription: true, placeHolder: "Select Haxe Display Configuration"}).then(function(choice:DisplayConfigurationPickItem) {
            if (choice == null || choice.index == getIndex())
                return;
            setIndex(choice.index);
        });
    }

    function refresh() {
        fixIndex();
        updateStatusBarItem();
        updateDisplayArgumentsProviderRegistration();
        notifyConfigurationChange();
    }

    function updateDisplayArgumentsProviderRegistration() {
        var config = getConfigurations();
        var isActive = config != null && config.length > 0;

        if (isActive && providerDisposable == null) {
            providerDisposable = api.registerDisplayArgumentsProvider("Haxe", this);
        } else if (!isActive && providerDisposable != null) {
            providerDisposable.dispose();
            providerDisposable = null;
        }
    }

    function updateStatusBarItem() {
        var configs = getConfigurations();
        if (provideArguments != null && configs != null && configs.length > 0) {
            var index = getIndex();
            statusBarItem.text = configs[index].join(" ");
            statusBarItem.show();
            return;
        }

        statusBarItem.hide();
    }

    function getConfigurations():Array<Array<String>> {
        var configs:Array<Array<String>> = workspace.getConfiguration("haxe").get("displayConfigurations");
        if (configs == null) configs = [] else configs = configs.copy();
        for (hxmlFile in hxmlDiscovery.hxmlFiles) {
            var hxmlConfig = [hxmlFile];
            if (!configs.exists(config -> config.equals(hxmlConfig))) {
                configs.push(hxmlConfig);
            }
        }
        return configs;
    }

    public inline function getConfiguration():Array<String> {
        return getConfigurations()[getIndex()];
    }

    public inline function getIndex():Int {
        return context.workspaceState.get(HaxeMemento.DisplayConfigurationIndex, 0);
    }

    function setIndex(index:Int) {
        context.workspaceState.update(HaxeMemento.DisplayConfigurationIndex, index);
        updateStatusBarItem();
        notifyConfigurationChange();
    }

    inline function notifyConfigurationChange() {
        if (provideArguments != null)
            provideArguments(getConfiguration());
    }
}

private typedef DisplayConfigurationPickItem = {
    >QuickPickItem,
    var index:Int;
}

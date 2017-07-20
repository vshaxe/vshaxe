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
        hxmlDiscovery.onDidChangeFiles(_ -> refresh());

        refresh();
    }

    var configurations:Array<Configuration>;

    function updateConfigurations() {
        var configs:Array<Array<String>> = workspace.getConfiguration("haxe").get("displayConfigurations");
        if (configs == null) configs = [];

        configurations = [];
        for (i in 0...configs.length)
            configurations.push({kind: Configured(i), args: configs[i]});

        for (hxmlFile in hxmlDiscovery.files) {
            var hxmlConfig = [hxmlFile];
            if (!configs.exists(config -> config.equals(hxmlConfig))) {
                configurations.push({kind: Discovered(hxmlFile), args: hxmlConfig});
            }
        }
    }

    public function activate(provideArguments) {
        this.provideArguments = provideArguments;
        var config = getCurrent();
        updateStatusBarItem(config);
        notifyConfigurationChange(config);
    }

    public function deactivate() {
        this.provideArguments = null;
        updateStatusBarItem(null);
    }

    function selectConfiguration() {
        if (configurations.length == 0) {
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
        for (conf in configurations) {
            var label, desc;
            switch conf.kind {
                case Discovered(id):
                    label = id;
                    desc = "auto-discovered";
                case Configured(_):
                    label = conf.args.join(" ");
                    desc = "from settings.json";
            }
            items.push({
                label: label,
                description: desc,
                config: conf,
            });
        }

        var current = getCurrent();
        if (current != null)
            items.moveToStart(item -> item.config == current);
        window.showQuickPick(items, {matchOnDescription: true, placeHolder: "Select Haxe Display Configuration"}).then(function(choice:DisplayConfigurationPickItem) {
            if (choice == null || choice.config == current)
                return;
            setCurrent(choice.config);
        });
    }

    function getCurrent():Null<Configuration> {
        var selection:SavedSelection = context.workspaceState.get(HaxeMemento.DisplayConfigurationIndex, 0);
        if ((selection is Int)) {
            for (conf in configurations) {
                switch conf.kind {
                    case Configured(idx) if (idx == selection):
                        return conf;
                    case _:
                }
            }
        } else {
            for (conf in configurations) {
                switch conf.kind {
                    case Discovered(id) if (id == selection):
                        return conf;
                    case _:
                }
            }
        }
        return null;
    }

    function setCurrent(config:Configuration) {
        context.workspaceState.update(HaxeMemento.DisplayConfigurationIndex, switch config.kind {
            case Configured(index): index;
            case Discovered(id): id;
        });
        updateStatusBarItem(config);
        notifyConfigurationChange(config);
    }

    function refresh() {
        updateConfigurations();
        updateDisplayArgumentsProviderRegistration();
        var config = getCurrent();
        if (config == null && configurations.length > 0) {
            config = configurations[0];
            setCurrent(config);
        } else {
            updateStatusBarItem(config);
            notifyConfigurationChange(config);
        }
    }

    function updateDisplayArgumentsProviderRegistration() {
        var isActive = configurations.length > 0;
        if (isActive && providerDisposable == null) {
            providerDisposable = api.registerDisplayArgumentsProvider("Haxe", this);
        } else if (!isActive && providerDisposable != null) {
            providerDisposable.dispose();
            providerDisposable = null;
        }
    }

    function updateStatusBarItem(config:Configuration) {
        if (provideArguments != null && config != null) {
            statusBarItem.text = config.args.join(" ");
            statusBarItem.show();
            return;
        }

        statusBarItem.hide();
    }

    inline function notifyConfigurationChange(config:Configuration) {
        if (provideArguments != null)
            provideArguments(if (config == null) [] else config.args);
    }
}

private typedef DisplayConfigurationPickItem = {
    >QuickPickItem,
    var config:Configuration;
}

private typedef Configuration = {
    var kind:ConfigurationKind;
    var args:Array<String>;
}

private enum ConfigurationKind {
    Configured(index:Int);
    Discovered(id:String);
}

private typedef SavedSelection = haxe.extern.EitherType<Int,String>;

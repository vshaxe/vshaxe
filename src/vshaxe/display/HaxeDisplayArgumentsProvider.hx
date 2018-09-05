package vshaxe.display;

import haxe.extern.EitherType;

class HaxeDisplayArgumentsProvider {
	final context:ExtensionContext;
	final displayArguments:DisplayArguments;
	final hxmlDiscovery:HxmlDiscovery;
	final statusBarItem:StatusBarItem;
	var provideArguments:Array<String>->Void;
	var providerDisposable:Disposable;
	var configurations:Array<Configuration>;

	public var configurationCount(get, never):Int;

	inline function get_configurationCount()
		return configurations.length;

	public var isActive(get, never):Bool;

	inline function get_isActive()
		return provideArguments != null;

	public var description(default, never) = "Project using haxe.displayConfigurations or HXML files (built-in)";

	public function new(context:ExtensionContext, displayArguments:DisplayArguments, hxmlDiscovery:HxmlDiscovery) {
		this.context = context;
		this.displayArguments = displayArguments;
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

	function updateConfigurations() {
		var configs:Array<SettingsConfiguration> = workspace.getConfiguration("haxe").get("displayConfigurations");
		if (configs == null)
			configs = [];

		configurations = [];
		for (i in 0...configs.length) {
			var config = configs[i];
			var args = null;
			var label = null;
			if (Std.is(config, Array)) {
				args = config;
			} else {
				var config:ComplexSettingsConfiguration = cast config;
				args = config.args;
				label = config.label;
			}
			configurations.push({kind: Configured(i, label), args: args});
		}

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
			window.showErrorMessage("No Haxe configurations are available. Please provide the haxe.displayConfigurations setting.",
				({title: "Edit settings"} : vscode.MessageItem))
				.then(function(
					button) {
				if (button == null)
					return;
				workspace.getConfiguration("haxe")
					.update("displayConfigurations", [], false)
					.then(_ -> workspace.openTextDocument(workspace.workspaceFolders[0].uri.fsPath + "/.vscode/settings.json")
					.then(document -> window.showTextDocument(document)));
			});
			return;
		}

		var items:Array<DisplayConfigurationPickItem> = [];
		for (configuration in configurations) {
			var description = if (configuration.kind.match(Discovered(_))) "auto-discovered" else "from settings.json";
			items.push({
				label: getConfigurationLabel(configuration),
				description: description,
				config: configuration,
			});
		}

		var current = getCurrent();
		if (current != null)
			items.moveToStart(item -> item.config == current);
		window.showQuickPick(items, {matchOnDescription: true, placeHolder: "Select Haxe Configuration"}).then(function(choice:DisplayConfigurationPickItem) {
			if (choice == null || choice.config == current)
				return;
			setCurrent(choice.config);
		});
	}

	public function getCurrentLabel():Null<String> {
		var current = getCurrent();
		if (current == null) {
			return null;
		}
		return getConfigurationLabel(current);
	}

	function getConfigurationLabel(configuration:Configuration):String {
		return switch (configuration.kind) {
			case Configured(_, label):
				if (label != null) {
					label;
				} else {
					configuration.args.join(" ");
				}
			case Discovered(id): id;
		}
	}

	public static final ConfigurationIndexKey = new HaxeMementoKey<SavedSelection>("displayConfigurationIndex");

	function getCurrent():Null<Configuration> {
		var selection = context.getWorkspaceState().get(ConfigurationIndexKey, 0);
		for (conf in configurations) {
			switch conf.kind {
				case Configured(idx, _) if (idx == selection):
					return conf;
				case Discovered(id) if (id == selection):
					return conf;
				case _:
			}
		}
		return null;
	}

	function setCurrent(config:Configuration) {
		context.getWorkspaceState().update(ConfigurationIndexKey, switch config.kind {
			case Configured(index, _): index;
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
			providerDisposable = displayArguments.registerProvider("Haxe", this);
		} else if (!isActive && providerDisposable != null) {
			providerDisposable.dispose();
			providerDisposable = null;
		}
	}

	function updateStatusBarItem(config:Configuration) {
		if (provideArguments != null && config != null) {
			var label = switch (config.kind) {
				case Configured(_, userLabel): userLabel;
				case _: null;
			}
			if (label == null) {
				label = config.args.join(" ");
				if (label.length > 50) {
					label = label.substr(0, 47).rtrim() + "...";
				}
			}
			statusBarItem.text = label;
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

private typedef SettingsConfiguration = EitherType<Array<String>, ComplexSettingsConfiguration>;

private typedef ComplexSettingsConfiguration = {
	var label:String;
	var args:Array<String>;
}

private typedef DisplayConfigurationPickItem = QuickPickItem & {
	var config:Configuration;
}

private typedef Configuration = {
	var kind:ConfigurationKind;
	var args:Array<String>;
}

private enum ConfigurationKind {
	Configured(index:Int, ?label:String);
	Discovered(id:String);
}

private typedef SavedSelection = EitherType<Int, String>;

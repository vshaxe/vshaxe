package vshaxe.display;

import haxe.extern.EitherType;

class HaxeDisplayArgumentsProvider {
	final context:ExtensionContext;
	final displayArguments:DisplayArguments;
	final hxmlDiscovery:HxmlDiscovery;
	final statusBarItem:StatusBarItem;
	var provideArguments:Null<Array<String>->Void>;
	var providerDisposable:Null<Disposable>;
	var configurations:Array<Configuration> = [];

	public var configurationCount(get, never):Int;

	inline function get_configurationCount()
		return configurations.length;

	public var isActive(get, never):Bool;

	inline function get_isActive()
		return provideArguments != null;

	public var description(default, never) = "Project using haxe.configurations or HXML files (built-in)";

	public function new(context:ExtensionContext, displayArguments:DisplayArguments, hxmlDiscovery:HxmlDiscovery) {
		this.context = context;
		this.displayArguments = displayArguments;
		this.hxmlDiscovery = hxmlDiscovery;

		statusBarItem = window.createStatusBarItem(Left, 10);
		statusBarItem.tooltip = "Select Haxe Configuration";
		statusBarItem.command = cast SelectConfiguration;
		context.subscriptions.push(statusBarItem);

		context.registerHaxeCommand(SelectConfiguration, selectConfiguration);

		context.subscriptions.push(workspace.onDidChangeConfiguration(_ -> refresh()));
		hxmlDiscovery.onDidChangeFiles(_ -> refresh());

		window.onDidChangeActiveTextEditor(onDidChangeActiveTextEditor);

		refresh();
	}

	function updateConfigurations() {
		var configs:Array<SettingsConfiguration> = workspace.getConfiguration("haxe").get("configurations", []);
		if (configs == null || configs.length == 0)
			configs = workspace.getConfiguration("haxe").get("displayConfigurations", []); // legacy handling

		configurations = [];
		for (i in 0...configs.length) {
			final config = configs[i];
			var args:Array<String>;
			var label:Null<String> = null;
			if (Std.is(config, Array)) {
				args = config;
			} else {
				final config:ComplexSettingsConfiguration = cast config;
				args = config.args;
				label = config.label;
			}
			configurations.push({kind: Configured(i, label), args: args});
		}

		for (hxmlFile in hxmlDiscovery.files) {
			final hxmlConfig = [hxmlFile];
			if (!configs.exists(config -> config.equals(hxmlConfig))) {
				configurations.push({kind: Discovered(hxmlFile), args: hxmlConfig});
			}
		}
	}

	public function activate(provideArguments) {
		this.provideArguments = provideArguments;
		setCurrent(getCurrent());
	}

	public function deactivate() {
		this.provideArguments = null;
		updateStatusBarItem(null);
	}

	function selectConfiguration() {
		if (configurations.length == 0) {
			window.showErrorMessage("No Haxe configurations are available. Please provide the haxe.configurations setting.",
				({title: "Edit settings"} : vscode.MessageItem))
				.then(function(button) {
					if (button == null)
						return;
					workspace.getConfiguration("haxe").update("configurations", [], false).then(function(_) {
						if (workspace.workspaceFolders == null)
							return;
						workspace.openTextDocument(workspace.workspaceFolders[0].uri.fsPath + "/.vscode/settings.json")
							.then(document -> window.showTextDocument(document));
					});
				});
			return;
		}

		final items:Array<ConfigurationPickItem> = [];
		for (configuration in configurations) {
			final description = if (configuration.kind.match(Discovered(_))) "auto-discovered" else "from settings.json";
			items.push({
				label: getConfigurationLabel(configuration),
				description: description,
				config: configuration,
			});
		}

		final current = getCurrent();
		if (current != null)
			items.moveToStart(item -> item.config == current);
		window.showQuickPick(items, {matchOnDescription: true, placeHolder: "Select Haxe Configuration"}).then(function(choice:ConfigurationPickItem) {
			if (choice == null || choice.config == current)
				return;
			context.getWorkspaceState().update(ConfigurationIndexKey, switch choice.config.kind {
				case Configured(index, _): index;
				case Discovered(id): id;
			});
			setCurrent(choice.config);
		});
	}

	public function getCurrentLabel():Null<String> {
		final current = getCurrent();
		if (current == null) {
			return null;
		}
		return getConfigurationLabel(current);
	}

	function getConfigurationLabel(configuration:Configuration):String {
		return switch configuration.kind {
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
		final selection:Null<Dynamic> = context.getWorkspaceState().get(ConfigurationIndexKey);
		for (conf in configurations) {
			switch conf.kind {
				case Configured(idx, _) if (idx == selection):
					return conf;
				case Discovered(id) if (id == selection):
					return conf;
				case _:
			}
		}
		return configurations[0];
	}

	function setCurrent(config:Null<Configuration>) {
		updateStatusBarItem(config);
		if (provideArguments != null)
			provideArguments(if (config == null) [] else config.args);
	}

	function refresh() {
		updateConfigurations();
		updateDisplayArgumentsProviderRegistration();
		checkConfigurationComment(window.activeTextEditor != null ? window.activeTextEditor.document : null);
		setCurrent(getCurrent());
	}

	function updateDisplayArgumentsProviderRegistration() {
		final isActive = configurations.length > 0;
		if (isActive && providerDisposable == null) {
			providerDisposable = displayArguments.registerProvider("Haxe", this);
		} else if (!isActive && providerDisposable != null) {
			providerDisposable.dispose();
			providerDisposable = null;
		}
	}

	function updateStatusBarItem(config:Null<Configuration>) {
		if (provideArguments != null && config != null) {
			var label = switch config.kind {
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

	function onDidChangeActiveTextEditor(editor:Null<TextEditor>) {
		if (editor != null && editor.document.languageId == "haxe") {
			if (checkConfigurationComment(editor.document)) {
				setCurrent(getCurrent());
			}
		}
	}

	function checkConfigurationComment(document:Null<TextDocument>):Bool {
		if (document == null || document.lineCount == 0) {
			return false;
		}
		var matcher = ~/\/\/\s*--\*\s*config\s*:\s*(\S+)\s*\*--/;
		if (matcher.match(document.lineAt(0).text)) {
			var configID = matcher.matched(1);
			for (conf in configurations) {
				switch conf.kind {
					case Configured(idx, _) if (Std.string(idx) == configID):
						context.getWorkspaceState().update(ConfigurationIndexKey, idx);
						return true;
					case Discovered(id) if (id == configID):
						context.getWorkspaceState().update(ConfigurationIndexKey, id);
						return true;
					case _:
				}
			}
		}
		return false;
	}
}

private typedef SettingsConfiguration = EitherType<Array<String>, ComplexSettingsConfiguration>;

private typedef ComplexSettingsConfiguration = {
	final label:String;
	final args:Array<String>;
}

private typedef ConfigurationPickItem = QuickPickItem & {
	final config:Configuration;
}

private typedef Configuration = {
	final kind:ConfigurationKind;
	final args:Array<String>;
}

private enum ConfigurationKind {
	Configured(index:Int, ?label:String);
	Discovered(id:String);
}

private typedef SavedSelection = EitherType<Int, String>;

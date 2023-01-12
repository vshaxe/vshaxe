package vshaxe.commands;

import vshaxe.display.HaxeDisplayArgumentsProvider;
import vshaxe.server.LanguageServer;

class Commands {
	final context:ExtensionContext;
	final server:LanguageServer;
	final haxeDisplayArgumentsProvider:HaxeDisplayArgumentsProvider;

	public function new(context:ExtensionContext, server:LanguageServer, haxeDisplayArgumentsProvider:HaxeDisplayArgumentsProvider) {
		this.context = context;
		this.server = server;
		this.haxeDisplayArgumentsProvider = haxeDisplayArgumentsProvider;

		context.registerHaxeCommand(RestartLanguageServer, server.restart);
		context.registerHaxeCommand(ShowReferences, showReferences);
		context.registerHaxeCommand(RunGlobalDiagnostics, server.runGlobalDiagnostics);
		context.registerHaxeCommand(ToggleCodeLens, toggleCodeLens);
		context.registerHaxeCommand(DebugSelectedConfiguration, debugSelectedConfiguration);
		context.registerHaxeCommand(CodeAction_HighlightInsertion, highlightInsertion);

		#if debug
		context.registerHaxeCommand(ClearMementos, clearMementos);
		#end
	}

	function showReferences(uri:String, position:Position, locations:Array<Location>) {
		inline function copyPosition(position)
			return new Position(position.line, position.character);
		// this is retarded
		final locations = locations.map(function(location) {
			return new Location(Uri.parse(cast location.uri), new Range(copyPosition(location.range.start), copyPosition(location.range.end)));
		});
		commands.executeCommand("editor.action.showReferences", Uri.parse(uri), copyPosition(position), locations)
			.then(s -> trace(s), s -> trace("err: " + s));
	}

	function toggleCodeLens() {
		final key = "enableCodeLens";
		final config = workspace.getConfiguration("haxe");
		final info = config.inspect(key);
		if (info == null) {
			return;
		}
		var value = getCurrentConfigValue(info, config);
		if (value == null) {
			value = false;
		}
		// editing the global config only has an effect if there's no workspace value
		final global = info.workspaceValue == null;
		config.update(key, !value, global);
	}

	function debugSelectedConfiguration() {
		if (!haxeDisplayArgumentsProvider.isActive) {
			window.showErrorMessage("The built-in completion provider is not active, so there is no configuration to be debugged.");
			return;
		}

		final label = haxeDisplayArgumentsProvider.getCurrentLabel();
		if (label == null) {
			window.showErrorMessage("There is no configuration selected.");
			return;
		}

		var folder:Null<WorkspaceFolder> = null;
		if (workspace.workspaceFolders != null) {
			folder = workspace.workspaceFolders[0];
		}
		debug.startDebugging(folder, label).then(_ -> {}, error -> {
			window.showErrorMessage(Std.string(error));
		});
	}

	function clearMementos() {
		inline function clear(key)
			context.workspaceState.update(key, js.Lib.undefined);
		clear(vshaxe.display.DisplayArguments.ProviderNameKey);
		clear(vshaxe.display.HaxeDisplayArgumentsProvider.ConfigurationIndexKey);
		clear(vshaxe.HxmlDiscovery.DiscoveredFilesKey);
		clear(vshaxe.configuration.HaxeInstallation.PreviousHaxeInstallationProviderKey);
		context.getGlobalState().delete(vshaxe.server.LanguageServer.DontShowOldPreviewHintAgainKey);
	}

	function getCurrentConfigValue<T>(info, config:WorkspaceConfiguration):Null<T> {
		var value = info.workspaceValue;
		if (value == null)
			value = info.globalValue;
		if (value == null)
			value = info.defaultValue;
		return value;
	}

	function highlightInsertion(uri:String, range:Range) {
		window.showTextDocument(Uri.parse(uri)).then(editor -> editor.revealRange(range));
	}
}

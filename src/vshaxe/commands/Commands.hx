package vshaxe.commands;

import js.lib.RegExp;
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
		context.registerHaxeCommand(Type, extendedTyping);

		#if debug
		context.registerHaxeCommand(ClearMementos, clearMementos);
		#end
	}

	function showReferences(uri:String, position:Position, locations:Array<Location>) {
		inline function copyPosition(position)
			return new Position(position.line, position.character);
		// this is retarded
		var locations = locations.map(function(location) {
			return new Location(Uri.parse(cast location.uri), new Range(copyPosition(location.range.start), copyPosition(location.range.end)));
		});
		commands.executeCommand("editor.action.showReferences", Uri.parse(uri), copyPosition(position), locations)
			.then(s -> trace(s), s -> trace("err: " + s));
	}

	function toggleCodeLens() {
		var key = "enableCodeLens";
		var config = workspace.getConfiguration("haxe");
		var info = config.inspect(key);
		if (info == null) {
			return;
		}
		var value = getCurrentConfigValue(info, config);
		if (value == null) {
			value = false;
		}
		// editing the global config only has an effect if there's no workspace value
		var global = info.workspaceValue == null;
		config.update(key, !value, global);
	}

	function debugSelectedConfiguration() {
		if (!haxeDisplayArgumentsProvider.isActive) {
			window.showErrorMessage("The built-in completion provider is not active, so there is no configuration to be debugged.");
			return;
		}

		var label = haxeDisplayArgumentsProvider.getCurrentLabel();
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

	function extendedTyping(args) {
		if (args.text == "{")
			indentCurlyBracket();
		commands.executeCommand('default:type', args);
	}

	// With possible comments after bracket
	final lineEndsWithOpenBracket = new RegExp("[([{]\\s*(\\/\\/.*|\\/[*].*[*]\\/\\s*)?$");

	function indentCurlyBracket():Void {
		var editor = window.activeTextEditor;
		if (editor == null)
			return;
		var lines:Array<{range:Range, spaces:String}> = [];
		for (selection in editor.selections) {
			if (!selection.isEmpty)
				continue;
			if (selection.active.line == 0)
				continue;
			var line = editor.document.lineAt(selection.active.line);
			if (!line.isEmptyOrWhitespace)
				continue;
			var prevLine = editor.document.lineAt(selection.active.line - 1);
			if (prevLine.text.length > 0) {
				// Do not reindent if prev line has open bracket at the end
				if (lineEndsWithOpenBracket.test(prevLine.text))
					continue;
			}
			if (line.text.length < prevLine.firstNonWhitespaceCharacterIndex)
				continue;
			var spaces = prevLine.text.substr(0, prevLine.firstNonWhitespaceCharacterIndex);
			lines.push({range: line.range, spaces: spaces});
		}
		if (lines.length == 0)
			return;
		editor.edit(edit -> {
			for (line in lines)
				edit.replace(line.range, line.spaces);
		}, {undoStopBefore: false, undoStopAfter: false});
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

	function getCurrentConfigValue<T>(info, config:WorkspaceConfiguration):T {
		var value = info.workspaceValue;
		if (value == null)
			value = info.globalValue;
		if (value == null)
			value = info.defaultValue;
		return value;
	}
}

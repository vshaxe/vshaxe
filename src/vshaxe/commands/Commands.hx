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
		context.registerHaxeCommand(ExportServerRecording, server.exportRecording);
		context.registerHaxeCommand(ShowReferences, showReferences);
		context.registerHaxeCommand(RunGlobalDiagnostics, server.runGlobalDiagnostics);
		context.registerHaxeCommand(ToggleCodeLens, toggleCodeLens);
		context.registerHaxeCommand(DebugSelectedConfiguration, debugSelectedConfiguration);
		context.registerHaxeCommand(CodeAction_HighlightInsertion, highlightInsertion);
		context.registerHaxeCommand(CodeAction_InsertSnippet, insertSnippet);
		context.registerHaxeCommand(CodeAction_SelectRanges, selectRanges);
		context.registerHaxeCommand(ShowOutputChannel, showOutputChannel);
		context.registerHaxeCommand(FixAll, fixAll);

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

	function insertSnippet(uri:String, range:Range, snippet:String):Void {
		window.showTextDocument(Uri.parse(uri)).then(editor -> {
			final firstLine = editor.document.lineAt(range.start.line);
			final indentNum = lineIndentationCount(firstLine.text);
			snippet = prepareSnippetIndentation(snippet, indentNum);
			final range = new Range(range.start, range.end);
			final str = new SnippetString(snippet);
			editor.insertSnippet(str, range);
		});
	}

	function selectRanges(uri:String, ranges:Array<Range>):Void {
		window.showTextDocument(Uri.parse(uri)).then(editor -> {
			// editor.selections = ranges.map(range -> {
			// 	new Selection(range.start, range.end);
			// });
			final ranges = ranges.map(range -> new Range(range.start, range.end));
			final fullRange = ranges.fold((item, result:Range) -> {
				if (result == item)
					return result;
				return result.union(item);
			}, ranges[0]);
			ranges.sort((range1, range2) -> {
				return range1.start.isBefore(range2.start) ? -1 : 1;
			});
			final docText = editor.document.getText();
			final fullEnd = editor.document.offsetAt(fullRange.end);
			var pos = editor.document.offsetAt(fullRange.start);
			var snippet = "";
			for (i => r in ranges) {
				final start = editor.document.offsetAt(r.start);
				final end = editor.document.offsetAt(r.end);
				snippet += docText.substring(pos, start);
				snippet += "${1:" + docText.substring(start, end) + "}";
				pos = end;
				if (i == ranges.length - 1) {
					snippet += "${0}" + docText.substring(end, fullEnd);
				}
			}
			final firstLine = editor.document.lineAt(fullRange.start.line);
			final indentNum = lineIndentationCount(firstLine.text);
			snippet = prepareSnippetIndentation(snippet, indentNum);
			final str = new SnippetString(snippet);
			editor.insertSnippet(str, fullRange);
		});
	}

	function lineIndentationCount(s:String):Int {
		var spaces = 0;
		for (i => _ in s) {
			if (!s.isSpace(i))
				break;
			spaces++;
		}
		return spaces;
	}

	function prepareSnippetIndentation(snippet:String, indent:Int):String {
		// snippet adds first line indentation to all next lines,
		// so we need to remove next line indentations
		final startIndentCount = indent;
		final snippetLines = snippet.split("\n");
		for (i => line in snippetLines) {
			if (i == 0)
				continue;
			if (lineIndentationCount(line) < startIndentCount)
				continue;
			snippetLines[i] = line.substr(startIndentCount);
		}
		return snippetLines.join("\n");
	}

	function showOutputChannel():Void {
		final serverClient = server.client ?? return;
		serverClient.outputChannel.show();
	}

	function fixAll():Void {
		final editor = window.activeTextEditor;
		if (editor == null)
			return;
		final document = editor.document;
		if (document.isDirty)
			return;
		final range = new Range(0, 0, document.lineCount, 0);
		commands.executeCommand('vscode.executeCodeActionProvider', document.uri, range, CodeActionKind.QuickFix.value).then((actions:Array<CodeAction>) -> {
			if (actions == null)
				return;
			editor.edit((editBuilder) -> {
				for (action in actions) {
					final kind = action.kind;
					if (kind == null || !kind.value.endsWith("auto"))
						continue;
					final wedit = action.edit;
					if (wedit == null)
						continue;
					for (tuple in wedit.entries()) {
						final edits = tuple.edits;
						final uri = tuple.uri;
						for (edit in edits) {
							editBuilder.replace(edit.range, edit.newText);
						}
					}
				}
			});
		});
	}
}

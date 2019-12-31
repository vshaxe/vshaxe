package vshaxe;

import js.lib.RegExp;

class AutoIndentation {
	// With possible comments after bracket
	static final lineEndsWithOpenBracket = ~/[([{][\t ]*(\/\/.*|\/[*].*[*]\/[\t ]*)?$/;

	final context:ExtensionContext;
	var typeDisposable:Null<Disposable>;

	public function new(context:ExtensionContext) {
		this.context = context;

		updateExtendedIndentation();
		updateLanguageConfiguration();

		context.subscriptions.push(workspace.onDidChangeConfiguration(_ -> updateExtendedIndentation()));
	}

	function updateLanguageConfiguration() {
		// based on https://github.com/microsoft/vscode/blob/bb02817e2e549fd88710d0e0a0336b80648e90b5/extensions/typescript-language-features/src/features/languageConfiguration.ts#L15
		languages.setLanguageConfiguration("haxe", {
			indentationRules: {
				decreaseIndentPattern: new RegExp("^((?!.*?\\/\\*).*\\*\\/)?\\s*[\\}\\]].*$"),
				increaseIndentPattern: new RegExp("^((?!\\/\\/).)*(\\{[^}\"'`]*|\\([^)\"'`]*|\\[[^\\]\"'`]*)$"),
				indentNextLinePattern: new RegExp("(^\\s*(for|while|do|if|else|try|catch)|function)\\b(?!.*[;{}]\\s*(\\/\\/.*|\\/[*].*[*]\\/\\s*)?$)")
			},
			onEnterRules: [
				{
					// e.g. /** | **/
					beforeText: new RegExp("^\\s*\\/\\*\\*(?!\\/)([^\\*]|\\*(?!\\/))*$"),
					afterText: new RegExp("^\\s*\\*\\*\\/$"),
					action: {indentAction: vscode.IndentAction.IndentOutdent},
				},
				{
					// e.g. /** |
					beforeText: new RegExp("^\\s*\\/\\*\\*(?!\\/)([^\\*]|\\*(?!\\/))*$"),
					action: {indentAction: vscode.IndentAction.Indent},
				},
				{
					beforeText: new RegExp("^\\s*(\\bcase\\s.+:|\\bdefault:)\\s*$"),
					afterText: new RegExp("^(?!\\s*(\\bcase\\b|\\bdefault\\b))"),
					action: {indentAction: vscode.IndentAction.Indent},
				}
			]
		});
	}

	function updateExtendedIndentation() {
		var wasEnabled = typeDisposable != null;
		var enabled = workspace.getConfiguration("haxe").get("enableExtendedIndentation", false);
		if (enabled == wasEnabled) {
			return;
		}
		if (enabled) {
			typeDisposable = commands.registerCommand("type", type);
			context.subscriptions.push(typeDisposable);
		} else {
			typeDisposable.dispose();
			typeDisposable = null;
		}
	}

	function type(args:{text:String}) {
		var editor = window.activeTextEditor;
		if (editor != null && editor.document.languageId == "haxe" && args.text == "{") {
			indentCurlyBracket(editor);
		}
		commands.executeCommand('default:type', args);
	}

	function indentCurlyBracket(editor:TextEditor) {
		var lines:Array<{range:Range, spaces:String}> = [];
		for (selection in editor.selections) {
			if (!selection.isEmpty || selection.active.line == 0) {
				continue;
			}
			var line = editor.document.lineAt(selection.active.line);
			if (!line.isEmptyOrWhitespace) {
				continue;
			}
			var prevLine = editor.document.lineAt(selection.active.line - 1);
			// Do not reindent if prev line has open bracket at the end
			if (prevLine.text.length > 0 && lineEndsWithOpenBracket.match(prevLine.text)) {
				continue;
			}
			if (line.text.length < prevLine.firstNonWhitespaceCharacterIndex) {
				continue;
			}
			var spaces = prevLine.text.substr(0, prevLine.firstNonWhitespaceCharacterIndex);
			lines.push({range: line.range, spaces: spaces});
		}
		if (lines.length == 0) {
			return;
		}
		editor.edit(function(edit) {
			for (line in lines) {
				edit.replace(line.range, line.spaces);
			}
		}, {undoStopBefore: false, undoStopAfter: false});
	}
}

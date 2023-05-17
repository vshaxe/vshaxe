package vshaxe;

import vshaxe.helper.RegExpHelper;

class AutoIndentation {
	// With possible comments after bracket
	static final lineEndsWithOpenBracket = ~/[([{][\t ]*(\/\/.*|\/[*].*[*]\/[\t ]*)?$/;

	final context:ExtensionContext;
	var typeDisposable:Null<Disposable>;
	var changeDisposable:Null<Disposable>;

	public function new(context:ExtensionContext) {
		this.context = context;

		updateExtendedIndentation();
		updateBraceBodyWrapping();
		updateLanguageConfiguration();

		context.subscriptions.push(workspace.onDidChangeConfiguration(_ -> updateBraceBodyWrapping()));
		context.subscriptions.push(workspace.onDidChangeConfiguration(_ -> updateExtendedIndentation()));
	}

	function updateLanguageConfiguration() {
		// based on https://github.com/microsoft/vscode/blob/bb02817e2e549fd88710d0e0a0336b80648e90b5/extensions/typescript-language-features/src/features/languageConfiguration.ts#L15
		languages.setLanguageConfiguration("haxe", {
			indentationRules: {
				decreaseIndentPattern: makeRegExp(~/^((?!.*?\/\*).*\*\/)?\s*[\}\]].*$/),
				increaseIndentPattern: makeRegExp(~/^((?!\/\/).)*(\{[^}"'`]*|\([^)"'`]*|\[[^\]"'`]*)$/),
				indentNextLinePattern: makeRegExp(~/(^\s*(for|while|do|if|else|try|catch)|function)\b(?!.*[;{}]\s*(\/\/.*|\/[*].*[*]\/\s*)?$)/)
			},
			onEnterRules: [
				{
					// e.g. /** | **/
					beforeText: makeRegExp(~/^\s*\/\*\*(?!\/)([^\*]|\*(?!\/))*$/),
					afterText: makeRegExp(~/^\s*\*\*\/$/),
					action: {indentAction: vscode.IndentAction.IndentOutdent},
				},
				{
					// e.g. /** |
					beforeText: makeRegExp(~/^\s*\/\*\*(?!\/)([^\*]|\*(?!\/))*$/),
					action: {indentAction: vscode.IndentAction.Indent},
				},
				{
					beforeText: makeRegExp(~/^\s*(\bcase\s.+:|\bdefault:)\s*$/),
					afterText: makeRegExp(~/^(?!\s*(\bcase\b|\bdefault\b))/),
					action: {indentAction: vscode.IndentAction.Indent},
				}
			]
		});
	}

	function updateExtendedIndentation() {
		final wasEnabled = typeDisposable != null;
		final enabled = workspace.getConfiguration("haxe").get("enableExtendedIndentation", false);
		if (enabled == wasEnabled) {
			return;
		}
		if (enabled) {
			try {
				typeDisposable = commands.registerCommand("type", type);
				context.subscriptions.push(typeDisposable);
			} catch (e) {
				window.showErrorMessage("Failed to register the 'type' command needed for the \"haxe.enableExtendedIndentation\" setting"
					+ " - there is probably a conflict with another extension such as Vim.");
			}
		} else {
			if (typeDisposable != null) {
				typeDisposable.dispose();
			}
			typeDisposable = null;
		}
	}

	function type(args:{text:String}) {
		final editor = window.activeTextEditor;
		if (editor != null && editor.document.languageId == "haxe" && args.text == "{") {
			indentOpenBrace(editor);
		}
		commands.executeCommand('default:type', args);
	}

	function indentOpenBrace(editor:TextEditor) {
		final lines:Array<{range:Range, spaces:String}> = [];
		for (selection in editor.selections) {
			if (!selection.isEmpty || selection.active.line == 0) {
				continue;
			}
			final line = editor.document.lineAt(selection.active.line);
			if (!line.isEmptyOrWhitespace) {
				continue;
			}
			final prevLine = editor.document.lineAt(selection.active.line - 1);
			// Do not reindent if prev line has open bracket at the end
			if (prevLine.text.length > 0 && lineEndsWithOpenBracket.match(prevLine.text)) {
				continue;
			}
			if (line.text.length < prevLine.firstNonWhitespaceCharacterIndex) {
				continue;
			}
			final spaces = prevLine.text.substr(0, prevLine.firstNonWhitespaceCharacterIndex);
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

	function updateBraceBodyWrapping() {
		final wasEnabled = changeDisposable != null;
		final enabled = workspace.getConfiguration("haxe").get("enableBraceBodyWrapping", false);
		if (enabled == wasEnabled) {
			return;
		}
		if (enabled) {
			changeDisposable = workspace.onDidChangeTextDocument(wrapBraceBody);
			context.subscriptions.push(changeDisposable);
		} else {
			if (changeDisposable != null) {
				changeDisposable.dispose();
			}
			changeDisposable = null;
		}
	}

	function wrapBraceBody(event:TextDocumentChangeEvent):Void {
		final editor:TextEditor = window.activeTextEditor ?? return;
		if (editor.document.fileName != event.document.fileName)
			return;
		final edits:Array<TextDocumentContentChangeEvent> = [];
		for (change in event.contentChanges) {
			if (change.rangeLength != 0 || change.text != '{}')
				continue;
			final lineCount = editor.document.lineCount;
			final lineIndex = change.range.start.line;
			final startLine = editor.document.lineAt(lineIndex);
			final charIndex = change.range.start.character;
			// cursor at the end of line
			if (startLine.text.substr(charIndex + 2).rtrim().length != 0)
				continue;
			// there is next line (body) in file
			if (lineCount <= lineIndex + 1)
				continue;
			if (isSingleLineBlockWithoutBrackets(editor, startLine)) {
				edits.push(change);
			}
		}
		if (edits.length == 0)
			return;
		editor.edit(builder -> {
			for (edit in edits) {
				final curLine = editor.document.lineAt(edit.range.start.line);
				final nextLine = editor.document.lineAt(edit.range.start.line + 1);
				builder.delete(new Range(edit.range.end.translate(0, 1), edit.range.end.translate(0, 2)));
				builder.insert(nextLine.range.end, '\n' + curLine.text.substr(0, curLine.firstNonWhitespaceCharacterIndex) + '}');
			}
		}, {undoStopBefore: false, undoStopAfter: true});
	}

	function isSingleLineBlockWithoutBrackets(editor:TextEditor, startLine:TextLine):Bool {
		final bodyLine = editor.document.lineAt(startLine.lineNumber + 1);
		final startCharIndex = startLine.firstNonWhitespaceCharacterIndex;
		// body in not on +1 indentation level
		if (startCharIndex >= bodyLine.firstNonWhitespaceCharacterIndex)
			return false;
		// no end line is fine
		if (editor.document.lineCount <= bodyLine.lineNumber + 1)
			return true;
		final endLine = editor.document.lineAt(startLine.lineNumber + 2);
		final endCharIndex = endLine.firstNonWhitespaceCharacterIndex;
		// end line is below start line
		if (endCharIndex < startCharIndex) {
			return true;
		} else {
			// do not make block inside of block
			return endLine.text.charAt(endCharIndex) != "}";
		}
		return true;
	}
}

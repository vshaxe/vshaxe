package vshaxe;

private typedef TypeCommandArgs = {
	text:String
}

class ExtendedIndentation {
	final context:ExtensionContext;
	var extendedIndentationDisposable:Null<Disposable>;
	// With possible comments after bracket
	final lineEndsWithOpenBracket = ~/[([{][\t ]*(\/\/.*|\/[*].*[*]\/[\t ]*)?$/;

	public function new(context:ExtensionContext) {
		this.context = context;
		context.subscriptions.push(workspace.onDidChangeConfiguration(_ -> extendedIndentationToggle()));
		extendedIndentationToggle();
	}

	function extendedIndentationToggle():Void {
		var isActive = workspace.getConfiguration("haxe").get("extendedIndentation", false);
		if (extendedIndentationDisposable != null)
			extendedIndentationDisposable.dispose();

		if (isActive) {
			extendedIndentationDisposable = commands.registerCommand("type", extendedTyping);
			context.subscriptions.push(extendedIndentationDisposable);
		}
	}

	function extendedTyping(args:TypeCommandArgs) {
		var editor = window.activeTextEditor;
		if (editor != null && editor.document.languageId == "haxe" && args.text == "{")
			indentCurlyBracket();
		commands.executeCommand('default:type', args);
	}

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
				if (lineEndsWithOpenBracket.match(prevLine.text))
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
}

package vscode;

typedef IndentationRule = {
	var decreaseIndentPattern:js.RegExp;
	var increaseIndentPattern:js.RegExp;
	@:optional var indentNextLinePattern:js.RegExp;
	@:optional var unIndentedLinePattern:js.RegExp;
}

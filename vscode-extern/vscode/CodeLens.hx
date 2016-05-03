package vscode;

@:jsRequire("vscode", "CodeLens")
extern class CodeLens {
	var range:Range;
	var command:Command;
	var isResolved:Bool;
	function new(range:Range, ?command:Command);
}

package vscode;

@:enum abstract IndentAction(Int) {
	var None = 0;
	var Indent = 1;
	var IndentOutdent = 2;
	var Outdent = 3;
}

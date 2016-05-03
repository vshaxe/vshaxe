package vscode;

@:enum abstract DiagnosticSeverity(Int) {
	var Error = 0;
	var Warning = 1;
	var Information = 2;
	var Hint = 3;
}

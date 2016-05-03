package vscode;

@:jsRequire("vscode", "Diagnostic")
extern class Diagnostic {
	var range:Range;
	var message:String;
	var source:String;
	var severity:DiagnosticSeverity;
	var code:haxe.extern.EitherType<String, Int>;
	function new(range:Range, message:String, ?severity:DiagnosticSeverity):Void;
}

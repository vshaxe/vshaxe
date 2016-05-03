package vscode;

@:jsRequire("vscode", "ParameterInformation")
extern class ParameterInformation {
	var label:String;
	var documentation:String;
	function new(label:String, ?documentation:String);
}

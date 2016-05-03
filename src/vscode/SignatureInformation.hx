package vscode;

@:jsRequire("vscode", "SignatureInformation")
extern class SignatureInformation {
	var label:String;
	var documentation:String;
	var parameters:Array<ParameterInformation>;
	function new(label:String, ?documentation:String);
}

package vscode;

@:jsRequire("vscode", "SignatureHelp")
extern class SignatureHelp {
	var signatures:Array<SignatureInformation>;
	var activeSignature:Int;
	var activeParameter:Int;
}

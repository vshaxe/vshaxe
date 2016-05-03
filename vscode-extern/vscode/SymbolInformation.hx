package vscode;

@:jsRequire("vscode", "SymbolInformation")
extern class SymbolInformation {
	var name:String;
	var containerName:String;
	var kind:SymbolKind;
	var location:Location;
	function new(name:String, kind:SymbolKind, range:Range, ?uri:Uri, ?containerName:String);
}

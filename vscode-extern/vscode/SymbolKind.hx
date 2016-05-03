package vscode;

@:enum abstract SymbolKind(Int) {
	var File = 0;
	var Module = 1;
	var Namespace = 2;
	var Package = 3;
	var Class = 4;
	var Method = 5;
	var Property = 6;
	var Field = 7;
	var Constructor = 8;
	var Enum = 9;
	var Interface = 10;
	var Function = 11;
	var Variable = 12;
	var Constant = 13;
	var String = 14;
	var Number = 15;
	var Boolean = 16;
	var Array = 17;
	var Object = 18;
	var Key = 19;
	var Null = 20;
}

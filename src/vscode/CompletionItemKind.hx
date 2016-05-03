package vscode;

@:enum abstract CompletionItemKind(Int) {
	var Text = 0;
	var Method = 1;
	var Function = 2;
	var Constructor = 3;
	var Field = 4;
	var Variable = 5;
	var Class = 6;
	var Interface = 7;
	var Module = 8;
	var Property = 9;
	var Unit = 10;
	var Value = 11;
	var Enum = 12;
	var Keyword = 13;
	var Snippet = 14;
	var Color = 15;
	var File = 16;
	var Reference = 17;
}

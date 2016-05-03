package vscode;

@:jsRequire("vscode", "CompletionItem")
extern class CompletionItem {
	var label:String;
	var kind:CompletionItemKind;
	var detail:String;
	var documentation:String;
	var sortText:String;
	var filterText:String;
	var insertText:String;
	var textEdit:TextEdit;
	function new(label:String);
}

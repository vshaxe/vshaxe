package vscode;

@:jsRequire("vscode", "CompletionList")
extern class CompletionList {
	var isIncomplete:Bool;
	var items:Array<CompletionItem>;
	function new(?items:Array<CompletionItem>, ?isIncomplete:Bool);
}

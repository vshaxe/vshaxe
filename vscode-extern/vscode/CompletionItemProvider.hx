package vscode;

import js.Promise.Thenable;

typedef CompletionItemProvider = {
	function provideCompletionItems(document:TextDocument, position:Position, token:CancellationToken):haxe.extern.EitherType<Array<CompletionItem>, haxe.extern.EitherType<Thenable<Array<CompletionItem>>, haxe.extern.EitherType<CompletionList, Thenable<CompletionList>>>>;

	@:optional // TODO: will that work?
	function resolveCompletionItem(item:CompletionItem, token:CancellationToken):haxe.extern.EitherType<CompletionItem, Thenable<CompletionItem>>;
}

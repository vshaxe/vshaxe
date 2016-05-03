package vscode;

import js.Promise.Thenable;

typedef TextDocumentContentProvider = {
	@:optional var onDidChange:Event<Uri>;
	function provideTextDocumentContent(uri:Uri, token:CancellationToken):haxe.extern.EitherType<String, Thenable<String>>;
}

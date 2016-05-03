package vscode;

import js.Promise.Thenable;

typedef DocumentHighlightProvider = {
	function provideDocumentHighlights(document:TextDocument, position:Position, token:CancellationToken):haxe.extern.EitherType<Array<DocumentHighlight>, Thenable<Array<DocumentHighlight>>>;
}

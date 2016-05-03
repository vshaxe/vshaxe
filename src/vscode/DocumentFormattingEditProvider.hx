package vscode;

import js.Promise.Thenable;

typedef DocumentFormattingEditProvider = {
	function provideDocumentFormattingEdits(document:TextDocument, options:FormattingOptions, token:CancellationToken):haxe.extern.EitherType<Array<TextEdit>, Thenable<Array<TextEdit>>>;
}

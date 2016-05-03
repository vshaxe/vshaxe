package vscode;

import js.Promise.Thenable;

typedef DocumentRangeFormattingEditProvider = {
	function provideDocumentRangeFormattingEdits(document:TextDocument, range:Range, options:FormattingOptions, token:CancellationToken):haxe.extern.EitherType<Array<TextEdit>, Thenable<Array<TextEdit>>>;
}

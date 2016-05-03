package vscode;

import js.Promise.Thenable;

typedef OnTypeFormattingEditProvider = {
	function provideOnTypeFormattingEdits(document:TextDocument, position:Position, ch:String, options:FormattingOptions, token:CancellationToken):haxe.extern.EitherType<Array<TextEdit>, Thenable<Array<TextEdit>>>;
}

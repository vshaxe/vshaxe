package vscode;

import js.Promise.Thenable;

typedef DocumentSymbolProvider = {
	function provideDocumentSymbols(document:TextDocument, token:CancellationToken):haxe.extern.EitherType<Array<SymbolInformation>, Thenable<Array<SymbolInformation>>>;
}

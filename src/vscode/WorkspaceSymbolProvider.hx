package vscode;

import js.Promise.Thenable;

typedef WorkspaceSymbolProvider = {
	function provideWorkspaceSymbols(query:String, token:CancellationToken):haxe.extern.EitherType<Array<SymbolInformation>, Thenable<Array<SymbolInformation>>>;
}

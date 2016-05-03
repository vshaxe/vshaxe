package vscode;

import js.Promise.Thenable;

typedef CodeLensProvider = {
	function provideCodeLenses(document:TextDocument, token:CancellationToken):haxe.extern.EitherType<Array<CodeLens>, Thenable<Array<CodeLens>>>;
	@:optional // TODO: will this work?
	function resolveCodeLens(codeLens:CodeLens, token:CancellationToken):haxe.extern.EitherType<CodeLens, Thenable<CodeLens>>;
}

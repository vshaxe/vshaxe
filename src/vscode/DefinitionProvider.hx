package vscode;

import js.Promise.Thenable;

typedef DefinitionProvider = {
	function provideDefinition(document:TextDocument, position:Position, token:CancellationToken):haxe.extern.EitherType<Definition, Thenable<Definition>>;
}

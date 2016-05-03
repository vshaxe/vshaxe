package vscode;

import js.Promise.Thenable;

typedef ReferenceProvider = {
	function provideReferences(document:TextDocument, position:Position, context:ReferenceContext, token:CancellationToken):haxe.extern.EitherType<Array<Location>, Thenable<Array<Location>>>;
}

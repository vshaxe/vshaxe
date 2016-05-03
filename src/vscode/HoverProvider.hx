package vscode;

import js.Promise.Thenable;

typedef HoverProvider = {
	function provideHover(document:TextDocument, position:Position, token:CancellationToken):haxe.extern.EitherType<Hover, Thenable<Hover>>;
}

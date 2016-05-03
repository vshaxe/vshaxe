package vscode;

import js.Promise.Thenable;

typedef SignatureHelpProvider = {
	function provideSignatureHelp(document:TextDocument, position:Position, token:CancellationToken):haxe.extern.EitherType<SignatureHelp, Thenable<SignatureHelp>>;
}

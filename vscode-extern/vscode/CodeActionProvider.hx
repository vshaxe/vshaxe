package vscode;

import js.Promise.Thenable;

typedef CodeActionProvider = {
	function provideCodeActions(document:TextDocument, range:Range, context:CodeActionContext, token:CancellationToken):haxe.extern.EitherType<Array<Command>, Thenable<Array<Command>>>;
}

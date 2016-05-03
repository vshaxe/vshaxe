package vscode;

import js.Promise.Thenable;

typedef RenameProvider = {
	function provideRenameEdits(document:TextDocument, position:Position, newName:String, token:CancellationToken):haxe.extern.EitherType<WorkspaceEdit, Thenable<WorkspaceEdit>>;
}

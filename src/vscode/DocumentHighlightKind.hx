package vscode;

@:enum abstract DocumentHighlightKind(Int) {
	var Text = 0;
	var Read = 1;
	var Write = 2;
}

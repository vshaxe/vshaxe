package vscode;

typedef TextDocumentChangeEvent = {
	var document:TextDocument;
	var contentChanges:Array<TextDocumentContentChangeEvent>;
}

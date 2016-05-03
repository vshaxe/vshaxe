package vscode;

typedef TextDocumentContentChangeEvent = {
	var range:Range;
	var rangeLength:Int;
	var text:String;
}

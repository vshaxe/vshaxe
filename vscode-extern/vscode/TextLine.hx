package vscode;

typedef TextLine = {
	var lineNumber(default,null):Int;
	var text(default,null):String;
	var range(default,null):Range;
	var rangeIncludingLineBreak(default,null):Range;
	var firstNonWhitespaceCharacterIndex(default,null):Int;
	var isEmptyOrWhitespace(default,null):Bool;
}

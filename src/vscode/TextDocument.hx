package vscode;

import js.Promise.Thenable;

typedef TextDocument = {
	var uri(default,null):Uri;
	var fileName(default,null):String;
	var isUntitled(default,null):Bool;
	var languageId(default,null):String;
	var version(default,null):Int;
	var isDirty(default,null):Bool;
	function save():Thenable<Bool>;
	var lineCount:Int;

	@:overload(function(position:Position):TextLine {})
	function lineAt(line:Int):TextLine;

	function offsetAt(position:Position):Int;
	function positionAt(offset:Int):Position;
	function getText(?range:Range):String;
	function getWordRangeAtPosition(position:Position):Range;
	function validateRange(range:Range):Range;
	function validatePosition(position:Position):Position;
}

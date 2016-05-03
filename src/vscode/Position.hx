package vscode;

@:jsRequire("vscode", "Position")
extern class Position {
	var line(default,null):Int;
	var character(default,null):Int;
	function new(line:Int, character:Int):Void;
	function isBefore(other:Position):Bool;
	function isBeforeOrEqual(other:Position):Bool;
	function isAfter(other:Position):Bool;
	function isAfterOrEqual(other:Position):Bool;
	function isEqual(other:Position):Bool;
	function compareTo(other:Position):Int;
	function translate(?lineDelta:Int, ?characterDelta:Int):Position;
	function with(?line:Int, ?character:Int):Position;
}

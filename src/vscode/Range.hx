package vscode;

@:jsRequire("vscode", "Range")
extern class Range {
	var start(default,null):Position;
	var end(default,null):Position;
	var isEmpty:Bool;
	var isSingleLine:Bool;

	@:overload(function(startLine:Int, startCharacter:Int, endLine:Int, endCharacter:Int):Void {})
	function new(start:Position, end:Position):Void;

	function contains(positionOrRange:haxe.extern.EitherType<Position, Range>):Bool;
	function isEqual(other:Range):Bool;
	function intersection(range:Range):Range;
	function union(other:Range):Range;
	function with(?start:Position, ?end:Position):Range;
}

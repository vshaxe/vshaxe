package vscode;

@:jsRequire("vscode", "Selection")
extern class Selection extends Range {
	var anchor:Position;
	var active:Position;
	var isReversed:Bool;

	@:overload(function(anchorLine:Int, anchorCharacter:Int, activeLine:Int, activeCharacter:Int):Void {})
	function new(anchor:Position, active:Position):Void;
}

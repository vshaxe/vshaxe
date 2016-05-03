package vscode;

typedef TextEditorEdit = {
	function replace(location:haxe.extern.EitherType<Position, haxe.extern.EitherType<Range, Selection>>, value:String):Void;
	function insert(location:Position, value:String):Void;
	function delete(location:haxe.extern.EitherType<Range, Selection>):Void;
	function setEndOfLine(endOfLine:EndOfLine):Void;
}

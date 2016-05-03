package vscode;

@:jsRequire("vscode", "TextEdit")
extern class TextEdit {
	static function replace(range:Range, newText:String):TextEdit;
	static function insert(position:Position, newText:String):TextEdit;
	static function delete(range:Range):TextEdit;
	var range:Range;
	var newText:String;
	function new(range:Range, newText:String);
}

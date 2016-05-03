package vscode;

@:jsRequire("vscode", "Hover")
extern class Hover {
	var contents:Array<MarkedString>;
	var range:Range;
	function new(contents:haxe.extern.EitherType<MarkedString, Array<MarkedString>>, ?range:Range);
}

package vscode;

@:jsRequire("vscode", "Location")
extern class Location {
	var uri:Uri;
	var range:Range;
	function new(uri:Uri, rangeOrPosition:haxe.extern.EitherType<Range,Position>):Void;
}

package vscode;

@:jsRequire("vscode", "WorkspaceEdit")
extern class WorkspaceEdit {
	function new();
	var size:Int;
	function replace(uri:Uri, range:Range, newText:String):Void;
	function insert(uri:Uri, position:Position, newText:String):Void;
	function delete(uri:Uri, range:Range):Void;
	function has(uri:Uri):Bool;
	function set(uri:Uri, edits:Array<TextEdit>):Void;
	function get(uri:Uri):Array<TextEdit>;
	function entries():Array<Array<Dynamic>>;
}

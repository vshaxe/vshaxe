package vscode;

typedef OutputChannel = {
	var name:String;
	function append(value:String):Void;
	function appendLine(value:String):Void;
	function clear():Void;

	@:overload(function(?preservceFocus:Bool):Void {})
	function show(?column:ViewColumn, ?preserveFocus:Bool):Void;
	function hide():Void;
	function dispose():Void;
}

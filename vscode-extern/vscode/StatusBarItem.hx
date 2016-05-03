package vscode;

typedef StatusBarItem = {
	var alignment:StatusBarAlignment;
	var priority:Float;
	var text:String;
	var tooltip:String;
	var color:String;
	var command:String;
	function show():Void;
	function hide():Void;
	function dispose():Void;
}

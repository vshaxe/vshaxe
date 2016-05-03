package vscode;

typedef EnterAction = {
	var indentAction:IndentAction;
	@:optional var appendText:String;
	@:optional var removeText:Int;
}

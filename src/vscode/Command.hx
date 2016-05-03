package vscode;

typedef Command = {
	var title:String;
	var command:String;
	@:optional var arguments:Array<Dynamic>;
}

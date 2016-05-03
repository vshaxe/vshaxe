package vscode;

typedef InputBoxOptions = {
	@:optional var value:String;
	@:optional var prompt:String;
	@:optional var placeHolder:String;
	@:optional var password:Bool;
	@:optional var validateInput:String->String;
}

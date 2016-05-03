package vscode;

@:jsRequire("vscode", "Uri")
extern class Uri {
	static function file(path:String):Uri;
	static function parse(value:String):Uri;
	var scheme:String;
	var authority:String;
	var path:String;
	var query:String;
	var fragment:String;
	var fsPath:String;
	function toString():String;
	function toJSON():Dynamic;
}

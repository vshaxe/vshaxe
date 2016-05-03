package vscode;

import js.Promise.Thenable;

typedef Extension<T> = {
	var id:String;
	var extensionPath:String;
	var isActive:Bool;
	var packageJSON:Dynamic;
	var exports:T;
	function activate():Thenable<T>;
}

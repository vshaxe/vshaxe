package vscode;

@:jsRequire("vscode", "Disposable")
extern class Disposable {
	static function from(disposableLikes:haxe.extern.Rest<{dispose:Void->Dynamic}>):Disposable;
	function new(callOnDispose:haxe.Constraints.Function):Void;
	function dispose():Dynamic;
}

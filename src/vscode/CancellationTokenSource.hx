package vscode;

@:jsRequire("vscode", "CancellationTokenSource")
extern class CancellationTokenSource {
	var token:CancellationToken;
	function cancel():Void;
	function dispose():Void;
}

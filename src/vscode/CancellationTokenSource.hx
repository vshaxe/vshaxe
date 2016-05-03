package vscode;

extern class CancellationTokenSource {
	var token:CancellationToken;
	function cancel():Void;
	function dispose():Void;
}

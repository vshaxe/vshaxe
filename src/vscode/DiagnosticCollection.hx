package vscode;

typedef DiagnosticCollection = {
	var name:String;
	@:overload(function(entries:Array<Array<Dynamic>>):Void {})
	function set(uri:Uri, diagnostics:Array<Diagnostic>):Void;
	function delete(uri:Uri):Void;
	function clear():Void;
	function dispose():Void;
}

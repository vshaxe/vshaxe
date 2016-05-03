package vscode;

typedef WorkspaceConfiguration = {
	function get<T>(section:String, ?defaultValue:T):T;
	function has(section:String):Bool;
}

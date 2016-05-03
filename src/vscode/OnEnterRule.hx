package vscode;

typedef OnEnterRule = {
	var beforeText:js.RegExp;
	@:optional var afterText:js.RegExp;
	var action:EnterAction;
}


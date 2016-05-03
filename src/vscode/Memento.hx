package vscode;

import js.Promise.Thenable;

typedef Memento = {
	function get<T>(key:String, ?defaultValue:T):T;
	function update(key:String, value:Dynamic):Thenable<Void>;
}

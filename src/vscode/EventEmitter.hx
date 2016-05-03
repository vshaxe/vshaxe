package vscode;

extern class EventEmitter<T> {
	var event:Event<T>;
	function fire(?data:T):Void;
	function dispose():Void;
}

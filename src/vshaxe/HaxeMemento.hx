package vshaxe;

import js.Promise.Thenable;

abstract HaxeMemento(vscode.Memento) from vscode.Memento {
	public inline function get<T>(key:HaxeMementoKey<T>, ?defaultValue:T):T {
		return this.get(key, defaultValue);
	}

	public inline function update<T>(key:HaxeMementoKey<T>, value:T):Thenable<Void> {
		return this.update(key, value);
	}

	public inline function delete<T>(key:HaxeMementoKey<T>):Thenable<Void> {
		return this.update(key, js.Lib.undefined);
	}
}

enum abstract HaxeMementoKey<T>(MementoKey<T>) to MementoKey<T> {
	public function new(key)
		this = new MementoKey("haxe." + key);
}

class HaxeMementoTools {
	public static inline function getWorkspaceState(context:ExtensionContext):HaxeMemento {
		return context.workspaceState;
	}
}

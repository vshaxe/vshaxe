package vshaxe;

import js.lib.Promise.Thenable;

abstract MementoKey<T>(String) to String {
	public inline function new(key)
		this = key;
}

private typedef MementoCollection<T> = haxe.DynamicAccess<Null<T>>;

class WorkspaceMementos {
	static inline final MEMENTO_VERSION = 1;
	static inline final MEMENTO_VERSION_KEY = new MementoKey<Int>("haxe.mementoVersion");

	final storage:Memento;

	public function new(storage) {
		this.storage = storage;
		maybeMigrate();
	}

	public function getDefault<T>(folder:WorkspaceFolder, key:MementoKey<T>, defaultValue:T):T {
		var value = get(folder, key);
		return if (value == null) defaultValue else value;
	}

	public function get<T>(folder:WorkspaceFolder, key:MementoKey<T>):Null<T> {
		var collection:Null<MementoCollection<T>> = storage.get(key);
		if (collection == null)
			return null;
		return collection[folder.uri.toString()];
	}

	public function set<T>(folder:WorkspaceFolder, key:MementoKey<T>, value:Null<T>):Thenable<Void> {
		var collection:Null<MementoCollection<T>> = storage.get(key);
		if (collection == null)
			collection = new MementoCollection();
		collection[folder.uri.toString()] = value;
		return storage.update(key, collection);
	}

	public function delete<T>(folder:WorkspaceFolder, key:MementoKey<T>):Thenable<Void> {
		var collection:Null<MementoCollection<T>> = storage.get(key);
		if (collection == null)
			collection = new MementoCollection();
		collection.remove(folder.uri.toString());
		return storage.update(key, collection);
	}

	function maybeMigrate() {
		var version:Null<Int> = storage.get(MEMENTO_VERSION_KEY);
		if (version == null) {
			inline function clear(key)
				storage.update(key, js.Lib.undefined);
			// TODO: figure out how to actually migrate data (need workspace folder info)
			clear(vshaxe.display.DisplayArguments.ProviderNameKey);
			clear(vshaxe.display.HaxeDisplayArgumentsProvider.ConfigurationIndexKey);
			clear(vshaxe.HxmlDiscovery.DiscoveredFilesKey);
			storage.update(MEMENTO_VERSION_KEY, MEMENTO_VERSION);
		}
	}
}

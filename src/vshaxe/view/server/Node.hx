package vshaxe.view.server;

import haxe.display.JsonModuleTypes.JsonModulePath;

typedef HaxeServerContext = {
	var index:Int;
	var desc:String;
	var signature:String;
	var platform:String;
	var classPaths:Array<String>;
	var defines:Array<{key:String, value:String}>;
}

typedef SizeResult = {
	var path:String;
	var size:Int;
}

typedef ModuleTypeSizeResult = SizeResult & {
	var fields:Array<SizeResult>;
}

typedef ModulesSizeResult = SizeResult & {
	var types:Array<ModuleTypeSizeResult>;
}

typedef ModuleId = {
	var path:String;
	var sign:String;
}

enum Kind {
	ServerRoot;
	MemoryRoot;
	ModuleMemory(types:Array<ModulesSizeResult>);
	ModuleTypeMemory(types:Array<ModuleTypeSizeResult>);
	Context(ctx:HaxeServerContext);
	ContextModules(ctx:HaxeServerContext);
	ContextFiles(ctx:HaxeServerContext);
	ModuleInfo(sign:String, path:String);
	ModuleList(modules:Array<ModuleId>);
	StringList(strings:Array<String>);
	StringMapping(mapping:Array<{var key:String; var value:String;}>);
	Leaf;
}

class Node extends TreeItem {
	public final parent:Null<Node>;
	public final kind:Kind;

	public function new(label:String, description:Null<String>, kind:Kind, ?parent:Node) {
		super(label, kind == Leaf ? None : Collapsed);
		this.description = description;
		this.parent = parent;
		this.kind = kind;
		switch (kind) {
			case StringList(_) | StringMapping(_) | Context(_):
				this.contextValue = "copyable";
			case ServerRoot | MemoryRoot | ContextModules(_) | ContextFiles(_) | ModuleInfo(_):
				this.contextValue = "reloadable";
			case _:
		}
	}
}

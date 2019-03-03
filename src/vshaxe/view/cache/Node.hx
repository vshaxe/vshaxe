package vshaxe.view.cache;

typedef HaxeServerContext = {
	final index:Int;
	final desc:String;
	final signature:String;
	final platform:String;
	final classPaths:Array<String>;
	final defines:Array<{key:String, value:String}>;
}

typedef SizeResult = {
	final path:String;
	final size:Int;
}

typedef ModuleTypeSizeResult = SizeResult & {
	final fields:Array<SizeResult>;
}

typedef ModulesSizeResult = SizeResult & {
	final types:Array<ModuleTypeSizeResult>;
}

typedef ModuleId = {
	final path:String;
	final sign:String;
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

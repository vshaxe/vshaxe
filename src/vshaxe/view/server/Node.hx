package vshaxe.view.server;

typedef HaxeServerContext = {
	var index:Int;
	var desc:String;
	var signature:String;
	var platform:String;
	var classPaths:Array<String>;
	var defines:Array<{key:String, value:String}>;
}

enum Kind {
	ServerRoot;
	MemoryRoot;
	Context(ctx:HaxeServerContext);
	ContextModules(ctx:HaxeServerContext);
	ContextFiles(ctx:HaxeServerContext);
	ModuleInfo(ctx:HaxeServerContext, path:String);
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
			case _:
		}
	}
}

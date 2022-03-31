package vshaxe.view.cache;

import haxe.display.JsonModuleTypes;
import haxe.display.Position.Location;
import haxe.display.Server;

enum Kind {
	ServerRoot;
	MemoryRoot;
	ContextMemory(ctx:HaxeServerContext);
	ModuleMemory(sign:String, path:String);
	Context(ctx:HaxeServerContext);
	ContextModules(ctx:HaxeServerContext);
	ContextFiles(ctx:HaxeServerContext);
	ModuleInfo(sign:String, path:String);
	ModuleList(modules:Array<ModuleId>);
	TypeList(sign:String, modulePath:String, types:Array<String>);
	TypeInfo(sign:String, modulePath:String, typeName:String);
	FieldList(fields:JsonClassFields);
	FieldInfo(field:JsonClassField);
	StringList(strings:Array<String>);
	StringMapping(mapping:Array<{key:String, value:String}>);
	Nodes(nodes:Array<Node>);
	Leaf;
}

class Node extends TreeItem {
	public final parent:Null<Node>;
	public final kind:Kind;
	public var gotoPosition:Null<Location>;

	public function new(label:String, description:Null<String>, kind:Kind, ?parent:Node) {
		super(label, if (kind == Leaf) None else Collapsed);
		this.description = description;
		this.parent = parent;
		this.kind = kind;
		switch kind {
			case StringList(_) | StringMapping(_) | Context(_):
				contextValue = "copyable";
			case ServerRoot | MemoryRoot | ContextModules(_) | ContextFiles(_) | ModuleInfo(_) | ContextMemory(_) | ModuleMemory(_):
				contextValue = "reloadable";
			case _:
		}
	}

	public function setGotoPosition(pos:Location) {
		gotoPosition = pos;
		contextValue += "gotoable";
	}
}

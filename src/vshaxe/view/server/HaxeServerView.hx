package vshaxe.view.server;

import vshaxe.server.LanguageServer;
import vshaxe.view.server.Node.ModuleId;
import vshaxe.view.server.Node.ModulesSizeResult;
import vshaxe.view.server.Node.HaxeServerContext;
import haxe.display.JsonModuleTypes;
import haxe.ds.ArraySort;

typedef JsonModule = {
	var id:Int;
	var path:JsonModulePath;
	var types:Array<JsonTypePath>;
	var file:String;
	var sign:String;
	var dependencies:Array<ModuleId>;
}

typedef JsonServerFile = {
	var file:String;
	var time:Float;
	var pack:String;
	var moduleName:Null<String>;
}

typedef HaxeMemoryResult = {
	var contexts:Array<{
		var context:Null<HaxeServerContext>;
		var size:Int;
		var modules:Array<ModulesSizeResult>;
	}>;
	var memory:{
		var totalCache:Int;
		var haxelibCache:Int;
		var parserCache:Int;
		var moduleCache:Int;
	}
}

class HaxeServerView {
	final context:ExtensionContext;
	final server:LanguageServer;
	@:nullSafety(Off) final view:TreeView<Node>;
	var didChangeTreeData = new EventEmitter<Node>();

	public var onDidChangeTreeData:Event<Node>;

	public function new(context:ExtensionContext, server:LanguageServer) {
		this.context = context;
		this.server = server;
		onDidChangeTreeData = didChangeTreeData.event;
		context.registerHaxeCommand(ServerView_CopyNodeValue, copyNodeValue);
		context.registerHaxeCommand(ServerView_ReloadNode, reloadNode);
		view = window.createTreeView("haxe.server", {treeDataProvider: this, showCollapseAll: true});
		window.registerTreeDataProvider("haxe.server", this);
		commands.executeCommand("setContext", "enableHaxeServerView", true);
	}

	public var getParent = function(node:Node) {
		return node.parent;
	}

	public function getTreeItem(node:Node) {
		return node;
	}

	public function getChildren(?node:Node):ProviderResult<Array<Node>> {
		return if (node == null) {
			[new Node("server", null, ServerRoot), new Node("memory", null, MemoryRoot)];
		} else {
			switch (node.kind) {
				case ServerRoot:
					server.runMethod("server/contexts").then(function(result:Array<HaxeServerContext>) {
						var nodes = [];
						for (ctx in result) {
							ArraySort.sort(ctx.defines, (kv1, kv2) -> Reflect.compare(kv1.key, kv2.key));
							nodes.push(new Node(ctx.platform, ctx.desc, Context(ctx)));
						}
						return nodes;
					}, reject -> reject);
				case MemoryRoot:
					server.runMethod("server/memory").then(function(result:HaxeMemoryResult) {
						var nodes = [];
						var kv = [
							{key: "total cache", value: formatSize(result.memory.totalCache)},
							{key: "haxelib cache", value: formatSize(result.memory.haxelibCache)},
							{key: "parser cache", value: formatSize(result.memory.parserCache)},
							{key: "module cache", value: formatSize(result.memory.moduleCache)}
						];
						nodes.push(new Node("overview", null, StringMapping(kv), node));
						for (ctx in result.contexts) {
							var name = ctx.context == null ? "?" : '${ctx.context.platform} (${ctx.context.desc}, ${ctx.context.index})';
							nodes.push(new Node(name, formatSize(ctx.size), ModuleMemory(ctx.modules), node));
						}
						return nodes;
					}, reject -> reject);
				case ModuleMemory(types):
					return types.map(function(sizeResult) {
						return new Node(sizeResult.path, formatSize(sizeResult.size), ModuleTypeMemory(sizeResult.types), node);
					});
				case ModuleTypeMemory(fields):
					return fields.map(function(sizeResult) {
						var kv = sizeResult.fields.map(sizeResult -> {key: sizeResult.path, value: formatSize(sizeResult.size)});
						return new Node(sizeResult.path, formatSize(sizeResult.size), StringMapping(kv), node);
					});
				case Context(ctx):
					[
						new Node('index', "" + ctx.index, Leaf, node),
						new Node('desc', ctx.desc, Leaf, node),
						new Node('signature', ctx.signature, Leaf, node),
						new Node("class paths", null, StringList(ctx.classPaths), node),
						new Node("defines", null, StringMapping(ctx.defines), node),
						new Node("modules", null, ContextModules(ctx), node),
						new Node("files", null, ContextFiles(ctx), node)
					];
				case StringList(strings):
					strings.map(s -> new Node(s, null, Leaf, node));
				case StringMapping(mapping):
					mapping.map(kv -> new Node(kv.key, kv.value, Leaf, node));
				case ContextModules(ctx):
					server.runMethod("server/modules", {signature: ctx.signature}).then(function(result:Array<String>) {
						var nodes = [];
						ArraySort.sort(result, Reflect.compare);
						for (s in result) {
							nodes.push(new Node(s, null, ModuleInfo(ctx.signature, s)));
						}
						return nodes;
					}, reject -> reject);
				case ContextFiles(ctx):
					server.runMethod("server/files", {signature: ctx.signature}).then(function(result:Array<JsonServerFile>) {
						var nodes = result.map(file -> new Node(file.file, null,
							StringMapping([{key: "mtime", value: "" + file.time}, {key: "package", value: file.pack}]), node));
						return nodes;
					}, reject -> reject);
				case ModuleList(modules):
					var nodes = [];
					for (module in modules) {
						nodes.push(new Node(module.path, null, ModuleInfo(module.sign, module.path)));
					}
					return nodes;
				case ModuleInfo(sign, path):
					server.runMethod("server/module", {signature: sign, path: path}).then(function(result:JsonModule) {
						var types = result.types.map(path -> path.typeName);
						ArraySort.sort(types, Reflect.compare);
						return [
							new Node("id", "" + result.id, Leaf, node),
							new Node("path", printPath(cast result.path), Leaf, node),
							new Node("file", result.file, Leaf, node),
							new Node("sign", result.sign, Leaf, node),
							new Node("types", null, StringList(types), node),
							new Node("dependencies", null, ModuleList(result.dependencies), node)
						];
					}, reject -> reject);
				case Leaf:
					[];
			}
		}
	}

	function copyNodeValue(node:Node) {
		function printKv(kv:Array<{key:String, value:String}>) {
			return kv.map(kv -> '${kv.key}=${kv.value}').join(" ");
		}
		var value = switch (node.kind) {
			case StringList(strings): strings.join(" ");
			case StringMapping(mapping): printKv(mapping);
			case Context(ctx):
				var buf = new StringBuf();
				function add(key:String, value:String) {
					buf.add('$key: $value\n');
				}
				add("index", "" + ctx.index);
				add("desc", ctx.desc);
				add("signature", ctx.signature);
				add("platform", ctx.platform);
				add("classPaths", ctx.classPaths.join(" "));
				add("defines", printKv(ctx.defines));
				buf.toString();
			case _: throw false;
		}
		env.clipboard.writeText(value);
	}

	function reloadNode(node:Node) {
		didChangeTreeData.fire(node);
	}

	static function printPath(path:JsonTypePath) {
		var buf = new StringBuf();
		if (path.pack.length > 0) {
			buf.add(path.pack.join('.'));
			buf.addChar('.'.code);
		}
		buf.add(path.moduleName);
		if (path.typeName != null) {
			buf.addChar('.'.code);
			buf.add(path.typeName);
		}
		return buf.toString();
	}

	static function formatSize(size:Int) {
		return if (size < 1024) {
			size + " B";
		} else if (size < 1024 * 1024) {
			(size >>> 10) + " KB";
		} else {
			var size = Std.string(size / (1024 * 1024));
			var offset = size.indexOf(".");
			if (offset < 0) {
				size + " MB";
			} else {
				size.substr(0, offset + 2) + " MB";
			}
		}
	}
}

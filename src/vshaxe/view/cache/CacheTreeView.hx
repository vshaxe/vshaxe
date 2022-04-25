package vshaxe.view.cache;

import haxe.display.JsonModuleTypes;
import haxe.display.Server;
import haxe.ds.ArraySort;
import haxe.format.JsonPrinter;
import vshaxe.server.LanguageServer;

class CacheTreeView {
	final context:ExtensionContext;
	final server:LanguageServer;
	@:nullSafety(Off) final view:TreeView<Node>;
	var didChangeTreeData = new EventEmitter<Node>();
	var skipRefresh:Map<Node, Array<Node>> = [];

	public var onDidChangeTreeData:Event<Node>;

	public function new(context:ExtensionContext, server:LanguageServer) {
		this.context = context;
		this.server = server;
		onDidChangeTreeData = didChangeTreeData.event;
		context.registerHaxeCommand(Cache_CopyNodeValue, copyNodeValue);
		context.registerHaxeCommand(Cache_ReloadNode, reloadNode);
		context.registerHaxeCommand(Cache_GotoNode, gotoNode);
		window.registerTreeDataProvider("haxe.cache", this);
		view = window.createTreeView("haxe.cache", {treeDataProvider: this, showCollapseAll: true});
	}

	public var getParent = function(node:Node) {
		return node.parent;
	}

	public var resolveTreeItem = js.Lib.undefined;

	public function getTreeItem(node:Node) {
		return node;
	}

	public function getChildren(?node:Node):ProviderResult<Array<Node>> {
		if (node == null) {
			return [new Node("server", null, ServerRoot), new Node("memory", null, MemoryRoot)];
		}

		final children = skipRefresh[node];
		return if (children != null) {
			skipRefresh.remove(node);
			children;
		} else {
			final node:Node = node;
			function updateCount(nodes:Array<Node>) {
				node.description = Std.string(nodes.length);
				skipRefresh[node] = nodes; // avoid endless refresh loop
				didChangeTreeData.fire(node);
			}
			switch node.kind {
				case Nodes(nodes):
					return nodes;
				case ServerRoot:
					server.runMethod(ServerMethods.Contexts).then(function(result:Array<HaxeServerContext>) {
						final nodes = [];
						for (ctx in result) {
							ArraySort.sort(ctx.defines, (kv1, kv2) -> Reflect.compare(kv1.key, kv2.key));
							nodes.push(new Node(ctx.platform, ctx.desc, Context(ctx)));
						}
						return nodes;
					}, reject -> reject);
				case MemoryRoot:
					server.runMethod(ServerMethods.Memory).then(function(result:HaxeMemoryResult) {
						final nodes = [];
						final kv = [
							{key: "context cache", value: formatSize(result.memory.contextCache)},
							{key: "haxelib cache", value: formatSize(result.memory.haxelibCache)},
							{key: "directory cache", value: formatSize(result.memory.directoryCache)},
							{key: "native lib cache", value: formatSize(result.memory.nativeLibCache)},
						];
						final cacheNode = new Node("total cache", formatSize(result.memory.totalCache), StringMapping(kv), node);
						final subnodes = [cacheNode];
						if (result.memory.additionalSizes != null) {
							for (item in result.memory.additionalSizes) {
								subnodes.push(new Node(item.name, formatSize(item.size), Leaf, node));
							}
						}
						nodes.push(new Node("overview", null, Nodes(subnodes), node));
						for (ctx in result.contexts) {
							final name = ctx.context == null ? "?" : '${ctx.context.platform} (${ctx.context.desc}, ${ctx.context.index})';
							nodes.push(new Node(name, formatSize(ctx.size), ContextMemory(ctx.context), node));
						}
						return nodes;
					}, reject -> reject);
				case ContextMemory(ctx):
					return server.runMethod(ServerMethods.ContextMemory, {signature: ctx.signature}).then(function(result:HaxeContextMemoryResult) {
						final a = result.moduleCache.list.map(module -> new Node(module.path, formatSize(module.size),
							module.hasTypes ? ModuleMemory(ctx.signature, module.path) : Leaf));
						final sizeNodes = [
							new Node("syntax cache", formatSize(result.syntaxCache.size), Leaf, node),
							new Node("module cache", formatSize(result.moduleCache.size), Leaf, node)
						];
						final sizeNode = new Node("?sizes", null, Nodes(sizeNodes), node);
						a.unshift(sizeNode);
						if (result.leaks != null) {
							final leakNodes = [];
							for (leak in result.leaks) {
								leakNodes.push(new Node(leak.path, null, StringList(leak.leaks.map(leak -> leak.path))));
							}
							final leakNode = new Node("?LEAKS", null, Nodes(leakNodes), node);
							a.unshift(leakNode);
						}
						return a;
					}, reject -> reject);
				case ModuleMemory(sign, path):
					return server.runMethod(ServerMethods.ModuleMemory, {signature: sign, path: path}).then(function(result:HaxeModuleMemoryResult) {
						final types = [];
						types.push(new Node("?module extra size", formatSize(result.moduleExtra), Leaf, node));
						for (type in result.types) {
							final subnodes = type.fields.map(function(field) {
								final fieldNode = new Node(field.name, formatSize(field.size), Leaf, node);
								if (field.pos != null) {
									fieldNode.setGotoPosition(field.pos);
								}
								return fieldNode;
							});
							final typeNode = new Node(type.name, formatSize(type.size), Nodes(subnodes), node);
							if (type.pos != null) {
								typeNode.setGotoPosition(type.pos);
							}
							types.push(typeNode);
						};
						return types;
					}, reject -> reject);
				case Context(ctx):
					[
						new Node('index', "" + ctx.index, Leaf, node),
						new Node('desc', ctx.desc, Leaf, node),
						new Node('signature', ctx.signature, Leaf, node),
						new Node("class paths", Std.string(ctx.classPaths.length), StringList(ctx.classPaths), node),
						new Node("defines", Std.string(ctx.defines.length), StringMapping(ctx.defines), node),
						new Node("modules", "?", ContextModules(ctx), node),
						new Node("files", "?", ContextFiles(ctx), node)
					];
				case StringList(strings):
					strings.map(s -> new Node(s, null, Leaf, node));
				case StringMapping(mapping):
					mapping.map(kv -> new Node(kv.key, kv.value, Leaf, node));
				case ContextModules(ctx):
					server.runMethod(ServerMethods.Modules, {signature: ctx.signature}).then(function(result:Array<String>) {
						final nodes = [];
						ArraySort.sort(result, Reflect.compare);
						for (s in result) {
							nodes.push(new Node(s, null, ModuleInfo(ctx.signature, s)));
						}
						updateCount(nodes);
						return nodes;
					}, reject -> reject);
				case ContextFiles(ctx):
					server.runMethod(ServerMethods.Files, {signature: ctx.signature}).then(function(result:Array<JsonServerFile>) {
						final nodes = result.map(file -> new Node(file.file, null,
							StringMapping([{key: "mtime", value: "" + file.time}, {key: "package", value: file.pack}]), node));
						updateCount(nodes);
						return nodes;
					}, reject -> reject);
				case ModuleList(modules):
					final nodes = [];
					for (module in modules) {
						nodes.push(new Node(module.path, null, ModuleInfo(module.sign, module.path)));
					}
					return nodes;
				case ModuleInfo(sign, path):
					server.runMethod(ServerMethods.Module, {signature: sign, path: path}).then(function(result:JsonModule) {
						final types = result.types.map(path -> path.typeName);
						ArraySort.sort(types, Reflect.compare);
						return [
							new Node("id", "" + result.id, Leaf, node),
							new Node("path", printPath(cast result.path), Leaf, node),
							new Node("file", result.file, Leaf, node),
							new Node("sign", result.sign, Leaf, node),
							#if (haxe_ver >= "4.3.0") new Node("dirty", result.dirty == null ? "no" : result.dirty, Leaf, node),
							#end
							new Node("types", Std.string(types.length), TypeList(sign, path, types), node),
							new Node("dependencies", Std.string(result.dependencies.length), ModuleList(result.dependencies), node)
						];
					}, reject -> reject);
				case TypeList(sign, modulePath, types):
					final nodes = [];
					for (name in types) {
						nodes.push(new Node(name, null, TypeInfo(sign, modulePath, name)));
					}
					nodes;
				case TypeInfo(sign, modulePath, typeName):
					function process<T>(result:JsonModuleType<T>) {
						final nodes = [new Node("name", result.name, Leaf, node)];
						switch [result.kind, result.args] {
							case [Class, args]:
								if (args.statics.length > 0) {
									nodes.push(new Node("statics", null, FieldList(args.statics), node));
								}
								if (args.fields.length > 0) {
									nodes.push(new Node("fields", null, FieldList(args.fields), node));
								}
							case [Enum, args]:
							case [Typedef, args]:
							case [Abstract, args]:
						}
						return nodes;
					}
					#if (haxe_ver >= "4.3.0")
					server.runMethod(ServerMethods.Type, {signature: sign, modulePath: modulePath, typeName: typeName}).then(process, reject -> reject);
					#else
					[];
					#end
				case FieldList(fields):
					return fields.map(field -> new Node(field.name, null, FieldInfo(field), node));
				case FieldInfo(field):
					return [
						new Node("name", field.name, Leaf, node),
						new Node("type", JsonPrinter.print(field.type), Leaf, node) // TODO: figure out how to access DisplayPrinter
					];
				case Leaf:
					[];
			}
		}
	}

	function copyNodeValue(node:Node) {
		function printKv(kv:Array<{key:String, value:String}>) {
			return kv.map(kv -> '${kv.key}=${kv.value}').join(" ");
		}
		final value = switch node.kind {
			case StringList(strings): strings.join(" ");
			case StringMapping(mapping): printKv(mapping);
			case Context(ctx):
				final buf = new StringBuf();
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

	function gotoNode(node:Node) {
		if (node.gotoPosition != null) {
			final pos = node.gotoPosition;
			final start = pos.range.start;
			final selection = new Range(start.line, start.character, start.line, start.character);
			workspace.openTextDocument(pos.file.toString()).then(document -> window.showTextDocument(document, {selection: selection}));
		}
	}

	function reloadNode(node:Node) {
		didChangeTreeData.fire(node);
	}

	static function printPath(path:JsonTypePath) {
		final buf = new StringBuf();
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
			final size = Std.string(size / (1024 * 1024));
			final offset = size.indexOf(".");
			if (offset < 0) {
				size + " MB";
			} else {
				size.substr(0, offset + 2) + " MB";
			}
		}
	}
}

package vshaxe.view.dependencies;

import haxe.io.Path;
import vshaxe.view.dependencies.DependencyResolver;
import vshaxe.view.dependencies.Node;
import vshaxe.display.DisplayArguments;
import vshaxe.helper.HaxeExecutable;
import vshaxe.helper.PathHelper;

class DependencyTreeView {
	final context:ExtensionContext;
	final haxeExecutable:HaxeExecutable;
	@:nullSafety(Off) final view:TreeView<Node>;
	var displayArguments:Null<Array<String>>;
	var relevantHxmls:Array<String> = [];
	var dependencyNodes:Array<Node> = [];
	var dependencies:Null<DependencyList>;
	var refreshNeeded:Bool = true;
	var previousSelection:Null<{node:Node, time:Float}>;
	var autoRevealEnabled:Bool;
	var _onDidChangeTreeData = new EventEmitter<Node>();

	public var onDidChangeTreeData:Event<Node>;

	public function new(context:ExtensionContext, displayArguments:DisplayArguments, haxeExecutable:HaxeExecutable) {
		this.context = context;
		this.displayArguments = displayArguments.arguments;
		this.haxeExecutable = haxeExecutable;

		onDidChangeTreeData = _onDidChangeTreeData.event;
		inline updateAutoReveal();

		window.registerTreeDataProvider("haxe.dependencies", this);
		view = window.createTreeView("haxe.dependencies", {treeDataProvider: this, showCollapseAll: true});

		context.registerHaxeCommand(RefreshDependencies, refresh);
		context.registerHaxeCommand(Dependencies_OpenTextDocument, openTextDocument);
		context.registerHaxeCommand(Dependencies_Refresh, refresh);
		context.registerHaxeCommand(Dependencies_OpenPreview, openPreview);
		context.registerHaxeCommand(Dependencies_OpenToTheSide, openToTheSide);
		context.registerHaxeCommand(Dependencies_RevealInExplorer, revealInExplorer);
		context.registerHaxeCommand(Dependencies_OpenInCommandPrompt, openInCommandPrompt);
		context.registerHaxeCommand(Dependencies_CopyPath, copyPath);

		var hxmlFileWatcher = workspace.createFileSystemWatcher("**/*.hxml");
		context.subscriptions.push(hxmlFileWatcher.onDidCreate(onDidChangeHxml));
		context.subscriptions.push(hxmlFileWatcher.onDidChange(onDidChangeHxml));
		context.subscriptions.push(hxmlFileWatcher.onDidDelete(onDidChangeHxml));
		context.subscriptions.push(hxmlFileWatcher);

		context.subscriptions.push(haxeExecutable.onDidChangeConfiguration(_ -> refresh()));
		context.subscriptions.push(workspace.onDidChangeConfiguration(_ -> updateAutoReveal()));
		context.subscriptions.push(displayArguments.onDidChangeArguments(onDidChangeDisplayArguments));
		context.subscriptions.push(window.onDidChangeActiveTextEditor(_ -> autoReveal()));
		context.subscriptions.push(view.onDidChangeVisibility(_ -> autoReveal()));
	}

	function onDidChangeHxml(uri:Uri) {
		for (hxml in relevantHxmls) {
			if (PathHelper.areEqual(uri.fsPath, hxml)) {
				refresh(false);
			}
		}
	}

	function refreshDependencies():Array<Node> {
		if (workspace.workspaceFolders == null) {
			return [];
		}
		var newDependencies = DependencyExtractor.extractDependencies(displayArguments, workspace.workspaceFolders[0].uri.fsPath);
		relevantHxmls = newDependencies.hxmls;

		// avoid FS access / creating processes unless there were _actually_ changes
		if (dependencies != null
			&& dependencies.libs.equals(newDependencies.libs)
			&& dependencies.classPaths.equals(newDependencies.classPaths)) {
			return dependencyNodes;
		}
		dependencies = newDependencies;

		return updateNodes(DependencyResolver.resolveDependencies(newDependencies, haxeExecutable));
	}

	function updateNodes(dependencyInfos:Array<DependencyInfo>):Array<Node> {
		var newNodes:Array<Node> = [];

		for (info in dependencyInfos) {
			// don't add duplicates
			if (newNodes.find(d -> PathHelper.areEqual(d.path, info.path)) != null) {
				continue;
			}

			// reuse existing nodes if possible to preserve their collapsibleState
			if (dependencies != null) {
				var oldNode = dependencyNodes.find(d -> d.path == info.path);
				if (oldNode != null) {
					newNodes.push(oldNode);
					continue;
				}
			}

			var node = createNode(info);
			if (node != null) {
				newNodes.push(node);
			}
		}

		// sort alphabetically, but always show std at the bottom
		Node.sort(newNodes);
		haxe.ds.ArraySort.sort(newNodes, (node1, node2) -> {
			if (node1.type == StandardLibrary) {
				return 1;
			} else if (node2.type == StandardLibrary) {
				return -1;
			}
			return 0;
		});

		return newNodes;
	}

	function createNode(info):Null<Node> {
		if (info == null) {
			return null;
		}
		var label = info.name;
		if (info.version != null) {
			label += ' (${info.version})';
		}
		var type = if (info.name == "haxe") StandardLibrary else Haxelib;
		return new Node(label, info.path, type);
	}

	function onDidChangeDisplayArguments(displayArguments:Array<String>) {
		this.displayArguments = displayArguments;
		refresh();
	}

	function updateAutoReveal() {
		autoRevealEnabled = workspace.getConfiguration("explorer").get("autoReveal", true);
	}

	function autoReveal() {
		var editor = window.activeTextEditor;
		if (editor == null || !view.visible || !autoRevealEnabled) {
			return;
		}
		var document = editor.document;
		function loop(nodes:Array<Node>) {
			for (node in nodes) {
				if (node.isDirectory && PathHelper.containsFile(node.path, document.fileName)) {
					loop(node.children);
				} else if (PathHelper.areEqual(node.path, document.fileName)) {
					view.reveal(node, {select: true});
					break;
				}
			}
		}
		loop(dependencyNodes);
	}

	function refresh(hard:Bool = true) {
		if (hard) {
			dependencies = null;
			for (node in dependencyNodes) {
				node.refresh();
			}
		}
		refreshNeeded = true;
		_onDidChangeTreeData.fire();
	}

	public function getTreeItem(element:Node):TreeItem {
		return element;
	}

	public function getChildren(?node:Node):Array<Node> {
		if (refreshNeeded) {
			dependencyNodes = refreshDependencies();
			refreshNeeded = false;
		}
		return if (node == null) dependencyNodes else node.children;
	}

	public var getParent = function(node:Node) {
		return node.parent;
	}

	function openTextDocument(node:Node) {
		var currentTime = Date.now().getTime();
		var doubleClickTime = 500;
		var preview = previousSelection == null
			|| previousSelection.node != node
			|| (currentTime - previousSelection.time) >= doubleClickTime;
		workspace.openTextDocument(node.path).then(document -> window.showTextDocument(document, {preview: preview}));
		previousSelection = {node: node, time: currentTime};
	}

	function openPreview(node:Node) {
		commands.executeCommand("markdown.showPreview", node.path);
	}

	function openToTheSide(node:Node) {
		if (node.resourceUri != null) {
			window.showTextDocument(node.resourceUri, {viewColumn: Three});
		}
	}

	function revealInExplorer(node:Node) {
		var explorer = switch (Sys.systemName()) {
			case "Windows": "explorer";
			case "Linux": "xdg-open";
			case "Mac": "open";
			case _: throw "unsupported OS";
		}
		var arg = node.path;
		if (Sys.systemName() == "Windows") {
			arg = '/select,"$arg"';
		}
		// this isn't proper Sys.command() usage
		// - but otherwise the quoting seems to work improperly :(
		@:nullSafety(Off) // #7821
		Sys.command('$explorer $arg');
	}

	function openInCommandPrompt(node:Node) {
		var cwd = node.path;
		if (!node.isDirectory) {
			cwd = Path.directory(node.path);
		}
		window.createTerminal({cwd: cwd}).show();
	}

	function copyPath(node:Node) {
		env.clipboard.writeText(PathHelper.capitalizeDriveLetter(node.path));
	}
}

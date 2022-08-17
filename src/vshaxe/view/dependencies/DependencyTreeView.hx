package vshaxe.view.dependencies;

import haxe.ds.ReadOnlyArray;
import haxe.io.Path;
import vshaxe.helper.HaxeConfiguration;
import vshaxe.helper.PathHelper;
import vshaxe.view.dependencies.Node;

class DependencyTreeView {
	final context:ExtensionContext;
	final haxeConfiguration:HaxeConfiguration;
	@:nullSafety(Off) final view:TreeView<Node>;
	var dependencyNodes:Array<Node> = [];
	var previousSelection:Null<{node:Node, time:Float}>;
	var autoRevealEnabled:Bool;
	var refreshNeeded:Bool = true;
	var _onDidChangeTreeData = new EventEmitter<Node>();

	public var onDidChangeTreeData:Event<Node>;

	public function new(context:ExtensionContext, haxeConfiguration:HaxeConfiguration) {
		this.context = context;
		this.haxeConfiguration = haxeConfiguration;

		onDidChangeTreeData = _onDidChangeTreeData.event;
		inline updateAutoReveal();

		window.registerTreeDataProvider("haxe.dependencies", this);
		view = window.createTreeView("haxe.dependencies", {treeDataProvider: this, showCollapseAll: true});

		context.registerHaxeCommand(RefreshDependencies, refresh);
		context.registerHaxeCommand(RevealActiveFileInSideBar, revealActiveFile);
		context.registerHaxeCommand(Dependencies_OpenTextDocument, openTextDocument);
		context.registerHaxeCommand(Dependencies_Refresh, refresh);
		context.registerHaxeCommand(Dependencies_OpenPreview, openPreview);
		context.registerHaxeCommand(Dependencies_OpenToTheSide, openToTheSide);
		context.registerHaxeCommand(Dependencies_RevealInExplorer, revealInExplorer);
		context.registerHaxeCommand(Dependencies_OpenInCommandPrompt, openInCommandPrompt);
		context.registerHaxeCommand(Dependencies_FindInFolder, findInFolder);
		context.registerHaxeCommand(Dependencies_CopyPath, copyPath);

		context.subscriptions.push(workspace.onDidChangeConfiguration(_ -> updateAutoReveal()));
		context.subscriptions.push(window.onDidChangeActiveTextEditor(_ -> autoReveal()));
		context.subscriptions.push(view.onDidChangeVisibility(_ -> autoReveal()));
		context.subscriptions.push(haxeConfiguration.onDidChange(onDidChangeHaxeConfiguration));
	}

	function onDidChangeHaxeConfiguration(_) {
		refreshNeeded = true;
		_onDidChangeTreeData.fire();
	}

	function refresh() {
		for (node in dependencyNodes) {
			node.refresh();
		}
		haxeConfiguration.invalidate();
	}

	function updateNodes(dependencyInfos:ReadOnlyArray<DependencyInfo>):Array<Node> {
		final newNodes:Array<Node> = [];

		for (info in dependencyInfos) {
			// don't add duplicates
			if (newNodes.find(d -> PathHelper.areEqual(d.path, info.path)) != null) {
				continue;
			}

			// reuse existing nodes if possible to preserve their collapsibleState
			final oldNode = dependencyNodes.find(d -> d.path == info.path);
			if (oldNode != null) {
				newNodes.push(oldNode);
				continue;
			}

			final node = createNode(info);
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
		final type = if (info.name == "haxe") StandardLibrary else Haxelib;
		return new Node(label, info.path, type);
	}

	function updateAutoReveal() {
		autoRevealEnabled = workspace.getConfiguration("explorer").get("autoReveal", true);
	}

	function autoReveal() {
		final editor = window.activeTextEditor;
		if (editor == null || !view.visible || !autoRevealEnabled) {
			return;
		}
		reveal(editor.document.fileName, false);
	}

	function reveal(file:String, focus:Bool):Bool {
		var found = false;
		function loop(nodes:Array<Node>) {
			for (node in nodes) {
				if (node.isDirectory && PathHelper.containsFile(node.path, file)) {
					loop(node.children);
				} else if (PathHelper.areEqual(node.path, file)) {
					found = true;
					view.reveal(node, {select: true, focus: focus});
					break;
				}
			}
		}
		loop(dependencyNodes);
		return found;
	}

	public function getTreeItem(element:Node):TreeItem {
		return element;
	}

	public function getChildren(?node:Node):Array<Node> {
		final config = haxeConfiguration.resolvedConfiguration;
		if (config == null) {
			return [];
		}
		if (refreshNeeded) {
			dependencyNodes = updateNodes(config.dependencies);
			refreshNeeded = false;
		}
		return if (node == null) dependencyNodes else node.children;
	}

	public var getParent = function(node:Node) {
		return node.parent;
	}

	public var resolveTreeItem = js.Lib.undefined;

	function revealActiveFile() {
		final editor = window.activeTextEditor;
		if (editor == null) {
			return;
		}
		getChildren(); // trigger refresh if needed
		final file = editor.document.fileName;
		if (!reveal(file, true)) {
			// if not found, try with the regular explorer
			commands.executeCommand("workbench.files.action.showActiveFileInExplorer");
		}
	}

	function openTextDocument(node:Node) {
		final currentTime = Date.now().getTime();
		final doubleClickTime = 500;
		final preview = previousSelection == null
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
		final path = '"${node.path}"';
		final command = switch Sys.systemName() {
			case "Windows": 'explorer /select,$path';
			case "Linux": 'xdg-open $path';
			case "Mac": 'open $path -R';
			case _: throw "unsupported OS";
		}
		@:nullSafety(Off) // #7821
		Sys.command(command);
	}

	function openInCommandPrompt(node:Node) {
		var cwd = node.path;
		if (!node.isDirectory) {
			cwd = Path.directory(node.path);
		}
		window.createTerminal({cwd: cwd}).show();
	}

	function findInFolder(node:Node) {
		if (!node.isDirectory) {
			return;
		}
		commands.executeCommand("workbench.action.findInFiles", {
			query: "",
			filesToInclude: PathHelper.capitalizeDriveLetter(PathHelper.sanitizeComas(node.path))
		});
	}

	function copyPath(node:Node) {
		env.clipboard.writeText(PathHelper.capitalizeDriveLetter(node.path));
	}
}

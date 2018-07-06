package vshaxe.view.dependencies;

import haxe.io.Path;
import vshaxe.view.dependencies.DependencyResolver;
import vshaxe.view.dependencies.Node;
import vshaxe.display.DisplayArguments;
import vshaxe.helper.CopyPaste;
import vshaxe.helper.HaxeExecutable;

class DependencyTreeView {
    var context:ExtensionContext;
    var displayArguments:Array<String>;
    var haxeExecutable:HaxeExecutable;
    var relevantHxmls:Array<String> = [];
    var dependencyNodes:Array<Node> = [];
    var dependencies:DependencyList;
    var refreshNeeded:Bool = true;
    var previousSelection:{node:Node, time:Float};

    var _onDidChangeTreeData = new EventEmitter<Node>();

    public var onDidChangeTreeData:Event<Node>;

    public function new(context:ExtensionContext, displayArguments:DisplayArguments, haxeExecutable:HaxeExecutable) {
        this.context = context;
        this.displayArguments = displayArguments.arguments;
        this.haxeExecutable = haxeExecutable;
        displayArguments.onDidChangeArguments(onDidChangeDisplayArguments);

        onDidChangeTreeData = _onDidChangeTreeData.event;
        window.registerTreeDataProvider("haxe.dependencies", this);
        context.registerHaxeCommand(RefreshDependencies, refresh);
        context.registerHaxeCommand(CollapseDependencies, collapseAll);
        context.registerHaxeCommand(Dependencies_OpenTextDocument, openTextDocument);
        context.registerHaxeCommand(Dependencies_Refresh, refresh);
        context.registerHaxeCommand(Dependencies_CollapseAll, collapseAll);
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
    }

    function onDidChangeHxml(uri:Uri) {
        for (hxml in relevantHxmls) {
            if (Path.normalize(uri.fsPath) == Path.normalize(hxml)) {
                refresh(false);
            }
        }
    }

    function refreshDependencies():Array<Node> {
        var newDependencies = DependencyExtractor.extractDependencies(displayArguments, workspace.workspaceFolders[0].uri.fsPath);
        relevantHxmls = newDependencies.hxmls;

        // avoid FS access / creating processes unless there were _actually_ changes
        if (dependencies != null && dependencies.libs.equals(newDependencies.libs) && dependencies.classPaths.equals(newDependencies.classPaths)) {
            return dependencyNodes;
        }
        dependencies = newDependencies;

        return updateNodes(DependencyResolver.resolveDependencies(newDependencies, haxeExecutable));
    }

    function updateNodes(dependencyInfos:Array<DependencyInfo>):Array<Node> {
        var newNodes:Array<Node> = [];

        for (info in dependencyInfos) {
            // don't add duplicates
            if (newNodes.find(d -> d.path == info.path) != null) {
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

    function createNode(info):Node {
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

    public final getParent = null;

    function openTextDocument(node:Node) {
        var currentTime = Date.now().getTime();
        var doubleClickTime = 500;
        var preview = previousSelection == null || previousSelection.node != node || (currentTime - previousSelection.time) >= doubleClickTime;
        workspace.openTextDocument(node.path).then(document -> window.showTextDocument(document, {preview: preview}));
        previousSelection = {node: node, time: currentTime};
    }

    function collapseAll(node:Node) {
        for (node in dependencyNodes) {
            node.collapse();
        }
        _onDidChangeTreeData.fire();
    }

    function openPreview(node:Node) {
        commands.executeCommand("markdown.showPreview", node.resourceUri);
    }

    function openToTheSide(node:Node) {
        window.showTextDocument(node.resourceUri, {viewColumn: Three});
    }

    function revealInExplorer(node:Node) {
        var explorer = switch (Sys.systemName()) {
            case "Windows": "explorer";
            case "Linux": "xdg-open";
            case "Mac": "open";
            case _: throw "unsupported OS";
        }
        var arg = node.resourceUri.fsPath;
        if (Sys.systemName() == "Windows") {
            arg = '/select,"$arg"';
        }
        // this isn't proper Sys.command() usage
        // - but otherwise the quoting seems to work improperly :(
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
        CopyPaste.copy(node.resourceUri.fsPath);
    }
}

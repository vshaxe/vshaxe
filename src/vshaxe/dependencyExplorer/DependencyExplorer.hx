package vshaxe.dependencyExplorer;

import haxe.io.Path;
import js.Promise;
import vshaxe.dependencyExplorer.DependencyResolver;
import vshaxe.display.DisplayArguments;
import vshaxe.helper.HaxeExecutable;

class DependencyExplorer {
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
        context.registerHaxeCommand(Dependencies_SelectNode, selectNode);
        context.registerHaxeCommand(Dependencies_CollapseAll, collapseAll);
        context.registerHaxeCommand(Dependencies_Refresh, refresh);

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
        var newDependencies = DependencyResolver.extractDependencies(displayArguments, workspace.rootPath);
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
        return new Node(label, info.path);
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

    public function getChildren(?node:Node):Thenable<Array<Node>> {
        return new Promise(function(resolve, _) {
            if (refreshNeeded) {
                dependencyNodes = refreshDependencies();
                refreshNeeded = false;
            }

            resolve(if (node == null) dependencyNodes else node.children);
        });
    }

    function selectNode(node:Node) {
        if (node.isDirectory) {
            node.toggleState();
            _onDidChangeTreeData.fire();
        } else {
            openTextDocument(node);
        }
    }

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
}

package vshaxe;

import haxe.io.Path;
import sys.FileSystem;
import Vscode.*;
import vscode.*;
import js.Promise;
import vshaxe.DependencyHelper;
using Lambda;

class DependencyExplorer {
    var context:ExtensionContext;
    var configuration:Array<String>;
    var relevantHxmls:Array<String> = [];
    var dependencies:Array<Node> = [];
    var refreshNeeded:Bool = true;

    var _onDidChangeTreeData = new EventEmitter<Node>();

    public var onDidChangeTreeData:Event<Node>;

    public function new(context:ExtensionContext, configuration:Array<String>) {
        this.context = context;
        this.configuration = configuration;

        onDidChangeTreeData = _onDidChangeTreeData.event;
        window.registerTreeDataProvider("haxeDependencies", this);
        commands.registerCommand("haxeDependencies.selectNode", selectNode);
        commands.registerCommand("haxeDependencies.collapseAll", collapseAll);

        var hxmlFileWatcher = workspace.createFileSystemWatcher("**/*.hxml");
        context.subscriptions.push(hxmlFileWatcher.onDidCreate(onDidChangeHxml));
        context.subscriptions.push(hxmlFileWatcher.onDidChange(onDidChangeHxml));
        context.subscriptions.push(hxmlFileWatcher.onDidDelete(onDidChangeHxml));
        context.subscriptions.push(hxmlFileWatcher);
    }

    function onDidChangeHxml(uri:Uri) {
        for (hxml in relevantHxmls) {
            if (Path.normalize(uri.fsPath) == Path.normalize(hxml)) {
                refresh();
            }
        }
    }

    function refreshDependencies():Array<Node> {
        var newDependencies:Array<Node> = [];

        var haxelibs = DependencyHelper.resolveHaxelibs(configuration);
        var paths = haxelibs.paths;
        relevantHxmls = haxelibs.hxmls;

        var stdLibPath = DependencyHelper.getStandardLibraryPath();
        if (stdLibPath != null && FileSystem.exists(stdLibPath)) {
            paths.push(stdLibPath);
        }

        for (path in paths) {
            // don't add duplicates
            if (newDependencies.find(d -> d.path == path) != null) {
                continue;
            }

            // reuse existing nodes if possible to preserve their collapsibleState
            if (dependencies != null) {
                var oldDependency = dependencies.find(d -> d.path == path);
                if (oldDependency != null) {
                    newDependencies.push(oldDependency);
                    continue;
                }
            }

            var info = if (path == stdLibPath) {
                DependencyHelper.getStandardLibraryInfo(path);
            } else {
                DependencyHelper.getHaxelibInfo(path);
            }

            var node = createNode(info);
            if (node != null) {
                newDependencies.push(node);
            }
        }

        return newDependencies;
    }

    function createNode(info):Node {
        if (info == null) {
            return null;
        }
        var label = '${info.name} (${info.version})';
        return new Node(label, info.path);
    }

    public function onDidChangeDisplayConfiguration(configuration:Array<String>) {
        this.configuration = configuration;
        refresh();
    }

    function refresh() {
        refreshNeeded = true;
        _onDidChangeTreeData.fire();
    }

    public function getTreeItem(element:Node):TreeItem {
        return element;
    }

    public function getChildren(?node:Node):Thenable<Array<Node>> {
        return new Promise(function(resolve, _) {
            if (refreshNeeded) {
                dependencies = refreshDependencies();
                refreshNeeded = false;
            }

            if (node == null) {
                resolve(dependencies);
            } else {
                resolve(getNodeChildren(node));
            }
        });
    }

    function getNodeChildren(node:Node):Array<Node> {
        if (!node.isDirectory) {
            return [];
        }

        var children = [];
        for (file in FileSystem.readDirectory(node.path)) {
            if (!isExcluded(file)) {
                children.push(new Node(file, '${node.path}/$file'));
            }
        };
        return children;
    }

    function isExcluded(file:String):Bool {
        // the proper way of doing this would be to check against the patterns in "files.exclude",
        // but then we'd need to include a lib for glob patterns...
        return file == ".git" || file == ".svn" || file == ".hg" || file == "CVS" || file == ".DS_Store";
    }

    function selectNode(node:Node) {
        if (node.isDirectory) {
            node.collapsibleState = if (node.collapsibleState == Collapsed) Expanded else Collapsed;
        } else {
            workspace.openTextDocument(node.path).then(document -> window.showTextDocument(document, {preview: true}));
        }
    }

    function collapseAll(node:Node) {
        for (node in dependencies) {
            if (node.collapsibleState != None) {
                node.collapsibleState = Collapsed;
            }
        }
        _onDidChangeTreeData.fire();
    }
}

private class Node extends TreeItem {
    public var path(default,null):String;
    public var isDirectory(default,null):Bool;

    public function new(label:String, path:String) {
        super(label);
        this.path = path;
        isDirectory = FileSystem.isDirectory(path);
        if (isDirectory) {
            collapsibleState = Collapsed;
        }

        command = {
            command: "haxeDependencies.selectNode",
            arguments: [this],
            title: "Open File"
        };
    }
}
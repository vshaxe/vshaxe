package vshaxe;

import sys.FileSystem;
import Vscode.*;
import vscode.*;
import js.Promise;
using Lambda;

class HaxelibExplorer {
    var context:ExtensionContext;
    var configuration:Array<String>;
    var haxelibs:Array<Node> = [];
    var refresh:Bool = true;

    var _onDidChangeTreeData = new EventEmitter<Node>();

    public var onDidChangeTreeData:Event<Node>;

    public function new(context:ExtensionContext, configuration:Array<String>) {
        this.context = context;
        this.configuration = configuration;

        onDidChangeTreeData = _onDidChangeTreeData.event;
        window.registerTreeDataProvider("haxelibDependencies", this);
        commands.registerCommand("haxelibDependencies.selectNode", selectNode);
    }

    function refreshHaxelibs():Array<Node> {
        var newHaxelibs:Array<Node> = [];

        for (path in HaxelibHelper.resolveHaxelibs(configuration)) {
            // don't add duplicates
            if (newHaxelibs.find(haxelib -> haxelib.path == path) != null) {
                continue;
            }

            // reuse existing nodes if possible to preserve their collapsibleState
            if (haxelibs != null) {
                var oldHaxelib = haxelibs.find(haxelib -> haxelib.path == path);
                if (oldHaxelib != null) {
                    newHaxelibs.push(oldHaxelib);
                    continue;
                }
            }

            var node = createHaxelibNode(path);
            if (node != null) {
                newHaxelibs.push(node);
            }
        }

        return newHaxelibs;
    }

    function createHaxelibNode(path:String):Node {
        var info = HaxelibHelper.getHaxelibInfo(path);
        if (info == null) {
            return null;
        }
        var label = '${info.name} (${info.version})';
        return new Node(label, info.path);
    }

    public function onDisplayConfigurationChanged(configuration:Array<String>) {
        this.configuration = configuration;
        refresh = true;
        _onDidChangeTreeData.fire();
    }

    public function getTreeItem(element:Node):TreeItem {
        return element;
    }

    public function getChildren(?node:Node):Thenable<Array<Node>> {
        return new Promise(function(resolve, _) {
            if (refresh) {
                haxelibs = refreshHaxelibs();
                refresh = false;
            }

            if (node == null) {
                resolve(haxelibs);
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
            command: "haxelibDependencies.selectNode",
            arguments: [this],
            title: "Open File"
        };
    }
}
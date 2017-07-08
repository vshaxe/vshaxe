package vshaxe.dependencyExplorer;

import sys.FileSystem;
import vscode.*;

class Node extends TreeItem {
    public var path(default,null):String;
    public var isDirectory(default,null):Bool;
    public var children(get,null):Array<Node>;

    public function new(label:String, path:String) {
        super(label);
        this.path = path;
        isDirectory = FileSystem.isDirectory(path);
        if (isDirectory) {
            collapsibleState = Collapsed;
        }

        command = {
            command: "haxe.dependencies.selectNode",
            arguments: [this],
            title: "Open File"
        };
    }

    public function collapse() {
        if (collapsibleState != None) {
            collapsibleState = Collapsed;
        }
    }

    public function toggleState() {
        collapsibleState = if (collapsibleState == Collapsed) Expanded else Collapsed;
    }

    function get_children():Array<Node> {
        if (children == null) {
            children = createChildren();
        }
        return children;
    }

    function createChildren() {
        if (!isDirectory) {
            return [];
        }

        var children = [];
        for (file in FileSystem.readDirectory(path)) {
            if (!isExcluded(file)) {
                children.push(new Node(file, '${path}/$file'));
            }
        }
        sortChildren(children);
        return children;
    }

    function sortChildren(children:Array<Node>) {
        haxe.ds.ArraySort.sort(children, (c1, c2) -> {
            function compare(a:String, b:String) {
                a = a.toLowerCase();
                b = b.toLowerCase();
                if (a < b) return -1;
                if (a > b) return 1;
                return 0;
            }

            if (c1.isDirectory && c2.isDirectory) {
                return compare(c1.label, c2.label);
            } else if (c1.isDirectory) {
                return -1;
            } else if (c2.isDirectory) {
                return 1;
            } else {
                return compare(c1.label, c2.label);
            }
        });
    }

    function isExcluded(file:String):Bool {
        // the proper way of doing this would be to check against the patterns in "files.exclude",
        // but then we'd need to include a lib for glob patterns...
        return file == ".git" || file == ".svn" || file == ".hg" || file == "CVS" || file == ".DS_Store";
    }
}
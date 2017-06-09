package vshaxe;

import sys.FileSystem;
import sys.io.File;
import Vscode.*;
import vscode.*;

class HaxelibExplorer {
    var context:ExtensionContext;
    var libraries:Array<String>;
    var _onDidChangeTreeData = new EventEmitter<TreeItem>();

    public var onDidChangeTreeData:Event<TreeItem>;

    public function new(context:ExtensionContext, configuration:Array<String>) {
        this.context = context;
        updateLibraries(configuration);

        onDidChangeTreeData = _onDidChangeTreeData.event;
        window.registerTreeDataProvider("haxelibDependencies", this);
    }

    function updateLibraries(configuration:Array<String>) {
        libraries = [];

        var hxmlFile = workspace.rootPath + "/" + configuration[0]; // TODO: this isn't a safe assumption
        if (hxmlFile != null && FileSystem.exists(hxmlFile)) {
            var hxml = File.getContent(hxmlFile);
            // TODO: parse the hxml properly
            ~/-lib\s+([\w:]+)/g.map(hxml, function(ereg) {
                libraries.push(ereg.matched(1));
                return "";
            });
        }
    }

    public function onDisplayConfigurationChanged(configuration:Array<String>) {
        updateLibraries(configuration);
    }

    public function getTreeItem(element:TreeItem):TreeItem {
        return element;
    }

    public function getChildren(?element:TreeItem):Array<TreeItem> {
        return [for (library in libraries) new TreeItem(library)];
    }
}
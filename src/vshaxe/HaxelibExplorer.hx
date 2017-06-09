package vshaxe;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import Vscode.*;
import vscode.*;
import js.Promise;
import js.node.ChildProcess;
import js.node.Buffer;
using StringTools;
using Lambda;

class HaxelibExplorer {
    var context:ExtensionContext;
    var configuration:Array<String>;
    var haxelibs:Array<Haxelib>;
    var haxelibRepo(get,never):String;

    function get_haxelibRepo():String {
        if (_haxelibRepo == null) {
            _haxelibRepo = Path.normalize((ChildProcess.execSync('haxelib config') : Buffer).toString().trim());
        }
        return _haxelibRepo;
    }

    var _onDidChangeTreeData = new EventEmitter<TreeItem>();
    var _haxelibRepo:String;

    public var onDidChangeTreeData:Event<TreeItem>;

    public function new(context:ExtensionContext, configuration:Array<String>) {
        this.context = context;
        this.configuration = configuration;

        onDidChangeTreeData = _onDidChangeTreeData.event;
        window.registerTreeDataProvider("haxelibDependencies", this);
    }

    function updateHaxelibs(configuration:Array<String>) {
        haxelibs = [];

        // TODO: register a file watcher for hxml files / listen to setting.json changes
        var hxmlFile = workspace.rootPath + "/" + configuration[0]; // TODO: this isn't a safe assumption
        if (hxmlFile != null && FileSystem.exists(hxmlFile)) {
            var hxml = File.getContent(hxmlFile);
            // TODO: parse the hxml properly
            ~/-lib\s+([\w:.]+)/g.map(hxml, function(ereg) {
                var name = ereg.matched(1);
                var path = getHaxelibPath(name);
                if (path != null) {
                    addHaxelib(path);
                }
                return "";
            });

            ~/-cp\s+(.*)/g.map(hxml, function(ereg) {
                addHaxelib(ereg.matched(1));
                return "";
            });
        }
    }

    function addHaxelib(path:String) {
        // don't add duplicates
        if (haxelibs.find(haxelib -> haxelib.path == path) != null) {
            return;
        }
        var info = getHaxelibInfo(path);
        if (info == null) {
            return;
        }
        var label = '${info.name} (${info.version})';
        haxelibs.push(new Haxelib(label, path));
    }

    function getHaxelibPath(lib:String):String {
        try {
            var result:Buffer = ChildProcess.execSync('haxelib path $lib');
            var path = null;
            for (line in result.toString().split("\n")) {
                var potentialPath = Path.normalize(line.trim());
                if (FileSystem.exists(potentialPath)) {
                    if (path == null) { // first path == path of the lib itself
                        path = potentialPath;
                    } else { // path of a depdendency
                        addHaxelib(potentialPath);
                    }
                }
            }
            return path;
        } catch(e:Any) {
            return null;
        }
    }

    function getHaxelibInfo(path:String):{name:String, version:String} {
        if (path.indexOf(haxelibRepo) == -1) {
            // TODO: deal with paths outside of haxelib
            return null;
        }

        path = path.replace(haxelibRepo, "");
        var segments = path.split("/");
        var name = segments[1];
        var version = segments[2].replace(",", ".");
        return {name:name, version:version};
    }

    public function onDisplayConfigurationChanged(configuration:Array<String>) {
        this.configuration = configuration;
        haxelibs = null;
        _onDidChangeTreeData.fire();
    }

    public function getTreeItem(element:TreeItem):TreeItem {
        return element;
    }

    public function getChildren(?element:TreeItem):Thenable<Array<TreeItem>> {
        return new Promise(function(resolve, _) {
            if (haxelibs == null) {
                updateHaxelibs(configuration);
            }
            var treeItems:Array<TreeItem> = [for (lib in haxelibs) lib];
            resolve(treeItems);
        });
    }
}

private class Haxelib extends TreeItem {
    public var path(default,null):String;

    public function new(label:String, path:String) {
        super(label);
        this.path = path;
    }
}
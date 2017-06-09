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

class HaxelibExplorer {
    var context:ExtensionContext;
    var configuration:Array<String>;
    var libraries:Array<Haxelib>;
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

    function updateLibraries(configuration:Array<String>) {
        libraries = [];

        var hxmlFile = workspace.rootPath + "/" + configuration[0]; // TODO: this isn't a safe assumption
        if (hxmlFile != null && FileSystem.exists(hxmlFile)) {
            var hxml = File.getContent(hxmlFile);
            // TODO: parse the hxml properly
            ~/-lib\s+([\w:.]+)/g.map(hxml, function(ereg) {
                var name = ereg.matched(1);
                trace(name);
                var path = getHaxelibPath(name);
                if (path != null) {
                    libraries.push({
                        name: name,
                        label: getHaxelibLabel(name, path),
                        path: path
                    });
                }
                return "";
            });
        }
    }

    function getHaxelibPath(lib:String):String {
        try {
            var result:Buffer = ChildProcess.execSync('haxelib path $lib');
            var path = null;
            for (line in result.toString().split("\n")) {
                var potentialPath = Path.normalize(line.trim());
                if (FileSystem.exists(potentialPath)) {
                    path = potentialPath;
                    break;
                }
            }
            return path;
        } catch(e:Any) {
            return null;
        }
    }

    function getHaxelibVersion(path:String):String {
        if (path.indexOf(haxelibRepo) == -1) {
            // can't assume that paths outside of haxelib follow the /<lib>/<version> naming scheme -
            // just show the path itself for e.g. "haxelib local"
            return path;
        }

        path = path.replace(haxelibRepo, "");
        var segments = path.split("/");
        var version = segments[2];
        if (version == null) {
            return "?";
        }
        return version.replace(",", ".");
    }

    function getHaxelibLabel(name:String, path:String) {
        name = name.split(":")[0];
        return '$name (${getHaxelibVersion(path)})';
    }

    public function onDisplayConfigurationChanged(configuration:Array<String>) {
        this.configuration = configuration;
        libraries = null;
    }

    public function getTreeItem(element:TreeItem):TreeItem {
        return element;
    }

    public function getChildren(?element:TreeItem):Thenable<Array<TreeItem>> {
        return new Promise(function(resolve, _) {
            if (libraries == null) {
                updateLibraries(configuration);
            }
            resolve([for (library in libraries) new TreeItem(library.label)]);
        });
    }
}

private typedef Haxelib = {
    name:String,
    label:String,
    path:String
}
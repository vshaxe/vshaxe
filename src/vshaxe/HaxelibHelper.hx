package vshaxe;

import haxe.io.Path;
import js.node.Buffer;
import js.node.ChildProcess;
import sys.io.File;
import sys.FileSystem;
import Vscode.*;
using StringTools;

class HaxelibHelper {
    static var _haxelibRepo:String;

    public static var haxelibRepo(get,never):String;

    static function get_haxelibRepo():String {
        if (_haxelibRepo == null) {
            _haxelibRepo = Path.normalize((ChildProcess.execSync('haxelib config') : Buffer).toString().trim());
        }
        return _haxelibRepo;
    }

    public static function resolveHaxelibs(configuration:Array<String>):Array<String> {
        if (configuration == null) {
            return [];
        }

        // TODO: register a file watcher for hxml files / listen to setting.json changes
        var hxmlFile = workspace.rootPath + "/" + configuration[0]; // TODO: this isn't a safe assumption
        if (hxmlFile == null || !FileSystem.exists(hxmlFile)) {
            return [];
        }

        var hxml = File.getContent(hxmlFile);
        var paths = [];
        // TODO: parse the hxml properly
        ~/-lib\s+([\w:.]+)/g.map(hxml, function(ereg) {
            var name = ereg.matched(1);
            paths = paths.concat(resolveHaxelib(name));
            return "";
        });

        ~/-cp\s+(.*)/g.map(hxml, function(ereg) {
            paths.push(ereg.matched(1));
            return "";
        });

        return paths;
    }

    public static function resolveHaxelib(lib:String):Array<String> {
        try {
            var result:Buffer = ChildProcess.execSync('haxelib path $lib');
            var paths = [];
            for (line in result.toString().split("\n")) {
                var potentialPath = Path.normalize(line.trim());
                if (FileSystem.exists(potentialPath)) {
                    paths.push(potentialPath);
                }
            }
            return paths;
        } catch(e:Any) {
            return [];
        }
    }

    public static function getHaxelibInfo(path:String) {
        if (path.indexOf(haxelibRepo) == -1) {
            // TODO: deal with paths outside of haxelib
            return null;
        }

        path = path.replace(haxelibRepo, "");
        var segments = path.split("/");
        var name = segments[1];
        var version = segments[2];
        var path = '$haxelibRepo/$name/$version';
        return {name:name, version:version.replace(",", "."), path:path};
    }
}
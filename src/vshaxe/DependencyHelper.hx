package vshaxe;

import Vscode.*;
import haxe.io.Path;
import js.node.Buffer;
import js.node.ChildProcess;
import sys.FileSystem;
import sys.io.File;
using StringTools;

class DependencyHelper {
    static var _haxelibRepo:String;

    public static var haxelibRepo(get, never):String;

    static function get_haxelibRepo():String {
        if (_haxelibRepo == null) {
            _haxelibRepo = Path.normalize((ChildProcess.execSync('haxelib config') : Buffer).toString().trim());
        }
        return _haxelibRepo;
    }

    public static function resolveHaxelibs(configuration:Array<String>) {
        var result = {
            paths: [],
            hxmls: []
        }

        if (configuration == null) {
            return result;
        }

        var hxmlFile = workspace.rootPath + "/" + configuration[0]; // TODO: this isn't a safe assumption
        result.hxmls.push(hxmlFile);
        if (hxmlFile == null || !FileSystem.exists(hxmlFile)) {
            return result;
        }

        var hxml = HxmlParser.parseFile(File.getContent(hxmlFile));
        for (line in hxml) {
            switch (line) {
                case Param("-lib", lib):
                    result.paths = result.paths.concat(resolveHaxelib(lib));
                case Param("-cp", cp):
                    result.paths.push(cp);
                case _:
            }
        }

        return result;
    }

    public static function resolveHaxelib(lib:String):Array<String> {
        var paths = [];
        for (line in getProcessOutput('haxelib path $lib')) {
            var potentialPath = Path.normalize(line);
            if (FileSystem.exists(potentialPath)) {
                paths.push(potentialPath);
            }
        }
        return paths;
    }

    static function getProcessOutput(command:String):Array<String> {
        try {
            var result:Buffer = ChildProcess.execSync(command);
            var lines = result.toString().split("\n");
            return [for (line in lines) line.trim()];
        } catch(e:Any) {
            return [];
        }
    }

    public static function getHaxelibInfo(path:String) {
        if (path.indexOf(haxelibRepo) == -1) {
            // dependencies outside of the haxelib repo (installed via "haxelib dev" or just classpaths)
            // - only bother to show these if they're outside of the current workspace
            var workspaceRootPath = Path.normalize(workspace.rootPath);
            var absPath = path;
            if (!Path.isAbsolute(path)) {
                absPath = Path.normalize(workspaceRootPath + "/" + path);
            }
            if (absPath.indexOf(workspaceRootPath) == -1) {
                return {name: path, version: null, path: absPath};
            }
            return null;
        }

        path = path.replace(haxelibRepo, "");
        var segments = path.split("/");
        var name = segments[1];
        var version = segments[2];
        var path = '$haxelibRepo/$name/$version';
        return {name: name, version: version.replace(",", "."), path: path};
    }

    public static function getStandardLibraryPath(displayServerHaxePath:String):String {
        // more or less a port of main.ml's get_std_class_paths()
        var path = Sys.getEnv("HAXE_STD_PATH");
        if (path != null) {
            return path;
        }

        if (Sys.systemName() == "Windows") {
            var haxePath = getHaxePath(displayServerHaxePath);
            if (haxePath == null) {
                return null;
            }
            return Path.join([Path.directory(haxePath), "std"]);
        } else {
            for (path in [
                    "/usr/local/lib/haxe/extraLibs/",
                    "/usr/lib/haxe/extraLibs/",
                    "/usr/local/lib/haxe/std/",
                    "/usr/share/haxe/std/",
                    "/usr/lib/haxe/std/"]
                ) {
                if (FileSystem.exists(path)) {
                    return path;
                }
            }
        }
        return null;
    }

    static function getHaxePath(displayServerHaxePath:String):String {
        var haxePath = displayServerHaxePath;
        if (haxePath == null || !FileSystem.exists(haxePath)) {
            haxePath = getProcessOutput("where haxe")[0];
        }
        return haxePath;
    }

    public static function getStandardLibraryInfo(path:String, displayServerHaxePath:String) {
        var version = "?";
        var result = ChildProcess.spawnSync(displayServerHaxePath, ["-version"]);
        var haxeVersionOutput = (result.stderr : Buffer).toString();
        if (haxeVersionOutput != null) {
            version = haxeVersionOutput.split(" ")[0].trim();
        }
        return {name: "std", path: path, version: version};
    }
}
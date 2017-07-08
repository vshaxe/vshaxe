package vshaxe.dependencyExplorer;

import haxe.Json;
import Vscode.*;
import haxe.io.Path;
import js.node.Buffer;
import js.node.ChildProcess;
import sys.FileSystem;
import sys.io.File;
import vshaxe.helper.PathHelper;
import vshaxe.dependencyExplorer.HxmlParser.DependencyList;
using StringTools;

typedef DependencyInfo = {
    name:String,
    version:String,
    path:String
}

class DependencyResolver {
    static var _haxelibRepo:String;

    static var haxelibRepo(get, never):String;

    public static function resolveDependencies(dependencies:DependencyList, haxePath:String):Array<DependencyInfo> {
        var paths = [];
        for (lib in dependencies.libs) {
            paths = paths.concat(resolveHaxelib(lib));
        }
        paths = paths.concat(dependencies.classPaths);

        var infos = paths.map(getDependencyInfo).filter(info -> info != null);

        // std lib needs to be handled separately
        var stdLibPath = getStandardLibraryPath(haxePath);
        if (stdLibPath != null && FileSystem.exists(stdLibPath)) {
            infos.push(getStandardLibraryInfo(stdLibPath, haxePath));
        }

        return infos;
    }

    static function get_haxelibRepo():String {
        if (_haxelibRepo == null) {
            _haxelibRepo = Path.normalize((ChildProcess.execSync('haxelib config') : Buffer).toString().trim());
        }
        return _haxelibRepo;
    }

    static function resolveHaxelib(lib:String):Array<String> {
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

    static function getDependencyInfo(path:String) {
        var absPath = PathHelper.absolutize(path, workspace.rootPath);
        if (absPath.indexOf(haxelibRepo) == -1) {
            // dependencies outside of the haxelib repo (installed via "haxelib dev" or just classpaths)
            // - only bother to show these if they're outside of the current workspace
            if (absPath.indexOf(Path.normalize(workspace.rootPath)) == -1) {
                // could be a "haxelib dev" haxelib
                var haxelibInfo = searchHaxelibJson(absPath);
                if (haxelibInfo == null) {
                    return {name: path, version: null, path: absPath};
                }
                return haxelibInfo;
            }
            return null;
        }

        // regular haxelibs inside the haxelib repo location
        path = absPath.replace(haxelibRepo + "/", "");
        var segments = path.split("/");
        var name = segments[0];
        var version = segments[1];

        path = '$haxelibRepo/$name';
        if (version != null) {
            path += '/$version';
            version = version.replace(",", ".");
        } else {
            version = path;
        }

        if (!FileSystem.exists(path)) {
            return null;
        }
        return {name: name, version: version, path: path};
    }

    static function searchHaxelibJson(path:String, levels:Int = 3) {
        if (levels <= 0) {
            return null;
        }

        var haxelibFile = Path.join([path, "haxelib.json"]);
        if (FileSystem.exists(haxelibFile)) {
            var content:{?name:String} = Json.parse(File.getContent(haxelibFile));
            if (content.name == null) {
                return null;
            }
            path = Path.normalize(path);
            return {name: content.name, version: path, path: path};
        }
        return searchHaxelibJson(Path.join([path, ".."]), levels - 1);
    }

    static function getStandardLibraryPath(displayServerHaxePath:String):String {
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
                    "/usr/local/share/haxe/std/",
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

    static function getStandardLibraryInfo(path:String, displayServerHaxePath:String) {
        var version = "?";
        var result = null;

        var oldCwd = Sys.getCwd();
        if (workspace.rootPath != null) {
            Sys.setCwd(workspace.rootPath);
        }
        result = ChildProcess.spawnSync(displayServerHaxePath, ["-version"]);
        Sys.setCwd(oldCwd);

        if (result != null && result.stderr != null) {
            var haxeVersionOutput = (result.stderr : Buffer).toString();
            if (haxeVersionOutput != null) {
                version = haxeVersionOutput.split(" ")[0].trim();
            }
        }

        return {name: "std", path: path, version: version};
    }
}
package vshaxe.dependencyExplorer;

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

        function processHxml(hxmlFile, cwd) {
            hxmlFile = absolutizePath(hxmlFile, cwd);
            result.hxmls.push(hxmlFile);
            if (hxmlFile == null || !FileSystem.exists(hxmlFile)) {
                return;
            }

            var hxml = HxmlParser.parseFile(File.getContent(hxmlFile));
            for (line in hxml) {
                switch (line) {
                    case Param("-lib", lib):
                        result.paths = result.paths.concat(resolveHaxelib(lib));
                    case Param("-cp", cp):
                        result.paths.push(cp);
                    case Param("--cwd", newCwd):
                        if (Path.isAbsolute(newCwd)) {
                            cwd = newCwd;
                        } else {
                            cwd = Path.join([cwd, newCwd]);
                        }
                    case Simple(name) if (name.endsWith(".hxml")):
                        processHxml(name, cwd);
                    case _:
                }
            }
        }

        for (hxml in configuration.filter(s -> s.endsWith(".hxml"))) {
            processHxml(hxml, workspace.rootPath);
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

    static function absolutizePath(path:String, cwd:String) {
        return Path.normalize(if (Path.isAbsolute(path)) {
            path;
        } else {
            Path.join([cwd, path]);
        });
    }

    public static function getHaxelibInfo(path:String) {
        var absPath = absolutizePath(path, workspace.rootPath);
        if (absPath.indexOf(haxelibRepo) == -1) {
            // dependencies outside of the haxelib repo (installed via "haxelib dev" or just classpaths)
            // - only bother to show these if they're outside of the current workspace
            if (absPath.indexOf(Path.normalize(workspace.rootPath)) == -1) {
                return {name: path, version: null, path: absPath};
            }
            return null;
        }

        path = absPath.replace(haxelibRepo + "/", "");
        var segments = path.split("/");
        var name = segments[0];
        var version = segments[1];
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
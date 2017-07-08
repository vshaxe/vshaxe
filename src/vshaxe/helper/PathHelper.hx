package vshaxe.helper;

import haxe.io.Path;

class PathHelper {
    public static function absolutize(path:String, cwd:String) {
        return Path.normalize(if (Path.isAbsolute(path)) {
            path;
        } else {
            Path.join([cwd, path]);
        });
    }

    public static function runInDirectory(directory:String, f:Void->Void) {
        var oldCwd = Sys.getCwd();
        Sys.setCwd(directory);
        f();
        Sys.setCwd(oldCwd);
    }
}
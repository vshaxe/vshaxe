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

    public static function relativize(path:String, cwd:String) {
        path = Path.normalize(path);
        cwd = Path.normalize(cwd) + "/";

        var segments = path.split(cwd);
        segments.shift();
        return segments.join(cwd);
    }
}
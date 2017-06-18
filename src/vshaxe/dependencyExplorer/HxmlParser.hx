package vshaxe.dependencyExplorer;

import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import vshaxe.helper.PathHelper;
using StringTools;

enum HxmlLine {
    Comment(comment:String);
    Simple(name:String);
    Param(name:String, value:String);
}

typedef DependencyList = {
    libs:Array<String>,
    classPaths:Array<String>,
    hxmls:Array<String>
}

class HxmlParser {
    static function unquote(s:String):String {
        var len = s.length;
        return if (len > 0 && s.fastCodeAt(0) == "\"".code && s.fastCodeAt(len - 1) == "\"".code)
            s.substring(1, len - 1);
        else
            s;
    }

    public static function parseFile(src:String):Array<HxmlLine> {
        var result = [];
        var srcLines = ~/[\n\r]+/g.split(src);
        for (line in srcLines) {
            line = unquote(line.trim());
            if (line.length == 0)
                continue;
            if (line.startsWith("#")) {
                result.push(Comment(line.substr(1).ltrim()));
            } else if (line.startsWith("-")) {
                var idx = line.indexOf(" ");
                if (idx == -1) {
                    result.push(Simple(line));
                } else {
                    var name = line.substr(0, idx);
                    var value = unquote(line.substr(idx).ltrim());
                    result.push(Param(name, value));
                }
            } else {
                result.push(Simple(line));
            }
        }
        return result;
    }

    public static function extractDependencies(configuration:Array<String>, cwd:String):DependencyList {
        var result = {
            libs: [],
            classPaths: [],
            hxmls: []
        }

        if (configuration == null) {
            return result;
        }

        function processHxml(hxmlFile, cwd) {
            hxmlFile = PathHelper.absolutize(hxmlFile, cwd);
            result.hxmls.push(hxmlFile);
            if (hxmlFile == null || !FileSystem.exists(hxmlFile)) {
                return;
            }

            var hxml = HxmlParser.parseFile(File.getContent(hxmlFile));
            for (line in hxml) {
                switch (line) {
                    case Param("-lib", lib):
                        result.libs.push(lib);
                    case Param("-cp", cp):
                        result.classPaths.push(cp);
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
            processHxml(hxml, cwd);
        }
        return result;
    }
}
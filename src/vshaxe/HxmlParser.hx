package vshaxe;

using StringTools;

enum HxmlLine {
    Comment(comment:String);
    Simple(name:String);
    Param(name:String, value:String);
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
}
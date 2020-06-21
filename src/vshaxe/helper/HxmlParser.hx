package vshaxe.helper;

enum HxmlLine {
	Comment(comment:String);
	Simple(name:String);
	Param(name:String, value:String);
}

class HxmlParser {
	static function unquote(s:String):String {
		final len = s.length;
		return if (len > 0 && s.fastCodeAt(0) == "\"".code && s.fastCodeAt(len - 1) == "\"".code) s.substring(1, len - 1); else s;
	}

	public static function parseFile(src:String):Array<HxmlLine> {
		final result = [];
		final srcLines = ~/[\n\r]+/g.split(src);
		for (line in srcLines) {
			line = unquote(line.trim());
			if (line.length == 0)
				continue;
			if (line.startsWith("#")) {
				result.push(Comment(line.substr(1).ltrim()));
			} else if (line.startsWith("-")) {
				final idx = line.indexOf(" ");
				if (idx == -1) {
					result.push(Simple(line));
				} else {
					final name = line.substr(0, idx);
					final value = unquote(line.substr(idx).ltrim());
					result.push(Param(name, value));
				}
			} else {
				result.push(Simple(line));
			}
		}
		return result;
	}

	public static function parseToArgs(src:String):Array<String> {
		final result = [];
		for (line in parseFile(src))
			switch line {
				case Comment(_):
				case Simple(arg):
					result.push(arg);
				case Param(name, value):
					result.push(name);
					result.push(value);
			}
		return result;
	}

	public static function parseArray(args:Array<String>):Array<HxmlLine> {
		final result = [];
		var flag:Null<String> = null;
		for (arg in args) {
			if (arg.startsWith("-")) {
				if (flag != null) {
					result.push(Simple(flag));
					flag = null;
				}
				flag = arg; // can't know what to do until we encounter the next arg
			} else if (flag != null) {
				result.push(Param(flag, arg));
				flag = null;
			} else {
				result.push(Simple(arg));
			}
		}

		if (flag != null) {
			result.push(Simple(flag));
		}

		return result;
	}
}

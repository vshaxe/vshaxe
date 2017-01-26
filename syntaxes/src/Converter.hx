import sys.io.File;

class Converter {
	static function main() {
		Sys.println("Converting syntax files to plist...");
		convert("haxe.YAML-tmLanguage", "haxe.tmLanguage");
		convert("hxml.YAML-tmLanguage", "hxml.tmLanguage");
	}

	static function convert(source:String, dest:String) {
		var content = File.getContent(source);
		var parsed = new yaml.Parser().parse(content,
			new yaml.Parser.ParserOptions().useObjects());

		switch (plist.Writer.write(parsed)) {
			case Success(data):
				File.saveContent(dest, data);
				Sys.println(source + " - done");
			case _: throw "Error";
		}
	}
}
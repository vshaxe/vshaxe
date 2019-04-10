import haxe.Json;
import sys.io.File;
import formatter.config.FormatterConfig;
import json2object.utils.JsonSchemaWriter;

class SchemaGenerator {
	static function main() {
		var schema = new JsonSchemaWriter<FormatterConfig>("\t").schema;
		File.saveContent("schemas/hxformat-schema.json", schema);
	}
}

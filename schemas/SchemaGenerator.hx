import sys.io.File;
import formatter.config.FormatterConfig;
import json2object.utils.JsonSchemaWriter;

using StringTools;

class SchemaGenerator {
	static function main() {
		var schema = new JsonSchemaWriter<FormatterConfig>("\t").schema;
		schema = schema.replace('"description"', '"markdownDescription"');
		File.saveContent("schemas/hxformat-schema.json", schema);
	}
}

import sys.io.File;
import formatter.config.FormatterConfig;
import json2object.utils.special.VSCodeSchemaWriter;

class SchemaGenerator {
	static function main() {
		File.saveContent("schemas/hxformat.schema.json", new VSCodeSchemaWriter<FormatterConfig>("\t").schema);
	}
}

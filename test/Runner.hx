import haxe.io.Path;
import sys.FileSystem;

function main() {
	final workspace = "test/workspace";
	FileSystem.createDirectory(workspace);

	VscodeTest.runTests({
		extensionDevelopmentPath: "..",
		extensionTestsPath: Path.join([Util.getCwd(), "test/suite/main.js"]),
		launchArgs: [workspace]
	});
}

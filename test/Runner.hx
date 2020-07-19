import haxe.io.Path;

function main() {
	VscodeTest.runTests({
		extensionDevelopmentPath: "..",
		extensionTestsPath: Path.join([Util.getCwd(), "test/suite/main.js"]),
		launchArgs: [".", '--disable-extensions']
	});
}

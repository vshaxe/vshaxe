import sys.FileSystem;
import sys.io.File;

using StringTools;

function main() {
	// this is not hacky at all... but seems there's no way to make `vsce package` skip prepublish
	final restorePackageJson = tempModification("package.json", function(content) {
		return content.split("\n").map(line -> if (line.contains("vscode:prepublish")) "" else line).join("\n");
	});
	final restoreVscodeIgnore = tempModification(".vscodeignore", function(content) {
		return content + [
			"vscode-languageclient",
			"semver",
			"vscode-languageserver-protocol",
			"vscode-jsonrpc",
			"vscode-languageserver-types",
		].map(lib -> '!node_modules/$lib/**/*').join("\n");
	});
	function restore() {
		restorePackageJson();
		restoreVscodeIgnore();
	}
	try {
		final out = Sys.command("vsce package");
		if (out != 0) {
			throw "Error: Failed to generate vsix file";
		}

		// if it didn't fail, there should be a .vsix now
		final vsixFiles = FileSystem.readDirectory(".").filter(file -> file.endsWith(".vsix"));
		if (vsixFiles.length > 1) {
			Sys.println('Multiple vsix files found: $vsixFiles');
		} else {
			Sys.command('code --install-extension ${vsixFiles[0]}');
			FileSystem.deleteFile(vsixFiles[0]);
		}
	} catch (e) {
		trace(e);
		restore();
	}
	restore();
}

function tempModification(file:String, modify:(content:String) -> String):() -> Void {
	final originalContent = File.getContent(file);
	final newContent = modify(originalContent);
	File.saveContent(file, newContent);
	return function() {
		File.saveContent(file, originalContent);
	};
}

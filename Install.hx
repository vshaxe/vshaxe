import sys.io.File;
import sys.FileSystem;

using StringTools;

class Install {
	static function main() {
		// this is not hacky at all... but seems there's no way to make `vsce package` skip prepublish
		var restorePackageJson = tempModification("package.json", function(content) {
			return content.split("\n").map(line -> if (line.contains("vscode:prepublish")) "" else line).join("\n");
		});
		var restoreVscodeIgnore = tempModification(".vscodeignore", function(content) {
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
			Sys.command("vsce package");

			// if it didn't fail, there should be a .vsix now
			var vsixFiles = FileSystem.readDirectory(".").filter(file -> file.endsWith(".vsix"));
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

	static function tempModification(file:String, modify:(content:String) -> String):() -> Void {
		var originalContent = File.getContent(file);
		var newContent = modify(originalContent);
		File.saveContent(file, newContent);
		return function() {
			File.saveContent(file, originalContent);
		};
	}
}

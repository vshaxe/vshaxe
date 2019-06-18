import sys.io.File;
import sys.FileSystem;

using StringTools;

class Install {
	static function main() {
		// this is not hacky at all... but seems there's no way to make `vsce package` skip prepublish
		var restorePackageJson = tempModification("package.json", "vscode:prepublish");
		function restore() {
			restorePackageJson();
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
		} catch (e:Any) {
			trace(e);
			restore();
		}
		restore();
	}

	static function tempModification(file:String, lineToRemove:String):() -> Void {
		var originalContent = File.getContent(file);
		var newContent = originalContent.split("\n").map(line -> if (line.contains(lineToRemove)) "" else line).join("\n");
		File.saveContent(file, newContent);
		return function() {
			File.saveContent(file, originalContent);
		};
	}
}

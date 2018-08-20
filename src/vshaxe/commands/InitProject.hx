package vshaxe.commands;

import sys.FileSystem;
import sys.io.File;

class InitProject {
	var context:ExtensionContext;

	public function new(context:ExtensionContext) {
		this.context = context;
		context.registerHaxeCommand(InitProject, initProject);
	}

	function initProject() {
		switch workspace.workspaceFolders {
			case null | []:
				window.showOpenDialog({
					canSelectFolders: true,
					canSelectFiles: false
				}).then(folders -> {
					if (folders != null && folders.length > 0) {
						setupFolder(folders[0].fsPath);
						commands.executeCommand("vscode.openFolder", folders[0]);
					}
				});
			case [folder]:
				setupFolder(folder.uri.fsPath);
			case folders:
				var options = {
					placeHolder: "Select a folder to set up a Haxe project into...",
				}
				window.showWorkspaceFolderPick(options).then(function(folder) {
					if (folder == null)
						return;
					setupFolder(folder.uri.fsPath);
				});
		}
	}

	function setupFolder(fsPath:String) {
		var nonEmpty = FileSystem.readDirectory(fsPath).exists(f -> !f.startsWith("."));
		if (nonEmpty) {
			window.showErrorMessage("To set up sample Haxe project, the folder must be empty");
			return;
		}

		copyRec(context.asAbsolutePath("./scaffold/project"), fsPath);
		window.setStatusBarMessage("Haxe project scaffolded", 2000);
	}

	function copyRec(from:String, to:String):Void {
		function loop(src, dst) {
			var fromPath = from + src;
			var toPath = to + dst;
			if (FileSystem.isDirectory(fromPath)) {
				FileSystem.createDirectory(toPath);
				for (file in FileSystem.readDirectory(fromPath))
					loop(src + "/" + file, dst + "/" + file);
			} else {
				File.copy(fromPath, toPath);
			}
		}
		loop("", "");
	}
}

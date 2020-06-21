package vshaxe;

import haxe.io.Path;
import sys.FileSystem;

using Lambda;

class ExtensionRecommender {
	final context:ExtensionContext;
	final folder:WorkspaceFolder;

	public function new(context, folder) {
		this.context = context;
		this.folder = folder;
	}

	public function run() {
		check([".haxerc", "haxe_libraries"], "lix", "lix extension", "lix.lix");
		check(["project.xml", "Project.xml", "project.hxp", "project.lime"], "Lime", "Lime extension", "openfl.lime-vscode-extension");
		check(["khafile.js"], "Kha", "Kha Extension Pack", "kodetech.kha-extension-pack");
	}

	inline static final InstallExtension = "Install Extension";
	inline static final DontShowAgainOption = "Don't Show Again";

	function check(projectFiles:Array<String>, projectName:String, extensionName:String, extensionId:String) {
		final memento = new HaxeMementoKey<Bool>("dontShowExtensionRecommendationAgain." + projectName);
		final globalState = context.globalState;
		if (globalState.get(memento, false)) {
			return;
		}
		final alreadyInstalled = extensions.all.exists(extension -> extension.id == extensionId);
		if (alreadyInstalled) {
			return;
		}
		final isExtensionRelevant = projectFiles.exists(file -> FileSystem.exists(Path.join([folder.uri.fsPath, file])));
		if (!isExtensionRelevant) {
			return;
		}
		final message = '$projectName project detected. For the best experience, the $extensionName should be installed.';
		window.showInformationMessage(message, InstallExtension, DontShowAgainOption).then(function(choice) {
			switch choice {
				case null:
				case InstallExtension:
					commands.executeCommand("workbench.extensions.installExtension", extensionId);
				case DontShowAgainOption:
					globalState.update(memento, true);
			}
		});
	}
}

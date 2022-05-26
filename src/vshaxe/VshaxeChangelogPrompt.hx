package vshaxe;

import haxe.Json;
import haxe.io.Path;
import sys.io.File;

class VshaxeChangelogPrompt {
	public function new(context:ExtensionContext) {
		final memento = new HaxeMementoKey<String>("vshaxeVersion");
		final globalState = context.globalState;
		final version = readVersion() ?? return;
		final lastSeenVersion = globalState.get(memento, "");
		if (lastSeenVersion == version)
			return;

		final button = "Open Release Notes";
		final prompt = window.showInformationMessage('VSHaxe has been updated to ${version}', button);
		prompt.then(item -> {
			if (item == button)
				env.openExternal(Uri.parse("https://github.com/vshaxe/vshaxe/blob/master/CHANGELOG.md"));
			globalState.update(memento, version);
		});
	}

	function readVersion():Null<String> {
		final ext = extensions.getExtension("nadako.vshaxe");
		if (ext == null)
			return null;
		final extensionPath = ext.extensionPath;
		if (extensionPath == null)
			return null;
		final path = Path.join([extensionPath, "package.json"]);
		return Json.parse(File.getContent(path)).version;
	}
}

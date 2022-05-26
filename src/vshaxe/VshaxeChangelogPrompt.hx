package vshaxe;

import haxe.Json;
import haxe.io.Path;
import sys.io.File;

class VshaxeChangelogPrompt {
	public function new(context:ExtensionContext) {
		final memento = new HaxeMementoKey<String>("vshaxeVersion");
		final globalState = context.globalState;
		final packageJson:{version:String} = context.extension.packageJSON;
		final version = packageJson.version;
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
}

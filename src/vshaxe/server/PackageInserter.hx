package vshaxe.server;

import haxeLanguageServer.LanguageServerMethods;

class PackageInserter {
	@:nullSafety(Off) final createEvent:Disposable;
	@:nullSafety(Off) final openEvent:Disposable;
	final server:LanguageServer;
	var lastCreatedFile:Null<Uri>;

	public function new(watcher:FileSystemWatcher, server:LanguageServer) {
		this.server = server;

		createEvent = watcher.onDidCreate(function(uri) {
			final editor = window.activeTextEditor;
			if (editor == null || editor.document.uri.fsPath != uri.fsPath) // not yet opened
				lastCreatedFile = uri;
			else
				insertPackageStatement(editor);
		});

		openEvent = window.onDidChangeActiveTextEditor(function(editor) {
			if (editor != null && lastCreatedFile != null && editor.document.uri.fsPath == lastCreatedFile.fsPath)
				insertPackageStatement(editor);
		});
	}

	function insertPackageStatement(editor:TextEditor) {
		lastCreatedFile = null;

		if (editor.document.getText(new Range(0, 0, 0, 1)).length > 0) // skip non-empty created files (can be created by e.g. copy-pasting)
			return;

		server.sendRequest(LanguageServerMethods.DeterminePackage, {fsPath: editor.document.uri.fsPath}).then(function(result:{pack:String}) {
			if (result.pack == "")
				return;
			editor.edit(function(edit) edit.insert(new Position(0, 0), 'package ${result.pack};\n\n'));
		});
	}

	public function dispose() {
		createEvent.dispose();
		openEvent.dispose();
	}
}

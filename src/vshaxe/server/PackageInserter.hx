package vshaxe.server;

class PackageInserter {
	final createEvent:Disposable;
	final openEvent:Disposable;
	final client:LanguageClient;
	var lastCreatedFile:Null<Uri>;

	public function new(watcher:FileSystemWatcher, client:LanguageClient) {
		this.client = client;

		createEvent = watcher.onDidCreate(function(uri) {
			var editor = window.activeTextEditor;
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

		client.sendRequest("haxe/determinePackage", {fsPath: editor.document.uri.fsPath}).then(function(result:{pack:String}) {
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

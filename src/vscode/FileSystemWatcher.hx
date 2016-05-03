package vscode;

extern class FileSystemWatcher extends Disposable {
	var ignoreCreateEvents:Bool;
	var ignoreChangeEvents:Bool;
	var ignoreDeleteEvents:Bool;
	var onDidCreate:Event<Uri>;
	var onDidChange:Event<Uri>;
	var onDidDelete:Event<Uri>;
}

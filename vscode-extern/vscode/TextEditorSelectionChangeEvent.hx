package vscode;

typedef TextEditorSelectionChangeEvent = {
	var textEditor:TextEditor;
	var selections:Array<Selection>;
}

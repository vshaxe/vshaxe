package vscode;

typedef QuickPickOptions = {
	@:optional var matchOnDescription:Bool;
	@:optional var matchOnDetail:Bool;
	@:optional var placeHolder:String;
	@:optional var onDidSelectItem:Dynamic->Dynamic;
}

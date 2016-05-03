package vscode;

import haxe.extern.EitherType;

typedef TextEditorOptions = {
	@:optional var tabSize:EitherType<Int,String>;
	@:optional var insertSpaces:EitherType<Bool,String>;
	@:optional var cursorStyle:TextEditorCursorStyle;
}

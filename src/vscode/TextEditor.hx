package vscode;

import js.Promise.Thenable;

typedef TextEditor = {
	var document:TextDocument;
	var selection:Selection;
	var selections:Array<Selection>;
	var options:TextEditorOptions;
	var viewColumn:ViewColumn;
	function edit(callback:TextEditorEdit->Void):Thenable<Bool>;
	function setDecorations(decorationType:TextEditorDecorationType, rangesOrOptions:haxe.extern.EitherType<Array<Range>, Array<DecorationOptions>>):Void;
	function revealRange(range:Range, ?revealType:TextEditorRevealType):Void;
	function show(?column:ViewColumn):Void;
	function hide():Void;
}

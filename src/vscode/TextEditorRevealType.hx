package vscode;

@:enum abstract TextEditorRevealType(Int) {
	var Default = 0;
	var InCenter = 1;
	var InCenterIfOutsideViewport = 2;
}

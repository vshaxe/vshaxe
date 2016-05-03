package vscode;

@:jsRequire("vscode", "DocumentHighlight")
extern class DocumentHighlight {
	var range:Range;
	var kind:DocumentHighlightKind;
	function new(range:Range, ?kind:DocumentHighlightKind);
}

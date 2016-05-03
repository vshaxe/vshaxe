package vscode;

typedef DecorationOptions = {
	var range:Range;
	var hoverMessage:haxe.extern.EitherType<MarkedString, Array<MarkedString>>;
}

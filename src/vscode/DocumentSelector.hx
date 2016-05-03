package vscode;

typedef DocumentSelector = haxe.extern.EitherType<DocumentSelectorSimple,Array<DocumentSelectorSimple>>;

private typedef DocumentSelectorSimple = haxe.extern.EitherType<String,DocumentFilter>;

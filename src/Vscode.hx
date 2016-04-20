import js.Promise.Thenable;
import haxe.Constraints.Function;

@:jsRequire("vscode")
extern class Vscode {
	static var version(default,null):String;
	static var commands(default,null):Commands;
	static var env(default,null):Env;
	static var extensions(default,null):Extensions;
	static var languages(default,null):Languages;
	static var window(default,null):Window;
	static var workspace(default,null):Workspace;
}

extern class Commands {
	function registerCommand(command:String, callback:Function, ?thisArg:Dynamic):Disposable;
	function registerTextEditorCommand(command:String, callback:TextEditor -> TextEditorEdit -> Void, ?thisArg:Dynamic):Disposable;
	function executeCommand<T>(command:String, rest:haxe.extern.Rest<Dynamic>):Thenable<T>;
	function getCommands(?filterInternal:Bool):Thenable<Array<String>>;
}

extern class Env {
	var language(default,null):String;
	var machineId(default,null):String;
	var sessionId(default,null):String;
}

extern class Extensions {
	function getExtension<T>(extensionId:String):Extension<T>;
	var all(default,null):Array<Extension<Dynamic>>;
}

extern class Languages {
	function getLanguages():Thenable<Array<String>>;
	function match(selector:DocumentSelector, document:TextDocument):Float;
	function createDiagnosticCollection(?name:String):DiagnosticCollection;
	function registerCompletionItemProvider(selector:DocumentSelector, provider:CompletionItemProvider, triggerCharacters:haxe.extern.Rest<String>):Disposable;
	function registerCodeActionsProvider(selector:DocumentSelector, provider:CodeActionProvider):Disposable;
	function registerCodeLensProvider(selector:DocumentSelector, provider:CodeLensProvider):Disposable;
	function registerDefinitionProvider(selector:DocumentSelector, provider:DefinitionProvider):Disposable;
	function registerHoverProvider(selector:DocumentSelector, provider:HoverProvider):Disposable;
	function registerDocumentHighlightProvider(selector:DocumentSelector, provider:DocumentHighlightProvider):Disposable;
	function registerDocumentSymbolProvider(selector:DocumentSelector, provider:DocumentSymbolProvider):Disposable;
	function registerWorkspaceSymbolProvider(provider:WorkspaceSymbolProvider):Disposable;
	function registerReferenceProvider(selector:DocumentSelector, provider:ReferenceProvider):Disposable;
	function registerRenameProvider(selector:DocumentSelector, provider:RenameProvider):Disposable;
	function registerDocumentFormattingEditProvider(selector:DocumentSelector, provider:DocumentFormattingEditProvider):Disposable;
	function registerDocumentRangeFormattingEditProvider(selector:DocumentSelector, provider:DocumentRangeFormattingEditProvider):Disposable;
	function registerOnTypeFormattingEditProvider(selector:DocumentSelector, provider:OnTypeFormattingEditProvider, firstTriggerCharacter:String, moreTriggerCharacter:haxe.extern.Rest<String>):Disposable;
	function registerSignatureHelpProvider(selector:DocumentSelector, provider:SignatureHelpProvider, triggerCharacters:haxe.extern.Rest<String>):Disposable;
	function setLanguageConfiguration(language:String, configuration:LanguageConfiguration):Disposable;
}

extern class Window {
	var activeTextEditor : TextEditor;
	var visibleTextEditors : Array<TextEditor>;
	var onDidChangeActiveTextEditor : Event<TextEditor>;
	var onDidChangeTextEditorSelection : Event<TextEditorSelectionChangeEvent>;
	var onDidChangeTextEditorOptions : Event<TextEditorOptionsChangeEvent>;
	var onDidChangeTextEditorViewColumn : Event<TextEditorViewColumnChangeEvent>;
	function showTextDocument(document:TextDocument, ?column:ViewColumn, ?preserveFocus:Bool):Thenable<TextEditor>;
	function createTextEditorDecorationType(options:DecorationRenderOptions):TextEditorDecorationType;
	@:overload(function(message:String, items:haxe.extern.Rest<String>):Thenable<String> {})
	function showInformationMessage<T:(MessageItem)>(message:String, items:haxe.extern.Rest<T>):Thenable<T>;
	@:overload(function(message:String, items:haxe.extern.Rest<String>):Thenable<String> {})
	function showWarningMessage<T:(MessageItem)>(message:String, items:haxe.extern.Rest<T>):Thenable<T>;
	@:overload(function(message:String, items:haxe.extern.Rest<String>):Thenable<String> {})
	function showErrorMessage<T:(MessageItem)>(message:String, items:haxe.extern.Rest<T>):Thenable<T>;
	@:overload(function(items:haxe.extern.EitherType<Array<String>, Thenable<Array<String>>>, ?options:QuickPickOptions):Thenable<String> {})
	function showQuickPick<T:(QuickPickItem)>(items:haxe.extern.EitherType<Array<T>, Thenable<Array<T>>>, ?options:QuickPickOptions):Thenable<T>;
	function showInputBox(?options:InputBoxOptions):Thenable<String>;
	function createOutputChannel(name:String):OutputChannel;
	@:overload(function(text:String, hideAfterTimeout:Float):Disposable {})
	@:overload(function(text:String, hideWhenDone:Thenable<Dynamic>):Disposable {})
	function setStatusBarMessage(text:String):Disposable;
	function createStatusBarItem(?alignment:StatusBarAlignment, ?priority:Float):StatusBarItem;
}

extern class Workspace {
	function createFileSystemWatcher(globPattern:String, ?ignoreCreateEvents:Bool, ?ignoreChangeEvents:Bool, ?ignoreDeleteEvents:Bool):FileSystemWatcher;
	var rootPath : String;
	function asRelativePath(pathOrUri:haxe.extern.EitherType<String, Uri>):String;
	function findFiles(include:String, exclude:String, ?maxResults:Float, ?token:CancellationToken):Thenable<Array<Uri>>;
	function saveAll(?includeUntitled:Bool):Thenable<Bool>;
	function applyEdit(edit:WorkspaceEdit):Thenable<Bool>;
	var textDocuments : Array<TextDocument>;
	@:overload(function(fileName:String):Thenable<TextDocument> {})
	function openTextDocument(uri:Uri):Thenable<TextDocument>;
	function registerTextDocumentContentProvider(scheme:String, provider:TextDocumentContentProvider):Disposable;
	var onDidOpenTextDocument : Event<TextDocument>;
	var onDidCloseTextDocument : Event<TextDocument>;
	var onDidChangeTextDocument : Event<TextDocumentChangeEvent>;
	var onDidSaveTextDocument : Event<TextDocument>;
	function getConfiguration(?section:String):WorkspaceConfiguration;
	var onDidChangeConfiguration : Event<Void>;
}

typedef Command = {
	var title : String;
	var command : String;
	@:optional
	var arguments : Array<Dynamic>;
};
typedef TextLine = {
	var lineNumber : Float;
	var text : String;
	var range : Range;
	var rangeIncludingLineBreak : Range;
	var firstNonWhitespaceCharacterIndex : Float;
	var isEmptyOrWhitespace : Bool;
};
typedef TextDocument = {
	var uri : Uri;
	var fileName : String;
	var isUntitled : Bool;
	var languageId : String;
	var version : Float;
	var isDirty : Bool;
	function save():Thenable<Bool>;
	var lineCount : Float;
	@:overload(function(position:Position):TextLine { })
	function lineAt(line:Float):TextLine;
	function offsetAt(position:Position):Float;
	function positionAt(offset:Float):Position;
	function getText(?range:Range):String;
	function getWordRangeAtPosition(position:Position):Range;
	function validateRange(range:Range):Range;
	function validatePosition(position:Position):Position;
};
@:jsRequire("vscode", "Position")
extern class Position {
	var line : Float;
	var character : Float;
	function new(line:Float, character:Float):Void;
	function isBefore(other:Position):Bool;
	function isBeforeOrEqual(other:Position):Bool;
	function isAfter(other:Position):Bool;
	function isAfterOrEqual(other:Position):Bool;
	function isEqual(other:Position):Bool;
	function compareTo(other:Position):Float;
	function translate(?lineDelta:Float, ?characterDelta:Float):Position;
	function with(?line:Float, ?character:Float):Position;
}
@:jsRequire("vscode", "Range")
extern class Range {
	var start : Position;
	var end : Position;
	@:overload(function(startLine:Float, startCharacter:Float, endLine:Float, endCharacter:Float):Void { })
	function new(start:Position, end:Position):Void;
	var isEmpty : Bool;
	var isSingleLine : Bool;
	function contains(positionOrRange:haxe.extern.EitherType<Position, Range>):Bool;
	function isEqual(other:Range):Bool;
	function intersection(range:Range):Range;
	function union(other:Range):Range;
	function with(?start:Position, ?end:Position):Range;
}
@:jsRequire("vscode", "Selection")
extern class Selection extends Range {
	var anchor : Position;
	var active : Position;
	@:overload(function(anchorLine:Float, anchorCharacter:Float, activeLine:Float, activeCharacter:Float):Void { })
	function new(anchor:Position, active:Position):Void;
	var isReversed : Bool;
}
typedef TextEditorSelectionChangeEvent = {
	var textEditor : TextEditor;
	var selections : Array<Selection>;
};
typedef TextEditorOptionsChangeEvent = {
	var textEditor : TextEditor;
	var options : TextEditorOptions;
};
typedef TextEditorViewColumnChangeEvent = {
	var textEditor : TextEditor;
	var viewColumn : ViewColumn;
};
@:enum abstract TextEditorCursorStyle(Int) {
	var Line = 1;
	var Block = 2;
	var Underline = 3;
}
typedef TextEditorOptions = {
	@:optional
	var tabSize : haxe.extern.EitherType<Float, String>;
	@:optional
	var insertSpaces : haxe.extern.EitherType<Bool, String>;
	@:optional
	var cursorStyle : TextEditorCursorStyle;
};
typedef TextEditorDecorationType = {
	var key : String;
	function dispose():Void;
};
@:enum abstract TextEditorRevealType(Int) {
	var Default = 0;
	var InCenter = 1;
	var InCenterIfOutsideViewport = 2;
}
@:enum abstract OverviewRulerLane(Int) {
	var Left = 1;
	var Center = 2;
	var Right = 4;
	var Full = 7;
}
typedef ThemableDecorationRenderOptions = {
	@:optional
	var backgroundColor : String;
	@:optional
	var outlineColor : String;
	@:optional
	var outlineStyle : String;
	@:optional
	var outlineWidth : String;
	@:optional
	var borderColor : String;
	@:optional
	var borderRadius : String;
	@:optional
	var borderSpacing : String;
	@:optional
	var borderStyle : String;
	@:optional
	var borderWidth : String;
	@:optional
	var textDecoration : String;
	@:optional
	var cursor : String;
	@:optional
	var color : String;
	@:optional
	var letterSpacing : String;
	@:optional
	var gutterIconPath : String;
	@:optional
	var overviewRulerColor : String;
};
typedef DecorationRenderOptions = {
	>ThemableDecorationRenderOptions,
	@:optional
	var isWholeLine : Bool;
	@:optional
	var overviewRulerLane : OverviewRulerLane;
	@:optional
	var light : ThemableDecorationRenderOptions;
	@:optional
	var dark : ThemableDecorationRenderOptions;
};
typedef DecorationOptions = {
	var range : Range;
	var hoverMessage : haxe.extern.EitherType<MarkedString, Array<MarkedString>>;
};
typedef TextEditor = {
	var document : TextDocument;
	var selection : Selection;
	var selections : Array<Selection>;
	var options : TextEditorOptions;
	var viewColumn : ViewColumn;
	function edit(callback:TextEditorEdit -> Void):Thenable<Bool>;
	function setDecorations(decorationType:TextEditorDecorationType, rangesOrOptions:haxe.extern.EitherType<Array<Range>, Array<DecorationOptions>>):Void;
	function revealRange(range:Range, ?revealType:TextEditorRevealType):Void;
	function show(?column:ViewColumn):Void;
	function hide():Void;
};
@:enum abstract EndOfLine(Int) {
	var LF = 1;
	var CRLF = 2;
}
typedef TextEditorEdit = {
	function replace(location:haxe.extern.EitherType<Position, haxe.extern.EitherType<Range, Selection>>, value:String):Void;
	function insert(location:Position, value:String):Void;
	function delete(location:haxe.extern.EitherType<Range, Selection>):Void;
	function setEndOfLine(endOfLine:EndOfLine):Void;
};
extern class Uri {
	static function file(path:String):Uri;
	static function parse(value:String):Uri;
	var scheme : String;
	var authority : String;
	var path : String;
	var query : String;
	var fragment : String;
	var fsPath : String;
	function toString():String;
	function toJSON():Dynamic;
}
typedef CancellationToken = {
	var isCancellationRequested : Bool;
	var onCancellationRequested : Event<Dynamic>;
};
extern class CancellationTokenSource {
	var token : CancellationToken;
	function cancel():Void;
	function dispose():Void;
}
@:jsRequire("vscode", "Disposable")
extern class Disposable {
	static function from(disposableLikes:haxe.extern.Rest<{ var dispose : Void -> Dynamic; }>):Disposable;
	function new(callOnDispose:haxe.Constraints.Function):Void;
	function dispose():Dynamic;
}
typedef Event<T> = { };
extern class EventEmitter<T> {
	var event : Event<T>;
	function fire(?data:T):Void;
	function dispose():Void;
}
extern class FileSystemWatcher extends Disposable {
	var ignoreCreateEvents : Bool;
	var ignoreChangeEvents : Bool;
	var ignoreDeleteEvents : Bool;
	var onDidCreate : Event<Uri>;
	var onDidChange : Event<Uri>;
	var onDidDelete : Event<Uri>;
}
typedef TextDocumentContentProvider = {
	@:optional
	var onDidChange : Event<Uri>;
	function provideTextDocumentContent(uri:Uri, token:CancellationToken):haxe.extern.EitherType<String, Thenable<String>>;
};
typedef QuickPickItem = {
	var label : String;
	var description : String;
	@:optional
	var detail : String;
};
typedef QuickPickOptions = {
	@:optional
	var matchOnDescription : Bool;
	@:optional
	var matchOnDetail : Bool;
	@:optional
	var placeHolder : String;
	@:optional
	var onDidSelectItem : haxe.extern.EitherType<Dynamic, String> -> Dynamic;
};
typedef MessageItem = {
	var title : String;
};
typedef InputBoxOptions = {
	@:optional
	var value : String;
	@:optional
	var prompt : String;
	@:optional
	var placeHolder : String;
	@:optional
	var password : Bool;
	@:optional
	var validateInput : String -> String;
};
typedef DocumentFilter = {
	@:optional
	var language : String;
	@:optional
	var scheme : String;
	@:optional
	var pattern : String;
};
typedef CodeActionContext = {
	var diagnostics : Array<Diagnostic>;
};
typedef CodeActionProvider = {
	function provideCodeActions(document:TextDocument, range:Range, context:CodeActionContext, token:CancellationToken):haxe.extern.EitherType<Array<Command>, Thenable<Array<Command>>>;
};
@:jsRequire("vscode", "CodeLens")
extern class CodeLens {
	var range : Range;
	var command : Command;
	var isResolved : Bool;
	function new(range:Range, ?command:Command):Void;
}
typedef CodeLensProvider = {
	function provideCodeLenses(document:TextDocument, token:CancellationToken):haxe.extern.EitherType<Array<CodeLens>, Thenable<Array<CodeLens>>>;
	@:optional
	function resolveCodeLens(codeLens:CodeLens, token:CancellationToken):haxe.extern.EitherType<CodeLens, Thenable<CodeLens>>;
};
typedef Definition = haxe.extern.EitherType<Location,Array<Location>>;
typedef DefinitionProvider = {
	function provideDefinition(document:TextDocument, position:Position, token:CancellationToken):haxe.extern.EitherType<Definition, Thenable<Definition>>;
};
@:jsRequire("vscode", "Hover")
extern class Hover {
	var contents : Array<MarkedString>;
	var range : Range;
	function new(contents:haxe.extern.EitherType<MarkedString, Array<MarkedString>>, ?range:Range):Void;
}
typedef HoverProvider = {
	function provideHover(document:TextDocument, position:Position, token:CancellationToken):haxe.extern.EitherType<Hover, Thenable<Hover>>;
};
@:enum abstract DocumentHighlightKind(Int) {
	var Text = 0;
	var Read = 1;
	var Write = 2;
}
@:jsRequire("vscode", "DocumentHighlight")
extern class DocumentHighlight {
	var range : Range;
	var kind : DocumentHighlightKind;
	function new(range:Range, ?kind:DocumentHighlightKind):Void;
}
typedef DocumentHighlightProvider = {
	function provideDocumentHighlights(document:TextDocument, position:Position, token:CancellationToken):haxe.extern.EitherType<Array<DocumentHighlight>, Thenable<Array<DocumentHighlight>>>;
};
@:enum abstract SymbolKind(Int) {
	var File = 0;
	var Module = 1;
	var Namespace = 2;
	var Package = 3;
	var Class = 4;
	var Method = 5;
	var Property = 6;
	var Field = 7;
	var Constructor = 8;
	var Enum = 9;
	var Interface = 10;
	var Function = 11;
	var Variable = 12;
	var Constant = 13;
	var String = 14;
	var Number = 15;
	var Boolean = 16;
	var Array = 17;
	var Object = 18;
	var Key = 19;
	var Null = 20;
}
@:jsRequire("vscode", "SymbolInformation")
extern class SymbolInformation {
	var name : String;
	var containerName : String;
	var kind : SymbolKind;
	var location : Location;
	function new(name:String, kind:SymbolKind, range:Range, ?uri:Uri, ?containerName:String):Void;
}
typedef DocumentSymbolProvider = {
	function provideDocumentSymbols(document:TextDocument, token:CancellationToken):haxe.extern.EitherType<Array<SymbolInformation>, Thenable<Array<SymbolInformation>>>;
};
typedef WorkspaceSymbolProvider = {
	function provideWorkspaceSymbols(query:String, token:CancellationToken):haxe.extern.EitherType<Array<SymbolInformation>, Thenable<Array<SymbolInformation>>>;
};
typedef ReferenceContext = {
	var includeDeclaration : Bool;
};
typedef ReferenceProvider = {
	function provideReferences(document:TextDocument, position:Position, context:ReferenceContext, token:CancellationToken):haxe.extern.EitherType<Array<Location>, Thenable<Array<Location>>>;
};
@:jsRequire("vscode", "TextEdit")
extern class TextEdit {
	static function replace(range:Range, newText:String):TextEdit;
	static function insert(position:Position, newText:String):TextEdit;
	static function delete(range:Range):TextEdit;
	var range : Range;
	var newText : String;
	function new(range:Range, newText:String):Void;
}
extern class WorkspaceEdit {
	var size : Float;
	function replace(uri:Uri, range:Range, newText:String):Void;
	function insert(uri:Uri, position:Position, newText:String):Void;
	function delete(uri:Uri, range:Range):Void;
	function has(uri:Uri):Bool;
	function set(uri:Uri, edits:Array<TextEdit>):Void;
	function get(uri:Uri):Array<TextEdit>;
	function entries():Array<Array<Dynamic>>;
}
typedef RenameProvider = {
	function provideRenameEdits(document:TextDocument, position:Position, newName:String, token:CancellationToken):haxe.extern.EitherType<WorkspaceEdit, Thenable<WorkspaceEdit>>;
};
typedef FormattingOptions = {
	var tabSize : Float;
	var insertSpaces : Bool;
};
typedef DocumentFormattingEditProvider = {
	function provideDocumentFormattingEdits(document:TextDocument, options:FormattingOptions, token:CancellationToken):haxe.extern.EitherType<Array<TextEdit>, Thenable<Array<TextEdit>>>;
};
typedef DocumentRangeFormattingEditProvider = {
	function provideDocumentRangeFormattingEdits(document:TextDocument, range:Range, options:FormattingOptions, token:CancellationToken):haxe.extern.EitherType<Array<TextEdit>, Thenable<Array<TextEdit>>>;
};
typedef OnTypeFormattingEditProvider = {
	function provideOnTypeFormattingEdits(document:TextDocument, position:Position, ch:String, options:FormattingOptions, token:CancellationToken):haxe.extern.EitherType<Array<TextEdit>, Thenable<Array<TextEdit>>>;
};
@:jsRequire("vscode", "ParameterInformation")
extern class ParameterInformation {
	var label : String;
	var documentation : String;
	function new(label:String, ?documentation:String):Void;
}
@:jsRequire("vscode", "SignatureInformation")
extern class SignatureInformation {
	var label : String;
	var documentation : String;
	var parameters : Array<ParameterInformation>;
	function new(label:String, ?documentation:String):Void;
}
extern class SignatureHelp {
	var signatures : Array<SignatureInformation>;
	var activeSignature : Float;
	var activeParameter : Float;
}
typedef SignatureHelpProvider = {
	function provideSignatureHelp(document:TextDocument, position:Position, token:CancellationToken):haxe.extern.EitherType<SignatureHelp, Thenable<SignatureHelp>>;
};
@:enum abstract CompletionItemKind(Int) {
	var Text = 0;
	var Method = 1;
	var Function = 2;
	var Constructor = 3;
	var Field = 4;
	var Variable = 5;
	var Class = 6;
	var Interface = 7;
	var Module = 8;
	var Property = 9;
	var Unit = 10;
	var Value = 11;
	var Enum = 12;
	var Keyword = 13;
	var Snippet = 14;
	var Color = 15;
	var File = 16;
	var Reference = 17;
}
@:jsRequire("vscode", "CompletionItem")
extern class CompletionItem {
	var label : String;
	var kind : CompletionItemKind;
	var detail : String;
	var documentation : String;
	var sortText : String;
	var filterText : String;
	var insertText : String;
	var textEdit : TextEdit;
	function new(label:String):Void;
}
@:jsRequire("vscode", "CompletionList")
extern class CompletionList {
	var isIncomplete : Bool;
	var items : Array<CompletionItem>;
	function new(?items:Array<CompletionItem>, ?isIncomplete:Bool):Void;
}
typedef CompletionItemProvider = {
	function provideCompletionItems(document:TextDocument, position:Position, token:CancellationToken):haxe.extern.EitherType<Array<CompletionItem>, haxe.extern.EitherType<Thenable<Array<CompletionItem>>, haxe.extern.EitherType<CompletionList, Thenable<CompletionList>>>>;
	@:optional
	function resolveCompletionItem(item:CompletionItem, token:CancellationToken):haxe.extern.EitherType<CompletionItem, Thenable<CompletionItem>>;
};
typedef CharacterPair = Array<String>;
typedef CommentRule = {
	@:optional
	var lineComment : String;
	@:optional
	var blockComment : CharacterPair;
};
typedef IndentationRule = {
	var decreaseIndentPattern : js.RegExp;
	var increaseIndentPattern : js.RegExp;
	@:optional
	var indentNextLinePattern : js.RegExp;
	@:optional
	var unIndentedLinePattern : js.RegExp;
};
@:enum abstract IndentAction(Int) {
	var None = 0;
	var Indent = 1;
	var IndentOutdent = 2;
	var Outdent = 3;
}
typedef EnterAction = {
	var indentAction : IndentAction;
	@:optional
	var appendText : String;
	@:optional
	var removeText : Float;
};
typedef OnEnterRule = {
	var beforeText : js.RegExp;
	@:optional
	var afterText : js.RegExp;
	var action : EnterAction;
};
typedef LanguageConfiguration = {
	@:optional
	var comments : CommentRule;
	@:optional
	var brackets : Array<CharacterPair>;
	@:optional
	var wordPattern : js.RegExp;
	@:optional
	var indentationRules : IndentationRule;
	@:optional
	var onEnterRules : Array<OnEnterRule>;
	@:optional
	var __electricCharacterSupport : { @:optional
	var brackets : Dynamic; @:optional
	var docComment : { var scope : String; var open : String; var lineStart : String; @:optional
	var close : String; }; };
	@:optional
	var __characterPairSupport : { var autoClosingPairs : Array<{ var open : String; var close : String; @:optional
	var notIn : Array<String>; }>; };
};
typedef WorkspaceConfiguration = {
	function get<T>(section:String, ?defaultValue:T):T;
	function has(section:String):Bool;
};
@:jsRequire("vscode", "Location")
extern class Location {
	var uri : Uri;
	var range : Range;
	function new(uri:Uri, rangeOrPosition:haxe.extern.EitherType<Range, Position>):Void;
}
@:enum abstract DiagnosticSeverity(Int) {
	var Error = 0;
	var Warning = 1;
	var Information = 2;
	var Hint = 3;
}
@:jsRequire("vscode", "Diagnostic")
extern class Diagnostic {
	var range : Range;
	var message : String;
	var source : String;
	var severity : DiagnosticSeverity;
	var code : haxe.extern.EitherType<String, Float>;
	function new(range:Range, message:String, ?severity:DiagnosticSeverity):Void;
}
typedef DiagnosticCollection = {
	var name : String;
	@:overload(function(entries:Array<Array<Dynamic>>):Void { })
	function set(uri:Uri, diagnostics:Array<Diagnostic>):Void;
	function delete(uri:Uri):Void;
	function clear():Void;
	function dispose():Void;
};
@:enum abstract ViewColumn(Int) {
	var One = 1;
	var Two = 2;
	var Three = 3;
}
typedef OutputChannel = {
	var name : String;
	function append(value:String):Void;
	function appendLine(value:String):Void;
	function clear():Void;
	@:overload(function(?preservceFocus:Bool):Void { })
	function show(?column:ViewColumn, ?preserveFocus:Bool):Void;
	function hide():Void;
	function dispose():Void;
};
@:enum abstract StatusBarAlignment(Int) {
	var Left = 0;
	var Right = 1;
}
typedef StatusBarItem = {
	var alignment : StatusBarAlignment;
	var priority : Float;
	var text : String;
	var tooltip : String;
	var color : String;
	var command : String;
	function show():Void;
	function hide():Void;
	function dispose():Void;
};
typedef Extension<T> = {
	var id : String;
	var extensionPath : String;
	var isActive : Bool;
	var packageJSON : Dynamic;
	var exports : T;
	function activate():Thenable<T>;
};
typedef ExtensionContext = {
	var subscriptions : Array<{ function dispose():Dynamic; }>;
	var workspaceState : Memento;
	var globalState : Memento;
	var extensionPath : String;
	function asAbsolutePath(relativePath:String):String;
};
typedef Memento = {
	function get<T>(key:String, ?defaultValue:T):T;
	function update(key:String, value:Dynamic):Thenable<Void>;
};

typedef TextDocumentContentChangeEvent = {
	var range : Range;
	var rangeLength : Float;
	var text : String;
};
typedef TextDocumentChangeEvent = {
	var document : TextDocument;
	var contentChanges : Array<TextDocumentContentChangeEvent>;
};
typedef DocumentSelectorSimple = haxe.extern.EitherType<String,DocumentFilter>;
typedef DocumentSelector = haxe.extern.EitherType<DocumentSelectorSimple,Array<DocumentSelectorSimple>>;
typedef MarkedString = haxe.extern.EitherType<String,{language:String, value:String}>

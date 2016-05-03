import js.Promise.Thenable;

import vscode.*;

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

private extern class Commands {
	function registerCommand(command:String, callback:haxe.Constraints.Function, ?thisArg:Dynamic):Disposable;
	function registerTextEditorCommand(command:String, callback:TextEditor -> TextEditorEdit -> Void, ?thisArg:Dynamic):Disposable;
	function executeCommand<T>(command:String, rest:haxe.extern.Rest<Dynamic>):Thenable<T>;
	function getCommands(?filterInternal:Bool):Thenable<Array<String>>;
}

private extern class Env {
	var language(default,null):String;
	var machineId(default,null):String;
	var sessionId(default,null):String;
}

private extern class Extensions {
	function getExtension<T>(extensionId:String):Extension<T>;
	var all(default,null):Array<Extension<Dynamic>>;
}

private extern class Languages {
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

private extern class Window {
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

private extern class Workspace {
	function createFileSystemWatcher(globPattern:String, ?ignoreCreateEvents:Bool, ?ignoreChangeEvents:Bool, ?ignoreDeleteEvents:Bool):FileSystemWatcher;
	var rootPath : String;
	function asRelativePath(pathOrUri:haxe.extern.EitherType<String, Uri>):String;
	function findFiles(include:String, exclude:String, ?maxResults:Int, ?token:CancellationToken):Thenable<Array<Uri>>;
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

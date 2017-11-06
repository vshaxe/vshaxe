package vshaxe.server;

import haxe.extern.EitherType;
import js.Promise;

@:jsRequire("vscode-languageclient", "LanguageClient")
extern class LanguageClient {
    function new(id:String, name:String, serverOptions:ServerOptions, clientOptions:LanguageClientOptions, ?forceDebug:Bool);

    function start():Disposable;
    function stop():Thenable<Void>;

    function onNotification(method:String, handler:Dynamic->Void):Void;
    function sendNotification(method:String, ?params:Dynamic):Void;
    function sendRequest<P,R>(method:String, param:P, ?token:CancellationToken):Thenable<R>;
    function onReady():Promise<Void>;
    var outputChannel(default,null):OutputChannel;

    function info(message:String, ?data:Any):Void;
    function warn(message:String, ?data:Any):Void;
    function error(message:String, ?data:Any):Void;
}

typedef ExecutableOptions = {
    ?cwd:String,
    ?stdio:EitherType<String,Array<String>>,
    ?env:Dynamic,
    ?detached:Bool,
}

typedef Executable = {
    command:String,
    ?args:Array<String>,
    ?options:ExecutableOptions,
}

typedef ForkOptions = {
    ?cwd:String,
    ?env:Dynamic,
    ?encoding:String,
    ?execArgv:Array<String>,
}

typedef NodeModule = {
    module:String,
    ?transport:TransportKind,
    ?args:Array<String>,
    ?runtime:String,
    ?options:ForkOptions,
}

abstract ServerOptions(Dynamic)
    from Executable
    from {run:Executable, debug:Executable}
    from {run:NodeModule, debug:NodeModule}
    from NodeModule
{}

@:enum abstract TransportKind(Int) {
    var stdio = 0;
    var ipc = 1;
    var pipe = 2;
}

typedef LanguageClientOptions = {
    ?documentSelector:EitherType<DocumentSelector,Array<String>>,
    ?synchronize:SynchronizeOptions,
    ?diagnosticCollectionName:String,
    ?outputChannel:OutputChannel,
    ?revealOutputChannelOn:RevealOutputChannelOn,
    ?stdioEncoding:String,
    ?initializationOptions:EitherType<Dynamic,Void->Dynamic>,
    ?middleware:Middleware,
    ?uriConverters:{
        code2Protocol:Uri->String,
        protocol2Code:String->Uri,
    },
    ?workspaceFolder:WorkspaceFolder,
}

typedef SynchronizeOptions = {
    ?configurationSection:EitherType<String,Array<String>>,
    ?fileEvents:EitherType<FileSystemWatcher,Array<FileSystemWatcher>>
}

@:enum abstract RevealOutputChannelOn(Int) {
    var Info = 1;
    var Warn = 2;
    var Error = 3;
    var Never = 4;
}

typedef ProvideCompletionItemsSignature = (document:TextDocument, position:Position, token:CancellationToken) -> ProviderResult<EitherType<Array<CompletionItem>,CompletionList>>;
typedef ResolveCompletionItemSignature = (item:CompletionItem, token:CancellationToken) -> ProviderResult<CompletionItem>;
typedef ProvideHoverSignature = (document:TextDocument, position:Position, token:CancellationToken) -> ProviderResult<Hover>;
typedef ProvideSignatureHelpSignature = (document:TextDocument, position:Position, token:CancellationToken) -> ProviderResult<SignatureHelp>;
typedef ProvideDefinitionSignature = (document:TextDocument, position:Position, token:CancellationToken) -> ProviderResult<Definition>;
typedef ProvideReferencesSignature = (document:TextDocument, position:Position, options:{includeDeclaration:Bool}, token:CancellationToken) -> ProviderResult<Array<Location>>;
typedef ProvideDocumentHighlightsSignature = (document:TextDocument, position:Position, token:CancellationToken) -> ProviderResult<Array<DocumentHighlight>>;
typedef ProvideDocumentSymbolsSignature = (document:TextDocument, token:CancellationToken) -> ProviderResult<Array<SymbolInformation>>;
typedef ProvideWorkspaceSymbolsSignature = (query:String, token:CancellationToken) -> ProviderResult<Array<SymbolInformation>>;
typedef ProvideCodeActionsSignature = (document:TextDocument, range:Range, context:CodeActionContext, token:CancellationToken) -> ProviderResult<Array<Command>>;
typedef ProvideCodeLensesSignature = (document:TextDocument, token:CancellationToken) -> ProviderResult<Array<CodeLens>>;
typedef ResolveCodeLensSignature = (codeLens:CodeLens, token:CancellationToken) -> ProviderResult<CodeLens>;
typedef ProvideDocumentFormattingEditsSignature = (document:TextDocument, options:FormattingOptions, token:CancellationToken) -> ProviderResult<Array<TextEdit>>;
typedef ProvideDocumentRangeFormattingEditsSignature = (document:TextDocument, range:Range, options:FormattingOptions, token:CancellationToken) -> ProviderResult<Array<TextEdit>>;
typedef ProvideOnTypeFormattingEditsSignature = (document:TextDocument, position:Position, ch:String, options:FormattingOptions, token:CancellationToken) -> ProviderResult<Array<TextEdit>>;
typedef ProvideRenameEditsSignature = (document:TextDocument, position:Position, newName:String, token:CancellationToken) -> ProviderResult<WorkspaceEdit>;
typedef ProvideDocumentLinksSignature = (document:TextDocument, token:CancellationToken) -> ProviderResult<Array<DocumentLink>>;
typedef ResolveDocumentLinkSignature = (link:DocumentLink, token:CancellationToken) -> ProviderResult<DocumentLink>;
typedef NextSignature<P,R> = (data:P, next:(data:P)->R) -> R;
typedef DidChangeConfigurationSignature = (sections:Null<Array<String>>) -> Void;
typedef WorkspaceMiddleware = {
    ?didChangeConfiguration:(sections:Null<Array<String>>, next:DidChangeConfigurationSignature)->Void
}

typedef Middleware = {
    ?didOpen:NextSignature<TextDocument,Void>,
    ?didChange:NextSignature<TextDocumentChangeEvent,Void>,
    ?willSave:NextSignature<TextDocumentWillSaveEvent,Void>,
    ?willSaveWaitUntil:NextSignature<TextDocumentWillSaveEvent,Thenable<Array<TextEdit>>>,
    ?didSave:NextSignature<TextDocument,Void>,
    ?didClose:NextSignature<TextDocument,Void>,
    ?provideCompletionItem:(document:TextDocument, position:Position, token:CancellationToken, next:ProvideCompletionItemsSignature) -> ProviderResult<EitherType<Array<CompletionItem>,CompletionList>>,
    ?resolveCompletionItem:(item:CompletionItem, token:CancellationToken, next:ResolveCompletionItemSignature) -> ProviderResult<CompletionItem>,
    ?provideHover:(document:TextDocument, position:Position, token:CancellationToken, next:ProvideHoverSignature) -> ProviderResult<Hover>,
    ?provideSignatureHelp:(document:TextDocument, position:Position, token:CancellationToken, next:ProvideSignatureHelpSignature) -> ProviderResult<SignatureHelp>,
    ?provideDefinition:(document:TextDocument, position:Position, token:CancellationToken, next:ProvideDefinitionSignature) -> ProviderResult<Definition>,
    ?provideReferences:(document:TextDocument, position:Position, options:{includeDeclaration:Bool}, token:CancellationToken, next:ProvideReferencesSignature) -> ProviderResult<Array<Location>>,
    ?provideDocumentHighlights:(document:TextDocument, position:Position, token:CancellationToken, next:ProvideDocumentHighlightsSignature) -> ProviderResult<Array<DocumentHighlight>>,
    ?provideDocumentSymbols:(document:TextDocument, token:CancellationToken, next:ProvideDocumentSymbolsSignature) -> ProviderResult<Array<SymbolInformation>>,
    ?provideWorkspaceSymbols:(query:String, token:CancellationToken, next:ProvideWorkspaceSymbolsSignature) -> ProviderResult<Array<SymbolInformation>>,
    ?provideCodeActions:(document:TextDocument, range:Range, context:CodeActionContext, token:CancellationToken, next:ProvideCodeActionsSignature) -> ProviderResult<Array<Command>>,
    ?provideCodeLenses:(document:TextDocument, token:CancellationToken, next:ProvideCodeLensesSignature) -> ProviderResult<Array<CodeLens>>,
    ?resolveCodeLens:(codeLens:CodeLens, token:CancellationToken, next:ResolveCodeLensSignature) -> ProviderResult<CodeLens>,
    ?provideDocumentFormattingEdits:(document:TextDocument, options:FormattingOptions, token:CancellationToken, next:ProvideDocumentFormattingEditsSignature) -> ProviderResult<Array<TextEdit>>,
    ?provideDocumentRangeFormattingEdits:(document:TextDocument, range:Range, options:FormattingOptions, token:CancellationToken, next:ProvideDocumentRangeFormattingEditsSignature) -> ProviderResult<Array<TextEdit>>,
    ?provideOnTypeFormattingEdits:(document:TextDocument, position:Position, ch:String, options:FormattingOptions, token:CancellationToken, next:ProvideOnTypeFormattingEditsSignature) -> ProviderResult<Array<TextEdit>>,
    ?provideRenameEdits:(document:TextDocument, position:Position, newName:String, token:CancellationToken, next:ProvideRenameEditsSignature) -> ProviderResult<WorkspaceEdit>,
    ?provideDocumentLinks:(document:TextDocument, token:CancellationToken, next:ProvideDocumentLinksSignature) -> ProviderResult<Array<DocumentLink>>,
    ?resolveDocumentLink:(link:DocumentLink, token:CancellationToken, next:ResolveDocumentLinkSignature) -> ProviderResult<DocumentLink>,
    ?workspace:WorkspaceMiddleware
}

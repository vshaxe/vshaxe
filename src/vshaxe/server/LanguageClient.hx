package vshaxe.server;

import haxe.extern.EitherType;
import jsonrpc.Types.Message;
import jsonrpc.Types.RequestMethod;
import jsonrpc.Types.NotificationMethod;
import jsonrpc.Types.NoData;
import jsonrpc.ResponseError;
import jsonrpc.Protocol;
import languageServerProtocol.protocol.Protocol.InitializeParams;
import languageServerProtocol.protocol.Protocol.InitializeResult;
import languageServerProtocol.protocol.Protocol.InitializeError;
import languageServerProtocol.protocol.Protocol.ClientCapabilities;
import languageServerProtocol.protocol.Protocol.ServerCapabilities;
import languageServerProtocol.protocol.Protocol.TraceMode;
import js.Promise;
import js.Error;

@:jsRequire("vscode-languageclient", "LanguageClient")
extern class LanguageClient {
	function new(id:String, name:String, serverOptions:ServerOptions, clientOptions:LanguageClientOptions, ?forceDebug:Bool);
	var initializeResult(default, null):Null<InitializeResult>;
	@:overload(function<R, E, RO>(type:RequestMethod<NoData, R, E, RO>, ?token:CancellationToken):Thenable<R> {})
	@:overload(function<P, R, E, RO>(type:RequestMethod<P, R, E, RO>, params:P, ?token:CancellationToken):Thenable<R> {})
	@:overload(function<R>(method:String, ?token:CancellationToken):Thenable<R> {})
	function sendRequest<R>(method:String, param:Any, ?token:CancellationToken):Thenable<R>;
	@:overload(function<R, E, RO>(type:RequestMethod<NoData, R, E, RO>, handler:RequestHandler<NoData, R, E>):Void {})
	@:overload(function<P, R, E, RO>(type:RequestMethod<P, R, E, RO>, handler:RequestHandler<P, R, E>):Void {})
	function onRequest<R, E>(method:String, handler:GenericRequestHandler<R, E>):Void;
	@:overload(function<P, RO>(type:NotificationMethod<P, RO>, ?params:P):Void {})
	@:overload(function(method:String):Void {})
	function sendNotification(method:String, params:Any):Void;
	function onNotification(method:String, handler:Dynamic->Void):Void;
	var clientOptions(default, null):LanguageClientOptions;
	// var protocol2CodeConverter(default,null):p2c.Converter;
	// var code2ProtocolConverter(default,null):c2p.Converter;
	var onTelemetry(default, null):Event<Any>;
	var onDidChangeState(default, null):Event<StateChangeEvent>;
	var outputChannel(default, null):OutputChannel;
	var diagnostics(default, null):Null<DiagnosticCollection>;
	function createDefaultErrorHandler():ErrorHandler;
	var trace:TraceMode;
	function info(message:String, ?data:Any):Void;
	function warn(message:String, ?data:Any):Void;
	function error(message:String, ?data:Any):Void;
	function needsStart():Bool;
	function needsStop():Bool;
	function onReady():Promise<Void>;
	function start():Disposable;
	function stop():Thenable<Void>;
	function registerFeatures(features:Array<EitherType<StaticFeature, DynamicFeature<Any>>>):Void;
	function registerFeature(feature:EitherType<StaticFeature, DynamicFeature<Any>>):Void;
	function registerProposedFeatures():Void;
}

typedef ExecutableOptions = {
	?cwd:String,
	?stdio:EitherType<String, Array<String>>,
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

abstract ServerOptions(Dynamic) from Executable from {run:Executable, debug:Executable} from {run:NodeModule, debug:NodeModule} from NodeModule {}

enum abstract TransportKind(Int) {
	var stdio;
	var ipc;
	var pipe;
}

typedef LanguageClientOptions = {
	?documentSelector:EitherType<DocumentSelector, Array<String>>,
	?synchronize:SynchronizeOptions,
	?diagnosticCollectionName:String,
	?outputChannel:OutputChannel,
	?revealOutputChannelOn:RevealOutputChannelOn,
	/**
	 * The encoding use to read stdout and stderr. Defaults
	 * to 'utf8' if ommitted.
	 */
	?stdioEncoding:String,
	?initializationOptions:EitherType<Dynamic, Void->Dynamic>,
	?initializationFailedHandler:InitializationFailedHandler,
	?middleware:Middleware,
	?uriConverters:{
		code2Protocol:Uri->String,
		protocol2Code:String->Uri,
	},
	?workspaceFolder:WorkspaceFolder,
}

enum abstract State(Int) {
	var Stopped = 1;
	var Running = 2;
}

typedef StateChangeEvent = {
	oldState:State,
	newState:State
}

typedef RegistrationData<T> = {
	id:String,
	registerOptions:T
}

/**
	An interface to type messages.
**/
typedef RPCMessageType = {
	var method(default, null):String;
	var numberOfParams(default, null):Int;
}

/**
 * A static feature. A static feature can't be dynamically activate via the
 * server. It is wired during the initialize sequence.
 */
typedef StaticFeature = {
	/**
	 * Called to fill the initialize params.
	 *
	 * @param params the initialize params.
	 */
	var ?fillInitializeParams:(params:InitializeParams) -> Void;

	/**
	 * Called to fill in the client capabilities this feature implements.
	 *
	 * @param capabilities The client capabilities to fill.
	 */
	function fillClientCapabilities(capabilities:ClientCapabilities):Void;

	/**
	 * Initialize the feature. This method is called on a feature instance
	 * when the client has successfully received the initalize request from
	 * the server and before the client sends the initialized notification
	 * to the server.
	 *
	 * @param capabilities the server capabilities
	 * @param documentSelector the document selector pass to the client's constuctor.
	 *  May be `undefined` if the client was created without a selector.
	 */
	function initialize(capabilities:ServerCapabilities, documentSelector:Null<DocumentSelector>):Void;
}

typedef DynamicFeature<T> = {
	/**
	 * The message for which this features support dynamic activation / registration.
	 */
	var messages:EitherType<RPCMessageType, Array<RPCMessageType>>;

	/**
	 * Called to fill the initialize params.
	 *
	 * @param params the initialize params.
	 */
	var ?fillInitializeParams:(params:InitializeParams) -> Void;

	/**
	 * Called to fill in the client capabilities this feature implements.
	 *
	 * @param capabilities The client capabilities to fill.
	 */
	function fillClientCapabilities(capabilities:ClientCapabilities):Void;

	/**
	 * Initialize the feature. This method is called on a feature instance
	 * when the client has successfully received the initalize request from
	 * the server and before the client sends the initialized notification
	 * to the server.
	 *
	 * @param capabilities the server capabilities.
	 * @param documentSelector the document selector pass to the client's constuctor.
	 *  May be `undefined` if the client was created without a selector.
	 */
	function initialize(capabilities:ServerCapabilities, documentSelector:Null<DocumentSelector>):Void;

	/**
	 * Is called when the server send a register request for the given message.
	 *
	 * @param message the message to register for.
	 * @param data additional registration data as defined in the protocol.
	 */
	function register(message:RPCMessageType, data:RegistrationData<T>):Void;

	/**
	 * Is called when the server wants to unregister a feature.
	 *
	 * @param id the id used when registering the feature.
	 */
	function unregister(id:String):Void;

	/**
	 * Called when the client is stopped to dispose this feature. Usually a feature
	 * unregisters listeners registerd hooked up with the VS Code extension host.
	 */
	function dispose():Void;
}

typedef SynchronizeOptions = {
	?configurationSection:EitherType<String, Array<String>>,
	?fileEvents:EitherType<FileSystemWatcher, Array<FileSystemWatcher>>
}

/**
 * An action to be performed when the connection is producing errors.
 */
enum abstract ErrorAction(Int) {
	/**
	 * Continue running the server.
	 */
	var Continue = 1;

	/**
	 * Shutdown the server.
	 */
	var Shutdown = 2;
}

/**
 * An action to be performed when the connection to a server got closed.
 */
enum abstract CloseAction(Int) {
	/**
	 * Don't restart the server. The connection stays closed.
	 */
	var DoNotRestart = 1;

	/**
	 * Restart the server.
	 */
	var Restart = 2;
}

/**
 * A pluggable error handler that is invoked when the connection is either
 * producing errors or got closed.
 */
typedef ErrorHandler = {
	/**
	 * An error has occurred while writing or reading from the connection.
	 *
	 * @param error - the error received
	 * @param message - the message to be delivered to the server if know.
	 * @param count - a count indicating how often an error is received. Will
	 *  be reset if a message got successfully send or received.
	 */
	function error(error:Error, message:Message, count:Int):ErrorAction;

	/**
	 * The connection to the server got closed.
	 */
	function closed():CloseAction;
}

typedef InitializationFailedHandler = (error:EitherType<ResponseError<InitializeError>, EitherType<Error, Any>>) -> Bool;

enum abstract RevealOutputChannelOn(Int) {
	var Info = 1;
	var Warn = 2;
	var Error = 3;
	var Never = 4;
}

typedef HandleDiagnosticsSignature = (uri:Uri, diagnostics:Array<Diagnostic>) -> Void;

typedef ProvideCompletionItemsSignature = (document:TextDocument, position:Position, context:CompletionContext, token:CancellationToken) ->
	ProviderResult<EitherType<Array<CompletionItem>, CompletionList>>;

typedef ResolveCompletionItemSignature = (item:CompletionItem, token:CancellationToken) -> ProviderResult<CompletionItem>;

typedef ProvideHoverSignature = (document:TextDocument, position:Position, token:CancellationToken) -> ProviderResult<Hover>;

typedef ProvideSignatureHelpSignature = (document:TextDocument, position:Position, token:CancellationToken) -> ProviderResult<SignatureHelp>;

typedef ProvideDefinitionSignature = (document:TextDocument, position:Position, token:CancellationToken) -> ProviderResult<Definition>;

typedef ProvideReferencesSignature = (document:TextDocument, position:Position, options:{includeDeclaration:Bool}, token:CancellationToken) ->
	ProviderResult<Array<Location>>;

typedef ProvideDocumentHighlightsSignature = (document:TextDocument, position:Position, token:CancellationToken) -> ProviderResult<Array<DocumentHighlight>>;

typedef ProvideDocumentSymbolsSignature = (document:TextDocument, token:CancellationToken) -> ProviderResult<Array<SymbolInformation>>;

typedef ProvideWorkspaceSymbolsSignature = (query:String, token:CancellationToken) -> ProviderResult<Array<SymbolInformation>>;

typedef ProvideCodeActionsSignature = (document:TextDocument, range:Range, context:CodeActionContext, token:CancellationToken) ->
	ProviderResult<Array<Command>>;

typedef ProvideCodeLensesSignature = (document:TextDocument, token:CancellationToken) -> ProviderResult<Array<CodeLens>>;

typedef ResolveCodeLensSignature = (codeLens:CodeLens, token:CancellationToken) -> ProviderResult<CodeLens>;

typedef ProvideDocumentFormattingEditsSignature = (document:TextDocument, options:FormattingOptions, token:CancellationToken) ->
	ProviderResult<Array<TextEdit>>;

typedef ProvideDocumentRangeFormattingEditsSignature = (document:TextDocument, range:Range, options:FormattingOptions, token:CancellationToken) ->
	ProviderResult<Array<TextEdit>>;

typedef ProvideOnTypeFormattingEditsSignature = (document:TextDocument, position:Position, ch:String, options:FormattingOptions, token:CancellationToken) ->
	ProviderResult<Array<TextEdit>>;

typedef ProvideRenameEditsSignature = (document:TextDocument, position:Position, newName:String, token:CancellationToken) -> ProviderResult<WorkspaceEdit>;

typedef ProvideDocumentLinksSignature = (document:TextDocument, token:CancellationToken) -> ProviderResult<Array<DocumentLink>>;

typedef ResolveDocumentLinkSignature = (link:DocumentLink, token:CancellationToken) -> ProviderResult<DocumentLink>;

typedef NextSignature<P, R> = (data:P, next:(data:P) -> R) -> R;

typedef DidChangeConfigurationSignature = (sections:Null<Array<String>>) -> Void;

typedef WorkspaceMiddleware = {
	?didChangeConfiguration:(sections:Null<Array<String>>, next:DidChangeConfigurationSignature) -> Void
}

/**
 * The Middleware lets extensions intercept the request and notications send and received
 * from the server
 */
typedef Middleware = {
	?didOpen:NextSignature<TextDocument, Void>,
	?didChange:NextSignature<TextDocumentChangeEvent, Void>,
	?willSave:NextSignature<TextDocumentWillSaveEvent, Void>,
	?willSaveWaitUntil:NextSignature<TextDocumentWillSaveEvent, Thenable<Array<TextEdit>>>,
	?didSave:NextSignature<TextDocument, Void>,
	?didClose:NextSignature<TextDocument, Void>,
	?handleDiagnostics:(uri:Uri, diagnostics:Array<Diagnostic>, next:HandleDiagnosticsSignature) -> Void,
	?provideCompletionItem:(document:TextDocument, position:Position, context:CompletionContext, token:CancellationToken,
			next:ProvideCompletionItemsSignature) -> ProviderResult<EitherType<Array<CompletionItem>, CompletionList>>,
	?resolveCompletionItem:(item:CompletionItem, token:CancellationToken, next:ResolveCompletionItemSignature) -> ProviderResult<CompletionItem>,
	?provideHover:(document:TextDocument, position:Position, token:CancellationToken, next:ProvideHoverSignature) -> ProviderResult<Hover>,
	?provideSignatureHelp:(document:TextDocument, position:Position, token:CancellationToken, next:ProvideSignatureHelpSignature) ->
		ProviderResult<SignatureHelp>,
	?provideDefinition:(document:TextDocument, position:Position, token:CancellationToken, next:ProvideDefinitionSignature) -> ProviderResult<Definition>,
	?provideReferences:(document:TextDocument, position:Position, options:{includeDeclaration:Bool}, token:CancellationToken, next:ProvideReferencesSignature) ->
		ProviderResult<Array<Location>>,
	?provideDocumentHighlights:(document:TextDocument, position:Position, token:CancellationToken, next:ProvideDocumentHighlightsSignature) ->
		ProviderResult<Array<DocumentHighlight>>,
	?provideDocumentSymbols:(document:TextDocument, token:CancellationToken, next:ProvideDocumentSymbolsSignature) -> ProviderResult<Array<SymbolInformation>>,
	?provideWorkspaceSymbols:(query:String, token:CancellationToken, next:ProvideWorkspaceSymbolsSignature) -> ProviderResult<Array<SymbolInformation>>,
	?provideCodeActions:(document:TextDocument, range:Range, context:CodeActionContext, token:CancellationToken, next:ProvideCodeActionsSignature) ->
		ProviderResult<Array<Command>>,
	?provideCodeLenses:(document:TextDocument, token:CancellationToken, next:ProvideCodeLensesSignature) -> ProviderResult<Array<CodeLens>>,
	?resolveCodeLens:(codeLens:CodeLens, token:CancellationToken, next:ResolveCodeLensSignature) -> ProviderResult<CodeLens>,
	?provideDocumentFormattingEdits:(document:TextDocument, options:FormattingOptions, token:CancellationToken, next:ProvideDocumentFormattingEditsSignature) ->
		ProviderResult<Array<TextEdit>>,
	?provideDocumentRangeFormattingEdits:(document:TextDocument, range:Range, options:FormattingOptions, token:CancellationToken,
			next:ProvideDocumentRangeFormattingEditsSignature) -> ProviderResult<Array<TextEdit>>,
	?provideOnTypeFormattingEdits:(document:TextDocument, position:Position, ch:String, options:FormattingOptions, token:CancellationToken,
			next:ProvideOnTypeFormattingEditsSignature) -> ProviderResult<Array<TextEdit>>,
	?provideRenameEdits:(document:TextDocument, position:Position, newName:String, token:CancellationToken, next:ProvideRenameEditsSignature) ->
		ProviderResult<WorkspaceEdit>,
	?provideDocumentLinks:(document:TextDocument, token:CancellationToken, next:ProvideDocumentLinksSignature) -> ProviderResult<Array<DocumentLink>>,
	?resolveDocumentLink:(link:DocumentLink, token:CancellationToken, next:ResolveDocumentLinkSignature) -> ProviderResult<DocumentLink>,
	?workspace:WorkspaceMiddleware
}

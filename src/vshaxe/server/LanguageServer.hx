package vshaxe.server;

import js.Promise;
import jsonrpc.Types;
import vshaxe.display.DisplayArguments;
import vshaxe.helper.HaxeExecutable;
import vshaxe.server.LanguageClient;
import haxeLanguageServer.LanguageServerMethods;
import haxeLanguageServer.Configuration.DisplayServerConfig;
import haxeLanguageServer.protocol.Protocol.Response;
import haxeLanguageServer.protocol.Protocol.HaxeRequestMethod;
import languageServerProtocol.Types.DocumentUri;

class LanguageServer {
	public var displayPort(default, null):Null<Int>;
	public var onDidRunHaxeMethod(get, never):Event<HaxeMethodResult>;
	public var onDidChangeRequestQueue(get, never):Event<Array<String>>;
	public var client(default, null):Null<LanguageClient>;

	final folder:WorkspaceFolder;
	final context:ExtensionContext;
	final haxeExecutable:HaxeExecutable;
	final displayArguments:DisplayArguments;
	final api:Vshaxe;
	final serverModulePath:String;
	final hxFileWatcher:FileSystemWatcher;
	final disposables:Array<{function dispose():Void;}>;
	var restartDisposables:Array<{function dispose():Void;}>;
	var progresses = new Map<Int, Void->Void>();
	var displayServerConfig:DisplayServerConfig;
	var displayServerConfigSerialized:Null<String>;
	final _onDidRunHaxeMethod = new EventEmitter<HaxeMethodResult>();

	inline function get_onDidRunHaxeMethod()
		return _onDidRunHaxeMethod.event;

	final _onDidChangeRequestQueue = new EventEmitter<Array<String>>();

	inline function get_onDidChangeRequestQueue()
		return _onDidChangeRequestQueue.event;

	public function new(folder:WorkspaceFolder, context:ExtensionContext, haxeExecutable:HaxeExecutable, displayArguments:DisplayArguments, api:Vshaxe) {
		this.folder = folder;
		this.context = context;
		this.displayArguments = displayArguments;
		this.haxeExecutable = haxeExecutable;
		this.api = api;

		serverModulePath = context.asAbsolutePath("./server_wrapper.js");
		hxFileWatcher = workspace.createFileSystemWatcher(new RelativePattern(folder, "**/*.hx"), false, true, false);

		inline prepareDisplayServerConfig();

		restartDisposables = [];
		disposables = [
			hxFileWatcher,
			workspace.onDidChangeConfiguration(_ -> refreshDisplayServerConfig()),
			haxeExecutable.onDidChangeConfiguration(_ -> refreshDisplayServerConfig()),
			window.onDidChangeActiveTextEditor(onDidChangeActiveTextEditor),
		];
	}

	public function dispose() {
		for (d in restartDisposables)
			d.dispose();
		for (d in disposables)
			d.dispose();
	}

	function sendNotification<P>(method:NotificationMethod<P>, ?params:P) {
		if (client != null) {
			if (params == null) {
				client.sendNotification(method);
			} else {
				client.sendNotification(method, params);
			}
		}
	}

	public function sendRequest<P, R>(method:RequestMethod<P, R, NoData>, params:P):Thenable<R> {
		return if (client != null) {
			client.sendRequest(method, params);
		} else {
			Promise.reject("client not initialized");
		}
	}

	function onNotification<P>(method:NotificationMethod<P>, handler:(params:P) -> Void) {
		if (client != null)
			client.onNotification(method, handler);
	}

	function refreshDisplayServerConfig() {
		if (prepareDisplayServerConfig())
			sendNotification(LanguageServerMethods.DidChangeDisplayServerConfig, displayServerConfig);
	}

	function onDidChangeActiveTextEditor(editor:Null<TextEditor>) {
		if (editor != null && editor.document.languageId == "haxe")
			sendNotification(LanguageServerMethods.DidChangeActiveTextEditor, {uri: new DocumentUri(editor.document.uri.toString())});
	}

	public function start() {
		var serverOptions = {
			run: {module: serverModulePath, options: {env: js.Node.process.env}},
			debug: {module: serverModulePath, options: {env: js.Node.process.env, execArgv: ["--nolazy", "--inspect=6504"]}}
		};
		var clientOptions:LanguageClientOptions = {
			documentSelector: [{scheme: "file", language: "haxe"}, {scheme: "untitled", language: "haxe"}],
			synchronize: {
				configurationSection: "haxe",
				fileEvents: hxFileWatcher
			},
			initializationOptions: {
				displayArguments: displayArguments.arguments,
				displayServerConfig: displayServerConfig,
				sendMethodResults: true
			},
			revealOutputChannelOn: Never,
			workspaceFolder: folder,
			middleware: {
				// TODO: remove this once vscode-languageclient supports CodeAction.isPreferred
				provideCodeActions: (document, range, context, token, next) -> {
					var result = next(document, range, context, token);
					function handle(result:Array<CodeAction>) {
						for (action in result) {
							if (action.kind == CodeActionKind.QuickFix) {
								action.isPreferred = true;
								action.title = "Yay";
								break;
							}
						}
					}
					return new Promise(function(resolve, reject) {
						if ((result is Array)) {
							handle(cast result);
							resolve(result);
						} else {
							var thenable:Thenable<Array<CodeAction>> = cast result;
							thenable.then(result -> {
								handle(result);
								resolve(cast result);
							});
						}
					});
				}
			}
		};

		var client = new LanguageClient("haxe", "Haxe", serverOptions, clientOptions);

		// If arguments change while we're starting language server we remember that fact
		// and send updated arguments once language server is ready. this can often happen on startup
		// due to asynchronous argument provider loading. I wonder if there's any way to handle this better...
		var argumentsChanged = false;
		var argumentChangeListenerDisposable = displayArguments.onDidChangeArguments(_ -> argumentsChanged = true);
		restartDisposables.push(argumentChangeListenerDisposable);

		client.onReady().then(function(_) {
			client.outputChannel.appendLine("Haxe language server started");

			restartDisposables.remove(argumentChangeListenerDisposable);
			argumentChangeListenerDisposable.dispose();

			if (argumentsChanged) {
				var arguments:Array<String> = [];
				if (displayArguments.arguments != null)
					arguments = displayArguments.arguments;
				sendNotification(LanguageServerMethods.DidChangeDisplayArguments, {arguments: arguments});
			}

			restartDisposables
				.push(displayArguments.onDidChangeArguments(arguments -> sendNotification(LanguageServerMethods.DidChangeDisplayArguments, {arguments: arguments})));

			restartDisposables.push(new PackageInserter(hxFileWatcher, this));

			onNotification(LanguageServerMethods.ProgressStart, onStartProgress);
			onNotification(LanguageServerMethods.ProgressStop, onStopProgress);
			onNotification(LanguageServerMethods.DidChangeDisplayPort, onDidChangeDisplayPort);
			onNotification(LanguageServerMethods.DidRunRunGlobalDiagnostics, onDidRunGlobalDiangostics);
			onNotification(LanguageServerMethods.DidRunHaxeMethod, onDidRunHaxeMethodCallback);
			onNotification(LanguageServerMethods.DidChangeRequestQueue, onDidChangeRequestQueueCallback);
			onNotification(LanguageServerMethods.CacheBuildFailed, onCacheBuildFailed);
			onNotification(LanguageServerMethods.DidDetectOldPreview, onDidDetectOldPreview);
			client.onDidChangeState(onDidChangeState);
		});

		restartDisposables.push(client.start());
		this.client = client;
	}

	/**
		Prepare new display server config and store it in `displayServerConfig` field.

		@return `true` if configuration was changed since last call
	**/
	function prepareDisplayServerConfig():Bool {
		var path = haxeExecutable.configuration.executable;
		var env = haxeExecutable.configuration.env;
		var haxeConfig = workspace.getConfiguration("haxe");
		var arguments = haxeConfig.get("displayServer.arguments", []);
		var print = haxeConfig.get("displayServer.print", {completion: false, reusing: false});
		if (!haxeExecutable.isConfigured()) {
			// apply legacy settings
			var displayServerConfig = haxeConfig.get("displayServer");
			function merge(conf:{?haxePath:String, ?env:haxe.DynamicAccess<String>}) {
				if (conf.haxePath != null)
					path = conf.haxePath;
				if (conf.env != null)
					env = conf.env;
			}
			if (displayServerConfig != null) {
				merge(displayServerConfig);
				var systemConfig = Reflect.field(displayServerConfig, HaxeExecutable.SYSTEM_KEY);
				if (systemConfig != null)
					merge(systemConfig);
			}
		}
		displayServerConfig = {
			path: path,
			env: env,
			arguments: arguments,
			print: print
		};
		var oldSerialized = displayServerConfigSerialized;
		displayServerConfigSerialized = haxe.Json.stringify(displayServerConfig);
		return displayServerConfigSerialized != oldSerialized;
	}

	function onStartProgress(data:{id:Int, title:String}) {
		window.withProgress({location: Window, title: data.title}, function(_, _) {
			return new js.Promise(function(resolve:Null<Any>->Void, _) {
				progresses[data.id] = function() resolve(null);
			});
		});
	}

	function onStopProgress(data:{id:Int}) {
		var stop = progresses[data.id];
		if (stop != null) {
			progresses.remove(data.id);
			stop();
		}
	}

	function onDidChangeDisplayPort(data:{port:Int}) {
		displayPort = data.port;
		var writeableApi:{?displayPort:Int} = cast api;
		writeableApi.displayPort = data.port;
	}

	public function restart() {
		if (client != null && client.outputChannel != null)
			client.outputChannel.dispose();

		for (d in restartDisposables)
			d.dispose();
		restartDisposables = [];

		stopAllProgresses();
		start();
	}

	function stopAllProgresses() {
		for (stop in progresses)
			stop();
		progresses = new Map();
	}

	public inline function runGlobalDiagnostics() {
		sendNotification(LanguageServerMethods.RunGlobalDiagnostics);
	}

	public function runMethod<P, R>(method:HaxeRequestMethod<P, Response<R>>, ?params:P):Thenable<R> {
		return sendRequest(LanguageServerMethods.RunMethod, {method: method, params: params});
	}

	function onDidRunGlobalDiangostics(_) {
		commands.executeCommand("workbench.action.problems.focus");
	}

	function onDidRunHaxeMethodCallback(data:HaxeMethodResult) {
		_onDidRunHaxeMethod.fire(data);
		#if debug
		commands.executeCommand("vshaxeDebugTools.methodResultsView.update", data);
		#end
	}

	function onDidChangeRequestQueueCallback(data:{queue:Array<String>}) {
		_onDidChangeRequestQueue.fire(data.queue);
	}

	inline static var ShowErrorOption = "Show Error";
	inline static var RetryOption = "Retry";

	function onCacheBuildFailed(_) {
		final message = "Unable to build cache - completion features may be slower than expected. Try fixing the error(s) and restarting the language server.";
		function showMessage(option1:String, option2:String) {
			window.showWarningMessage(message, option1, option2).then(function(selection) {
				if (selection == null) {
					return;
				}
				switch selection {
					case RetryOption:
						restart();
					case ShowErrorOption if (client != null):
						client.outputChannel.show();
						showMessage(RetryOption, js.Lib.undefined);
					case _:
				}
			});
		}
		showMessage(ShowErrorOption, RetryOption);
	}

	inline static var VisitDownloadPageOption = "Visit Donwload Page";
	inline static var DontShowAgainOption = "Don't Show Again";
	public static final DontShowOldPreviewHintAgainKey = new HaxeMementoKey<Bool>("dontShowRC1HintAgain");

	function onDidDetectOldPreview(?data:{preview:String}) {
		var globalState = context.globalState;
		if (globalState.get(DontShowOldPreviewHintAgainKey, false)) {
			return;
		}
		var detectedVersion = if (data == null) "" else ' (${data.preview})';
		final message = 'Old Haxe 4 preview build detected' + detectedVersion
			+ '. Consider upgrading to Haxe 4.0.0-rc.1 for improved completion features and stability.';
		window.showInformationMessage(message, VisitDownloadPageOption, DontShowAgainOption).then(function(selection) {
			if (selection == null) {
				return;
			}
			switch selection {
				case VisitDownloadPageOption:
					env.openExternal(Uri.parse("https://haxe.org/download/version/4.0.0-rc.1/"));
				case DontShowAgainOption:
					globalState.update(DontShowOldPreviewHintAgainKey, true);
				case _:
			}
		});
	}

	function onDidChangeState(event:StateChangeEvent) {
		if (event.newState == Stopped) {
			stopAllProgresses();
		}
	}
}

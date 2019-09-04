package vshaxe.server;

import haxe.extern.Rest;
import haxe.display.Protocol.Response;
import haxe.display.Protocol.HaxeRequestMethod;
import js.lib.Promise;
import jsonrpc.Types;
import vshaxe.display.DisplayArguments;
import vshaxe.configuration.HaxeInstallation;
import vshaxe.server.LanguageClient;
import haxeLanguageServer.LanguageServerMethods;
import haxeLanguageServer.Configuration.DisplayServerConfig;
import languageServerProtocol.Types.DocumentUri;

class LanguageServer {
	public var displayPort(default, null):Null<Int>;
	public var onDidRunMethod(get, never):Event<MethodResult>;
	public var onDidChangeRequestQueue(get, never):Event<Array<String>>;
	public var client(default, null):Null<LanguageClient>;

	final folder:WorkspaceFolder;
	final context:ExtensionContext;
	final haxeInstallation:HaxeInstallation;
	final displayArguments:DisplayArguments;
	final api:Vshaxe;
	final serverModulePath:String;
	final hxFileWatcher:FileSystemWatcher;
	final disposables:Array<{function dispose():Void;}>;
	var restartDisposables:Array<{function dispose():Void;}>;
	var queuedNotifications:Array<{method:NotificationType<Dynamic>, ?params:Dynamic}>;
	var clientStartingUp:Bool;
	var progresses = new Map<Int, Void->Void>();
	var displayServerConfig:DisplayServerConfig;
	var displayServerConfigSerialized:Null<String>;
	final _onDidRunMethod = new EventEmitter<MethodResult>();

	inline function get_onDidRunMethod()
		return _onDidRunMethod.event;

	final _onDidChangeRequestQueue = new EventEmitter<Array<String>>();

	inline function get_onDidChangeRequestQueue()
		return _onDidChangeRequestQueue.event;

	public function new(folder:WorkspaceFolder, context:ExtensionContext, haxeInstallation:HaxeInstallation, displayArguments:DisplayArguments, api:Vshaxe) {
		this.folder = folder;
		this.context = context;
		this.displayArguments = displayArguments;
		this.haxeInstallation = haxeInstallation;
		this.api = api;

		serverModulePath = context.asAbsolutePath("bin/server.js");
		hxFileWatcher = workspace.createFileSystemWatcher(new RelativePattern(folder, "**/*.hx"), false, true, false);

		inline prepareDisplayServerConfig();

		restartDisposables = [];
		queuedNotifications = [];
		clientStartingUp = false;
		disposables = [
			hxFileWatcher,
			workspace.onDidChangeConfiguration(_ -> refreshDisplayServerConfig(false)),
			haxeInstallation.haxe.onDidChangeConfiguration(_ -> refreshDisplayServerConfig(true)),
			window.onDidChangeActiveTextEditor(onDidChangeActiveTextEditor),
			displayArguments.onDidChangeArguments(arguments -> sendNotification(LanguageServerMethods.DidChangeDisplayArguments, {arguments: arguments}))
		];
	}

	public function dispose() {
		for (d in restartDisposables)
			d.dispose();
		for (d in disposables)
			d.dispose();
	}

	function sendNotification<P>(method:NotificationType<P>, ?params:P) {
		if (client == null) {
			return;
		}
		if (clientStartingUp) {
			queuedNotifications.push({method: method, params: params});
			return;
		}
		if (params == null) {
			client.sendNotification(method);
		} else {
			client.sendNotification(method, params);
		}
	}

	public function sendRequest<P, R>(method:RequestType<P, R, NoData>, params:P):Thenable<R> {
		return if (client != null) {
			client.sendRequest(method, params);
		} else {
			Promise.reject("client not initialized");
		}
	}

	function onNotification<P>(method:NotificationType<P>, handler:(params:P) -> Void) {
		if (client != null)
			client.onNotification(method, handler);
	}

	function refreshDisplayServerConfig(force:Bool) {
		if (prepareDisplayServerConfig() || force)
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
				haxelibConfig: {
					executable: haxeInstallation.haxelib.configuration
				},
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
		client.onReady().then(function(_) {
			client.outputChannel.appendLine("Haxe language server started");

			clientStartingUp = false;
			for (notification in queuedNotifications) {
				sendNotification(notification.method, notification.params);
			}
			queuedNotifications = [];

			restartDisposables.push(new PackageInserter(hxFileWatcher, this));

			onNotification(LanguageServerMethods.ProgressStart, onStartProgress);
			onNotification(LanguageServerMethods.ProgressStop, onStopProgress);
			onNotification(LanguageServerMethods.DidChangeDisplayPort, onDidChangeDisplayPort);
			onNotification(LanguageServerMethods.DidRunRunGlobalDiagnostics, onDidRunGlobalDiangostics);
			onNotification(LanguageServerMethods.DidRunMethod, onDidRunMethodCallback);
			onNotification(LanguageServerMethods.DidChangeRequestQueue, onDidChangeRequestQueueCallback);
			onNotification(LanguageServerMethods.CacheBuildFailed, onCacheBuildFailed);
			onNotification(LanguageServerMethods.HaxeKeepsCrashing, onHaxeKeepsCrashing);
			onNotification(LanguageServerMethods.DidDetectOldPreview, onDidDetectOldPreview);
			client.onDidChangeState(onDidChangeState);
		});

		clientStartingUp = true;
		restartDisposables.push(client.start());
		this.client = client;
	}

	/**
		Prepare new display server config and store it in `displayServerConfig` field.

		@return `true` if configuration was changed since last call
	**/
	function prepareDisplayServerConfig():Bool {
		var haxeExecutable = haxeInstallation.haxe;
		var path = haxeExecutable.configuration.executable;
		var env = haxeExecutable.configuration.env;
		var haxeConfig = workspace.getConfiguration("haxe");
		var arguments = haxeConfig.get("displayServer.arguments", []);
		var print = haxeConfig.get("displayServer.print", {completion: false, reusing: false});
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
			return new js.lib.Promise(function(resolve:Null<Any>->Void, _) {
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

	function onDidRunMethodCallback(data:MethodResult) {
		_onDidRunMethod.fire(data);
		#if debug
		commands.executeCommand("vshaxeDebugTools.methodResultsView.update", data);
		#end
	}

	function onDidChangeRequestQueueCallback(data:{queue:Array<String>}) {
		_onDidChangeRequestQueue.fire(data.queue);
	}

	function onCacheBuildFailed(_) {
		final message = "Unable to build cache - completion features may be slower than expected. Try fixing the error(s) and restarting the language server.";
		showRestartLanguageServerMessage(window.showWarningMessage, message);
	}

	function onHaxeKeepsCrashing(_) {
		showRestartLanguageServerMessage(window.showErrorMessage, "Haxe process has crashed 3 times, not attempting any more restarts.");
	}

	inline static var ShowErrorOption = "Show Error";
	inline static var RetryOption = "Retry";

	function showRestartLanguageServerMessage(method:(message:String, options:MessageOptions, items:Rest<String>) -> Thenable<Null<String>>, message:String) {
		function showMessage(option1:String, option2:String) {
			method(message, {}, option1, option2).then(function(selection) {
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

	inline static var VisitDownloadPageOption = "Visit Download Page";
	inline static var DontShowAgainOption = "Don't Show Again";
	public static final DontShowOldPreviewHintAgainKey = new HaxeMementoKey<Bool>("dontShowRC4HintAgain");

	function onDidDetectOldPreview(?data:{preview:String}) {
		var globalState = context.globalState;
		if (globalState.get(DontShowOldPreviewHintAgainKey, false)) {
			return;
		}
		var detectedVersion = if (data == null) "" else ' (${data.preview})';
		final message = 'Old Haxe 4 preview build detected'
			+ detectedVersion
			+ '. Consider upgrading to Haxe 4.0.0-rc.4 for improved completion features and stability.';
		window.showInformationMessage(message, VisitDownloadPageOption, DontShowAgainOption).then(function(selection) {
			switch selection {
				case null:
				case VisitDownloadPageOption:
					env.openExternal(Uri.parse("https://haxe.org/download/version/4.0.0-rc.4/"));
				case DontShowAgainOption:
					globalState.update(DontShowOldPreviewHintAgainKey, true);
			}
		});
	}

	function onDidChangeState(event:StateChangeEvent) {
		if (event.newState == Stopped) {
			stopAllProgresses();
		}
	}
}

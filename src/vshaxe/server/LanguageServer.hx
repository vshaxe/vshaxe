package vshaxe.server;

import haxe.display.Protocol.HaxeRequestMethod;
import haxe.display.Protocol.Response;
import haxe.extern.Rest;
import haxeLanguageServer.DisplayServerConfig;
import haxeLanguageServer.LanguageServerMethods;
import js.lib.Promise;
import jsonrpc.Types;
import languageServerProtocol.textdocument.TextDocument.DocumentUri;
import vshaxe.configuration.HaxeInstallation;
import vshaxe.display.DisplayArguments;
import vshaxe.server.LanguageClient;

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
			haxeInstallation.onDidChange(_ -> refreshDisplayServerConfig(true)),
			window.onDidChangeActiveTextEditor(onDidChangeActiveTextEditor),
			displayArguments.onDidChangeArguments(arguments -> sendNotification(LanguageServerMethods.DidChangeDisplayArguments, {
				arguments: arguments
			}))
		];
	}

	public function dispose() {
		for (d in restartDisposables) {
			d.dispose();
		}
		for (d in disposables) {
			d.dispose();
		}
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
		if (client != null) {
			client.onNotification(method, handler);
		}
	}

	function onRequest<P, R, E>(method:RequestType<P, R, E>, handler:(params:P) -> Thenable<R>) {
		if (client != null) {
			client.onRequest(method, handler);
		}
	}

	function refreshDisplayServerConfig(force:Bool) {
		if (prepareDisplayServerConfig() || force) {
			sendNotification(LanguageServerMethods.DidChangeDisplayServerConfig, displayServerConfig);
		}
	}

	function onDidChangeActiveTextEditor(editor:Null<TextEditor>) {
		if (editor != null && editor.document.languageId == "haxe") {
			sendNotification(LanguageServerMethods.DidChangeActiveTextEditor, {uri: new DocumentUri(editor.document.uri.toString())});
		}
	}

	public function start() {
		final serverOptions = {
			run: {module: serverModulePath, options: {env: js.Node.process.env}},
			debug: {module: serverModulePath, options: {env: js.Node.process.env, execArgv: ["--nolazy", "--inspect=6504"]}}
		};
		final clientOptions:LanguageClientOptions = {
			documentSelector: [
				{language: "haxe", scheme: "file"},
				{language: "haxe", scheme: "untitled"},
				{language: "hxml", scheme: "file"},
				{language: "hxml", scheme: "untitled"}
			],
			synchronize: {
				configurationSection: "haxe",
				fileEvents: hxFileWatcher
			},
			initializationOptions: {
				displayArguments: displayArguments.arguments,
				displayServerConfig: displayServerConfig,
				haxelibConfig: {
					executable: haxeInstallation.haxelib.configuration.executable
				},
				sendMethodResults: true
			},
			revealOutputChannelOn: Never,
			workspaceFolder: folder
		};

		final client = new LanguageClient("haxe", "Haxe", serverOptions, clientOptions);
		client.onReady().then(function(_) {
			client.outputChannel.appendLine("Haxe language server started");

			clientStartingUp = false;
			for (notification in queuedNotifications) {
				sendNotification(notification.method, notification.params);
			}
			queuedNotifications = [];

			restartDisposables.push(new PackageInserter(hxFileWatcher, this));

			onNotification(LanguageServerMethods.DidChangeDisplayPort, onDidChangeDisplayPort);
			onNotification(LanguageServerMethods.DidRunRunGlobalDiagnostics, onDidRunGlobalDiangostics);
			onNotification(LanguageServerMethods.DidRunMethod, onDidRunMethodCallback);
			onNotification(LanguageServerMethods.DidChangeRequestQueue, onDidChangeRequestQueueCallback);
			onNotification(LanguageServerMethods.CacheBuildFailed, onCacheBuildFailed);
			onNotification(LanguageServerMethods.HaxeKeepsCrashing, onHaxeKeepsCrashing);
			onNotification(LanguageServerMethods.DidDetectOldHaxeVersion, onDidDetectOldHaxeVersion);
			onRequest(LanguageServerMethods.ListLibraries, onListLibraries);
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
		final haxeExecutable = haxeInstallation.haxe;
		final path = haxeExecutable.configuration.executable;
		final env = haxeInstallation.env;
		final haxeConfig = workspace.getConfiguration("haxe");
		final arguments = haxeConfig.get("displayServer.arguments", []);
		final useSocket = haxeConfig.get("displayServer.useSocket", true);
		final print = haxeConfig.get("displayServer.print", {completion: false, reusing: false});
		displayServerConfig = {
			path: path,
			env: env,
			arguments: arguments,
			print: print,
			useSocket: useSocket
		};
		final oldSerialized = displayServerConfigSerialized;
		displayServerConfigSerialized = haxe.Json.stringify(displayServerConfig);
		return displayServerConfigSerialized != oldSerialized;
	}

	function onDidChangeDisplayPort(data:{port:Int}) {
		displayPort = data.port;
		final writeableApi:{?displayPort:Int} = cast api;
		writeableApi.displayPort = data.port;
	}

	public function restart() {
		if (client != null && client.outputChannel != null)
			client.outputChannel.dispose();

		for (d in restartDisposables)
			d.dispose();
		restartDisposables = [];

		start();
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

	inline static final ShowErrorOption = "Show Error";
	inline static final RetryOption = "Retry";

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

	inline static final VisitDownloadPageOption = "Visit Download Page";
	inline static final DontShowAgainOption = "Don't Show Again";
	public static final DontShowOldPreviewHintAgainKey = new HaxeMementoKey<Bool>("dontShowHaxe4HintAgain");

	function onDidDetectOldHaxeVersion(data:{haxe4Preview:Bool, version:String}) {
		final globalState = context.globalState;
		if (globalState.get(DontShowOldPreviewHintAgainKey, false)) {
			return;
		}
		final version = if (data.haxe4Preview) "a Haxe 4 preview build" else 'Haxe ${data.version}';
		var message = 'You are using $version. Consider upgrading to Haxe 4 for greatly improved completion features and stability.';
		if (!haxeInstallation.haxe.isDefault) {
			message += " Current Haxe executable is " + haxeInstallation.haxe.configuration.executable;
		}
		window.showInformationMessage(message, VisitDownloadPageOption, DontShowAgainOption).then(function(selection) {
			switch selection {
				case null:
				case VisitDownloadPageOption:
					env.openExternal(Uri.parse("https://haxe.org/download"));
				case DontShowAgainOption:
					globalState.update(DontShowOldPreviewHintAgainKey, true);
			}
		});
	}

	function onListLibraries(_):Thenable<Array<{name:String}>> {
		return new Promise(function(resolve, reject) {
			resolve(haxeInstallation.listLibraries());
		});
	}
}

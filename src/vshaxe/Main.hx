package vshaxe;

import js.lib.RegExp;
import vshaxe.commands.Commands;
import vshaxe.commands.InitProject;
import vshaxe.view.HaxeServerViewContainer;
import vshaxe.view.dependencies.DependencyTreeView;
import vshaxe.configuration.HaxeInstallation;
import vshaxe.display.DisplayArguments;
import vshaxe.display.DisplayArgumentsSelector;
import vshaxe.display.HaxeDisplayArgumentsProvider;
import vshaxe.helper.HxmlParser;
import vshaxe.helper.HaxeCodeLensProvider;
import vshaxe.server.LanguageServer;
import vshaxe.tasks.HaxeTaskProvider;
import vshaxe.tasks.HxmlTaskProvider;
import vshaxe.tasks.TaskConfiguration;

class Main {
	var api:Vshaxe;

	function new(context:ExtensionContext) {
		new InitProject(context);

		var folder = if (workspace.workspaceFolders == null) null else workspace.workspaceFolders[0];
		if (folder == null)
			return; // TODO: look into this - we could support _some_ nice functionality (e.g. std lib completion or --interp task)

		commands.executeCommand("setContext", "vshaxeActivated", true); // https://github.com/Microsoft/vscode/issues/10471

		var mementos = new WorkspaceMementos(context.workspaceState);

		var hxmlDiscovery = new HxmlDiscovery(folder, mementos);
		context.subscriptions.push(hxmlDiscovery);

		var displayArguments = new DisplayArguments(folder, mementos);
		context.subscriptions.push(displayArguments);

		var haxeInstallation = new HaxeInstallation(folder, mementos);
		context.subscriptions.push(haxeInstallation);

		var problemMatchers = ["$haxe-absolute", "$haxe", "$haxe-error", "$haxe-trace"];
		api = {
			haxeExecutable: haxeInstallation.haxe,
			enableCompilationServer: true,
			problemMatchers: problemMatchers.copy(),
			taskPresentation: {},
			registerDisplayArgumentsProvider: displayArguments.registerProvider,
			registerHaxeInstallationProvider: haxeInstallation.registerProvider,
			parseHxmlToArguments: HxmlParser.parseToArgs
		};

		var server = new LanguageServer(folder, context, haxeInstallation, displayArguments, api);
		context.subscriptions.push(server);

		new HaxeCodeLensProvider();
		new HaxeServerViewContainer(context, server);
		new DependencyTreeView(context, displayArguments, haxeInstallation);
		new EvalDebugger(displayArguments, haxeInstallation.haxe);
		new DisplayArgumentsSelector(context, displayArguments);
		var haxeDisplayArgumentsProvider = new HaxeDisplayArgumentsProvider(context, displayArguments, hxmlDiscovery);
		new Commands(context, server, haxeDisplayArgumentsProvider);
		new ExtensionRecommender(context, folder).run();

		var taskConfiguration = new TaskConfiguration(haxeInstallation.haxe, problemMatchers, server, api);
		new HxmlTaskProvider(taskConfiguration, hxmlDiscovery);
		new HaxeTaskProvider(taskConfiguration, displayArguments, haxeDisplayArgumentsProvider);
		setLanguageConfiguration();

		scheduleServerStart(displayArguments, haxeInstallation, server);
	}

	function scheduleServerStart(displayArguments:DisplayArguments, haxeInstallation:HaxeInstallation, server:LanguageServer) {
		// wait until we have the providers we need to avoid immediate server restarts
		var waitingForDisplayArguments = displayArguments.isWaitingForProvider();
		var waitingForInstallation = haxeInstallation.isWaitingForProvider();

		var serverStarted = false;
		var disposables = [];
		function maybeStartServer() {
			if (!waitingForInstallation && !waitingForDisplayArguments && !serverStarted) {
				disposables.iter(d -> d.dispose());
				serverStarted = true;
				server.start();
			}
		}
		if (waitingForDisplayArguments) {
			disposables.push(displayArguments.onDidChangeArguments(_ -> {
				waitingForDisplayArguments = false;
				maybeStartServer();
			}));
		}
		if (waitingForInstallation) {
			disposables.push(haxeInstallation.onDidChange(_ -> {
				waitingForInstallation = false;
				maybeStartServer();
			}));
		}

		// if there's no provider, just start a server anyway after 5 seconds
		haxe.Timer.delay(() -> {
			waitingForDisplayArguments = false;
			waitingForInstallation = false;
			maybeStartServer();
		}, 5000);

		// or maybe we're just ready right away
		maybeStartServer();
	}

	function setLanguageConfiguration():Void {
		// based on https://github.com/microsoft/vscode/blob/bb02817e2e549fd88710d0e0a0336b80648e90b5/extensions/typescript-language-features/src/features/languageConfiguration.ts#L15
		var defaultWordPattern = "(-?\\d*\\.\\d\\w*)|([^\\`\\~\\!\\@\\#\\%\\^\\&\\*\\(\\)\\-\\=\\+\\[\\{\\]\\}\\\\\\|\\;\\:\\'\\\"\\,\\.\\<\\>\\/\\?\\s]+)";
		var wordPattern = defaultWordPattern + "|(@:\\w*)"; // metadata
		languages.setLanguageConfiguration("haxe", {
			wordPattern: new RegExp(wordPattern),
			indentationRules: {
				decreaseIndentPattern: new RegExp("^((?!.*?\\/\\*).*\\*\\/)?\\s*[\\}\\]].*$"),
				increaseIndentPattern: new RegExp("^((?!\\/\\/).)*(\\{[^}\"'`]*|\\([^)\"'`]*|\\[[^\\]\"'`]*)$"),
				indentNextLinePattern: new RegExp("(^\\s*(for|while|do|if|else|try|catch)|function)\\b(?!.*[;{}]\\s*(\\/\\/.*|\\/[*].*[*]\\/\\s*)?$)")
			},
			onEnterRules: [
				{
					beforeText: new RegExp("^\\s*(\\bcase\\s.+:|\\bdefault:)$"),
					afterText: new RegExp("^(?!\\s*(\\bcase\\b|\\bdefault\\b))"),
					action: {indentAction: vscode.IndentAction.Indent},
				}
			]
		});
	}

	@:expose("activate")
	static function main(context:ExtensionContext) {
		return new Main(context).api;
	}
}

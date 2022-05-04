package vshaxe;

import vshaxe.commands.Commands;
import vshaxe.commands.InitProject;
import vshaxe.configuration.HaxeInstallation;
import vshaxe.display.DisplayArguments;
import vshaxe.display.DisplayArgumentsSelector;
import vshaxe.display.HaxeDisplayArgumentsProvider;
import vshaxe.helper.HaxeCodeLensProvider;
import vshaxe.helper.HaxeConfiguration;
import vshaxe.helper.HxmlParser;
import vshaxe.server.LanguageServer;
import vshaxe.tasks.HaxeTaskProvider;
import vshaxe.tasks.HxmlTaskProvider;
import vshaxe.tasks.TaskConfiguration;
import vshaxe.view.HaxeServerViewContainer;
import vshaxe.view.dependencies.DependencyTreeView;

@:expose("activate")
function main(context:ExtensionContext) {
	new InitProject(context);
	new AutoIndentation(context);

	final folder = if (workspace.workspaceFolders == null) null else workspace.workspaceFolders[0];
	if (folder == null)
		return js.Lib.undefined; // TODO: look into this - we could support _some_ nice functionality (e.g. std lib completion or --interp task)

	final mementos = new WorkspaceMementos(context.workspaceState);

	final hxmlDiscovery = new HxmlDiscovery(folder, mementos);
	context.subscriptions.push(hxmlDiscovery);

	final displayArguments = new DisplayArguments(folder, mementos);
	context.subscriptions.push(displayArguments);

	final haxeInstallation = new HaxeInstallation(folder, mementos);
	context.subscriptions.push(haxeInstallation);

	final haxeConfiguration = new HaxeConfiguration(context, folder, displayArguments, haxeInstallation);
	context.subscriptions.push(haxeConfiguration);

	ColorDecorations.init(context);

	final problemMatchers = ["$haxe-absolute", "$haxe", "$haxe-error", "$haxe-trace"];
	final api = {
		haxeExecutable: haxeInstallation.haxe,
		haxelibExecutable: haxeInstallation.haxelib.accessor,
		enableCompilationServer: true,
		problemMatchers: problemMatchers.copy(),
		taskPresentation: {},
		registerDisplayArgumentsProvider: displayArguments.registerProvider,
		registerHaxeInstallationProvider: haxeInstallation.registerProvider,
		parseHxmlToArguments: HxmlParser.parseToArgs,
		getActiveConfiguration: haxeConfiguration.getActiveConfiguration
	};

	final server = new LanguageServer(folder, context, haxeInstallation, displayArguments, api);
	context.subscriptions.push(server);

	new HaxeCodeLensProvider();
	new HaxeServerViewContainer(context, server);
	new DependencyTreeView(context, haxeConfiguration);
	new EvalDebugger(displayArguments, haxeInstallation.haxe);
	new DisplayArgumentsSelector(context, displayArguments);
	final haxeDisplayArgumentsProvider = new HaxeDisplayArgumentsProvider(context, displayArguments, hxmlDiscovery);
	new Commands(context, server, haxeDisplayArgumentsProvider);
	new ExtensionRecommender(context, folder).run();

	final taskConfiguration = new TaskConfiguration(haxeInstallation, problemMatchers, server, api);
	new HxmlTaskProvider(taskConfiguration, hxmlDiscovery);
	new HaxeTaskProvider(taskConfiguration, displayArguments, haxeDisplayArgumentsProvider);

	scheduleStartup(displayArguments, haxeInstallation, server);
	return api;
}

private function scheduleStartup(displayArguments:DisplayArguments, haxeInstallation:HaxeInstallation, server:LanguageServer) {
	// wait until we have the providers we need to avoid immediate server restarts
	var waitingForDisplayArguments = displayArguments.isWaitingForProvider();
	var waitingForInstallation = haxeInstallation.isWaitingForProvider();
	var haxeFileOpened = false;

	var started = false;
	final disposables = [];
	function maybeStartServer() {
		if (!waitingForInstallation && (!waitingForDisplayArguments || haxeFileOpened) && !started) {
			disposables.iter(d -> d.dispose());
			started = true;
			commands.executeCommand("setContext", "vshaxeActivated", true);
			server.start();
		}
	}
	if (waitingForDisplayArguments) {
		disposables.push(displayArguments.onDidChangeArguments(_ -> {
			waitingForDisplayArguments = false;
			maybeStartServer();
		}));

		function onDocument(document) {
			if (document.languageId == "haxe") {
				haxeFileOpened = true;
				maybeStartServer();
			}
		}
		function onActiveEditor(editor:Null<TextEditor>) {
			if (editor != null) {
				onDocument(editor.document);
			}
		}
		disposables.push(workspace.onDidOpenTextDocument(onDocument));
		disposables.push(window.onDidChangeActiveTextEditor(onActiveEditor));
		onActiveEditor(window.activeTextEditor);
	}
	if (waitingForInstallation) {
		disposables.push(haxeInstallation.onDidChange(_ -> {
			waitingForInstallation = false;
			maybeStartServer();
		}));
	}

	// maybe we're ready right away
	maybeStartServer();
}

package vshaxe;

import vshaxe.commands.Commands;
import vshaxe.commands.InitProject;
import vshaxe.view.dependencies.DependencyTreeView;
import vshaxe.view.methods.MethodTreeView;
import vshaxe.display.DisplayArguments;
import vshaxe.display.DisplayArgumentsSelector;
import vshaxe.display.HaxeDisplayArgumentsProvider;
import vshaxe.helper.HxmlParser;
import vshaxe.helper.HaxeCodeLensProvider;
import vshaxe.helper.HaxeExecutable;
import vshaxe.server.LanguageServer;
import vshaxe.tasks.HaxeTaskProvider;
import vshaxe.tasks.HxmlTaskProvider;
import vshaxe.tasks.TaskConfiguration;

class Main {
	var api:Vshaxe;

	function new(context:ExtensionContext) {
		new InitProject(context);

		var wsFolder = if (workspace.workspaceFolders == null) null else workspace.workspaceFolders[0];
		if (wsFolder == null)
			return; // TODO: look into this - we could support _some_ nice functionality (e.g. std lib completion or --interp task)

		commands.executeCommand("setContext", "vshaxeActivated", true); // https://github.com/Microsoft/vscode/issues/10471

		var wsMementos = new WorkspaceMementos(context.workspaceState);

		var hxmlDiscovery = new HxmlDiscovery(wsFolder, wsMementos);
		context.subscriptions.push(hxmlDiscovery);

		var displayArguments = new DisplayArguments(wsFolder, wsMementos);
		context.subscriptions.push(displayArguments);

		var haxeExecutable = new HaxeExecutable(wsFolder);
		context.subscriptions.push(haxeExecutable);

		var problemMatchers = ["$haxe-absolute", "$haxe", "$haxe-error", "$haxe-trace"];
		api = {
			haxeExecutable: haxeExecutable,
			enableCompilationServer: true,
			problemMatchers: problemMatchers.copy(),
			taskPresentation: {},
			registerDisplayArgumentsProvider: displayArguments.registerProvider,
			parseHxmlToArguments: HxmlParser.parseToArgs
		};

		var server = new LanguageServer(wsFolder, context, haxeExecutable, displayArguments, api);
		context.subscriptions.push(server);

		new HaxeCodeLensProvider();
		new DependencyTreeView(context, displayArguments, haxeExecutable);
		new MethodTreeView(context, server);
		new DisplayArgumentsSelector(context, displayArguments);
		var haxeDisplayArgumentsProvider = new HaxeDisplayArgumentsProvider(context, displayArguments, hxmlDiscovery);
		new Commands(context, server, haxeDisplayArgumentsProvider);

		var taskConfiguration = new TaskConfiguration(haxeExecutable, problemMatchers, server, api);
		new HxmlTaskProvider(taskConfiguration, hxmlDiscovery);
		new HaxeTaskProvider(taskConfiguration, displayArguments, haxeDisplayArgumentsProvider);

		// wait until we have display arguments before starting the server
		if (displayArguments.arguments == null) {
			var serverStarted = false;
			var disposable:Disposable;
			disposable = displayArguments.onDidChangeArguments(arguments -> {
				disposable.dispose();
				server.start();
				serverStarted = true;
			});
			// if there's no provider, just start a server anyway after 5 seconds
			haxe.Timer.delay(() -> {
				if (!serverStarted) {
					disposable.dispose();
					server.start();
				}
			}, 5000);
		} else {
			server.start();
		}
	}

	@:keep
	@:expose("activate")
	static function main(context:ExtensionContext) {
		return new Main(context).api;
	}
}

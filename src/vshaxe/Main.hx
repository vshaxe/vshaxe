package vshaxe;

import vshaxe.commands.Commands;
import vshaxe.commands.InitProject;
import vshaxe.dependencyExplorer.DependencyExplorer;
import vshaxe.display.DisplayArguments;
import vshaxe.display.DisplayArgumentsSelector;
import vshaxe.display.HaxeDisplayArgumentsProvider;
import vshaxe.helper.HxmlParser;
import vshaxe.helper.HaxeExecutable;
import vshaxe.server.LanguageServer;
import vshaxe.tasks.HxmlTaskProvider;

class Main {
    var api:Vshaxe;

    function new(context:ExtensionContext) {
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

        api = {
            haxeExecutable: haxeExecutable,
            registerDisplayArgumentsProvider: displayArguments.registerProvider,
            parseHxmlToArguments: HxmlParser.parseToArgs
        };

        var server = new LanguageServer(wsFolder, context, haxeExecutable, displayArguments);
        context.subscriptions.push(server);

        new Commands(context, server);
        new InitProject(context);
        new DependencyExplorer(context, displayArguments, haxeExecutable);
        new DisplayArgumentsSelector(context, displayArguments);
        new HaxeDisplayArgumentsProvider(context, displayArguments, hxmlDiscovery);
        new HxmlTaskProvider(hxmlDiscovery, haxeExecutable);

        server.start();
    }

    @:keep
    @:expose("activate")
    static function main(context:ExtensionContext) {
        return new Main(context).api;
    }
}

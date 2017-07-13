package vshaxe;

import vshaxe.commands.Commands;
import vshaxe.commands.InitProject;
import vshaxe.dependencyExplorer.DependencyExplorer;
import vshaxe.display.DisplayArguments;
import vshaxe.display.HaxeDisplayArgumentsProvider;
import vshaxe.helper.HxmlParser;
import vshaxe.server.LanguageServer;
import vshaxe.tasks.HxmlTaskProvider;

class Main {
    var api:Vshaxe;

    function new(context:ExtensionContext) {
        var displayArguments = new DisplayArguments(context);
        api = {
            registerDisplayArgumentsProvider: displayArguments.registerProvider,
            parseHxmlToArguments: HxmlParser.parseToArgs
        };

        var server = new LanguageServer(context, displayArguments);
        new Commands(context, server);
        new InitProject(context);
        new DependencyExplorer(context, displayArguments);
        var hxmlDiscovery = new HxmlDiscovery(context);
        new HaxeDisplayArgumentsProvider(context, api, hxmlDiscovery);
        new HxmlTaskProvider(hxmlDiscovery);

        server.start();
    }

    @:keep
    @:expose("activate")
    static function main(context:ExtensionContext) {
        return new Main(context).api;
    }
}

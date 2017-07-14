package vshaxe;

import vshaxe.commands.Commands;
import vshaxe.commands.InitProject;
import vshaxe.dependencyExplorer.DependencyExplorer;
import vshaxe.display.DisplayArguments;
import vshaxe.display.HaxeDisplayArgumentsProvider;
import vshaxe.helper.HxmlParser;
import vshaxe.helper.HaxeExecutable;
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

        var haxeExecutable = new HaxeExecutable(context);
        var server = new LanguageServer(context, haxeExecutable, displayArguments);
        new Commands(context, server);
        new InitProject(context);
        new DependencyExplorer(context, displayArguments, haxeExecutable);
        var hxmlDiscovery = new HxmlDiscovery(context);
        new HaxeDisplayArgumentsProvider(context, api, hxmlDiscovery);
        new HxmlTaskProvider(hxmlDiscovery, haxeExecutable);

        server.start();
    }

    @:keep
    @:expose("activate")
    static function main(context:ExtensionContext) {
        return new Main(context).api;
    }
}

package vshaxe;

import vshaxe.commands.Commands;
import vshaxe.dependencyExplorer.DependencyExplorer;
import vshaxe.display.DisplayArguments;
import vshaxe.display.DisplayConfiguration;
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
        new DisplayConfiguration(context, api);
        new DependencyExplorer(context, displayArguments);
        new Commands(context, server);
        new HxmlTaskProvider(context);

        setLanguageConfiguration();
        server.start();
    }

    function setLanguageConfiguration() {
        var defaultWordPattern = "(-?\\d*\\.\\d\\w*)|([^\\`\\~\\!\\@\\#\\%\\^\\&\\*\\(\\)\\-\\=\\+\\[\\{\\]\\}\\\\\\|\\;\\:\\'\\\"\\,\\.\\<\\>\\/\\?\\s]+)";
        var wordPattern = defaultWordPattern + "|(@:\\w*)"; // metadata
        languages.setLanguageConfiguration("Haxe", {wordPattern: new js.RegExp(wordPattern)});
    }

    @:keep
    @:expose("activate")
    static function main(context:ExtensionContext) {
        return new Main(context).api;
    }
}

package vshaxe;

import vshaxe.dependencyExplorer.DependencyExplorer;

class Main {
    var api:Vshaxe;

    function new(context:ExtensionContext) {
        new InitProject(context);

        var displayArguments = new DisplayArguments(context);
        displayArguments.registerProvider("settings", new DisplayConfiguration(context));

        var server = new LanguageServer(context, displayArguments);

        new DependencyExplorer(context, displayArguments);
        new Commands(context, server);
        new HxmlTaskProvider(context);

        api = {
            registerDisplayArgumentsProvider: displayArguments.registerProvider,
            parseHxmlToArguments: vshaxe.dependencyExplorer.HxmlParser.parseToArgs
        };

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

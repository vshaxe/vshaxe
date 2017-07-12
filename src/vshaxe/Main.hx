package vshaxe;

import Vscode.*;
import vscode.*;
import vshaxe.dependencyExplorer.DependencyExplorer;

// TODO: move elsewhere, rename and document
private typedef Api = {
    public function registerDisplayArgumentsProvider(name:String, provider:DisplayArgumentsProvider):Disposable;
}

class Main {
    var api:Api;

    function new(context:ExtensionContext) {
        new InitProject(context);

        var displayArguments = new DisplayArguments(context);
        displayArguments.registerProvider("settings", new DisplayConfiguration(context));

        var server = new LanguageServer(context, displayArguments);

        new DependencyExplorer(context, displayArguments);
        new Commands(context, server);
        new HxmlTaskProvider(context);

        api = {
            registerDisplayArgumentsProvider: displayArguments.registerProvider
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

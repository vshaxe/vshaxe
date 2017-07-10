package vshaxe;

import vshaxe.api.VshaxeAPI;
import Vscode.*;
import vscode.*;

class Main {
    public static var api:VshaxeAPI;
    public static var instance:Main;

    public var server:LanguageServer;

    function new(context:ExtensionContext) {
        new InitProject(context);
        server = new LanguageServer(context, api.onReady);
        new Commands(context, server);

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
        api = new VshaxeAPI();
        init(context);
        return api;
    }

    static function init(context:ExtensionContext) {
        instance = new Main(context);
    }
}
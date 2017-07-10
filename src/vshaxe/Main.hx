package vshaxe;

import js.Promise;
import Vscode.*;
import vscode.*;

class Main {
    public static var instance:Main;
    public var server:LanguageServer;

    function new(context:ExtensionContext, ?onReadyCallback) {
        new InitProject(context);
        server = new LanguageServer(context, onReadyCallback);
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
        var api = new Api();
        init(context, api);
        return api;
    }

    static function init(context:ExtensionContext, api:Api) {
        instance = new Main(context, api.onReady);
    }
}

@:allow(vshaxe)
@:keep class Api {
    private var isReady:Bool;
    private var resolvePromise:Array<Api->Void>;

    private function new() {}

    public function onReady():Promise<Api> {
        if (!isReady) {
            isReady = (Main.instance != null && Main.instance.server.isReady);
        }
        if (isReady) {
            if (resolvePromise != null) {
                for (resolve in resolvePromise) {
                    resolve(this);
                }
                resolvePromise = null;
            }
            return Promise.resolve(this);
        } else {
            resolvePromise = [];
            var promise = new Promise(function (resolve, reject) {
                resolvePromise.push (resolve);
            });
            return promise;
        }
    }

    public function updateDisplayArguments(args:Array<String>):Void {
        if (isReady) {
            Main.instance.server.updateDisplayArguments(args);
        }
    }
}
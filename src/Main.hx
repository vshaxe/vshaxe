import haxe.extern.EitherType;
import js.node.ChildProcess;

class Main {
    @:keep
    @:expose("activate")
    static function main(context:ExtensionContext) {
        var serverModule = context.asAbsolutePath("bin/server.js");
        // var serverOptions = {
        //     run: {module: serverModule},
        //     debug: {module: serverModule, options: {execArgv: ["--nolazy", "--debug=6004"]}}
        // };
        var serverOptions = cast {
            command: "node",
            args: [serverModule],
        };
        var clientOptions = {
            documentSelector: "haxe",
            synchronize: {
                configurationSection: "haxe"
            }
        };

        var disposable = null;

        inline function start() {
            var client = new LanguageClient("Haxe", serverOptions, clientOptions);
            disposable = client.start();
            context.subscriptions.push(disposable);
        }

        start();

        context.subscriptions.push(Vscode.commands.registerCommand("haxe.restartLanguageServer", function() {
            if (disposable != null) {
                context.subscriptions.remove(disposable);
                disposable.dispose();
            }
            start();
        }));
    }
}

@:jsRequire("vscode")
extern class Vscode {
    static var commands(default,never):VscodeCommands;
    static var window(default,never):VscodeWindow;
}

extern class VscodeCommands {
    function registerCommand(command:String, callback:Void->Void):Disposable;
}

extern class VscodeWindow {
    function showInformationMessage(message:String, items:haxe.extern.Rest<String>):js.Promise.Thenable<String>;
    function createOutputChannel(name:String):OutputChannel;
}

extern class OutputChannel {
    function append(value:String):Void;
    function appendLine(value:String):Void;
}

@:enum abstract TransportKind(Int) {
    var stdio = 0;
    var ipc = 1;
}

typedef NodeModule = {
    var module:String;
    @:optional var transport:TransportKind;
    @:optional var args:Array<String>;
    @:optional var options:ChildProcessForkOptions;
}

typedef ServerOptions = {
    run: NodeModule,
    debug: NodeModule,
}

typedef LanguageClientOptions = {
    @:optional var documentSelector:EitherType<String,Array<String>>;
    @:optional var synchronize:SynchronizeOptions;
    @:optional var diagnosticCollectionName:String;
    @:optional var initializationOptions:Dynamic;
}

typedef SynchronizeOptions = {
    @:optional var configurationSection:EitherType<String,Array<String>>;
    @:optional var fileEvents:EitherType<FileSystemWatcher,Array<FileSystemWatcher>>;
    @:optional var textDocumentFilter:TextDocument->Bool;
}

@:jsRequire("vscode-languageclient", "LanguageClient")
extern class LanguageClient {
    function new(name:String, serverOptions:ServerOptions, languageOptions:LanguageClientOptions, ?forceDebug:Bool);
    function start():Disposable;
    function stop():Void;
    function onNotification(type:{method:String}, handler:Dynamic->Void):Void;
}

typedef Disposable = {
    function dispose():Void;
}

extern class ExtensionContext {
    function asAbsolutePath(path:String):String;
    var subscriptions:Array<Disposable>;
}

extern class TextDocument {}
extern class FileSystemWatcher {}


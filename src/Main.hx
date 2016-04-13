import haxe.extern.EitherType;
import js.node.ChildProcess;

class Main {
    @:expose("activate")
    static function main(context:ExtensionContext) {
        var serverModule = context.asAbsolutePath("bin/server.js");
        var serverOptions = {module: serverModule};
        var clientOptions = {
            documentSelector: "haxe"
        };
        var client = new LanguageClient("Haxe", serverOptions, clientOptions);
        context.subscriptions.push(client.start());
    }
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

typedef ServerOptions = NodeModule;

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


import haxe.extern.EitherType;
import js.node.ChildProcess;
import js.node.Fs;

class Main {
    var context:ExtensionContext;
    var serverDisposable:Disposable;

    function new(ctx) {
        context = ctx;
        context.subscriptions.push(Vscode.commands.registerCommand("haxe.restartLanguageServer", restartLanguageServer));
        context.subscriptions.push(Vscode.commands.registerCommand("haxe.scaffoldProject", scaffoldProject));
        startLanguageServer();
    }

    function startLanguageServer() {
        var serverModule = context.asAbsolutePath("./server_wrapper.js");
        var serverOptions = {
            run: {module: serverModule},
            debug: {module: serverModule, options: {execArgv: ["--nolazy", "--debug=6004"]}}
        };
        var clientOptions = {
            documentSelector: "haxe",
            synchronize: {
                configurationSection: "haxe"
            }
        };
        var client = new LanguageClient("Haxe", serverOptions, clientOptions);
        client.onReady().then(function(_) {
            Vscode.window.setStatusBarMessage("Haxe language server started", 2000);
        });
        serverDisposable = client.start();
        context.subscriptions.push(serverDisposable);
    }

    function restartLanguageServer() {
        if (serverDisposable != null) {
            context.subscriptions.remove(serverDisposable);
            serverDisposable.dispose();
        }
        startLanguageServer();
    }

    function scaffoldProject() {
        var workspaceRoot = Vscode.workspace.rootPath;
        if (Fs.readdirSync(workspaceRoot).length > 0) {
            Vscode.window.showErrorMessage("Workspace must be empty to scaffold a Haxe project");
            return;
        }
        var scaffoldSource = context.asAbsolutePath("./scaffold");
        function copy(from, to) {
            var fromPath = scaffoldSource + from;
            var toPath = workspaceRoot + to;
            if (sys.FileSystem.isDirectory(fromPath)) {
                sys.FileSystem.createDirectory(toPath);
                for (file in sys.FileSystem.readDirectory(fromPath))
                    copy(from + "/" + file, to + "/" + file);
            } else {
                sys.io.File.copy(fromPath, toPath);
            }
        }
        copy("", "");
        Vscode.window.setStatusBarMessage("Haxe project scaffolded", 2000);
    }

    @:keep
    @:expose("activate")
    static function main(context:ExtensionContext) {
        new Main(context);
    }
}

@:jsRequire("vscode")
extern class Vscode {
    static var commands(default,never):VscodeCommands;
    static var window(default,never):VscodeWindow;
    static var workspace(default,never):VscodeWorkspace;
}

extern class VscodeCommands {
    function registerCommand(command:String, callback:Void->Void):Disposable;
}

extern class VscodeWindow {
    function showInformationMessage(message:String, items:haxe.extern.Rest<String>):js.Promise.Thenable<String>;
    function showErrorMessage(message:String, items:haxe.extern.Rest<String>):js.Promise.Thenable<String>;
    function setStatusBarMessage(text:String, ?hideAfterTimeout:Int):Disposable;
    function createOutputChannel(name:String):OutputChannel;
}

extern class VscodeWorkspace {
    var rootPath(default,never):String;
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
    function onReady():js.Promise<Void>;
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


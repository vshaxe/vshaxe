package vshaxe.server;

import vshaxe.display.DisplayArguments;
import vshaxe.helper.HaxeExecutable;

class LanguageServer {
    var context:ExtensionContext;
    var disposable:Disposable;
    var hxFileWatcher:FileSystemWatcher;
    var haxeExecutable:HaxeExecutable;
    var displayArguments:DisplayArguments;

    public var client(default,null):LanguageClient;

    public function new(context:ExtensionContext, haxeExecutable:HaxeExecutable, displayArguments:DisplayArguments) {
        this.context = context;
        this.displayArguments = displayArguments;
        this.haxeExecutable = haxeExecutable;
        context.subscriptions.push(window.onDidChangeActiveTextEditor(onDidChangeActiveTextEditor));
    }

    function onDidChangeActiveTextEditor(editor:TextEditor) {
        if (editor != null && editor.document.languageId == "haxe")
            client.sendNotification({method: "vshaxe/didChangeActiveTextEditor"}, {uri: editor.document.uri.toString()});
    }

    public function start() {
        var serverModule = context.asAbsolutePath("./server_wrapper.js");
        var serverOptions = {
            run: {module: serverModule, options: {env: js.Node.process.env}},
            debug: {module: serverModule, options: {env: js.Node.process.env, execArgv: ["--nolazy", "--debug=6004"]}}
        };
        hxFileWatcher = workspace.createFileSystemWatcher("**/*.hx", false, true, false);
        var clientOptions = {
            documentSelector: "haxe",
            synchronize: {
                configurationSection: "haxe",
                fileEvents: hxFileWatcher
            },
            initializationOptions: {
                displayArguments: displayArguments.arguments,
                displayServerConfig: prepareDisplayServerConfig(),
            }
        };
        client = new LanguageClient("haxe", "Haxe", serverOptions, clientOptions);
        client.logFailedRequest = function(type, error) {
            client.warn('Request ${type.method} failed.', error);
        };

        // If arguments change while we're starting language server we remember that fact
        // and send updated arguments once language server is ready. this can often happen on startup
        // due to asynchronous argument provider loading. I wonder if there's any way to handle this better...
        var argumentsChanged = false;
        var argumentChangeListenerDisposable = displayArguments.onDidChangeArguments(_ -> argumentsChanged = true);

        var executableChangeListenerDisposable = null; // TODO: technically exec config can change while server is starting, but meh...

        client.onReady().then(function(_) {
            client.outputChannel.appendLine("Haxe language server started");
            argumentChangeListenerDisposable.dispose();
            if (argumentsChanged)
                client.sendNotification({method: "vshaxe/didChangeDisplayArguments"}, {arguments: displayArguments.arguments});
            argumentChangeListenerDisposable = displayArguments.onDidChangeArguments(arguments -> client.sendNotification({method: "vshaxe/didChangeDisplayArguments"}, {arguments: arguments}));
            executableChangeListenerDisposable = haxeExecutable.onDidChangeConfig(_ -> client.sendNotification({method: "vshaxe/didChangeDisplayServerConfig"}, prepareDisplayServerConfig()));

            context.subscriptions.push(hxFileWatcher.onDidCreate(function(uri) {
                var editor = window.activeTextEditor;
                if (editor == null || editor.document.uri.fsPath != uri.fsPath)
                    return;
                if (editor.document.getText(new Range(0, 0, 0, 1)).length > 0) // skip non-empty created files (can be created by e.g. copy-pasting)
                    return;

                client.sendRequest({method: "vshaxe/determinePackage"}, {fsPath: uri.fsPath}).then(function(result:{pack:String}) {
                    if (result.pack == "")
                        return;
                    editor.edit(function(edit) edit.insert(new Position(0, 0), 'package ${result.pack};\n\n'));
                });
            }));
            context.subscriptions.push(hxFileWatcher);

            client.onNotification({method: "vshaxe/progressStart"}, startProgress);
            client.onNotification({method: "vshaxe/progressStop"}, stopProgress);

            #if debug
            client.onNotification({method: "vshaxe/updateParseTree"}, function(result:{uri:String, parseTree:String}) {
                commands.executeCommand("hxparservis.updateParseTree", result.uri, result.parseTree);
            });
            #end
        });
        var clientDisposable = client.start();
        disposable = new Disposable(function() {
            clientDisposable.dispose();
            argumentChangeListenerDisposable.dispose();
            if (executableChangeListenerDisposable != null) executableChangeListenerDisposable.dispose();
        });
        context.subscriptions.push(disposable);
    }

    function prepareDisplayServerConfig() {
        var config = haxeExecutable.config;
        // TODO: handle legacy haxe.displayServer config here
        return {
            path: config.path,
            env: config.env,
            arguments: workspace.getConfiguration("haxe.displayServer").get("arguments", [])
        };
    }

    var progresses = new Map<Int,Void->Void>();

    function startProgress(data:{id:Int, title:String}) {
        window.withProgress({location: Window, title: data.title}, function(_) {
            return new js.Promise(function(resolve, _) {
                progresses[data.id] = function() resolve(null);
            });
        });
    }

    function stopProgress(data:{id:Int}) {
        var stop = progresses[data.id];
        if (stop != null) {
            progresses.remove(data.id);
            stop();
        }
    }

    public function restart() {
        if (client != null && client.outputChannel != null)
            client.outputChannel.dispose();

        if (disposable != null) {
            context.subscriptions.remove(disposable);
            disposable.dispose();
            disposable = null;
        }
        if (hxFileWatcher != null) {
            context.subscriptions.remove(hxFileWatcher);
            hxFileWatcher.dispose();
            hxFileWatcher = null;
        }

        for (stop in progresses) {
            stop();
        }
        progresses = new Map();

        start();
    }
}
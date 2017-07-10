package vshaxe;

import Vscode.*;
import vscode.*;
import vshaxe.dependencyExplorer.DependencyExplorer;

class LanguageServer {
    var context:ExtensionContext;
    var disposable:Disposable;
    var hxFileWatcher:FileSystemWatcher;
    var displayConfig:DisplayConfiguration;
    var dependencyExplorer:DependencyExplorer;
    var onReadyCallback:Void->Void;

    public var client(default,null):LanguageClient;
    public var isReady:Bool;

    public function new(context:ExtensionContext, ?onReadyCallback:Void->Void) {
        this.context = context;
        this.onReadyCallback = onReadyCallback;

        displayConfig = new DisplayConfiguration(context);
        dependencyExplorer = new DependencyExplorer(context, displayConfig.getConfiguration());
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
                displayArguments: displayConfig.getConfiguration()
            }
        };
        client = new LanguageClient("haxe", "Haxe", serverOptions, clientOptions);
        client.logFailedRequest = function(type, error) {
            client.warn('Request ${type.method} failed.', error);
        };
        client.onReady().then(function(_) {
            client.outputChannel.appendLine("Haxe language server started");
            displayConfig.onDidChangeDisplayConfiguration = function(arguments) {
                client.sendNotification({method: "vshaxe/didChangeDisplayArguments"}, {arguments: arguments});
                dependencyExplorer.onDidChangeDisplayArguments(arguments);
            }

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

            isReady = true;
            if (onReadyCallback != null) {
                onReadyCallback();
            }
        });
        disposable = client.start();
        context.subscriptions.push(disposable);
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

    public function updateDisplayArguments(arguments:String):Void {
        // TODO: Better parsing
        var args = [];
        var lines = arguments.split("\n");
        for (line in lines) {
            line = StringTools.trim(line);
            if (line != "") {
                args = args.concat(line.split (" "));
            }
        }
        client.sendNotification({method: "vshaxe/didChangeDisplayArguments"}, {arguments: args});
        dependencyExplorer.onDidChangeDisplayArguments(args);
    }
}
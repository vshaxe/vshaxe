package vshaxe.server;

import vshaxe.display.DisplayArguments;
import vshaxe.helper.HaxeExecutable;

class LanguageServer {
    var context:ExtensionContext;
    var disposable:Disposable;
    var hxFileWatcher:FileSystemWatcher;
    var progresses = new Map<Int,Void->Void>();
    var haxeExecutable:HaxeExecutable;
    var displayArguments:DisplayArguments;
    var displayServerConfig:{path:String, env:haxe.DynamicAccess<String>, arguments:Array<String>};
    var displayServerConfigSerialized:String;

    public var client(default,null):LanguageClient;

    public function new(context:ExtensionContext, haxeExecutable:HaxeExecutable, displayArguments:DisplayArguments) {
        this.context = context;
        this.displayArguments = displayArguments;
        this.haxeExecutable = haxeExecutable;

        prepareDisplayServerConfig();
        context.subscriptions.push(workspace.onDidChangeConfiguration(_ -> refreshDisplayServerConfig()));
        context.subscriptions.push(haxeExecutable.onDidChangeConfiguration(_ -> refreshDisplayServerConfig()));

        context.subscriptions.push(window.onDidChangeActiveTextEditor(onDidChangeActiveTextEditor));
    }

    function refreshDisplayServerConfig() {
        if (prepareDisplayServerConfig() && client != null)
            client.sendNotification({method: "vshaxe/didChangeDisplayServerConfig"}, displayServerConfig);
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
                displayServerConfig: displayServerConfig,
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

        client.onReady().then(function(_) {
            client.outputChannel.appendLine("Haxe language server started");
            argumentChangeListenerDisposable.dispose();
            if (argumentsChanged)
                client.sendNotification({method: "vshaxe/didChangeDisplayArguments"}, {arguments: displayArguments.arguments});
            argumentChangeListenerDisposable = displayArguments.onDidChangeArguments(arguments -> client.sendNotification({method: "vshaxe/didChangeDisplayArguments"}, {arguments: arguments}));

            context.subscriptions.push(new PackageInserter(hxFileWatcher, client));
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
        });
        context.subscriptions.push(disposable);
    }

    /**
        Prepare new display server config and store it in `displayServerConfig` field.

        @return `true` if configuration was changed since last call
    **/
    function prepareDisplayServerConfig():Bool {
        var path = haxeExecutable.configuration.executable;
        var env = haxeExecutable.configuration.env;
        var haxeConfig = workspace.getConfiguration("haxe");
        var arguments = haxeConfig.get("displayServer.arguments", []);
        if (!haxeExecutable.isConfigured()) {
            // apply legacy settings
            var displayServerConfig = haxeConfig.get("displayServer");
            function merge(conf:{?haxePath:String, ?env:haxe.DynamicAccess<String>}) {
                if (conf.haxePath != null)
                    path = conf.haxePath;
                if (conf.env != null)
                    env = conf.env;
            }
            if (displayServerConfig != null) {
                merge(displayServerConfig);
                var systemConfig = Reflect.field(displayServerConfig, HaxeExecutable.SYSTEM_KEY);
                if (systemConfig != null)
                    merge(systemConfig);
            }
        }
        displayServerConfig = {
            path: path,
            env: env,
            arguments: arguments,
        };
        var oldSerialized = displayServerConfigSerialized;
        displayServerConfigSerialized = haxe.Json.stringify(displayServerConfig);
        return displayServerConfigSerialized != oldSerialized;
    }

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
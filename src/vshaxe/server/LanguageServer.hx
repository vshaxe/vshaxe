package vshaxe.server;

import vshaxe.display.DisplayArguments;
import vshaxe.helper.HaxeExecutable;
import vshaxe.server.LanguageClient;

class LanguageServer {
    public var displayPort(default,null):Null<Int>;

    final folder:WorkspaceFolder;
    final haxeExecutable:HaxeExecutable;
    final displayArguments:DisplayArguments;
    final api:Vshaxe;
    final serverModulePath:String;
    final hxFileWatcher:FileSystemWatcher;
    final disposables:Array<{ function dispose():Void; }>;

    var client:LanguageClient;
    var restartDisposables:Array<{ function dispose():Void; }>;
    var progresses = new Map<Int,Void->Void>();
    var displayServerConfig:{path:String, env:haxe.DynamicAccess<String>, arguments:Array<String>};
    var displayServerConfigSerialized:String;

    public function new(folder:WorkspaceFolder, context:ExtensionContext, haxeExecutable:HaxeExecutable, displayArguments:DisplayArguments, api:Vshaxe) {
        this.folder = folder;
        this.displayArguments = displayArguments;
        this.haxeExecutable = haxeExecutable;
        this.api = api;

        serverModulePath = context.asAbsolutePath("./server_wrapper.js");
        hxFileWatcher = workspace.createFileSystemWatcher(new RelativePattern(folder, "**/*.hx"), false, true, false);

        prepareDisplayServerConfig();

        disposables = [
            hxFileWatcher,
            workspace.onDidChangeConfiguration(_ -> refreshDisplayServerConfig()),
            haxeExecutable.onDidChangeConfiguration(_ -> refreshDisplayServerConfig()),
            window.onDidChangeActiveTextEditor(onDidChangeActiveTextEditor),
        ];
        restartDisposables = [];
    }

    public function dispose() {
        for (d in restartDisposables) d.dispose();
        for (d in disposables) d.dispose();
    }

    function refreshDisplayServerConfig() {
        if (prepareDisplayServerConfig() && client != null)
            client.sendNotification("vshaxe/didChangeDisplayServerConfig", displayServerConfig);
    }

    function onDidChangeActiveTextEditor(editor:TextEditor) {
        if (editor != null && editor.document.languageId == "haxe")
            client.sendNotification("vshaxe/didChangeActiveTextEditor", {uri: editor.document.uri.toString()});
    }

    public function start() {
        var serverOptions = {
            run: {module: serverModulePath, options: {env: js.Node.process.env}},
            debug: {module: serverModulePath, options: {env: js.Node.process.env, execArgv: ["--nolazy", "--inspect=6004"]}}
        };

        var clientOptions:LanguageClientOptions = {
            documentSelector: "haxe",
            synchronize: {
                configurationSection: "haxe",
                fileEvents: hxFileWatcher
            },
            initializationOptions: {
                displayArguments: displayArguments.arguments,
                displayServerConfig: displayServerConfig,
            },
            revealOutputChannelOn: Never,
            workspaceFolder: folder,
        };

        client = new LanguageClient("haxe", "Haxe", serverOptions, clientOptions);

        // If arguments change while we're starting language server we remember that fact
        // and send updated arguments once language server is ready. this can often happen on startup
        // due to asynchronous argument provider loading. I wonder if there's any way to handle this better...
        var argumentsChanged = false;
        var argumentChangeListenerDisposable = displayArguments.onDidChangeArguments(_ -> argumentsChanged = true);
        restartDisposables.push(argumentChangeListenerDisposable);

        client.onReady().then(function(_) {
            client.outputChannel.appendLine("Haxe language server started");

            restartDisposables.remove(argumentChangeListenerDisposable);
            argumentChangeListenerDisposable.dispose();

            if (argumentsChanged)
                client.sendNotification("vshaxe/didChangeDisplayArguments", {arguments: displayArguments.arguments});

            restartDisposables.push(displayArguments.onDidChangeArguments(arguments -> client.sendNotification("vshaxe/didChangeDisplayArguments", {arguments: arguments})));

            restartDisposables.push(new PackageInserter(hxFileWatcher, client));

            client.onNotification("vshaxe/progressStart", onStartProgress);
            client.onNotification("vshaxe/progressStop", onStopProgress);
            client.onNotification("vshaxe/didChangeDisplayPort", onDidChangeDisplayPort);
            client.onNotification("vshaxe/didRunGlobalDiagnostics", onDidRunGlobalDiangostics);

            #if debug
            client.onNotification("vshaxe/updateParseTree", function(result:{uri:String, parseTree:String}) {
                commands.executeCommand("hxparservis.updateParseTree", result.uri, result.parseTree);
            });
            #end
        });

        restartDisposables.push(client.start());
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

    function onStartProgress(data:{id:Int, title:String}) {
        window.withProgress({location: Window, title: data.title}, function(_, _) {
            return new js.Promise(function(resolve, _) {
                progresses[data.id] = function() resolve(null);
            });
        });
    }

    function onStopProgress(data:{id:Int}) {
        var stop = progresses[data.id];
        if (stop != null) {
            progresses.remove(data.id);
            stop();
        }
    }

    function onDidChangeDisplayPort(data:{port:Int}) {
        displayPort = data.port;
        var writeableApi:{?displayPort:Int} = cast api;
        writeableApi.displayPort = data.port;
    }

    public function restart() {
        if (client != null && client.outputChannel != null)
            client.outputChannel.dispose();

        for (d in restartDisposables) d.dispose();
        restartDisposables = [];

        for (stop in progresses) stop();
        progresses = new Map();

        start();
    }

    public inline function runGlobalDiagnostics() {
        client.sendNotification("vshaxe/runGlobalDiagnostics");
    }

    function onDidRunGlobalDiangostics(_) {
        commands.executeCommand("workbench.action.problems.focus");
    }
}

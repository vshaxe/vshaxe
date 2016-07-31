package vshaxe;

import vscode.*;
import Vscode.*;

class Main {
    var context:ExtensionContext;
    var serverDisposable:Disposable;
    var hxFileWatcher:FileSystemWatcher;
    var vshaxeChannel:OutputChannel;
    var displayConfig:DisplayConfiguration;

    function new(ctx) {
        context = ctx;

        displayConfig = new DisplayConfiguration(ctx);
        new InitProject(ctx);

        vshaxeChannel = window.createOutputChannel("vshaxe");
        vshaxeChannel.show();
        context.subscriptions.push(vshaxeChannel);

        context.subscriptions.push(commands.registerCommand("haxe.restartLanguageServer", restartLanguageServer));
        context.subscriptions.push(commands.registerCommand("haxe.applyFixes", applyFixes));

        startLanguageServer();
    }

    inline function log(message:String) {
        vshaxeChannel.append(message);
    }

    function applyFixes(uri:String, version:Int, edits:Array<TextEdit>) {
        var editor = window.activeTextEditor;
        if (editor == null || editor.document.uri.toString() != uri)
            return;

        // TODO:
        // if (editor.document.version != version) {
        //     window.showInformationMessage("Fix is outdated and cannot be applied to the document");
        //     return;
        // }

        editor.edit(function(mutator) {
            for (edit in edits) {
                var range = new Range(edit.range.start.line, edit.range.start.character, edit.range.end.line, edit.range.end.character);
                mutator.replace(range, edit.newText);
            }
        });
    }



    function startLanguageServer() {
        var serverModule = context.asAbsolutePath("./server_wrapper.js");
        var serverOptions = {
            run: {module: serverModule, options: {env: js.Node.process.env}},
            debug: {module: serverModule, options: {env: js.Node.process.env, execArgv: ["--nolazy", "--debug=6004"]}}
        };
        var clientOptions = {
            documentSelector: "haxe",
            synchronize: {
                configurationSection: "haxe"
            },
            initializationOptions: {
                displayConfigurationIndex: displayConfig.getIndex()
            }
        };
        var client = new LanguageClient("Haxe", serverOptions, clientOptions);
        client.onNotification({method: "vshaxe/log"}, log);
        client.onReady().then(function(_) {
            log("Haxe language server started\n");
            displayConfig.onDidChangeIndex = function(index) {
                client.sendNotification({method: "vshaxe/didChangeDisplayConfigurationIndex"}, {index: index});
            }

            hxFileWatcher = workspace.createFileSystemWatcher("**/*.hx", false, true, true);
            context.subscriptions.push(hxFileWatcher.onDidCreate(function(uri) {
                var editor = window.activeTextEditor;
                if (editor == null || editor.document.uri.fsPath != uri.fsPath)
                    return;
                client.sendRequest({method: "vshaxe/calculatePackage"}, {fsPath: uri.fsPath}).then(function(result:{pack:String}) {
                    if (result.pack == "")
                        return;
                    editor.edit(function(edit) edit.insert(new Position(0, 0), 'package ${result.pack};\n'));
                });
            }));
            context.subscriptions.push(hxFileWatcher);
        });
        serverDisposable = client.start();
        context.subscriptions.push(serverDisposable);
    }

    function restartLanguageServer() {
        if (serverDisposable != null) {
            context.subscriptions.remove(serverDisposable);
            serverDisposable.dispose();
            serverDisposable = null;
        }
        if (hxFileWatcher != null) {
            context.subscriptions.remove(hxFileWatcher);
            hxFileWatcher.dispose();
            hxFileWatcher = null;
        }
        startLanguageServer();
    }

    @:keep
    @:expose("activate")
    static function main(context:ExtensionContext) {
        new Main(context);
    }
}

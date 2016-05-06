package vshaxe;

import vscode.*;

using StringTools;

private typedef DisplayConfigurationPickItem = {
    >QuickPickItem,
    var index:Int;
}

class Main {
    var context:ExtensionContext;
    var languageClient:LanguageClient;
    var serverDisposable:Disposable;
    var vshaxeChannel:OutputChannel;
    var statusBarItem:StatusBarItem;

    function new(ctx) {
        context = ctx;

        fixDisplayConfigurationIndex();

        new InitProject(ctx);

        vshaxeChannel = Vscode.window.createOutputChannel("vshaxe");
        vshaxeChannel.show();

        statusBarItem = Vscode.window.createStatusBarItem(Right);
        statusBarItem.tooltip = "Select Haxe configuration";
        statusBarItem.command = "haxe.selectDisplayConfiguration";
        statusBarItem.color = "orange";

        context.subscriptions.push(vshaxeChannel);
        context.subscriptions.push(statusBarItem);
        context.subscriptions.push(Vscode.commands.registerCommand("haxe.restartLanguageServer", restartLanguageServer));
        context.subscriptions.push(Vscode.commands.registerCommand("haxe.applyFixes", applyFixes));
        context.subscriptions.push(Vscode.commands.registerCommand("haxe.selectDisplayConfiguration", selectDisplayConfiguration));
        context.subscriptions.push(Vscode.workspace.onDidChangeConfiguration(onDidChangeConfiguration));
        context.subscriptions.push(Vscode.window.onDidChangeActiveTextEditor(onDidChangeActiveTextEditor));
        showHideStatusBarItem();
        startLanguageServer();
    }

    function fixDisplayConfigurationIndex() {
        var index = getDisplayConfigurationIndex();
        var configs = getDisplayConfigurations();
        if (configs == null || index >= configs.length)
            setDisplayConfigurationIndex(0);
    }

    function showHideStatusBarItem() {
        if (statusBarItem == null)
            return;

        if (Vscode.window.activeTextEditor == null) {
            statusBarItem.hide();
            return;
        }

        if (Vscode.languages.match({language: 'haxe', scheme: 'file'}, Vscode.window.activeTextEditor.document) > 0) {
            var configs = getDisplayConfigurations();
            if (configs != null && configs.length >= 2) {
                var index = getDisplayConfigurationIndex();
                statusBarItem.text = 'Haxe: $index (${configs[index].join(" ")})';
                statusBarItem.show();
                return;
            }
        }

        statusBarItem.hide();
    }

    function onDidChangeActiveTextEditor(_) {
        showHideStatusBarItem();
    }

    function onDidChangeConfiguration(_) {
        fixDisplayConfigurationIndex();
        showHideStatusBarItem();
    }

    function selectDisplayConfiguration() {
        var configs = getDisplayConfigurations();
        if (configs == null || configs.length < 2)
            return;

        var items:Array<DisplayConfigurationPickItem> = [];
        for (index in 0...configs.length) {
            var args = configs[index];
            var label = args.join(" ");
            items.push({
                label: "" + index,
                description: label,
                index: index,
            });
        }

        Vscode.window.showQuickPick(items, {placeHolder: "Select haxe display configurations"}).then(function(choice:DisplayConfigurationPickItem) {
            if (choice == null || choice.index == getDisplayConfigurationIndex())
                return;
            setDisplayConfigurationIndex(choice.index);
            showHideStatusBarItem();
        });
    }

    function log(message:String) {
        vshaxeChannel.append(message);
    }

    function applyFixes(uri:String, version:Int, edits:Array<TextEdit>) {
        var editor = Vscode.window.activeTextEditor;
        if (editor == null || editor.document.uri.toString() != uri)
            return;

        // TODO:
        // if (editor.document.version != version) {
        //     Vscode.window.showInformationMessage("Fix is outdated and cannot be applied to the document");
        //     return;
        // }

        editor.edit(function(mutator) {
            for (edit in edits) {
                var range = new Range(edit.range.start.line, edit.range.start.character, edit.range.end.line, edit.range.end.character);
                mutator.replace(range, edit.newText);
            }
        });
    }

    inline function getDisplayConfigurations():Array<Array<String>> {
        return Vscode.workspace.getConfiguration("haxe").get("displayConfigurations");
    }

    inline function setDisplayConfigurationIndex(index:Int) {
        context.workspaceState.update("haxe.displayConfigurationIndex", index);
        if (languageClient != null)
            languageClient.sendNotification({method: "vshaxe/didChangeDisplayConfigurationIndex"}, {index: index});
    }

    inline function getDisplayConfigurationIndex():Int {
        return context.workspaceState.get("haxe.displayConfigurationIndex", 0);
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
                displayConfigurationIndex: getDisplayConfigurationIndex()
            }
        };
        var client = new LanguageClient("Haxe", serverOptions, clientOptions);
        client.onNotification({method: "vshaxe/log"}, log);
        client.onReady().then(function(_) {
            log("Haxe language server started\n");
            languageClient = client;
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

    @:keep
    @:expose("activate")
    static function main(context:ExtensionContext) {
        new Main(context);
    }
}

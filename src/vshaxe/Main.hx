package vshaxe;

import vscode.*;
import Vscode.*;
import haxe.Constraints.Function;
using StringTools;

class Main {
    var context:ExtensionContext;
    var serverDisposable:Disposable;
    var hxFileWatcher:FileSystemWatcher;
    var vshaxeChannel:OutputChannel;
    var displayConfig:DisplayConfiguration;
    var client:LanguageClient;

    function new(ctx) {
        context = ctx;

        displayConfig = new DisplayConfiguration(ctx);
        new InitProject(ctx);

        registerCommand("restartLanguageServer", restartLanguageServer);
        registerCommand("applyFixes", applyFixes);
        registerCommand("showReferences", showReferences);
        registerCommand("runGlobalDiagnostics", runGlobalDiagnostics);

        var defaultWordPattern = "(-?\\d*\\.\\d\\w*)|([^\\`\\~\\!\\@\\#\\%\\^\\&\\*\\(\\)\\-\\=\\+\\[\\{\\]\\}\\\\\\|\\;\\:\\'\\\"\\,\\.\\<\\>\\/\\?\\s]+)";
        var wordPattern = defaultWordPattern + "|(@:\\w*)"; // metadata
        languages.setLanguageConfiguration("Haxe", {wordPattern: new js.RegExp(wordPattern)});

        startLanguageServer();
    }

    function registerCommand(command:String, callback:Function) {
        context.subscriptions.push(commands.registerCommand("haxe." + command, callback));
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
        var selections = [];
        var previousEdits:Array<TextEdit> = [];

        editor.edit(function(mutator) {
            for (edit in edits) {
                var range = new Range(edit.range.start.line, edit.range.start.character, edit.range.end.line, edit.range.end.character);
                mutator.delete(range);

                var text = edit.newText;
                var re = ~/(?!\\)\$/;
                re.match(text);
                var pos = re.matchedPos();
                text = re.replace(text, "");
                // unescape dollar signs
                text = text.replace("\\$", "$");

                var rangeStart = range.start;
                mutator.insert(rangeStart, text);

                if (pos != null) {
                    var cursorPos = range.start.translate(0, pos.pos);
                    // need to translate the cursor pos according to what previous edits did.
                    // assume text edits are already sorted correctly...
                    for (prev in previousEdits) {
                        var lines = prev.newText.split("\n");
                        var lineDelta = prev.range.end.line - prev.range.start.line + (lines.length - 1);
                        var characterDelta = prev.range.end.character - prev.range.start.character + lines[lines.length - 1].length;
                        cursorPos = cursorPos.translate(lineDelta, characterDelta);
                    }
                    selections.push(new vscode.Selection(cursorPos, cursorPos));
                }

                previousEdits.push(edit);
            }
            commands.executeCommand("closeParameterHints");
        }).then(function(ok) {
            if (ok) editor.selections = selections;
        });
    }

    function showReferences(uri:String, position:Position, locations:Array<Location>) {
        inline function copyPosition(position) return new Position(position.line, position.character);
        // this is retarded
        var locations = locations.map(function(location)
            return new Location(Uri.parse(cast location.uri), new Range(copyPosition(location.range.start), copyPosition(location.range.end)))
        );
        commands.executeCommand("editor.action.showReferences", Uri.parse(uri), copyPosition(position), locations).then(function(s) trace(s), function(s) trace("err: " + s));
    }

    function runGlobalDiagnostics() {
        client.sendNotification({method: "vshaxe/runGlobalDiagnostics"});
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
        client = new LanguageClient("haxe", "Haxe", serverOptions, clientOptions);
        client.logFailedRequest = function(type, error) {
            client.warn('Request ${type.method} failed.', error);
        };
        client.onReady().then(function(_) {
            client.outputChannel.appendLine("Haxe language server started");
            displayConfig.onDidChangeIndex = function(index) {
                client.sendNotification({method: "vshaxe/didChangeDisplayConfigurationIndex"}, {index: index});
            }

            hxFileWatcher = workspace.createFileSystemWatcher("**/*.hx", false, true, true);
            context.subscriptions.push(hxFileWatcher.onDidCreate(function(uri) {
                var editor = window.activeTextEditor;
                if (editor == null || editor.document.uri.fsPath != uri.fsPath)
                    return;
                if (editor.document.getText(new Range(0, 0, 0, 1)).length > 0) // skip non-empty created files (can be created by e.g. copy-pasting)
                    return;

                client.sendRequest({method: "vshaxe/determinePackage"}, {fsPath: uri.fsPath}).then(function(result:{pack:String}) {
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
        if (client != null && client.outputChannel != null)
            client.outputChannel.dispose();
            
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

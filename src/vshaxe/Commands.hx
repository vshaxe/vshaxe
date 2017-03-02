package vshaxe;

import Vscode.*;
import haxe.Constraints.Function;
import vscode.*;
using StringTools;

class Commands {
    var context:ExtensionContext;
    var server:LanguageServer;

    public function new(context:ExtensionContext, server:LanguageServer) {
        this.context = context;
        this.server = server;

        registerCommand("restartLanguageServer", server.restart);
        registerCommand("applyFixes", applyFixes);
        registerCommand("showReferences", showReferences);
        registerCommand("runGlobalDiagnostics", runGlobalDiagnostics);
        registerCommand("toggleCodeLens", toggleCodeLens);
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
                var pos = null;
                if (re.match(text)) pos = re.matchedPos();
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
            if (ok && selections.length > 0) editor.selections = selections;
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
        server.client.sendNotification({method: "vshaxe/runGlobalDiagnostics"});
    }

    function toggleCodeLens() {
        var key = "enableCodeLens";
        var config = workspace.getConfiguration("haxe");
        var info = config.inspect(key);
        var value = getCurrentConfigValue(info, config);
        // editing the global config only has an effect if there's no workspace value
        var global = info.workspaceValue == null;
        config.update(key, !value, global);
    }

    function getCurrentConfigValue<T>(info, config:WorkspaceConfiguration):T {
        var value = info.workspaceValue;
        if (value == null)
            value = info.globalValue;
        if (value == null)
            value = info.defaultValue;
        return value;
    }
}
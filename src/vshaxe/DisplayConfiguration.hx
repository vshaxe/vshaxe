package vshaxe;

import vscode.ExtensionContext;
import vscode.QuickPickItem;
import vscode.StatusBarItem;
import Vscode.*;
using vshaxe.helper.ArrayHelper;

class DisplayConfiguration {
    var context:ExtensionContext;
    var statusBarItem:StatusBarItem;
    var configuration:Array<String>;

    public function new(context:ExtensionContext) {
        this.context = context;

        statusBarItem = window.createStatusBarItem(Left);
        statusBarItem.tooltip = "Select Haxe configuration";
        statusBarItem.command = "haxe.selectDisplayConfiguration";
        context.subscriptions.push(statusBarItem);

        context.subscriptions.push(commands.registerCommand("haxe.selectDisplayConfiguration", selectConfiguration));

        context.subscriptions.push(workspace.onDidChangeConfiguration(onDidChangeConfiguration));
        context.subscriptions.push(window.onDidChangeActiveTextEditor(onDidChangeActiveTextEditor));

        fixIndex();
        updateStatusBarItem();
        configuration = getConfiguration();
    }

    function fixIndex() {
        var index = getIndex();
        var configs = getConfigurations();
        if (configs == null || index >= configs.length)
            setIndex(0);
    }

    function selectConfiguration() {
        var configs = getConfigurations();
        if (configs == null || configs.length == 0) {
            window.showErrorMessage("No Haxe display configurations are available. Please provide the haxe.displayConfigurations setting.", ({title: "Edit settings"} : vscode.MessageItem)).then(function(button) {
                if (button == null)
                    return;
                workspace.openTextDocument(workspace.rootPath + "/.vscode/settings.json").then(function(doc) window.showTextDocument(doc));
            });
            return;
        }
        if (configs.length == 1) {
            window.showInformationMessage("Only one Haxe display configuration found: " + configs[0].join(" "));
            return;
        }

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

        window.showQuickPick(items, {matchOnDescription: true, placeHolder: "Select Haxe display configuration"}).then(function(choice:DisplayConfigurationPickItem) {
            if (choice == null || choice.index == getIndex())
                return;
            setIndex(choice.index);
        });
    }

    function onDidChangeConfiguration(_) {
        fixIndex();
        updateStatusBarItem();
        checkConfigurationChange();
    }

    function onDidChangeActiveTextEditor(_) {
        updateStatusBarItem();
    }

    function updateStatusBarItem() {
        if (window.activeTextEditor == null) {
            statusBarItem.hide();
            return;
        }

        if (languages.match({language: 'haxe', scheme: 'file'}, window.activeTextEditor.document) > 0) {
            var configs = getConfigurations();
            if (configs != null && configs.length >= 2) {
                var index = getIndex();
                statusBarItem.text = '$(gear) Haxe: $index (${configs[index].join(" ")})';
                statusBarItem.show();
                return;
            }
        }

        statusBarItem.hide();
    }

    inline function getConfigurations():Array<Array<String>> {
        return workspace.getConfiguration("haxe").get("displayConfigurations");
    }

    public inline function getConfiguration():Array<String> {
        return getConfigurations()[getIndex()];
    }

    public inline function getIndex():Int {
        return context.workspaceState.get("haxe.displayConfigurationIndex", 0);
    }

    function setIndex(index:Int) {
        context.workspaceState.update("haxe.displayConfigurationIndex", index);
        updateStatusBarItem();
        checkConfigurationChange();
    }

    function checkConfigurationChange() {
        var newConfiguration = getConfiguration();
        if (!newConfiguration.equals(configuration)) {
            onDidChangeDisplayConfiguration(newConfiguration);
            configuration = newConfiguration;
        }
    }

    public dynamic function onDidChangeDisplayConfiguration(configuration:Array<String>):Void {}
}

private typedef DisplayConfigurationPickItem = {
    >QuickPickItem,
    var index:Int;
}

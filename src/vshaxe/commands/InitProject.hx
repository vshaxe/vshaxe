package vshaxe.commands;

import sys.FileSystem;
import sys.io.File;

class InitProject {
    var context:ExtensionContext;

    public function new(context:ExtensionContext) {
        this.context = context;
        context.registerHaxeCommand(InitProject, initProject);
    }

    function initProject() {
        var workspaceRoot = workspace.rootPath;

        if (workspaceRoot == null) {
            window.showErrorMessage("Please open a folder to set up a Haxe project into");
            return;
        }

        var vscodeDir = workspaceRoot + "/.vscode";
        if (FileSystem.exists(vscodeDir)) {
            showConfigureHint();
            return;
        }

        var emptyOrOnlyHiddenFiles = FileSystem.readDirectory(workspaceRoot).foreach(function(f) return f.startsWith("."));
        if (emptyOrOnlyHiddenFiles) {
            scaffoldEmpty(workspaceRoot);
            return;
        }

        var hxmls = findHxmls(workspaceRoot);
        if (hxmls.length == 0) {
            window.showErrorMessage("To set up Haxe project, workspace must be either empty or contain HXML files to choose from");
        } else if (hxmls.length == 1) {
            scaffoldVscodeSettings(vscodeDir, hxmls[0], hxmls);
        } else {
            createWorkspaceConfiguration(vscodeDir, hxmls);
        }
    }

    function scaffoldEmpty(root:String) {
        var scaffoldSource = context.asAbsolutePath("./scaffold/project");
        copyRec(scaffoldSource, root);
        window.setStatusBarMessage("Haxe project scaffolded", 2000);
    }

    function showConfigureHint() {
        var channel = window.createOutputChannel("Haxe scaffold");
        context.subscriptions.push(channel);
        var content = File.getContent(context.asAbsolutePath("./scaffold/configureHint.txt"));
        channel.clear();
        channel.append(content);
        channel.show();
    }

    function findHxmls(root:String):Array<QuickPickItem> {
        var hxmls:Array<QuickPickItem> = [];
        function loop(path:String):Void {
            var fullPath = root + "/" + path;
            if (FileSystem.isDirectory(fullPath)) {
                if (path == ".haxelib")
                    return;
                for (file in FileSystem.readDirectory(fullPath)) {
                    if (file.endsWith(".hxml"))
                        hxmls.push({label: file, description: path});
                    else
                        loop(if (path.length == 0) file else path + "/" + file);
                }
            }
        }
        loop("");
        return hxmls;
    }

    static function getHxmlPath(item:QuickPickItem):String {
        var path = item.description, file = item.label;
        return if (path.length == 0) file else path + "/" + file;
    }

    function createWorkspaceConfiguration(vscodeDir:String, items:Array<QuickPickItem>) {
        var pick = window.showQuickPick(items, {placeHolder: "Choose HXML file to use"});
        pick.then(function(s:QuickPickItem):Void {
            if (s != null)
                scaffoldVscodeSettings(vscodeDir, s, items);
        });
    }

    function scaffoldVscodeSettings(vscodeDir:String, item:QuickPickItem, items:Array<QuickPickItem>) {
        var selectedHxml = getHxmlPath(item);

        // update settings
        var hxmls = items.map(function(item) return getHxmlPath(item));
        // move selected on top
        hxmls.remove(selectedHxml);
        hxmls.insert(0, selectedHxml);
        var config = workspace.getConfiguration("haxe");
        config.update("displayConfigurations", [for (hxml in hxmls) [hxml]]).then(function(_) {
            workspace.openTextDocument(vscodeDir + "/settings.json").then(function(doc) {
                window.showTextDocument(doc);
                window.showInformationMessage("Please check if " + selectedHxml + " is suitable for completion and modify haxe.displayConfigurations if needed.");
            });
        });
    }

    function copyRec(from:String, to:String):Void {
        function loop(src, dst) {
            var fromPath = from + src;
            var toPath = to + dst;
            if (FileSystem.isDirectory(fromPath)) {
                FileSystem.createDirectory(toPath);
                for (file in FileSystem.readDirectory(fromPath))
                    loop(src + "/" + file, dst + "/" + file);
            } else {
                File.copy(fromPath, toPath);
            }
        }
        loop("", "");
    }
}

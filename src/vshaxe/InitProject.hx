package vshaxe;

import sys.FileSystem;
import sys.io.File;

import vscode.ExtensionContext;
import vscode.QuickPickItem;
import Vscode.*;

using StringTools;

class InitProject {
    var context:ExtensionContext;

    public function new(context:ExtensionContext) {
        this.context = context;
        context.subscriptions.push(commands.registerCommand("haxe.initProject", initProject));
    }

    function initProject() {
        var workspaceRoot = workspace.rootPath;

        if (workspaceRoot == null) {
            window.showErrorMessage("Please open a folder to set up a Haxe project into");
            return;
        }

        if (FileSystem.readDirectory(workspaceRoot).length == 0) {
            scaffoldEmpty(workspaceRoot);
            return;
        }

        var vscodeDir = workspaceRoot + "/.vscode";
        if (FileSystem.exists(vscodeDir)) {
            showConfigureHint();
            return;
        }

        var hxmls = findHxmls(workspaceRoot);
        if (hxmls.length > 0) {
            createWorkspaceConfiguration(vscodeDir, hxmls);
            return;
        }

        window.showErrorMessage("To set up Haxe project, workspace must be either empty or contain HXML files to choose from");
    }

    function scaffoldEmpty(root:String) {
        var scaffoldSource = context.asAbsolutePath("./scaffold");
        copyRec(scaffoldSource, root);
        window.setStatusBarMessage("Haxe project scaffolded", 2000);
    }

    function showConfigureHint() {
        var channel = window.createOutputChannel("Haxe scaffold");
        context.subscriptions.push(channel);
        var content = File.getContent(context.asAbsolutePath("./configureHint.txt"));
        var tasks = File.getContent(context.asAbsolutePath("./scaffold/.vscode/tasks.json"));
        content = content.replace("{{tasks}}", tasks);
        channel.clear();
        channel.append(content);
        channel.show();
    }

    function findHxmls(root:String):Array<QuickPickItem> {
        var hxmls = [];
        function loop(path:String):Void {
            var fullPath = root + "/" + path;
            if (FileSystem.isDirectory(fullPath)) {
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

    function createWorkspaceConfiguration(vscodeDir:String, hxmls:Array<QuickPickItem>) {
        var pick = window.showQuickPick(hxmls, {placeHolder: "Choose HXML file to use"});
        pick.then(function(s:QuickPickItem):Void {
            if (s == null)
                return;

            var path = s.description, file = s.label;
            var hxmlPath = if (path.length == 0) file else path + "/" + file;

            copyRec(context.asAbsolutePath("./scaffold/.vscode"), vscodeDir);

            inline function replaceBuildHxml(file) {
                var path = vscodeDir + "/" + file;
                var content = File.getContent(path);
                File.saveContent(path, content.replace('"build.hxml"', '"$hxmlPath"'));
            }
            replaceBuildHxml("tasks.json");
            replaceBuildHxml("settings.json");

            workspace.openTextDocument(vscodeDir + "/settings.json").then(function(doc) {
                window.showTextDocument(doc);
                window.showInformationMessage("Please check if " + hxmlPath + " is suitable for completion and modify haxe.displayConfigurations if needed.");
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

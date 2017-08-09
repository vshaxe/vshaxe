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

        var nonEmpty = FileSystem.readDirectory(workspaceRoot).exists(f -> !f.startsWith("."));
        if (nonEmpty) {
            window.showErrorMessage("To set up sample Haxe project, the workspace must be empty");
            return;
        }

        copyRec(context.asAbsolutePath("./scaffold/project"), workspaceRoot);
        window.setStatusBarMessage("Haxe project scaffolded", 2000);
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

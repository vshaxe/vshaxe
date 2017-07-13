package vshaxe.tasks;

import haxe.io.Path;
import vshaxe.helper.PathHelper;

class HxmlTaskProvider {
    var hxmlFiles:Array<String> = [];

    public function new(context:ExtensionContext) {
        workspace.registerTaskProvider("hxml", this);
        var pattern = "*.hxml";
        workspace.findFiles(pattern).then(files -> hxmlFiles = files.map(uri -> uri.fsPath));

        // looks like file watchers require a glob prefixed with the workspace root
        var prefixedPattern = Path.join([workspace.rootPath, pattern]);
        var fileWatcher = workspace.createFileSystemWatcher(prefixedPattern, false, true, false);
        fileWatcher.onDidCreate(uri -> hxmlFiles.push(uri.fsPath));
        fileWatcher.onDidDelete(uri -> hxmlFiles.remove(uri.fsPath));
    }

    public function provideTasks(?token:CancellationToken):ProviderResult<Array<Task>> {
        return [for (file in hxmlFiles) {
            var relativePath = PathHelper.relativize(file, workspace.rootPath);
            var definition:HaxeTaskDefinition = {
                type: "hxml",
                file: relativePath
            };
            var task = new Task(definition, relativePath, "haxe", new ShellExecution('haxe "$relativePath"'), "$haxe");
            task.group = TaskGroup.Build;
            task;
        }];
    }

    public function resolveTask(task:Task, ?token:CancellationToken):ProviderResult<Task> {
        return task;
    }
}

private typedef HaxeTaskDefinition = {
    > TaskDefinition,
    file:String
}
package vshaxe.tasks;

import vshaxe.helper.PathHelper;

class HxmlTaskProvider {
    var hxmlDiscovery:HxmlDiscovery;

    public function new(hxmlDiscovery) {
        this.hxmlDiscovery = hxmlDiscovery;
        workspace.registerTaskProvider("hxml", this);
    }

    public function provideTasks(?token:CancellationToken):ProviderResult<Array<Task>> {
        return [for (file in hxmlDiscovery.hxmlFiles) {
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
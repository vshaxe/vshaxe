package vshaxe.tasks;

class HxmlTaskProvider {
    var hxmlDiscovery:HxmlDiscovery;

    public function new(hxmlDiscovery) {
        this.hxmlDiscovery = hxmlDiscovery;
        workspace.registerTaskProvider("hxml", this);
    }

    public function provideTasks(?token:CancellationToken):ProviderResult<Array<Task>> {
        return [for (file in hxmlDiscovery.hxmlFiles) {
            var definition:HaxeTaskDefinition = {
                type: "hxml",
                file: file
            };
            var task = new Task(definition, file, "haxe", new ShellExecution('haxe "$file"'), "$haxe");
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
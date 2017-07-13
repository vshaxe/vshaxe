package vshaxe.tasks;

import vshaxe.helper.HaxeExecutableHelper;

class HxmlTaskProvider {
    var hxmlDiscovery:HxmlDiscovery;
    var haxeExecutable:HaxeExecutableHelper;

    public function new(hxmlDiscovery, haxeExecutable) {
        this.hxmlDiscovery = hxmlDiscovery;
        this.haxeExecutable = haxeExecutable;
        workspace.registerTaskProvider("hxml", this);
    }

    public function provideTasks(?token:CancellationToken):ProviderResult<Array<Task>> {
        return [for (file in hxmlDiscovery.hxmlFiles) {
            var definition:HaxeTaskDefinition = {
                type: "hxml",
                file: file
            };
            var haxePath = haxeExecutable.config.path;
            var task = new Task(definition, file, "haxe", new ShellExecution('$haxePath "$file"', {env: haxeExecutable.config.env}), "$haxe");
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
package vshaxe.tasks;

import vshaxe.helper.HaxeExecutable;

class HxmlTaskProvider {
    var hxmlDiscovery:HxmlDiscovery;
    var haxeExecutable:HaxeExecutable;

    public function new(hxmlDiscovery, haxeExecutable) {
        this.hxmlDiscovery = hxmlDiscovery;
        this.haxeExecutable = haxeExecutable;
        workspace.registerTaskProvider("hxml", this);
    }

    public function provideTasks(?token:CancellationToken):ProviderResult<Array<Task>> {
        return [for (file in hxmlDiscovery.files) {
            var definition:HaxeTaskDefinition = {
                type: "hxml",
                file: file
            };
            var exectuable = haxeExecutable.configuration.executable;
            var task = new Task(definition, file, "haxe", new ProcessExecution(exectuable, [file], {env: haxeExecutable.configuration.env}), "$haxe");
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
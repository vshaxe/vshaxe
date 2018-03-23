package vshaxe.tasks;

import vshaxe.helper.HaxeExecutable;
import vshaxe.server.LanguageServer;

class HxmlTaskProvider {
    var hxmlDiscovery:HxmlDiscovery;
    var haxeExecutable:HaxeExecutable;
    var server:LanguageServer;

    public function new(hxmlDiscovery, haxeExecutable, server) {
        this.hxmlDiscovery = hxmlDiscovery;
        this.haxeExecutable = haxeExecutable;
        this.server = server;
        workspace.registerTaskProvider("hxml", this);
    }

    public function provideTasks(?token:CancellationToken):ProviderResult<Array<Task>> {
        return [for (file in hxmlDiscovery.files) {
            var definition:HaxeTaskDefinition = {
                type: "hxml",
                file: file
            };
            var exectuable = haxeExecutable.configuration.executable;
            var args = [file];
            if (server.displayPort != null && workspace.getConfiguration("haxe").get("enableCompilationServer")) {
                args = args.concat(["--connect", Std.string(server.displayPort)]);
            }
            var execution = new ProcessExecution(exectuable, args, {env: haxeExecutable.configuration.env});
            var task = new Task(definition, file, "haxe", execution, "$haxe");
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
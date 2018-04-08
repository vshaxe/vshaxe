package vshaxe.tasks;

import vshaxe.helper.HaxeExecutable;
import vshaxe.server.LanguageServer;

class HxmlTaskProvider {
    final hxmlDiscovery:HxmlDiscovery;
    final haxeExecutable:HaxeExecutable;
    final server:LanguageServer;
    final api:Vshaxe;

    var enableCompilationServer:Bool;

    public function new(hxmlDiscovery, haxeExecutable, server, api) {
        this.hxmlDiscovery = hxmlDiscovery;
        this.haxeExecutable = haxeExecutable;
        this.server = server;
        this.api = api;

        workspace.registerTaskProvider("hxml", this);
        workspace.onDidChangeConfiguration(_ -> updateEnableCompilationServer());
        updateEnableCompilationServer();
    }

    function updateEnableCompilationServer() {
        enableCompilationServer = workspace.getConfiguration("haxe").get("enableCompilationServer");
        var writeableApi:{enableCompilationServer:Bool} = cast api;
        writeableApi.enableCompilationServer = enableCompilationServer;
    }

    public function provideTasks(?token:CancellationToken):ProviderResult<Array<Task>> {
        return [for (file in hxmlDiscovery.files) {
            var definition:HaxeTaskDefinition = {
                type: "hxml",
                file: file
            };
            var exectuable = haxeExecutable.configuration.executable;
            var args = [file];
            if (server.displayPort != null && enableCompilationServer) {
                args = args.concat(["--connect", Std.string(server.displayPort)]);
            }
            var execution = new ProcessExecution(exectuable, args, {env: haxeExecutable.configuration.env});
            var task = new Task(definition, file, "haxe", execution, ["$haxe-absolute", "$haxe"]);
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
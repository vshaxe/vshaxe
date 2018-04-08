package vshaxe.tasks;

import vshaxe.helper.HaxeExecutable;
import vshaxe.server.LanguageServer;

private typedef WriteableApi = {
    enableCompilationServer:Bool,
    taskPresentation:vshaxe.TaskPresentationOptions
}

class HxmlTaskProvider {
    final hxmlDiscovery:HxmlDiscovery;
    final haxeExecutable:HaxeExecutable;
    final problemMatchers:Array<String>;
    final server:LanguageServer;
    final api:Vshaxe;

    var enableCompilationServer:Bool;
    var taskPresentation:TaskPresentationOptions;

    public function new(hxmlDiscovery, haxeExecutable, problemMatchers, server, api) {
        this.hxmlDiscovery = hxmlDiscovery;
        this.haxeExecutable = haxeExecutable;
        this.problemMatchers = problemMatchers;
        this.server = server;
        this.api = api;

        workspace.registerTaskProvider("hxml", this);
        workspace.onDidChangeConfiguration(_ -> updateTaskConfiguration());
        updateTaskConfiguration();
    }

    function updateTaskConfiguration() {
        enableCompilationServer = workspace.getConfiguration("haxe").get("enableCompilationServer");
        var presentation = workspace.getConfiguration("haxe").get("taskPresentation");
        taskPresentation = {
            echo: presentation.echo,
            reveal: switch (presentation.reveal) {
                case "always": Always;
                case "silent": Silent;
                case "never": Never;
                default: Always;
            },
            focus: presentation.focus,
            panel: switch (presentation.panel) {
                case "shared": Shared;
                case "dedicated": Dedicated;
                case "new": New;
                default: Shared;
            }
        };

        var writeableApi:WriteableApi = cast api;
        writeableApi.enableCompilationServer = enableCompilationServer;
        writeableApi.taskPresentation = taskPresentation;
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
            var task = new Task(definition, file, "haxe", execution, problemMatchers);
            task.group = TaskGroup.Build;
            task.presentationOptions = taskPresentation;
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
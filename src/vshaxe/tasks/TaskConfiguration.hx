package vshaxe.tasks;

import vshaxe.helper.HaxeExecutable;
import vshaxe.server.LanguageServer;

private typedef WriteableApi = {
	enableCompilationServer:Bool,
	taskPresentation:vshaxe.TaskPresentationOptions
}

class TaskConfiguration {
	final haxeExecutable:HaxeExecutable;
	final problemMatchers:Array<String>;
	final server:LanguageServer;
	final api:Vshaxe;
	var enableCompilationServer:Bool;
	var taskPresentation:TaskPresentationOptions;

	public function new(haxeExecutable, problemMatchers, server, api) {
		this.haxeExecutable = haxeExecutable;
		this.problemMatchers = problemMatchers;
		this.server = server;
		this.api = api;

		inline update();
		workspace.onDidChangeConfiguration(_ -> update());
	}

	function update() {
		enableCompilationServer = workspace.getConfiguration("haxe").get("enableCompilationServer", true);
		var presentation:{
			?echo:Bool,
			?reveal:String,
			?focus:Bool,
			?panel:String,
			?showReuseMessage:Bool,
			?clear:Bool
		} = workspace.getConfiguration("haxe").get("taskPresentation", {});

		taskPresentation = {
			echo: presentation.echo,
			reveal: switch presentation.reveal {
				case "always": Always;
				case "silent": Silent;
				case "never": Never;
				default: Always;
			},
			focus: presentation.focus,
			panel: switch presentation.panel {
				case "shared": Shared;
				case "dedicated": Dedicated;
				case "new": New;
				default: Shared;
			},
			showReuseMessage: presentation.showReuseMessage,
			clear: presentation.clear
		};

		var writeableApi:WriteableApi = cast api;
		writeableApi.enableCompilationServer = enableCompilationServer;
		writeableApi.taskPresentation = taskPresentation;
	}

	public function createTask(definition:TaskDefinition, name:String, args:Array<String>):Task {
		var exectuable = haxeExecutable.configuration.executable;
		if (server.displayPort != null && enableCompilationServer) {
			args = ["--connect", Std.string(server.displayPort)].concat(args);
		}
		var execution = new ProcessExecution(exectuable, args, {env: haxeExecutable.configuration.env});
		var task = new Task(definition, TaskScope.Workspace, name, "haxe", execution, problemMatchers);
		task.group = TaskGroup.Build;
		task.presentationOptions = taskPresentation;
		return task;
	}
}

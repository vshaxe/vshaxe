package vshaxe.tasks;

import vshaxe.configuration.HaxeInstallation;
import vshaxe.server.LanguageServer;

private typedef WriteableApi = {
	enableCompilationServer:Bool,
	taskPresentation:vshaxe.TaskPresentationOptions
}

class TaskConfiguration {
	final haxeInstallation:HaxeInstallation;
	final problemMatchers:Array<String>;
	final server:LanguageServer;
	final api:Vshaxe;
	var enableCompilationServer:Bool;
	var taskPresentation:TaskPresentationOptions;

	public function new(haxeInstallation, problemMatchers, server, api) {
		this.haxeInstallation = haxeInstallation;
		this.problemMatchers = problemMatchers;
		this.server = server;
		this.api = api;

		inline update();
		workspace.onDidChangeConfiguration(_ -> update());
	}

	function update() {
		enableCompilationServer = workspace.getConfiguration("haxe").get("enableCompilationServer", true);
		final presentation:{
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

		final writeableApi:WriteableApi = cast api;
		writeableApi.enableCompilationServer = enableCompilationServer;
		writeableApi.taskPresentation = taskPresentation;
	}

	public function createTask(definition:TaskDefinition, name:String, args:Array<String>):Task {
		final exectuable = haxeInstallation.haxe.configuration.executable;
		if (server.displayPort != null && enableCompilationServer) {
			args = ["--connect", Std.string(server.displayPort)].concat(args);
		}
		final execution = new ProcessExecution(exectuable, args, {env: haxeInstallation.env});
		final task = new Task(definition, TaskScope.Workspace, name, "haxe", execution, problemMatchers);
		task.group = TaskGroup.Build;
		task.presentationOptions = taskPresentation;
		return task;
	}
}

package vshaxe.tasks;

import vshaxe.display.DisplayArguments;
import vshaxe.display.HaxeDisplayArgumentsProvider;

class HaxeTaskProvider {
	final taskConfiguration:TaskConfiguration;
	final displayArguments:DisplayArguments;
	final haxeDisplayArgumentsProvider:HaxeDisplayArgumentsProvider;

	public function new(taskConfiguration, displayArguments, haxeDisplayArgumentsProvider) {
		this.taskConfiguration = taskConfiguration;
		this.displayArguments = displayArguments;
		this.haxeDisplayArgumentsProvider = haxeDisplayArgumentsProvider;
		tasks.registerTaskProvider("haxe", this);
	}

	public function provideTasks(?token:CancellationToken):ProviderResult<Array<Task>> {
		if (haxeDisplayArgumentsProvider.configurationCount == 0 || displayArguments.arguments == null) {
			return [];
		}

		final definition:HaxeTaskDefinition = {
			type: "haxe",
			args: "active configuration"
		};
		final task = taskConfiguration.createTask(definition, "active configuration", displayArguments.arguments);
		return [task];
	}

	public function resolveTask(task:Task, ?token:CancellationToken):ProviderResult<Task> {
		return task;
	}
}

private typedef HaxeTaskDefinition = TaskDefinition & {args:String};

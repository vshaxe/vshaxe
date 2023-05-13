package vshaxe.tasks;

class HxmlTaskProvider {
	final taskConfiguration:TaskConfiguration;
	final hxmlDiscovery:HxmlDiscovery;

	public function new(taskConfiguration, hxmlDiscovery) {
		this.taskConfiguration = taskConfiguration;
		this.hxmlDiscovery = hxmlDiscovery;
		tasks.registerTaskProvider("hxml", this);
	}

	public function provideTasks(?token:CancellationToken):ProviderResult<Array<Task>> {
		return [
			for (file in hxmlDiscovery.files) {
				final definition:HxmlTaskDefinition = {
					type: "hxml",
					file: file
				};
				taskConfiguration.createTask(definition, file, [file]);
			}
		];
	}

	public function resolveTask(task:Task, ?token:CancellationToken):ProviderResult<Task> {
		final definition:HxmlTaskDefinition = cast task.definition;
		final file = definition.file;
		return taskConfiguration.createTask(definition, file, [file]);
	}
}

typedef HxmlTaskDefinition = TaskDefinition & {file:String};

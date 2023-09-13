package vshaxe.tasks;

import haxe.io.Path;
import js.node.Fs.Fs;
import js.node.Os;
import sys.FileSystem;
import sys.io.File;
import vshaxe.configuration.HaxeInstallation;
import vshaxe.helper.PathHelper;
import vshaxe.helper.SemVer;
import vshaxe.server.LanguageServer;
import vshaxe.tasks.HxmlTaskProvider.HxmlTaskDefinition;

using Safety;

private typedef WriteableApi = {
	enableCompilationServer:Bool,
	taskPresentation:vshaxe.TaskPresentationOptions
}

class TaskConfiguration {
	final haxeInstallation:HaxeInstallation;
	final problemMatchers:Array<String>;
	final server:LanguageServer;
	final api:Vshaxe;
	final outputChannel:OutputChannel;

	var haxeVersion:SemVer;
	var enableCompilationServer:Bool;
	var taskPresentation:TaskPresentationOptions;

	public function new(haxeInstallation, problemMatchers, server, api) {
		this.haxeInstallation = haxeInstallation;
		this.problemMatchers = problemMatchers;
		this.server = server;
		this.api = api;
		this.outputChannel = window.createOutputChannel("haxe-task");

		inline update();
		workspace.onDidChangeConfiguration(_ -> update());

		tasks.onDidEndTask(e -> {
			var name = e.execution.task.name;
			var type = e.execution.task.definition.type;
			switch (type) {
				case "haxe":
					onTaskEnd("active configuration");

				case "hxml":
					final def:HxmlTaskDefinition = cast e.execution.task.definition;
					onTaskEnd(def.file);

				case _:
			}
		});
	}

	function update() {
		haxeVersion = try SemVer.ofString(haxeInstallation.haxe.configuration.version.or("")) catch (_) SemVer.DEFAULT;

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
		final executable = haxeInstallation.haxe.configuration.executable;

		if (server.displayPort != null && enableCompilationServer) {
			var host = server.displayHost ?? "127.0.0.1";
			args = ["--connect", host + ":" + Std.string(server.displayPort)].concat(args);
		}

		final haxe_4_3_0 = SemVer.ofString('4.3.0');
		if (haxeVersion >= haxe_4_3_0) {
			final path = getLogFile(name);
			final defineNamespace = haxeVersion == haxe_4_3_0 ? "message-" : "message.";

			args = args.concat([
				"-D",  '${defineNamespace}log-file=$path',
				"-D", '${defineNamespace}log-format=indent'
			]);
		}

		final execution = new ProcessExecution(executable, args, {env: haxeInstallation.env});
		final problemMatchers = haxeVersion < haxe_4_3_0 ? problemMatchers : [];
		final task = new Task(definition, TaskScope.Workspace, name, definition.type, execution, problemMatchers);
		task.group = TaskGroup.Build;
		task.presentationOptions = taskPresentation;
		return task;
	}

	function onTaskEnd(name:String):Void {
		if (haxeVersion < SemVer.ofString('4.3.0'))
			return;
		final path = getLogFile(name);

		if (FileSystem.exists(path) && !FileSystem.isDirectory(path)) {
			final diagnostics:Map<String, Array<Diagnostic>> = [];
			final problemMatcher = ~/^(\s*)(.+):(\d+): (?:lines \d+-(\d+)|character(?:s (\d+)-| )(\d+)) : (?:(Warning|Info) : (?:\((W[^\)]+)\) )?)?(.*)$/;

			function isEmpty(s:String)
				return s == null || s == "";

			function createRange() {
				var line = Std.parseInt(problemMatcher.matched(3)).or(1);
				var lineEnd = Std.parseInt(problemMatcher.matched(4)).or(line);

				var colEnd = Std.parseInt(problemMatcher.matched(6)).or(1);
				var col = Std.parseInt(problemMatcher.matched(5)).or(colEnd);

				return new Range(new Position(line - 1, col - 1), new Position(lineEnd - 1, colEnd - 1));
			}

			function convertIndentation(s:String):String {
				if (s.length < 3)
					return s;
				return s.substring(2).replace("  ", "⋅⋅⋅") + " ";
			}

			function postProcess(diagnostic:Diagnostic) {
				if (diagnostic.relatedInformation.or([]).length == 0)
					return;

				var message = diagnostic.message;
				for (rel in diagnostic.relatedInformation.or([])) {
					if (!rel.location.range.isEqual(diagnostic.range))
						return;
					message += "\n" + rel.message;
				}

				diagnostic.message = message;
				diagnostic.relatedInformation = [];
			}

			var diagnostic = null;
			final logs = File.getContent(path);

			for (line in logs.split("\n")) {
				if (problemMatcher.match(line)) {
					final file = PathHelper.absolutize(problemMatcher.matched(2).or(""), workspace.rootPath.or(""));
					final uri = Uri.file(file);

					if (isEmpty(problemMatcher.matched(1))) {
						if (diagnostic != null)
							postProcess(diagnostic);

						diagnostic = new Diagnostic(createRange(), problemMatcher.matched(9), switch problemMatcher.matched(7) {
							case null | "": Error;
							case "Warning": Warning;
							case "Info": Information;
							case _: Error;
						});

						diagnostic.code = problemMatcher.matched(8);
						if (diagnostic.code == "WDeprecated") {
							diagnostic.tags ??= [];
							diagnostic.tags.push(Deprecated);
						}

						if (!diagnostics.exists(file))
							diagnostics.set(file, [diagnostic]);
						else
							@:nullSafety(Off) diagnostics.get(file).push(diagnostic);
					} else if (diagnostic != null) {
						// Add related info
						var rel = new DiagnosticRelatedInformation(new Location(uri, createRange()),
							convertIndentation(problemMatcher.matched(1)) + problemMatcher.matched(9));

						if (diagnostic.relatedInformation == null)
							diagnostic.relatedInformation = [rel];
						else
							diagnostic.relatedInformation.push(rel);
					}
				}
			}

			if (diagnostic != null)
				postProcess(diagnostic);

			final clientDiagnostics = server.client?.diagnostics;
			if (clientDiagnostics != null) {
				if (diagnostics.empty()) {
					clientDiagnostics.clear();
				} else {
					final diagnostics = [for (file => diag in diagnostics) [(Uri.file(file) : Any), (diag : Any)]];

					// Clear previous diagnostics
					clientDiagnostics.forEach(function(uri, _, _) {
						final uriStr = uri.toString();
						if (!diagnostics.exists(item -> uriStr == (item[0] : Uri).toString()))
							diagnostics.push([uri, []]);
					});

					clientDiagnostics.set(diagnostics);
				}
			}

			// TODO: add some settings to _not_ delete the file?
			Fs.unlink(path, (err) -> if (err != null) outputChannel.appendLine('Error while removing log file: ' + err.message));
		} else {
			server.client?.diagnostics?.clear();
		}
	}

	function getLogFile(taskName:String):String {
		return Path.join([Os.tmpdir(), 'vshaxe-${workspace.name}-$taskName-errors.log']);
	}
}

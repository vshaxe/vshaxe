package builders;

class VSCodeTasksBuilder implements IBuilder {
    var cli:CliTools;

    public function new(cli) {
        this.cli = cli;
    }

    public function build(config:Config) {
        var base = Reflect.copy(template);
        for (target in config.targets) {
            base.tasks = buildTask(target, false).concat(buildTask(target, true));
        }
        base.tasks = base.tasks.filterDuplicates(function(t1, t2) return t1.taskName == t2.taskName);

        var tasksJson = haxe.Json.stringify(base, null, "    ");
        tasksJson = '// ${Warning.Message}\n$tasksJson';
        cli.saveContent(".vscode/tasks.json", tasksJson);
    }

    static var problemMatcher = {
        owner: "haxe",
        pattern: {
            "regexp": "^(.+):(\\d+): (?:lines \\d+-(\\d+)|character(?:s (\\d+)-| )(\\d+)) : (?:(Warning) : )?(.*)$",
            "file": 1,
            "line": 2,
            "endLine": 3,
            "column": 4,
            "endColumn": 5,
            "severity": 6,
            "message": 7
        }
    }

    static var template = {
        version: "0.1.0",
        command: "haxe",
        suppressTaskName: true,
        tasks: [],
        _runner: "terminal"
    }

    function buildTask(target:Target, debug:Bool):Array<Task> {
        var config = target.getConfig();
        var suffix = "";
        if (!config.impliesDebug && debug) suffix = " (debug)";

        var task:Task = {
            taskName: '$target$suffix',
            args: ["--run", "Build", "-t", target],
            problemMatcher: problemMatcher
        }

        if (config.impliesDebug || debug) {
            if (config.isBuildCommand) {
                task.isBuildCommand = true;
                task.taskName += " - BUILD";
            }
            if (config.isTestCommand) {
                task.isTestCommand = true;
                task.taskName += " - TEST";
            }
            task.args.push("--debug");
        }

        return [task].concat(config.targetDependencies.get().flatMap(buildTask.bind(_, debug)));
    }
}

typedef Task = {
    var taskName:String;
    var args:Array<String>;
    var problemMatcher:{};
    @:optional var isBuildCommand:Bool;
    @:optional var isTestCommand:Bool;
}
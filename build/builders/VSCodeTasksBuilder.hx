package builders;

class VSCodeTasksBuilder extends BaseBuilder {
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
        version: "2.0.0",
        command: "haxe",
        suppressTaskName: true,
        tasks: []
    }

    static var defaultTasks = [
        {
            taskName: "{install-all}",
            args: makeArgs(["--mode", "install", "--target", "all"]),
            problemMatcher: problemMatcher
        },
        {
            taskName: "{generate-complete-hxml}",
            args: makeArgs(["--display", "--target", "all"]),
            problemMatcher: problemMatcher
        },
        {
            taskName: "{generate-vscode-tasks}",
            args: makeArgs(["--gen-tasks", "--target", "all"]),
            problemMatcher: problemMatcher
        }
    ];

    override public function build(config:Config) {
        var base = Reflect.copy(template);
        for (name in config.targets) {
            var target = project.targets.getTarget(name);
            base.tasks = buildTask(target, false).concat(buildTask(target, true));
        }
        base.tasks = base.tasks.filterDuplicates(function(t1, t2) return t1.taskName == t2.taskName);
        base.tasks = base.tasks.concat(defaultTasks);

        var tasksJson = haxe.Json.stringify(base, null, "    ");
        tasksJson = '// ${Warning.Message}\n$tasksJson';
        cli.saveContent(".vscode/tasks.json", tasksJson);
    }

    function buildTask(target:Target, debug:Bool):Array<Task> {
        var suffix = "";
        if (!target.impliesDebug && debug) suffix = " (debug)";

        var task:Task = {
            taskName: '${target.name}$suffix',
            args: makeArgs(["-t", target.name]),
            problemMatcher: problemMatcher
        }

        if (target.impliesDebug || debug) {
            if (target.isBuildCommand) {
                task.isBuildCommand = true;
                task.taskName += " - BUILD";
            }
            if (target.isTestCommand) {
                task.isTestCommand = true;
                task.taskName += " - TEST";
            }
            task.args.push("--debug");
        }

        return [task].concat(target.targetDependencies.get().flatMap(
            function(s) return buildTask(project.targets.getTarget(s), debug)
        ));
    }

    static function makeArgs(additionalArgs:Array<String>):Array<String> {
        return ["--run", "Build"].concat(additionalArgs);
    }
}

typedef Task = {
    var taskName:String;
    var args:Array<String>;
    var problemMatcher:{};
    @:optional var isBuildCommand:Bool;
    @:optional var isTestCommand:Bool;
}
package;

import builders.*;

/** The build script for VSHaxe **/
class Main {
    static inline var PROJECT_FILE = "project.json";

    static function main() new Main();

    var cli:CliTools;

    function new() {
        var cliArgs:CliArguments = {
            targets: [],
            debug: false,
            mode: Build
        };

        var dryRun = false;
        var verbose = false;
        var genTasks = false;
        var display = false;
        var help = false;
        var modeStr = "build";

        var args = Sys.args();
        var argHandler = hxargs.Args.generate([
            @doc("One or multiple targets to build.")
            ["-t", "--target"] => function(name:String) cliArgs.targets.push(name),

            @doc("Build mode - accepted values are 'build', 'install', and 'both'.")
            ["-m", "--mode"] => function(mode:String) modeStr = mode,

            @doc("Build the target(s) in debug mode. Implies -debug, -D js_unflatten and -lib jstack.")
            ["--debug"] => function() cliArgs.debug = true,

            @doc("Perform a dry run (no command invocations). Implies -verbose.")
            ["--dry-run"] => function() dryRun = true,

            @doc("Output the commands that are executed.")
            ["-v", "--verbose"] => function() verbose = true,

            @doc("Generate a tasks.json to .vscode (and don't build anything).")
            ["--gen-tasks"] => function() genTasks = true,

            @doc("Generate a complete.hxml for auto completion (and don't build anything).")
            ["--display"] => function() display = true,

            @doc("Display this help text and exit.")
            ["--help"] => function() help = true,
        ]);

        Sys.setCwd(".."); // move out of /build

        try {
            argHandler.parse(args);
        } catch (e:Any) {
            Sys.println('$e\n\nAvailable commands:\n${argHandler.getDoc()}');
            Sys.exit(1);
        }

        cli = new CliTools(verbose, dryRun);
        if (args.length == 0 || help)
            cli.exit(argHandler.getDoc());

        if (!sys.FileSystem.exists(PROJECT_FILE)) cli.fail('Could not find $PROJECT_FILE.');
        var project = haxe.Json.parse(sys.io.File.getContent(PROJECT_FILE));

        validateTargets(cliArgs.targets);
        validateEnum("mode", modeStr, Mode.getConstructors());
        cliArgs.mode = Mode.createByName(getEnumName(modeStr));

        if (genTasks && display)
            cli.fail("Can only specify one: --gen-tasks or --display");

        if (genTasks) new VSCodeTasksBuilder(cli, project).build(cliArgs);
        else if (display) new DisplayHxmlBuilder(cli, project).build(cliArgs);
        else new HaxeBuilder(cli, project).build(cliArgs);
    }

    function validateTargets(targets:Array<String>) {
        var targetList = 'List of valid targets:\n  ${targets}';
        if (targets.length == 0)
            cli.fail("No target(s) specified! " + targetList);

        for (target in targets)
            validateEnum("target", target, targets);
    }

    function validateEnum<T>(name:String, value:T, validValues:Array<T>) {
        var validStrValues = [for (value in validValues) Std.string(value).toLowerCase()];
        if (validStrValues.indexOf(Std.string(value)) == -1)
            cli.fail('Unknown $name \'$value\'. Valid values are: $validStrValues');
    }

    function getEnumName(cliName:String):String {
        return cliName.substr(0, 1).toUpperCase() + cliName.substr(1);
    }
}

typedef CliArguments = {
    var targets:Array<String>;
    var debug:Bool;
    var mode:Mode;
}

enum Mode {
    Build;
    Install;
    Both;
}
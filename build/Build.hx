package;

import builders.*;

/** The build script for VSHaxe **/
class Build {
    static function main() new Build();

    var cli:CliTools;

    function new() {
        var config = {
            targets: [],
            installDeps: false,
            debug: false
        };

        var dryRun = false;
        var verbose = false;
        var genTasks = false;
        var help = false;

        var args = Sys.args();
        var argHandler = hxargs.Args.generate([
            @doc("One or multiple targets to build. One of: [].")
            ["-t", "--target"] => function(name:String) config.targets.push(new Target(name)),

            @doc("Install the haxelib dependencies for the given targets.")
            ["--install"] => function() config.installDeps = true,

            @doc("Build the target(s) in debug mode. Implies -debug, -D js_unflatten and -lib jstack.")
            ["--debug"] => function() config.debug = true,

            @doc("Perform a dry run (no command invocations). Implies -verbose.")
            ["--dry-run"] => function() dryRun = true,

            @doc("Output the commands that are executed.")
            ["--verbose"] => function() verbose = true,

            @doc("Generate a tasks.json to .vscode (and don't build anything).")
            ["--gen-tasks"] => function() genTasks = true,

            @doc("Display this help text and exit.")
            ["--help"] => function() help = true,
        ]);

        inline function getHelp()
            return argHandler.getDoc().replace("[]", Std.string(Target.list));

        try {
            argHandler.parse(args);
        } catch (e:Any) {
            Sys.println('$e\n\nAvailable commands:\n${getHelp()}');
            Sys.exit(1);
        }

        cli = new CliTools(verbose, dryRun);

        if (args.length == 0 || help)
            cli.exit(getHelp());

        validateTargets(config.targets);

        Sys.setCwd(".."); // move out of /build

        var builder:IBuilder = if (genTasks) new VSCodeTasksBuilder(cli) else new HaxeBuilder(cli);
        builder.build(config);
    }

    function validateTargets(targets:Array<Target>) {
        var validTargets = Target.list;
        var targetList = 'List of valid targets:\n  ${validTargets}';
        if (targets.length == 0)
            cli.fail("No target(s) specified! " + targetList);

        for (target in targets) {
            if (validTargets.indexOf(target) == -1) {
                cli.fail('Unknown target \'$target\'. $targetList');
            }
        }
    }
}

typedef Config = {
    var targets:Array<Target>;
    var debug:Bool;
    var installDeps:Bool;
}
package;

/** The build script for VSHaxe **/
class Build {
    static function main() new Build();

    var cli:CliTools;

    function new() {
        var targets = [];
        var installDeps = false;
        var dryRun = false;
        var verbose = false;
        var debug = false;
        var genTasks = false;
        var help = false;

        var args = Sys.args();
        var argHandler = hxargs.Args.generate([
            @doc("One or multiple targets to build. One of: [].")
            ["-t", "--target"] => function(name:String) targets.push(new Target(name)),

            @doc("Install the haxelib dependencies for the given targets.")
            ["--install"] => function() installDeps = true,

            @doc("Perform a dry run (no command invocations). Implies -verbose.")
            ["--dry-run"] => function() dryRun = true,

            @doc("Output the commands that are executed.")
            ["--verbose"] => function() verbose = true,

            @doc("Build the target(s) in debug mode. Implies -debug, -D js_unflatten and -lib jstack.")
            ["--debug"] => function() debug = true,

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

        validateTargets(targets);

        Sys.setCwd(".."); // move out of /build
        if (genTasks)
            TaskBuilder.build(targets, cli);
        else for (target in targets)
            buildTarget(target, debug, installDeps);
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

    function installTarget(target:Target, debug:Bool) {
        cli.println('Installing Haxelibs for \'$target\'...\n');

        var config = target.getConfig();

        cli.runCommands(config.installCommands);

        // TODO: move defaults into config
        cli.run("haxelib", Haxelibs.HxNodeJS.installArgs);

        for (lib in config.haxelibs.safeCopy())
            cli.run("haxelib", lib.installArgs);

        // TODO: move defaults into config
        if (debug)
            cli.run("haxelib", Haxelibs.JStack.installArgs);

        cli.println('');
    }

    function buildTarget(target:Target, debug:Bool, installDeps:Bool) {
        var config = target.getConfig();
        debug = debug || config.impliesDebug;

        if (installDeps)
            installTarget(target, debug);

        cli.println('Building \'$target\'...\n');

        for (dependency in config.targetDependencies.safeCopy())
            buildTarget(dependency, debug, installDeps);

        var args = config.args.safeCopy();
        if (args.length == 0)
            return;

        if (args.indexOf("-js") != -1) {
            args = args.concat([
                // TODO: move defaults into config
                "-lib", Haxelibs.HxNodeJS.name
            ]);
        }

        var haxelibs = config.haxelibs.safeCopy();

        if (debug) {
            var debugArgs = config.debugArgs.safeCopy();
            debugArgs = debugArgs.concat([
                // TODO: move defaults into config
                "-debug",
                "-D", "js_unflatten",
                "-lib", Haxelibs.JStack.name
            ]);
            args = args.concat(debugArgs);
        }

        for (lib in haxelibs) {
            args.push("-lib");
            args.push(lib.name);
        }

        cli.inDir(config.cwd, function() {
            cli.runCommands(config.beforeBuildCommands);
            cli.run("haxe", args);
            cli.runCommands(config.afterBuildCommands);
        });

        cli.println("\n----------------------------------------------\n");
    }
}
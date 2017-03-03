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

        var args = Sys.args();
        var argHandler = hxargs.Args.generate([
            @doc("One or multiple targets to build. One of: [all, client, language-server, language-server-tests, tm-language-conversion, tm-language-tests, formatter-cli, formatter-tests].")
            ["-t", "--target"] => function(name:String) targets.push(new Target(name)),

            @doc("Installs the haxelib dependencies for the given targets.")
            ["--install"] => function() installDeps = true,

            @doc("Performs a dry run (no command invocations). Implies -verbose.")
            ["--dry-run"] => function() dryRun = true,

            @doc("Outputs the commands that are executed.")
            ["--verbose"] => function() verbose = true,

            @doc("Build the target(s) in debug mode. Implies -debug, -D js_unflatten and -lib jstack.")
            ["--debug"] => function() debug = true,
        ]);
        argHandler.parse(args);

        cli = new CliTools(verbose, dryRun);

        if (args.length == 0)
            cli.exit(argHandler.getDoc(), 0);

        if (targets.length == 0)
            cli.exit("No target(s) specified!\n", 1);

        validateTargets(targets);
        build(targets, debug, installDeps);
    }

    function validateTargets(targets:Array<Target>) {
        var validTargets = Target.list;
        for (target in targets) {
            if (validTargets.indexOf(target) == -1) {
                cli.exit('Unknown target \'$target\'. Lists of valid targets:\n  $validTargets', 1);
            }
        }
    }

    function build(targets:Array<Target>, debug:Bool, installDeps:Bool) {
        Sys.setCwd(".."); // move out of /build
        for (target in targets) buildTarget(target, debug, installDeps);
    }

    function installTarget(target:Target, debug:Bool) {
        cli.println('Installing Haxelibs for \'$target\'...\n');

        var config = target.getConfig();

        // TODO: move defaults into config
        cli.run("haxelib", Haxelibs.HxNodeJS.installArgs);

        for (lib in config.haxelibs.safeCopy())
            cli.run("haxelib", lib.installArgs);

        // TODO: move defaults into config
        if (debug || config.impliesDebug)
            cli.run("haxelib", Haxelibs.JStack.installArgs);

        cli.println('');
    }

    function buildTarget(target:Target, debug:Bool, installDeps:Bool) {
        if (installDeps)
            installTarget(target, debug);

        cli.println('Building \'$target\'...\n');

        var config = target.getConfig();

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

        if (debug || config.impliesDebug) {
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
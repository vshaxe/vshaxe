package;

/** The build script for VSHaxe **/
class Build {
    static function main() {
        new Build();
    }

    var dryRun = false;
    var verbose = false;

    function new() {
        var targets = [];
        var installDeps = false;
        var debug = false;
        var args = Sys.args();
        var argHandler = hxargs.Args.generate([
            @doc("One or multiple targets to build. One of: [all, client, language-server, language-server-tests, tm-language-conversion, tm-language-tests, formatter-cli, formatter-tests].")
            ["-t", "--target"] => function(name:String) targets.push(new Target(name)),

            @doc("Installs the haxelib dependencies for the given targets.")
            ["--install"] => function() installDeps = true,

            @doc("Performs a dry run (no command invocations). Implies -verbose.")
            ["--dry-run"] => function() {
                dryRun = true;
                verbose = true;
            },

            @doc("Outputs the commands that are executed.")
            ["--verbose"] => function() verbose = true,

            @doc("Build the target(s) in debug mode. Implies -debug, -D js_unflatten and -lib jstack.")
            ["--debug"] => function() debug = true,
        ]);
        if (args.length == 0)
            printHelpAndExit(argHandler.getDoc(), 0);

        argHandler.parse(args);

        if (targets.length == 0)
            printHelpAndExit("No target(s) specified!\n", 1);

        validateTargets(targets);
        build(targets, debug, installDeps);
    }

    function printHelpAndExit(doc, code) {
        Sys.println("VSHaxe Build Script");
        Sys.println(doc);
        Sys.exit(code);
    }

    function validateTargets(targets:Array<Target>) {
        var validTargets = Target.list;
        for (target in targets) {
            if (validTargets.indexOf(target) == -1) {
                printHelpAndExit('Unknown target \'$target\'. Lists of valid targets:\n  $validTargets', 1);
            }
        }
    }

    function build(targets:Array<Target>, debug:Bool, installDeps:Bool) {
        // move out of /build
        Sys.setCwd("..");
        for (target in targets) buildTarget(target, debug, installDeps);
    }

    function installTarget(target:Target, debug:Bool) {
        if (verbose) Sys.println('Installing Haxelibs for \'$target\'...\n');

        var config = target.getConfig();

        // TODO: move defaults into config
        run("haxelib", Haxelibs.HxNodeJS.installArgs);

        for (lib in getArray(config.haxelibs))
            run("haxelib", lib.installArgs);

        // TODO: move defaults into config
        if (debug || config.impliesDebug)
            run("haxelib", Haxelibs.JStack.installArgs);

        if (verbose) Sys.println('');
    }

    function buildTarget(target:Target, debug:Bool, installDeps:Bool) {
        if (installDeps)
            installTarget(target, debug);

        if (verbose) Sys.println('Building \'$target\'...\n');

        var config = target.getConfig();

        for (dependency in getArray(config.targetDependencies))
            buildTarget(dependency, debug, installDeps);

        var args = getArray(config.args);
        if (args.length == 0)
            return;

        if (args.indexOf("-js") != -1) {
            args = args.concat([
                // TODO: move defaults into config
                "-lib", Haxelibs.HxNodeJS.name
            ]);
        }

        var haxelibs = getArray(config.haxelibs);

        if (debug || config.impliesDebug) {
            var debugArgs = getArray(config.debugArgs);
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

        inDir(config.cwd, function() {
            runCommands(config.beforeBuildCommands);
            run("haxe", args);
            runCommands(config.afterBuildCommands);
        });

        if (verbose) Sys.println("\n----------------------------------------------\n");
    }

    function runCommands(commands:Array<Array<String>>) {
        for (command in getArray(commands))
            runCommand(command);
    }

    function runCommand(command:Array<String>) {
        if (command.length == 0) return;
        var executable = command[0];
        command.shift();
        run(executable, command);
    }

    function getArray<T>(a:Array<T>):Array<T> {
        return if (a == null) [] else a.copy();
    }

    function inDir(dir:String, f:Void->Void) {
        var oldCwd = Sys.getCwd();
        setCwd(dir);
        f();
        setCwd(oldCwd);
    }

    function setCwd(dir:String) {
        if (dir == null) return;
        if (verbose) Sys.println("cd " + dir);
        Sys.setCwd(dir);
    }

    function run(command:String, args:Array<String>) {
        if (verbose) Sys.println(command + " " + args.join(" "));
        if (!dryRun) {
            var result = Sys.command(command, args);
            if (result != 0)
                Sys.exit(result);
        }
    }
}
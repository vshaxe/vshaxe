package builders;

class HaxeBuilder implements IBuilder {
    var cli:CliTools;

    public function new(cli) {
        this.cli = cli;
    }

    public function build(config:Config) {
        for (target in config.targets)
            buildTarget(target, config.debug, config.mode);
    }

    function installTarget(target:Target, debug:Bool) {
        cli.println('Installing Haxelibs for \'$target\'...\n');

        var config = target.getConfig();

        cli.runCommands(config.installCommands);

        // TODO: move defaults into config
        cli.run("haxelib", Haxelibs.HxNodeJS.installArgs.get());

        for (lib in config.haxelibs.get())
            cli.run("haxelib", lib.installArgs.get());

        // TODO: move defaults into config
        if (debug)
            cli.run("haxelib", Haxelibs.JStack.installArgs.get());

        cli.println('');
    }

    function buildTarget(target:Target, debug:Bool, mode:Mode) {
        var config = target.getConfig();
        debug = debug || config.impliesDebug;

        if (mode != Build)
            installTarget(target, debug);

        if (mode == Install)
            return;

        cli.println('Building \'$target\'...\n');

        for (dependency in config.targetDependencies.get())
            buildTarget(dependency, debug, mode);

        var args = config.args.get();
        if (args.length == 0)
            return;

        if (args.indexOf("-js") != -1) {
            args = args.concat([
                // TODO: move defaults into config
                "-lib", Haxelibs.HxNodeJS.name
            ]);
        }

        var haxelibs = config.haxelibs.get();

        if (debug) {
            var debugArgs = config.debugArgs.get();
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

        for (cp in config.classPaths.get()) {
            args.push("-cp");
            args.push(cp);
        }

        for (define in config.defines.get()) {
            args.push("-D");
            args.push(define);
        }

        cli.inDir(config.cwd, function() {
            cli.runCommands(config.beforeBuildCommands);
            cli.run("haxe", args);
            cli.runCommands(config.afterBuildCommands);
        });

        cli.println("\n----------------------------------------------\n");
    }
}
package builders;

class HaxeBuilder implements IBuilder {
    var cli:CliTools;

    public function new(cli) {
        this.cli = cli;
    }

    public function build(config:Config) {
        for (target in config.targets)
            buildTarget(target, config.project, config.debug, config.mode);
    }

    function installTarget(target:String, project:Project, debug:Bool) {
        cli.println('Installing Haxelibs for \'$target\'...\n');

        var args = project.targets.getTarget(target);
        cli.runCommands(args.installCommands);

        inline function getInstallArgs(lib:String)
            return project.haxelibs.get().getHaxelib(lib).installArgs.get();

        // TODO: move defaults into config
        cli.run("haxelib", getInstallArgs("hxnodejs"));

        for (lib in args.haxelibs.get())
            cli.run("haxelib", getInstallArgs(lib));

        // TODO: move defaults into config
        if (debug)
            cli.run("haxelib", getInstallArgs("jstack"));

        cli.println('');
    }

    function buildTarget(target:String, project:Project, debug:Bool, mode:Mode) {
        var config = project.targets.getTarget(target);
        debug = debug || config.impliesDebug;

        if (mode != Build)
            installTarget(target, project, debug);

        if (mode == Install)
            return;

        cli.println('Building \'$target\'...\n');

        for (dependency in config.targetDependencies.get())
            buildTarget(dependency, project, debug, mode);

        var args = config.args.get();
        if (args.length == 0)
            return;

        if (args.indexOf("-js") != -1) {
            args = args.concat([
                // TODO: move defaults into config
                "-lib", "hxnodejs"
            ]);
        }

        var haxelibs = config.haxelibs.get();

        if (debug) {
            var debugArgs = config.debugArgs.get();
            debugArgs = debugArgs.concat([
                // TODO: move defaults into config
                "-debug",
                "-D", "js_unflatten",
                "-lib", "jstack"
            ]);
            args = args.concat(debugArgs);
        }

        for (lib in haxelibs) {
            args.push("-lib");
            args.push(project.haxelibs.get().getHaxelib(lib).name);
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
package builders;

class HaxeBuilder implements IBuilder {
    var cli:CliTools;

    public function new(cli) {
        this.cli = cli;
    }

    public function build(config:Config) {
        for (name in config.targets) {
            var target = config.project.targets.getTarget(name);
            buildTarget(target, config.project, config.debug, config.mode);
        }
    }

    function installTarget(target:Target, project:Project, debug:Bool) {
        cli.println('Installing Haxelibs for \'${target.name}\'...\n');

        cli.runCommands(target.installCommands);

        inline function getInstallArgs(lib:String)
            return project.haxelibs.get().getHaxelib(lib).installArgs.get();

        // TODO: move defaults into config
        cli.run("haxelib", getInstallArgs("hxnodejs"));

        for (lib in target.haxelibs.get())
            cli.run("haxelib", getInstallArgs(lib));

        // TODO: move defaults into config
        if (debug)
            cli.run("haxelib", getInstallArgs("jstack"));

        cli.println('');
    }

    function buildTarget(target:Target, project:Project, debug:Bool, mode:Mode) {
        debug = debug || target.impliesDebug;

        if (mode != Build)
            installTarget(target, project, debug);

        for (dependency in target.targetDependencies.get())
            buildTarget(project.targets.getTarget(dependency), project, debug, mode);

        if (mode == Install)
            return;

        cli.println('Building \'${target.name}\'...\n');

        var args = target.args.get();
        if (args.length == 0)
            return;

        if (args.indexOf("-js") != -1) {
            args = args.concat([
                // TODO: move defaults into config
                "-lib", "hxnodejs"
            ]);
        }

        var haxelibs = target.haxelibs.get();

        if (debug) {
            var debugArgs = target.debugArgs.get();
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

        for (cp in target.classPaths.get()) {
            args.push("-cp");
            args.push(cp);
        }

        for (define in target.defines.get()) {
            args.push("-D");
            args.push(define);
        }

        cli.inDir(target.workingDirectory, function() {
            cli.runCommands(target.beforeBuildCommands);
            cli.run("haxe", args);
            cli.runCommands(target.afterBuildCommands);
        });

        cli.println("\n----------------------------------------------\n");
    }
}
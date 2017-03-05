package builders;

class HaxeBuilder extends BaseBuilder {
    override public function build(cliArgs:CliArguments) {
        for (name in cliArgs.targets)
            buildTarget(resolveTarget(name), cliArgs.debug, cliArgs.mode);
    }

    function installTarget(target:Target, debug:Bool) {
        cli.println('Installing Haxelibs for \'${target.name}\'...\n');

        cli.runCommands(target.installCommands);

        inline function getInstallArgs(lib:String)
            return resolveHaxelib(lib).installArgs.get();

        // TODO: move defaults into config
        cli.run("haxelib", getInstallArgs("hxnodejs"));

        for (lib in target.haxelibs.get())
            cli.run("haxelib", getInstallArgs(lib));

        // TODO: move defaults into config
        if (debug)
            cli.run("haxelib", getInstallArgs("jstack"));

        cli.println('');
    }

    function buildTarget(target:Target, debug:Bool, mode:Mode) {
        debug = debug || target.impliesDebug;

        if (mode != Build)
            installTarget(target, debug);

        for (dependency in target.targetDependencies.get())
            buildTarget(resolveTarget(dependency), debug, mode);

        if (mode == Install)
            return;

        cli.println('Building \'${target.name}\'...\n');

        var args = collectHxmlArgs(target);
        if (target.debug != null)
        args = args.concat(collectHxmlArgs(target.debug));

        if (debug) {
            args = args.concat([
                // TODO: move defaults into config
                "-debug",
                "-D", "js_unflatten",
                "-lib", "jstack"
            ]);
        }

        cli.inDir(target.workingDirectory, function() {
            cli.runCommands(target.beforeBuildCommands);
            cli.run("haxe", args);
            cli.runCommands(target.afterBuildCommands);
        });

        cli.println("\n----------------------------------------------\n");
    }

    function collectHxmlArgs(targetArgs:TargetArguments):Array<String> {
        var args = targetArgs.args.get();
        if (args.length == 0)
            return [];

        if (args.indexOf("-js") != -1) {
            args = args.concat([
                // TODO: move defaults into config
                "-lib", "hxnodejs"
            ]);
        }

        var haxelibs = targetArgs.haxelibs.get();

        for (lib in haxelibs) {
            args.push("-lib");
            args.push(resolveHaxelib(lib).name);
        }

        for (cp in targetArgs.classPaths.get()) {
            args.push("-cp");
            args.push(cp);
        }

        for (define in targetArgs.defines.get()) {
            args.push("-D");
            args.push(define);
        }

        return args;
    }
}
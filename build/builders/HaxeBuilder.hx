package builders;

class HaxeBuilder extends BaseBuilder {
    override public function build(cliArgs:CliArguments) {
        for (name in cliArgs.targets)
            buildTarget(resolveTarget(name), cliArgs.debug, cliArgs.mode);
    }

    function installTarget(target:Target, debug:Bool) {
        cli.println('Installing Haxelibs for \'${target.name}\'...\n');

        cli.runCommands(target.installCommands);

        // TODO: might wanna avoid calling resolveTargetHxml() twice
        var libs = resolveTargetHxml(target, debug, false, false).haxelibs.get();
        libs = libs.filterDuplicates(function(lib1, lib2) return lib1 == lib2);
        for (lib in libs)
            cli.run("haxelib", resolveHaxelib(lib).installArgs.get());

        cli.println('');
    }

    function buildTarget(target:Target, debug:Bool, mode:Mode) {
        debug = debug || (target.args != null && target.args.debug);

        if (mode != Build)
            installTarget(target, debug);

        for (dependency in target.targetDependencies.get())
            buildTarget(resolveTarget(dependency), debug, mode);

        if (mode == Install)
            return;

        cli.println('Building \'${target.name}\'...\n');

        var workingDirectory = null;
        if (target.args != null) workingDirectory = target.args.workingDirectory;
        cli.inDir(workingDirectory, function() {
            cli.runCommands(target.beforeBuildCommands);
            if (!target.composite)
                cli.run("haxe", printHxml(resolveTargetHxml(target, debug, false, false)));
            cli.runCommands(target.afterBuildCommands);
        });

        cli.println("\n----------------------------------------------\n");
    }

    function printHxml(hxml:Hxml):Array<String> {
        if (hxml == null)
            return [];

        var args = [];

        for (lib in hxml.haxelibs.get()) {
            args.push("-lib");
            args.push(resolveHaxelib(lib).name);
        }

        for (cp in hxml.classPaths.get()) {
            args.push("-cp");
            args.push(cp);
        }

        for (define in hxml.defines.get()) {
            args.push("-D");
            args.push(define);
        }

        if (hxml.deadCodeElimination != null) {
            args.push("-dce");
            args.push(hxml.deadCodeElimination);
        }

        if (hxml.noInline == true) args.push('--no-inline');

        if (hxml.debug) args.push("-debug");

        if (hxml.main != null) {
            args.push('-main');
            args.push(hxml.main);
        }

        if (hxml.packageName != null) args.push(hxml.packageName);

        if (hxml.output != null) {
            args.push('-${hxml.output.target}');
            args.push(hxml.output.path);
        }

        return args;
    }
}
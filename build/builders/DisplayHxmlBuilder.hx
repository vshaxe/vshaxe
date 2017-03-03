package builders;

import Target.TargetArguments;

class DisplayHxmlBuilder implements IBuilder {
    var cli:CliTools;

    public function new(cli) {
        this.cli = cli;
    }

    public function build(config:Config) {
       var classPaths = [];
       var defines = [];
       var haxelibs = [];
       forEachTarget(targetsToArgs(config.targets), function(args) {
            classPaths = classPaths.concat(args.classPaths.get().map(function(cp) {
                return if (args.cwd == null) cp else haxe.io.Path.join([args.cwd, cp]);
            }));
            defines = defines.concat(args.defines.get());
            haxelibs = haxelibs.concat(args.haxelibs.get().map(function(haxelib) return haxelib.name));
        });
        var hxml = ['# ${Warning.Message}'];
        for (cp in classPaths) hxml.push('-cp $cp');
        for (define in defines) hxml.push('-D $define');
        for (lib in haxelibs) hxml.push('-lib $lib');

        var hxml = hxml.filterDuplicates(function(s1, s2) return s1 == s2);
        // TODO: get rid of these hacks
        hxml.push("-cp build");
        hxml.push("-lib hxnodejs");
        hxml.push("-lib jstack");
        hxml.push("-js some.js");

        hxml.push("-debug"); // we usually always want -debug in display configs

        cli.saveContent("complete.hxml", hxml.join("\n"));
    }

    function forEachTarget(targets:Array<TargetArguments>, callback:TargetArguments->Void) {
        for (target in targets) {
            callback(target);
            forEachTarget(targetsToArgs(target.targetDependencies.get()), callback);
        }
    }

    function targetsToArgs(targets:Array<Target>):Array<TargetArguments>
        return targets.map(function(target) return target.getConfig());
}
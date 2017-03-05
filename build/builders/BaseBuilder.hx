package builders;

/** sounds like an RTS... **/
class BaseBuilder implements IBuilder {
    var cli:CliTools;
    var defaults:Project;
    var project:Project;

    public function new(cli:CliTools, defaults:Project, project:Project) {
        this.cli = cli;
        this.defaults = defaults;
        this.project = project;
    }

    public function build(cliArgs:CliArguments) {}

    function resolveHaxelib(name:String):Haxelib {
        for (lib in project.haxelibs)
            if (lib.name == name)
                return lib;
        return null;
    }

    function resolveTarget(name:String):Target {
        for (target in project.targets)
            if (target.name == name)
                return target;
        for (target in defaults.targets)
            if (target.name == name)
                return target;
        return null;
    }

    function resolveTargets(names:Array<String>):Array<Target> {
        return names.map(resolveTarget);
    }

    function resolveTargetHxml(target:Target, debug:Bool, flatten:Bool):Hxml {
        var hxmls:Array<Hxml> = [target, target.debug];
        if (debug) hxmls.push({ args: ["-debug"] });

        var inherited = resolveInherited(target);
        if (inherited != null) hxmls.push(inherited);

        if (flatten) {
            var dependencyHxmls = resolveTargets(target.targetDependencies.get()).map(resolveTargetHxml.bind(_, debug, flatten));
            hxmls = hxmls.concat(dependencyHxmls);
        }

        return mergeHxmls(hxmls, flatten);
    }

    function resolveInherited(target:Target):Target {
        if (target.inherit != null) return resolveTarget(target.inherit);
        if (project.inherit != null) return resolveTarget(project.inherit);
        return null;
    }

    function mergeHxmls(hxmls:Array<Hxml>, flatten:Bool):Hxml {
        var classPaths = [];
        var defines = [];
        var haxelibs = [];
        var args = [];

        function merge(hxml:Hxml) {
            if (hxml == null) return;
            var rawClassPaths = hxml.classPaths.get();
            if (flatten) rawClassPaths = rawClassPaths.map(function(cp) return haxe.io.Path.join([hxml.workingDirectory, cp]));
            classPaths = classPaths.concat(rawClassPaths);
            defines = defines.concat(hxml.defines.get());
            haxelibs = haxelibs.concat(hxml.haxelibs.get());
            args = args.concat(hxml.args.get());
        }

        for (hxml in hxmls) merge(hxml);

        return {
            workingDirectory: '',
            classPaths: classPaths,
            defines: defines,
            haxelibs: haxelibs,
            args: args
        };
    }
}
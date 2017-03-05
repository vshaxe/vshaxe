package builders;

/** sounds like an RTS... **/
class BaseBuilder implements IBuilder {
    var cli:CliTools;
    var project:Project;

    public function new(cli:CliTools, project:Project) {
        this.cli = cli;
        this.project = project;
    }

    public function build(config:Config) {}

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
        return null;
    }

    function resolveTargets(names:Array<String>):Array<Target> {
        return names.map(resolveTarget);
    }
}
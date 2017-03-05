package;

typedef Named = {
    public var name(default,null):String;
}

typedef Project = {
    /** name of a target in defaults.json to base all targets in this config on **/
    @:optional var inherit(default,null):String;
    var haxelibs(default,null):Array<Haxelib>;
    var targets(default,null):Array<Target>;
}

/** simn is gonna love this naming... **/
typedef PlacedProject = {
    >Project,
    var directory(default,null):String;
    var subProjects:Array<PlacedProject>;
}

typedef Haxelib = {
    >Named,
    var installArgs(default,null):Array<String>;
}

typedef Target = {
    >Named,
    >TargetArguments,
    /** Whether this target is just a collection of other targets **/
    @:optional var composite(default,null):Bool;
    /** name of a target in defaults.json to base this config on **/
    @:optional var inherit(default,null):String;
    /** arguments that only apply in debug mode **/
    @:optional var debug(default,null):TargetArguments;
    /** arguments that only apply for display **/
    @:optional var display(default,null):TargetArguments;

    /** VSCode tasks.json config **/
    @:optional var isBuildCommand(default,null):Bool;
    @:optional var isTestCommand(default,null):Bool;
}

typedef TargetArguments = {
    @:optional var targetDependencies(default,null):Array<String>;
    /** additional, non-haxelib install commands (npm install...) **/
    @:optional var installCommands(default,null):Array<Array<String>>;
    @:optional var beforeBuildCommands(default,null):Array<Array<String>>;
    @:optional var afterBuildCommands(default,null):Array<Array<String>>;
    @:optional var args(default,null):Hxml;
}

typedef Hxml = {
    @:optional var workingDirectory:String; // not read-only, meh
    @:optional var classPaths(default,null):Array<String>;
    @:optional var defines(default,null):Array<String>;
    @:optional var haxelibs(default,null):Array<String>;
    @:optional var debug(default,null):Bool;
    @:optional var output(default,null):Output;
    @:optional var deadCodeElimination(default,null):String; // TODO enum abstract
    @:optional var noInline(default,null):Bool;
    @:optional var main(default,null):String; // can only specify either main or package, but you could specify both here :/
    @:optional var packageName(default,null):String;
}

typedef Output = {
    var target(default,null):String; // TODO enum abstract
    var path(default,null):String;
}

// https://github.com/elnabo/json2object/issues/9
/*@:forward(iterator)
abstract ArrayHandle<T>(Array<T>) from Array<T> {
    public function get() {
        return if (this == null) [] else this.copy();
    }
}*/
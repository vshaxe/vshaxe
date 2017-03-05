package;

typedef Project = {
    /** name of a target in defaults.json to base all targets in this config on **/
    @:optional var inherit(default,null):String;
    var haxelibs(default,null):ArrayHandle<Haxelib>;
    var targets(default,null):ArrayHandle<Target>;
}

typedef Haxelib = {
    var name(default,null):String;
    var installArgs(default,null):ArrayHandle<String>;
}

typedef Target = {
    >TargetArguments,
    /** name of a target in defaults.json to base this config on **/
    @:optional var inherit(default,null):String;
    /** name of the target - must be unique! **/
    var name(default,null):String;
    /** whether this target _defaults_ mode by default (tests mostly) **/
    @:optional var impliesDebug(default,null):Bool;
    /** arguments that only apply in debug mode **/
    @:optional var debug(default,null):TargetArguments;
    @:optional var isBuildCommand(default,null):Bool;
    @:optional var isTestCommand(default,null):Bool;
}

typedef TargetArguments = {
    >Hxml,
    @:optional var targetDependencies(default,null):ArrayHandle<String>;
    /** additional, non-haxelib install commands (npm install...) **/
    @:optional var installCommands(default,null):ArrayHandle<ArrayHandle<String>>;
    @:optional var beforeBuildCommands(default,null):ArrayHandle<ArrayHandle<String>>;
    @:optional var afterBuildCommands(default,null):ArrayHandle<ArrayHandle<String>>;
}

typedef Hxml = {
    @:optional var workingDirectory(default,null):String;
    @:optional var classPaths(default,null):ArrayHandle<String>;
    @:optional var defines(default,null):ArrayHandle<String>;
    @:optional var haxelibs(default,null):ArrayHandle<String>;
    /** "unstructured" arguments **/
    @:optional var args(default,null):ArrayHandle<String>;
}

@:forward(iterator)
abstract ArrayHandle<T>(Array<T>) from Array<T> {
    public function get() {
        return if (this == null) [] else this.copy();
    }
}
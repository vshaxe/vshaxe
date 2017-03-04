package;

typedef Project = {
    var haxelibs(default,null):ArrayHandle<Haxelib>;
    var targets(default,null):ArrayHandle<TargetArguments>;
}

typedef Haxelib = {
    var name(default,null):String;
    var installArgs(default,null):ArrayHandle<String>;
}

typedef TargetArguments = {
    var name(default,null):String;
    @:optional var classPaths(default,null):ArrayHandle<String>;
    @:optional var defines(default,null):ArrayHandle<String>;
    @:optional var args(default,null):ArrayHandle<String>;
    @:optional var targetDependencies(default,null):ArrayHandle<String>;
    @:optional var haxelibs(default,null):ArrayHandle<String>;
    /** additional, non-haxelib install commands (npm install...) **/
    @:optional var installCommands(default,null):ArrayHandle<ArrayHandle<String>>;
    @:optional var cwd:String;
    /** -debug, -D js_unflatten and -lib jstack are implied **/
    @:optional var debugArgs(default,null):ArrayHandle<String>;
    @:optional var beforeBuildCommands(default,null):ArrayHandle<ArrayHandle<String>>;
    @:optional var afterBuildCommands(default,null):ArrayHandle<ArrayHandle<String>>;
    /** if this target is built in debug mode by default (tests mostly) **/
    @:optional var impliesDebug(default,null):Bool;
    @:optional var isBuildCommand(default,null):Bool;
    @:optional var isTestCommand(default,null):Bool;
}

abstract ArrayHandle<T>(Array<T>) from Array<T> {
    public function get() {
        return if (this == null) [] else this.copy();
    }

    public function iterator()
        return this.iterator();
}
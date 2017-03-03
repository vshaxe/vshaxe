package;

typedef Haxelib = {
    var name(default,null):String;
    var installArgs(default,null):ArrayHandle<String>;
}

@:publicFields
class Haxelibs {
    static var HxNodeJS(default,null):Haxelib = {
        name: "hxnodejs",
        installArgs: ["git", "hxnodejs", "https://github.com/HaxeFoundation/hxnodejs"]
    };

    static var HxArgs(default,null):Haxelib = {
        name: "hxargs",
        installArgs: ["install", "hxargs"]
    };

    static var HaxeHxparser(default,null):Haxelib = {
        name: "haxe-hxparser",
        installArgs: ["git", "haxe-hxparser", "https://github.com/vshaxe/haxe-hxparser"]
    };

    static var CompileTime(default,null):Haxelib = {
        name: "compiletime",
        installArgs: ["install", "compiletime"]
    };

    static var Mockatoo(default,null):Haxelib = {
        name: "mockatoo",
        installArgs: ["git", "mockatoo", "https://github.com/grosmar/mockatoo", "master", "src"]
    };

    static var MConsole(default,null):Haxelib = {
        name: "mconsole",
        installArgs: ["install", "mconsole"]
    };

    static var JStack(default,null):Haxelib = {
        name: "jstack",
        installArgs: ["install", "jstack"]
    };

    static var Yaml(default,null):Haxelib = {
        name: "yaml",
        installArgs: ["install", "yaml"]
    };

    static var Plist(default,null):Haxelib = {
        name: "plist",
        installArgs: ["git", "plist", "https://github.com/back2dos/plist"]
    };
}
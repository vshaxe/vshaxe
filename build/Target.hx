package;

import Haxelibs;

@:enum abstract Target(String) to String {
    static var configs:Map<String, TargetArguments> = [
        All => {
            targetDependencies: [
                Client,
                LanguageServer,
                LanguageServerTests,
                TmLanguage,
                Formatter,
            ]
        },
        Client => {
            args: [
                "-cp", "vscode-extern/src",
                "-cp", "src",
                "-D", "hxnodejs-no-version-warning",
                "-dce", "full",
                "-D", "analyzer-optimize",
                "-js", "bin/client.js",
                "vshaxe.Main"
            ],
            debugArgs: [
                "-D", "JSTACK_MAIN=vshaxe.Main.main"
            ]
        },
        LanguageServer => {
            haxelibs: [Haxelibs.HaxeHxparser],
            cwd: "server",
            args: [
                "-cp", "src",
                "-cp", "protocol/src",
                "-cp", "formatter/src",
                "-main", "haxeLanguageServer.Main",
                "-js", "../bin/server.js",
                "-dce", "full",
                "-D", "hxnodejs-no-version-warning"
            ],
            debugArgs: [
                "--no-inline"
            ]
        },
        LanguageServerTests => {
            haxelibs: [Haxelibs.HaxeHxparser, Haxelibs.CompileTime, Haxelibs.Mockatoo, Haxelibs.MConsole],
            cwd: "server",
            args: [
                "-cp", "src",
                "-cp", "test",
                "-cp", "protocol/src",
                "-cp", "formatter/src",
                "-main", "TestMain",
                "-js", "../bin/test.js",
                "-dce", "full",
                "-D", "hxnodejs-no-version-warning"
            ],
            debugArgs: [
                "--no-inline"
            ],
            afterBuildCommands: [
                ["node", "../bin/test.js"]
            ],
            impliesDebug: true
        },
        TmLanguage => {
            targetDependencies: [
                TmLanguageConversion,
                TmLanguageTests
            ]
        },
        TmLanguageConversion => {
            haxelibs: [Haxelibs.Yaml, Haxelibs.Plist],
            cwd: "syntaxes",
            args: [
                "-cp", "src",
                "-main", "Converter",
                "-neko", "bin/convert.n"
            ],
            afterBuildCommands: [
                ["neko", "bin/convert.n"]
            ],
            impliesDebug: true
        },
        TmLanguageBuildTests => {
            cwd: "syntaxes",
            beforeBuildCommands: [
                ["npm", "install", "vscode-textmate"]
            ],
            args: [
                "-cp", "src",
                "-main", "Build",
                "-js", "bin/build.js"
            ],
            afterBuildCommands: [
                ["node", "bin/build.js"]
            ],
            impliesDebug: true
        },
        TmLanguageTests => {
            targetDependencies: [
                TmLanguageBuildTests
            ],
            cwd: "syntaxes",
            args: [
                "-cp", "src",
                "-main", "Test",
                "-js", "bin/test.js"
            ],
            afterBuildCommands: [
                ["node", "bin/test.js"]
            ],
            impliesDebug: true
        },
        Formatter => {
            targetDependencies: [
                FormatterCLI,
                FormatterTests
            ]
        },
        FormatterCLI => {
            haxelibs: [Haxelibs.HaxeHxparser, Haxelibs.HxArgs],
            cwd: "server/formatter",
            args: [
                "-cp", "src",
                "-main", "haxeFormatter.Cli",
                "-js", "bin/cli.js"
            ],
            debugArgs: []
        },
        FormatterTests => {
            haxelibs: [Haxelibs.HaxeHxparser],
            cwd: "server/formatter",
            args: [
                "-cp", "src",
                "-cp", "test",
                "-main", "haxeFormatter.TestMain",
                "-js", "bin/test.js"
            ],
            afterBuildCommands: [
                ["node", "bin/test.js"]
            ],
            impliesDebug: true
        }
    ];

    public static var list(get, never):Array<Target>;

    public static function get_list():Array<Target> {
        return [for (name in configs.keys()) new Target(name)];
    }

    var All = "all";
    var Client = "client";
    var LanguageServer = "language-server";
    var LanguageServerTests = "language-server-tests";
    var TmLanguage = "tm-language";
    var TmLanguageConversion = "tm-language-conversion";
    var TmLanguageBuildTests = "tm-language-build-tests";
    var TmLanguageTests = "tm-language-tests";
    var Formatter = "formatter";
    var FormatterCLI = "formatter-cli";
    var FormatterTests = "formatter-tests";

    inline public function new(name)
        this = name;

    inline public function getConfig()
        return configs[this];
}

typedef TargetArguments = {
    @:optional var args(default,null):Array<String>;
    @:optional var targetDependencies(default,null):Array<Target>;
    @:optional var haxelibs(default,null):Array<Haxelib>;
    @:optional var cwd:String;
    /** -debug and -D js_unflatten are implied **/
    @:optional var debugArgs(default,null):Array<String>;
    @:optional var beforeBuildCommands(default,null):Array<Array<String>>;
    @:optional var afterBuildCommands(default,null):Array<Array<String>>;
    /** if this target is built in debug mode by default (tests mostly) **/
    @:optional var impliesDebug(default,null):Bool;
}

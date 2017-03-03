package;

import Haxelibs;
import Haxelibs.*;

@:enum abstract Target(String) to String {
    static var configs:Map<String, TargetArguments> = [
        All => {
            targetDependencies: [
                Test,
                TmLanguage
            ]
        },
        Test => {
            targetDependencies: [
                VsHaxe,
                LanguageServerTests,
                Formatter
            ],
            impliesDebug: true,
            isTestCommand: true
        },
        VsHaxe => {
            targetDependencies: [
                Client,
                LanguageServer
            ],
            isBuildCommand: true
        },
        Client => {
            installCommands: [
                ["npm", "install"]
            ],
            classPaths: [
                "vscode-extern/src",
                "src"
            ],
            defines: [
                "hxnodejs-no-version-warning",
                "analyzer-optimize"
            ],
            args: [
                "-dce", "full",
                "-js", "bin/client.js",
                "vshaxe.Main"
            ],
            debugArgs: [
                "-D", "JSTACK_MAIN=vshaxe.Main.main"
            ]
        },
        LanguageServer => {
            haxelibs: [HaxeHxparser],
            cwd: "server",
            classPaths: [
                "src",
                "protocol/src",
                "formatter/src",
            ],
            defines: [
                "hxnodejs-no-version-warning"
            ],
            args: [
                "-main", "haxeLanguageServer.Main",
                "-js", "../bin/server.js",
                "-dce", "full",
            ],
            debugArgs: [
                "--no-inline"
            ]
        },
        LanguageServerTests => {
            haxelibs: [HaxeHxparser, CompileTime, Mockatoo, MConsole],
            cwd: "server",
            classPaths: [
                "src",
                "test",
                "protocol/src",
                "formatter/src",
            ],
            defines: [
                "hxnodejs-no-version-warning"
            ],
            args: [
                "-main", "TestMain",
                "-js", "../bin/test.js",
                "-dce", "full",
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
            haxelibs: [Yaml, Plist],
            cwd: "syntaxes",
            classPaths: [
                "src"
            ],
            args: [
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
            installCommands: [
                ["npm", "install", "vscode-textmate"]
            ],
            classPaths: [
                "src"
            ],
            args: [
                "-main", "Build",
                "-js", "bin/build.js"
            ],
            afterBuildCommands: [
                ["node", "bin/build.js"]
            ],
            impliesDebug: true
        },
        TmLanguageTests => {
            cwd: "syntaxes",
            targetDependencies: [
                TmLanguageBuildTests
            ],
            classPaths: [
                "src"
            ],
            args: [
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
            haxelibs: [HaxeHxparser, HxArgs],
            cwd: "server/formatter",
            classPaths: [
                "src"
            ],
            args: [
                "-main", "haxeFormatter.Cli",
                "-js", "bin/cli.js"
            ],
            debugArgs: []
        },
        FormatterTests => {
            haxelibs: [HaxeHxparser],
            cwd: "server/formatter",
            classPaths: [
                "src",
                "test"
            ],
            args: [
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

    public static function get_list():Array<Target>
        return [for (name in configs.keys()) new Target(name)];

    var All = "all";
    var Test = "test";
    var VsHaxe = "vshaxe";
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

    inline public function getConfig():TargetArguments
        return configs[this];
}

typedef TargetArguments = {
    @:optional var classPaths(default,null):Array<String>;
    @:optional var defines(default,null):Array<String>;
    @:optional var args(default,null):Array<String>;
    @:optional var targetDependencies(default,null):Array<Target>;
    @:optional var haxelibs(default,null):Array<Haxelib>;
    /** additional, non-haxelib install commands (npm install...) **/
    @:optional var installCommands(default,null):Array<Array<String>>;
    @:optional var cwd:String;
    /** -debug, -D js_unflatten and -lib jstack are implied **/
    @:optional var debugArgs(default,null):Array<String>;
    @:optional var beforeBuildCommands(default,null):Array<Array<String>>;
    @:optional var afterBuildCommands(default,null):Array<Array<String>>;
    /** if this target is built in debug mode by default (tests mostly) **/
    @:optional var impliesDebug(default,null):Bool;
    @:optional var isBuildCommand(default,null):Bool;
    @:optional var isTestCommand(default,null):Bool;
}

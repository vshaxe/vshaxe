package vshaxe.helper;

import haxe.io.Path;
import haxe.extern.EitherType;
import sys.FileSystem;
import vshaxe.HaxeExecutableConfiguration;
import vshaxe.helper.PathHelper;

/** unprocessed config **/
private typedef RawHaxeExecutableConfig = {
    var path:String;
    var env:haxe.DynamicAccess<String>;
}

private typedef HaxeExecutablePathOrConfigBase = EitherType<String,RawHaxeExecutableConfig>;

typedef HaxeExecutablePathOrConfig = EitherType<
    String,
    {
        >RawHaxeExecutableConfig,
        @:optional var windows:RawHaxeExecutableConfig;
        @:optional var linux:RawHaxeExecutableConfig;
        @:optional var osx:RawHaxeExecutableConfig;
    }
>;

class HaxeExecutable {
    public static var SYSTEM_KEY(default,never) = switch (Sys.systemName()) {
        case "Windows": "windows";
        case "Mac": "osx";
        default: "linux";
    };

    public var configuration(default,null):HaxeExecutableConfiguration;

    public var onDidChangeConfiguration(get,never):Event<HaxeExecutableConfiguration>;
    var _onDidChangeConfiguration:EventEmitter<HaxeExecutableConfiguration>;
    function get_onDidChangeConfiguration() return _onDidChangeConfiguration.event;

    var rawConfig:RawHaxeExecutableConfig;

    public function new(context:ExtensionContext) {
        updateConfig(getExecutableSettings());
        _onDidChangeConfiguration = new EventEmitter();
        context.subscriptions.push(workspace.onDidChangeConfiguration(_ -> refresh()));
    }

    /** Returns true if haxe.executable setting was configured by user **/
    public function isConfigured() {
        var executableSetting = workspace.getConfiguration("haxe").inspect("executable");
        return executableSetting.workspaceValue != null || executableSetting.globalValue != null;
    }

    static inline function getExecutableSettings() return workspace.getConfiguration("haxe").get("executable");

    function refresh() {
        var oldConfig = rawConfig;
        updateConfig(getExecutableSettings());
        if (!isSame(oldConfig, rawConfig))
            _onDidChangeConfiguration.fire(configuration);
    }

    static function isSame(oldConfig:RawHaxeExecutableConfig, newConfig:RawHaxeExecutableConfig):Bool {
        // ouch...
        if (oldConfig.path != newConfig.path)
            return false;

        var oldKeys = oldConfig.env.keys();
        var newKeys = newConfig.env.keys();
        if (oldKeys.length != newKeys.length)
            return false;

        for (key in newKeys) {
            var oldValue = oldConfig.env[key];
            var newValue = newConfig.env[key];
            if (oldValue != newValue)
                return false;
            oldKeys.remove(key);
        }

        if (oldKeys.length > 0)
            return false;

        return true;
    }

    function updateConfig(input:Null<HaxeExecutablePathOrConfig>) {
        var executable = "haxe";
        var env:haxe.DynamicAccess<String> = {};

        function merge(conf:HaxeExecutablePathOrConfigBase) {
            if ((conf is String)) {
                executable = conf;
            } else {
                var conf:RawHaxeExecutableConfig = conf;
                if (conf.path != null)
                    executable = conf.path;
                if (conf.env != null)
                    env = conf.env;
            }
        }

        if (input != null) {
            merge(input);
            var systemConfig = Reflect.field(input, SYSTEM_KEY);
            if (systemConfig != null)
                merge(systemConfig);
        }

        var isCommand = false;
        if (!Path.isAbsolute(executable)) {
            var absolutePath = PathHelper.absolutize(executable, workspace.rootPath);
            if (FileSystem.exists(absolutePath) && !FileSystem.isDirectory(absolutePath)) {
                executable = absolutePath;
            } else {
                isCommand = true;
            }
        }

        rawConfig = input;
        configuration = {
            executable: executable,
            isCommand: isCommand,
            env: env
        }
    }
}

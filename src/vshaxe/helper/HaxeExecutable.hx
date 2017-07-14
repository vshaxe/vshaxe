package vshaxe.helper;

import haxe.extern.EitherType;
import vshaxe.HaxeExecutableConfiguration;

/** same as vshaxe.HaxeExecutableConfiguration, but not read-only **/
private typedef WritableHaxeExecutableConfiguration = {
    var path:String;
    var env:haxe.DynamicAccess<String>;
}

private typedef HaxeExecutablePathOrConfigBase = EitherType<String,HaxeExecutableConfiguration>;

typedef HaxeExecutablePathOrConfig = EitherType<
    String,
    {
        >HaxeExecutableConfiguration,
        @:optional var windows:HaxeExecutableConfiguration;
        @:optional var linux:HaxeExecutableConfiguration;
        @:optional var osx:HaxeExecutableConfiguration;
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
        var oldConfig = configuration;
        updateConfig(getExecutableSettings());
        if (!isSame(oldConfig, configuration))
            _onDidChangeConfiguration.fire(configuration);
    }

    static function isSame(oldConfig:HaxeExecutableConfiguration, newConfig:HaxeExecutableConfiguration):Bool {
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
        var newConfig:WritableHaxeExecutableConfiguration = {
            path: "haxe",
            env: {},
        };

        function merge(conf:HaxeExecutablePathOrConfigBase) {
            if ((conf is String)) {
                newConfig.path = conf;
            } else {
                var conf:HaxeExecutableConfiguration = conf;
                if (conf.path != null)
                    newConfig.path = conf.path;
                if (conf.env != null)
                    newConfig.env = conf.env;
            }
        }

        if (input != null) {
            merge(input);
            var systemConfig = Reflect.field(input, SYSTEM_KEY);
            if (systemConfig != null)
                merge(systemConfig);
        }

        configuration = newConfig;
    }
}

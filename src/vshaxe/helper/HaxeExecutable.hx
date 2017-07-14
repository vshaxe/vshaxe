package vshaxe.helper;

import haxe.extern.EitherType;

typedef HaxeExecutableConfigBase = {
    var path:String;
    var env:haxe.DynamicAccess<String>;
}

private typedef HaxeExecutablePathOrConfigBase = EitherType<String,HaxeExecutableConfigBase>;

typedef HaxeExecutablePathOrConfig = EitherType<
    String,
    {
        >HaxeExecutableConfigBase,
        @:optional var windows:HaxeExecutablePathOrConfigBase;
        @:optional var linux:HaxeExecutablePathOrConfigBase;
        @:optional var osx:HaxeExecutablePathOrConfigBase;
    }
>;

class HaxeExecutable {
    public static var SYSTEM_KEY(default,never) = switch (Sys.systemName()) {
        case "Windows": "windows";
        case "Mac": "osx";
        default: "linux";
    };

    public var config(default,null):HaxeExecutableConfigBase;

    public var onDidChangeConfig(get,never):Event<HaxeExecutableConfigBase>;
    var _onDidChangeConfig:EventEmitter<HaxeExecutableConfigBase>;
    inline function get_onDidChangeConfig() return _onDidChangeConfig.event;

    public function new(context:ExtensionContext) {
        updateConfig(getExecutableSettings());
        _onDidChangeConfig = new EventEmitter();
        context.subscriptions.push(workspace.onDidChangeConfiguration(_ -> refresh()));
    }

    /** Returns true if haxe.executable setting was configured by user **/
    public function isConfigured() {
        var executableSetting = workspace.getConfiguration("haxe").inspect("executable");
        return executableSetting.workspaceValue != null || executableSetting.globalValue != null;
    }

    static inline function getExecutableSettings() return workspace.getConfiguration("haxe").get("executable");

    function refresh() {
        var oldConfig = config;
        updateConfig(getExecutableSettings());
        if (!isSame(oldConfig, config))
            _onDidChangeConfig.fire(config);
    }

    static function isSame(oldConfig:HaxeExecutableConfigBase, newConfig:HaxeExecutableConfigBase):Bool {
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
        config = {
            path: "haxe",
            env: {},
        };

        function merge(conf:HaxeExecutablePathOrConfigBase) {
            if ((conf is String)) {
                config.path = conf;
            } else {
                var conf:HaxeExecutableConfigBase = conf;
                if (conf.path != null)
                    config.path = conf.path;
                if (conf.env != null)
                    config.env = conf.env;
            }
        }

        if (input != null) {
            merge(input);
            var systemConfig = Reflect.field(input, SYSTEM_KEY);
            if (systemConfig != null)
                merge(systemConfig);
        }
    }
}

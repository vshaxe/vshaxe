package vshaxe.helper;

import vscode.ExtensionContext;
import vshaxe.helper.HaxeExecutable;

class HaxeExecutableHelper {
    var executable:HaxeExecutable;

    public var config(get,never):HaxeExecutableConfigBase;
    var _onDidChangeConfig:EventEmitter<HaxeExecutableConfigBase>;
    inline function get_config() return executable.config;

    public var onDidChangeConfig(get,never):Event<HaxeExecutableConfigBase>;
    inline function get_onDidChangeConfig() return _onDidChangeConfig.event;

    public function new(context:ExtensionContext) {
        executable = new HaxeExecutable(getExecutableSettings());
        _onDidChangeConfig = new EventEmitter();
        context.subscriptions.push(workspace.onDidChangeConfiguration(_ -> refresh()));
    }

    static inline function getExecutableSettings() return workspace.getConfiguration("haxe").get("executable");

    function refresh() {
        var oldConfig = config;
        executable.updateConfig(getExecutableSettings());
        if (isSame(oldConfig, config))
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
}

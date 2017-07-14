package vshaxe;

@:enum abstract HaxeMemento(String) to String {
    var DisplayArgumentsProviderName = memento("displayArgumentsProviderName");
    var DisplayConfigurationIndex = memento("displayConfigurationIndex");
    var HxmlDiscoveryFiles = memento("hxmlDiscoveryFiles");

    inline static function memento(name:String):String {
        return "haxe." + name;
    }
}
package vshaxe;

@:enum abstract HaxeCommand(String) to String {
    /* public commands, defined in `package.json` */
    var RestartLanguageServer = command("restartLanguageServer");
    var InitProject = command("initProject");
    var SelectDisplayArgumentsProvider = command("selectDisplayArgumentsProvider");
    var SelectDisplayConfiguration = command("selectDisplayConfiguration");
    var RunGlobalDiagnostics = command("runGlobalDiagnostics");
    var ToggleCodeLens = command("toggleCodeLens");
    var Dependencies_Refresh = command("dependencies.refresh");
    var Dependencies_CollapseAll = command("dependencies.collapseAll");

    /* internal commands, _not_ defined in `package.json` */
    var ApplyFixes = command("applyFixes");
    var ShowReferences = command("showReferences");
    var Dependencies_SelectNode = command("dependencies.selectNode");

    inline static function command(name:String):String {
        return "haxe." + name;
    }
}
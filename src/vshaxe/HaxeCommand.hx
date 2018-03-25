package vshaxe;

@:enum abstract HaxeCommand(String) to String {
    /* public commands, defined in `package.json` */
    var RestartLanguageServer = command("restartLanguageServer");
    var InitProject = command("initProject");
    var SelectDisplayArgumentsProvider = command("selectDisplayArgumentsProvider");
    var SelectDisplayConfiguration = command("selectDisplayConfiguration");
    var RunGlobalDiagnostics = command("runGlobalDiagnostics");
    var ToggleCodeLens = command("toggleCodeLens");
    var CollapseDependencies = command("collapseDependencies");
    var RefreshDependencies = command("refreshDependencies");


    /* internal commands, either not defined in `package.json` at all or hidden from command palette */
    var ApplyFixes = command("applyFixes");
    var ShowReferences = command("showReferences");
    var Dependencies_SelectNode = command("dependencies.selectNode");
    var Dependencies_Refresh = command("dependencies.refresh");
    var Dependencies_CollapseAll = command("dependencies.collapseAll");
    var Dependencies_RevealInExplorer = command("dependencies.revealInExplorer");
    var ClearMementos = command("clearMementos");

    inline static function command(name:String):String {
        return "haxe." + name;
    }
}
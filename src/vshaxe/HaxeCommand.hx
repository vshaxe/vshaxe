package vshaxe;

// should this be a build macro?
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
    var ClearMementos = command("clearMementos");
    var Methods_CollapseAll = command("methods.collapseAll");
    var Dependencies_SelectNode = command("dependencies.selectNode");
    var Dependencies_Refresh = command("dependencies.refresh");
    var Dependencies_CollapseAll = command("dependencies.collapseAll");
    var Dependencies_OpenPreview = command("dependencies.openPreview");
    var Dependencies_OpenToTheSide = command("dependencies.openToTheSide");
    var Dependencies_RevealInExplorer = command("dependencies.revealInExplorer");
    var Dependencies_OpenInCommandPrompt = command("dependencies.openInCommandPrompt");
    var Dependencies_CopyPath = command("dependencies.copyPath");

    inline static function command(name:String):String {
        return "haxe." + name;
    }
}

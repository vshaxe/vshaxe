package vshaxe;

// should this be a build macro?
enum abstract HaxeCommand(String) to String {
	/* public commands, defined in `package.json` */
	final RestartLanguageServer = command("restartLanguageServer");
	final InitProject = command("initProject");
	final SelectDisplayArgumentsProvider = command("selectDisplayArgumentsProvider");
	final SelectConfiguration = command("selectConfiguration");
	final DebugSelectedConfiguration = command("debugSelectedConfiguration");
	final RunGlobalDiagnostics = command("runGlobalDiagnostics");
	final ToggleCodeLens = command("toggleCodeLens");
	final RefreshDependencies = command("refreshDependencies");
	final RevealActiveFileInSideBar = command("revealActiveFileInSideBar");
	/* internal commands, either not defined in `package.json` at all or hidden from command palette */
	final ShowReferences = command("showReferences");
	final ClearMementos = command("clearMementos");
	final Methods_SwitchToQueue = command("methods.switchToQueue");
	final Methods_SwitchToTimers = command("methods.switchToTimers");
	final Methods_Copy = command("methods.copy");
	final Methods_Track = command("methods.track");
	final Dependencies_OpenTextDocument = command("dependencies.openTextDocument");
	final Dependencies_Refresh = command("dependencies.refresh");
	final Dependencies_OpenPreview = command("dependencies.openPreview");
	final Dependencies_OpenToTheSide = command("dependencies.openToTheSide");
	final Dependencies_RevealInExplorer = command("dependencies.revealInExplorer");
	final Dependencies_OpenInCommandPrompt = command("dependencies.openInCommandPrompt");
	final Dependencies_FindInFolder = command("dependencies.findInFolder");
	final Dependencies_CopyPath = command("dependencies.copyPath");
	final Cache_CopyNodeValue = command("cache.copyNodeValue");
	final Cache_ReloadNode = command("cache.reloadNode");
	final Cache_GotoNode = command("cache.gotoNode");
	inline static function command(name:String):String {
		return "haxe." + name;
	}
}

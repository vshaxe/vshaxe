package vshaxe;

import vscode.Event;

/**
	Contains the configuration for the Haxelib executable.
	@since 2.23.0
**/
typedef HaxelibExecutable = {
	/**
		Object containing the Haxelib executable configuration.
	**/
	var configuration(default, never):HaxelibExecutableConfiguration;

	/**
		Event that is fired when `configuration` changes.
	**/
	var onDidChangeConfiguration(get, never):Event<HaxelibExecutableConfiguration>;
}

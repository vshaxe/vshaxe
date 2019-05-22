package vshaxe;

import vscode.Event;

/**
	Contains the configuration for the Haxe executable.
**/
typedef HaxeExecutable = {
	/**
		Object containing the Haxe executable configuration.
	**/
	var configuration(default, never):HaxeExecutableConfiguration;

	/**
		Event that is fired when `configuration` changes.
	**/
	var onDidChangeConfiguration(get, never):Event<HaxeExecutableConfiguration>;
}

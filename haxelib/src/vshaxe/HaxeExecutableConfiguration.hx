package vshaxe;

/**
	Configuration for the Haxe executable.
**/
typedef HaxeExecutableConfiguration = {
	/**
		Absolute path to the Haxe executable, or a command / alias like `"haxe"`.
		Use `isCommand` to check.
	**/
	var executable(default, never):String;

	/**
		Whether `executable` is a command (`true`) or an absolute path (`false`).
	**/
	var isCommand(default, never):Bool;

	/**
		Additional environment variables used for running Haxe executable.
	**/
	var env(default, never):haxe.DynamicAccess<String>;
}

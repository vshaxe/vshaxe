package vshaxe;

/**
	Configuration for the Haxelib executable.
	@since 2.23.0
**/
typedef HaxelibExecutableConfiguration = {
	/**
		Absolute path to the Haxelib executable, or a command / alias like `"haxelib"`.
		Use `isCommand` to check.
	**/
	var executable(default, never):String;

	/**
		How `executable` was determined.
	**/
	var source(default, never):HaxelibExecutableSource;

	/**
		Whether `executable` is a command (`true`) or an absolute path (`false`).
	**/
	var isCommand(default, never):Bool;
}

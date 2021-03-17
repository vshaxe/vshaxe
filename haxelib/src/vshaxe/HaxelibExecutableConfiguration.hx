package vshaxe;

/**
	Configuration for the Haxelib executable.
	@since 2.23.0
**/
typedef HaxelibExecutableConfiguration = {
	/**
		Absolute path to the Haxelib executable, or a command / alias like `"haxelib"`.
	**/
	var executable(default, never):String;
}

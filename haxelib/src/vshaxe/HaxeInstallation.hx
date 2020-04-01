package vshaxe;

typedef HaxeInstallation = {
	/**
		The Haxe executable to be used for resolving `"haxe.executable": "auto"`.
	**/
	var ?haxeExecutable(default, never):String;

	/**
		The Haxelib executable to be used for resolving `"haxelib.executable": "auto"`.
	**/
	var ?haxelibExecutable(default, never):String;

	/**
		Path to the Haxe standard library.
	**/
	var ?standardLibraryPath(default, never):String;
}
